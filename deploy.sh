#!/bin/bash

# Hugo博客部署脚本
# 作者：你的名字
# 功能：构建Hugo网站并部署到服务器

set -e  # 遇到错误时立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置文件路径
CONFIG_FILE="deploy.config"

# 默认配置 - 可在deploy.config文件中覆盖
SERVER_USER="your_username"           # 服务器用户名
SERVER_HOST="your_server_ip"          # 服务器IP或域名
SERVER_PATH="/var/www/html/"          # 服务器网站目录路径
SSH_PORT="22"                         # SSH端口，默认22

# Hugo配置
HUGO_ENV="production"
PUBLIC_DIR="public"

# 函数：打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] ${message}${NC}"
}

# 函数：检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_message $RED "错误：命令 '$1' 未找到，请先安装"
        exit 1
    fi
}

# 函数：显示帮助信息
show_help() {
    echo "Hugo博客部署脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help          显示此帮助信息"
    echo "  -b, --build-only    仅构建，不部署"
    echo "  -d, --deploy-only   仅部署，不构建"
    echo "  -c, --clean         清理构建目录"
    echo "  -t, --test          测试模式（构建但不上传）"
    echo ""
    echo "示例:"
    echo "  $0                  完整部署（构建+上传）"
    echo "  $0 -b               仅构建网站"
    echo "  $0 -d               仅部署已构建的网站"
    echo "  $0 -t               测试构建"
}

# 函数：清理构建目录
clean_build() {
    print_message $YELLOW "清理构建目录..."
    if [ -d "$PUBLIC_DIR" ]; then
        rm -rf "$PUBLIC_DIR"
        print_message $GREEN "构建目录已清理"
    else
        print_message $BLUE "构建目录不存在，跳过清理"
    fi
}

# 函数：构建网站
build_site() {
    print_message $YELLOW "开始构建Hugo网站..."
    
    # 检查Hugo是否已安装
    check_command "hugo"
    
    # 设置环境变量，确保正确的字符编码
    export HUGO_ENV="$HUGO_ENV"
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
    
    print_message $BLUE "设置UTF-8编码环境，确保中文文件名正确处理"
    
    # 构建网站
    hugo --gc --minify
    
    if [ $? -eq 0 ]; then
        print_message $GREEN "网站构建成功！"
        
        # 显示构建统计
        if [ -d "$PUBLIC_DIR" ]; then
            file_count=$(find $PUBLIC_DIR -type f | wc -l)
            dir_size=$(du -sh $PUBLIC_DIR | cut -f1)
            print_message $BLUE "构建统计: $file_count 个文件，总大小: $dir_size"
        fi
    else
        print_message $RED "网站构建失败！"
        exit 1
    fi
}

# 函数：检查服务器连接
test_connection() {
    print_message $YELLOW "测试服务器连接..."
    
    if ssh -p $SSH_PORT -o ConnectTimeout=5 -o BatchMode=yes $SERVER_USER@$SERVER_HOST 'exit' 2>/dev/null; then
        print_message $GREEN "服务器连接测试成功"
        return 0
    else
        print_message $RED "无法连接到服务器 $SERVER_USER@$SERVER_HOST:$SSH_PORT"
        print_message $YELLOW "请检查："
        print_message $YELLOW "1. 服务器地址和端口是否正确"
        print_message $YELLOW "2. SSH密钥是否已配置"
        print_message $YELLOW "3. 网络连接是否正常"
        return 1
    fi
}

