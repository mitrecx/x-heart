# Hugo博客部署脚本使用说明

## 快速开始

### 1. 创建并配置服务器信息
```bash
# 从模板创建配置文件
cp deploy.config.template deploy.config

# 编辑配置文件，填入真实服务器信息
nano deploy.config
```

配置示例：
```bash
SERVER_USER="root"
SERVER_HOST="123.456.789.0" 
SERVER_PATH="/var/www/html/"
SSH_PORT="22"
```

### 2. 配置SSH免密登录
```bash
# 生成SSH密钥
ssh-keygen -t rsa

# 复制到服务器
ssh-copy-id user@server
```

### 3. 执行部署
```bash
# 完整部署
./deploy.sh

# 仅构建
./deploy.sh -b

# 仅部署  
./deploy.sh -d

# 测试模式
./deploy.sh -t
```

## 文件说明

- `deploy.sh` - 主部署脚本
- `deploy.config.template` - 配置文件模板（可提交到git）
- `deploy.config` - 真实配置文件（不提交到git，包含敏感信息）
- `fix-encoding.sh` - 中文文件名编码修复工具
- `.rsyncignore` - 排除文件列表

## 配置安全性

- ✅ `deploy.config.template` - 模板文件，可安全提交到git
- ❌ `deploy.config` - 真实配置，已加入.gitignore，不会泄露
- 🔒 服务器敏感信息受到保护

## 常见问题

1. **连接失败**: 检查服务器地址和SSH配置
2. **权限错误**: 确保用户有目录写入权限  
3. **构建失败**: 检查Hugo安装和配置文件
4. **配置文件不存在**: 运行 `cp deploy.config.template deploy.config`
5. **rsync未安装**: 脚本会自动尝试安装或使用备用方案(scp+tar)

## 服务器环境

脚本支持自动检测和适配不同的服务器环境：

### 优先方案：rsync
- ✅ 增量同步，快速高效
- ✅ 自动检测服务器是否安装rsync
- ✅ 支持Ubuntu/Debian/CentOS/Fedora自动安装
- 🔧 自动适配不同rsync版本（2.6.9+ 兼容）

### 备用方案：scp+tar
- 🔄 当rsync不可用时自动启用
- 📦 打包压缩后上传
- 🔄 服务器端自动解压部署
- ✅ 兼容所有支持SSH的服务器

## 中文支持

脚本已内置完整的中文文件名支持：

- ✅ **UTF-8编码环境** - 自动设置正确的字符编码
- 🔤 **中文文件名** - 完美支持中文标签和目录名
- 📁 **全流程保护** - 从构建到部署全程保持编码一致性
- 🔧 **自动修复** - 无需手动配置，自动处理编码问题

## 中文编码问题修复

如果部署后发现中文文件名显示为乱码，可以使用修复工具：

```bash
# 运行编码修复工具
./fix-encoding.sh
```

修复工具会：
1. 🔍 检测服务器上的文件名编码状态
2. 🔄 提供重新部署或locale设置方案
3. ✅ 验证修复结果 