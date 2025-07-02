#!/bin/bash

# 修复服务器上中文文件名编码问题的脚本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置文件路径
CONFIG_FILE="deploy.config"

# 打印带颜色的消息
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}[$(date '+%Y-%m-%d %H:%M:%S')] ${message}${NC}"
}

# 读取配置文件
if [ -f "$CONFIG_FILE" ]; then
    print_message $BLUE "读取配置文件: $CONFIG_FILE"
    source "$CONFIG_FILE"
else
    print_message $RED "错误：配置文件 $CONFIG_FILE 不存在"
    exit 1
fi

print_message $GREEN "🔧 中文文件名编码修复工具"
print_message $BLUE "目标服务器: $SERVER_USER@$SERVER_HOST:$SSH_PORT"
print_message $BLUE "网站目录: $SERVER_PATH"
echo ""

# 检查连接
print_message $YELLOW "测试服务器连接..."
if ! ssh -p $SSH_PORT -o ConnectTimeout=5 $SERVER_USER@$SERVER_HOST 'exit' 2>/dev/null; then
    print_message $RED "无法连接到服务器"
    exit 1
fi
print_message $GREEN "服务器连接正常"

# 检查当前文件名状态
print_message $YELLOW "检查服务器上的文件名编码状态..."
ssh -p $SSH_PORT $SERVER_USER@$SERVER_HOST "
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
    
    if [ -d '$SERVER_PATH/tags' ]; then
        echo '当前标签目录内容:'
        ls -1 '$SERVER_PATH/tags' | grep -v 'index\|page' | head -10
        echo ''
        
        # 检查是否有编码问题
        if ls '$SERVER_PATH/tags' | grep -q '\\\\#'; then
            echo '检测到文件名编码问题，需要修复'
            exit 1
        else
            echo '文件名编码正常'
            exit 0
        fi
    else
        echo '错误：tags目录不存在'
        exit 2
    fi
"

case $? in
    0)
        print_message $GREEN "✅ 文件名编码正常，无需修复"
        exit 0
        ;;
    1)
        print_message $YELLOW "⚠️  检测到编码问题，开始修复..."
        ;;
    2)
        print_message $RED "❌ tags目录不存在，请先部署网站"
        exit 1
        ;;
esac

# 方案1：重新部署（推荐）
print_message $BLUE "修复方案1：重新部署（推荐）"
echo "  优点：彻底解决问题，确保编码正确"
echo "  缺点：需要重新传输所有文件"
echo ""

read -p "是否要重新部署以修复编码问题？(Y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
    print_message $GREEN "开始重新部署..."
    
    # 清理服务器目录
    print_message $YELLOW "清理服务器目录..."
    ssh -p $SSH_PORT $SERVER_USER@$SERVER_HOST "
        export LC_ALL=C.UTF-8
        export LANG=C.UTF-8
        rm -rf '$SERVER_PATH'/*
    "
    
    # 重新部署
    print_message $YELLOW "重新部署..."
    if ./deploy.sh -d; then
        print_message $GREEN "✅ 重新部署成功！"
    else
        print_message $RED "❌ 重新部署失败"
        exit 1
    fi
else
    # 方案2：设置服务器locale
    print_message $BLUE "修复方案2：设置服务器locale"
    print_message $YELLOW "在服务器上设置正确的locale..."
    
    ssh -p $SSH_PORT $SERVER_USER@$SERVER_HOST "
        echo '设置服务器locale...'
        
        # 检查是否有sudo权限
        if sudo -n true 2>/dev/null; then
            echo '检测到sudo权限，安装中文locale...'
            sudo locale-gen zh_CN.UTF-8 2>/dev/null || true
            sudo update-locale LANG=zh_CN.UTF-8 2>/dev/null || true
        else
            echo '无sudo权限，仅设置环境变量'
        fi
        
        # 在用户profile中添加locale设置
        if ! grep -q 'LC_ALL=C.UTF-8' ~/.bashrc 2>/dev/null; then
            echo 'export LC_ALL=C.UTF-8' >> ~/.bashrc
            echo 'export LANG=C.UTF-8' >> ~/.bashrc
            echo 'locale设置已添加到~/.bashrc'
        fi
        
        echo '请重新登录SSH或运行 source ~/.bashrc'
    "
    
    print_message $YELLOW "建议重新登录服务器后再次检查文件名显示"
fi

print_message $GREEN "🎉 修复完成！"
print_message $BLUE "提示：如果问题仍然存在，可以升级rsync版本: brew install rsync" 