# 函数：检查服务器环境
check_server_environment() {
    print_message $YELLOW "检查服务器环境..."
    
    # 检查rsync是否已安装
    if ssh -p $SSH_PORT $SERVER_USER@$SERVER_HOST 'command -v rsync' >/dev/null 2>&1; then
        print_message $GREEN "服务器rsync检查通过"
        return 0
    else
        print_message $YELLOW "服务器未安装rsync，尝试安装..."
        
        # 尝试自动安装rsync
        if ssh -p $SSH_PORT $SERVER_USER@$SERVER_HOST 'command -v apt-get' >/dev/null 2>&1; then
            # Ubuntu/Debian系统
            print_message $BLUE "检测到Ubuntu/Debian系统，安装rsync..."
            ssh -p $SSH_PORT $SERVER_USER@$SERVER_HOST 'sudo apt-get update && sudo apt-get install -y rsync' 2>/dev/null
        elif ssh -p $SSH_PORT $SERVER_USER@$SERVER_HOST 'command -v yum' >/dev/null 2>&1; then
            # CentOS/RHEL系统
            print_message $BLUE "检测到CentOS/RHEL系统，安装rsync..."
            ssh -p $SSH_PORT $SERVER_USER@$SERVER_HOST 'sudo yum install -y rsync' 2>/dev/null
        elif ssh -p $SSH_PORT $SERVER_USER@$SERVER_HOST 'command -v dnf' >/dev/null 2>&1; then
            # Fedora系统
            print_message $BLUE "检测到Fedora系统，安装rsync..."
            ssh -p $SSH_PORT $SERVER_USER@$SERVER_HOST 'sudo dnf install -y rsync' 2>/dev/null
        else
            print_message $YELLOW "无法自动安装rsync，将使用备用部署方案"
            return 1
        fi
        
        # 再次检查rsync是否安装成功
        if ssh -p $SSH_PORT $SERVER_USER@$SERVER_HOST 'command -v rsync' >/dev/null 2>&1; then
            print_message $GREEN "rsync安装成功"
            return 0
        else
            print_message $YELLOW "rsync安装失败，将使用备用部署方案"
            return 1
        fi
    fi
}

# 函数：检查rsync版本和功能支持
check_rsync_features() {
    local rsync_version=$(rsync --version 2>/dev/null | head -1)
    
    # 检查是否支持--iconv选项（rsync 3.0+）
    if rsync --help 2>/dev/null | grep -q -- "--iconv"; then
        return 0  # 支持iconv
    else
        return 1  # 不支持iconv
    fi
}

# 函数：验证部署后的文件名编码
verify_deployment() {
    # 静默检查服务器上的中文文件名编码
    local result=$(ssh -p $SSH_PORT $SERVER_USER@$SERVER_HOST "
        export LC_ALL=C.UTF-8 LANG=C.UTF-8
        
        if [ -d '$SERVER_PATH/tags' ]; then
            if ls '$SERVER_PATH/tags' 2>/dev/null | grep -q '\\\\#'; then
                echo 'ENCODING_ERROR'
            else
                echo 'ENCODING_OK'
            fi
        else
            echo 'NO_TAGS_DIR'
        fi
    " 2>/dev/null)
    
    case "$result" in
        "ENCODING_OK")
            return 0
            ;;
        "ENCODING_ERROR")
            return 1
            ;;
        "NO_TAGS_DIR")
            return 2
            ;;
        *)
            return 1
            ;;
    esac
}

# 函数：使用rsync部署
deploy_with_rsync() {
    print_message $YELLOW "使用rsync同步文件到服务器..."
    
    # 设置字符编码环境变量，解决中文文件名乱码问题
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
    
    # 构建rsync命令
    RSYNC_CMD="rsync -avz --delete"
    
    # 检查rsync版本和功能支持
    if check_rsync_features; then
        # 新版本rsync，支持--iconv选项
        RSYNC_CMD="$RSYNC_CMD --iconv=UTF-8,UTF-8"
        print_message $BLUE "使用rsync新版本编码转换"
    else
        # 旧版本rsync，使用其他方法处理编码
        print_message $BLUE "使用rsync兼容模式"
        # 在SSH连接中设置远程环境
        export RSYNC_RSH="ssh -p $SSH_PORT -o 'SetEnv LC_ALL=C.UTF-8'"
    fi
    
    # 如果存在排除文件，则使用它
    if [ -f ".rsyncignore" ]; then
        RSYNC_CMD="$RSYNC_CMD --exclude-from=.rsyncignore"
    else
        # 使用默认排除规则
        RSYNC_CMD="$RSYNC_CMD --exclude '.DS_Store' --exclude 'Thumbs.db'"
    fi
    
    # 添加SSH配置（如果没有设置RSYNC_RSH）
    if [ -z "$RSYNC_RSH" ]; then
        RSYNC_CMD="$RSYNC_CMD -e 'ssh -p $SSH_PORT'"
    fi
    
    # 执行同步
    eval "$RSYNC_CMD $PUBLIC_DIR/ $SERVER_USER@$SERVER_HOST:$SERVER_PATH"
    
    local result=$?
    
    # 清理环境变量
    unset RSYNC_RSH
    
    return $result
}

