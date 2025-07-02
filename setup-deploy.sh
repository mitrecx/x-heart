#!/bin/bash

# Hugo博客部署设置脚本
# 帮助用户快速配置部署环境

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}🚀 Hugo博客部署设置向导${NC}"
echo ""

# 检查是否已存在配置文件
if [ -f "deploy.config" ]; then
    echo -e "${YELLOW}⚠️  配置文件 deploy.config 已存在${NC}"
    read -p "是否要重新配置？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "设置已取消"
        exit 0
    fi
fi

# 从模板创建配置文件
echo -e "${BLUE}📋 创建配置文件...${NC}"
cp deploy.config.template deploy.config

echo -e "${GREEN}✅ 配置文件已创建${NC}"
echo ""
echo -e "${YELLOW}📝 请编辑 deploy.config 文件，填入你的真实服务器信息：${NC}"
echo ""
echo "需要配置的主要项目："
echo "  - SERVER_USER: 服务器用户名"
echo "  - SERVER_HOST: 服务器IP或域名"
echo "  - SERVER_PATH: 网站目录路径"
echo "  - SSH_PORT: SSH端口（默认22）"
echo ""
echo -e "${BLUE}💡 提示：${NC}"
echo "1. 使用编辑器打开: nano deploy.config"
echo "2. 配置SSH免密登录: ssh-copy-id user@server"
echo "3. 测试部署: ./deploy.sh -t"
echo ""
echo -e "${GREEN}🎉 设置完成！${NC}" 