# 函数：使用scp备用部署方案
deploy_with_scp() {
    print_message $YELLOW "使用备用方案(scp+tar)部署文件..."
    
    # 设置字符编码环境变量，解决中文文件名乱码问题
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
    
    # 创建临时压缩包
    TEMP_FILE="website_$(date +%Y%m%d_%H%M%S).tar.gz"
    print_message $BLUE "创建临时压缩包: $TEMP_FILE"
    
    # 压缩网站文件，保持UTF-8编码
    # 设置tar的locale确保正确处理文件名，抑制Apple扩展属性警告
    LC_ALL=C.UTF-8 tar -czf "$TEMP_FILE" -C "$PUBLIC_DIR" . 2>/dev/null
    
    if [ $? -ne 0 ]; then
        print_message $RED "创建压缩包失败"
        return 1
    fi
    
    # 上传压缩包
    print_message $BLUE "上传压缩包到服务器..."
    # 确保scp也使用正确的编码，静默上传
    LC_ALL=C.UTF-8 scp -q -P $SSH_PORT "$TEMP_FILE" $SERVER_USER@$SERVER_HOST:/tmp/
    
    if [ $? -ne 0 ]; then
        print_message $RED "上传文件失败"
        rm -f "$TEMP_FILE"
        return 1
    fi
    
    # 在服务器上解压并部署
    print_message $BLUE "在服务器上解压和部署..."
    ssh -p $SSH_PORT $SERVER_USER@$SERVER_HOST "
        # 设置服务器端UTF-8编码环境
        export LC_ALL=C.UTF-8
        export LANG=C.UTF-8
        
        # 备份现有文件（如果存在）
        if [ -d '$SERVER_PATH' ] && [ \"\$(ls -A '$SERVER_PATH' 2>/dev/null)\" ]; then
            tar -czf /tmp/backup_\$(date +%Y%m%d_%H%M%S).tar.gz -C '$SERVER_PATH' . 2>/dev/null || true
        fi
        
        # 清理目标目录
        rm -rf '$SERVER_PATH'/*
        
        # 解压新文件，保持UTF-8编码
        cd '$SERVER_PATH' && LC_ALL=C.UTF-8 tar -xzf /tmp/$TEMP_FILE 2>/dev/null
        
        # 清理临时文件
        rm -f /tmp/$TEMP_FILE
    "
    
    local result=$?
    
    # 清理本地临时文件
    rm -f "$TEMP_FILE"
    
    return $result
}

# 函数：部署到服务器
deploy_site() {
    print_message $YELLOW "开始部署到服务器..."
    
    # 检查public目录是否存在
    if [ ! -d "$PUBLIC_DIR" ]; then
        print_message $RED "错误：$PUBLIC_DIR 目录不存在，请先构建网站"
        exit 1
    fi
    
    # 测试服务器连接
    if ! test_connection; then
        exit 1
    fi
    
    # 检查服务器环境
    USE_RSYNC=true
    if ! check_server_environment; then
        USE_RSYNC=false
    fi
    
    # 检查本地rsync版本，对于旧版本直接使用scp+tar方案
    if [ "$USE_RSYNC" = true ]; then
        local rsync_version=$(rsync --version 2>/dev/null | head -1)
        if echo "$rsync_version" | grep -q "2\.6\." || ! check_rsync_features; then
            print_message $BLUE "检测到旧版本rsync，使用scp+tar方案确保中文编码正确"
            USE_RSYNC=false
        fi
    fi
    
    # 创建服务器目录（如果不存在）
    ssh -p $SSH_PORT $SERVER_USER@$SERVER_HOST "mkdir -p $SERVER_PATH"
    
    # 选择部署方式
    if [ "$USE_RSYNC" = true ]; then
        # 检查本地rsync
        if command -v rsync &> /dev/null; then
            deploy_with_rsync
            DEPLOY_RESULT=$?
        else
            print_message $BLUE "使用scp+tar方案"
            deploy_with_scp
            DEPLOY_RESULT=$?
        fi
    else
        deploy_with_scp
        DEPLOY_RESULT=$?
    fi
    
    # 检查部署结果
    if [ $DEPLOY_RESULT -eq 0 ]; then
        print_message $GREEN "部署成功！"
        print_message $BLUE "网站地址: http://blog.mitrecx.top/"
        
        # 静默验证文件名编码
        if verify_deployment; then
            print_message $GREEN "✅ 文件名编码正常"
        else
            print_message $YELLOW "⚠️  检测到编码问题，可运行 ./fix-encoding.sh 修复"
        fi
    else
        print_message $RED "部署失败！"
        exit 1
    fi
}

# 函数：显示配置信息
show_config() {
    print_message $BLUE "当前部署配置:"
    echo "  服务器: $SERVER_USER@$SERVER_HOST:$SSH_PORT"
    echo "  路径: $SERVER_PATH"
    echo "  环境: $HUGO_ENV"
    echo ""
}

# 主函数
main() {
    # 检查是否在正确的目录
    if [ ! -f "hugo.toml" ] && [ ! -f "config.toml" ] && [ ! -f "config.yaml" ]; then
        print_message $RED "错误：当前目录不是Hugo项目根目录"
        exit 1
    fi
    
    # 读取配置文件
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        print_message $RED "错误：配置文件 $CONFIG_FILE 不存在"
        print_message $YELLOW "请先创建配置文件："
        print_message $YELLOW "1. 复制模板: cp deploy.config.template deploy.config"
        print_message $YELLOW "2. 编辑配置: nano deploy.config"
        print_message $YELLOW "3. 填入你的真实服务器信息"
        exit 1
    fi
    
    print_message $GREEN "Hugo博客部署脚本启动"
    show_config
    
    # 解析命令行参数
    BUILD_ONLY=false
    DEPLOY_ONLY=false
    CLEAN_BUILD=false
    TEST_MODE=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -b|--build-only)
                BUILD_ONLY=true
                shift
                ;;
            -d|--deploy-only)
                DEPLOY_ONLY=true
                shift
                ;;
            -c|--clean)
                CLEAN_BUILD=true
                shift
                ;;
            -t|--test)
                TEST_MODE=true
                shift
                ;;
            *)
                print_message $RED "未知选项: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 执行清理（如果需要）
    if [ "$CLEAN_BUILD" = true ]; then
        clean_build
    fi
    
    # 执行相应的操作
    if [ "$DEPLOY_ONLY" = true ]; then
        # 仅部署
        deploy_site
    elif [ "$BUILD_ONLY" = true ]; then
        # 仅构建
        build_site
    elif [ "$TEST_MODE" = true ]; then
        # 测试模式
        build_site
        print_message $GREEN "测试模式：构建完成，跳过部署"
    else
        # 完整部署
        build_site
        deploy_site
    fi
    
    print_message $GREEN "所有操作完成！"
}

# 执行主函数
main "$@" 