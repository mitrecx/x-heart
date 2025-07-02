# 部署故障排除指南

## 常见部署问题及解决方案

### 🔧 rsync相关问题

#### 问题1: `bash: rsync: command not found`
**原因**: 服务器未安装rsync工具

**解决方案**:
1. **自动解决** - 脚本会自动尝试安装rsync
2. **手动安装**:
   ```bash
   # Ubuntu/Debian
   sudo apt-get update && sudo apt-get install -y rsync
   
   # CentOS/RHEL
   sudo yum install -y rsync
   
   # Fedora
   sudo dnf install -y rsync
   ```
3. **备用方案** - 脚本会自动切换到scp+tar方案

#### 问题2: rsync不支持iconv选项
**现象**: `rsync: --iconv=UTF-8,UTF-8: unknown option`

**原因**: rsync版本过旧（< 3.0），不支持--iconv选项

**解决方案**:
脚本已自动检测并适配：
- ✅ 自动检测rsync版本和功能支持
- 🔄 旧版本自动使用环境变量方案
- 📊 新版本使用--iconv选项

**手动升级rsync** (可选):
```bash
# macOS使用Homebrew
brew install rsync

# Ubuntu/Debian
sudo apt-get install rsync

# 检查版本
rsync --version
```

#### 问题3: rsync权限错误
**现象**: `rsync: failed to set times on...`

**解决方案**:
```bash
# 确保目标目录权限正确
ssh user@server "sudo chown -R user:user /var/www/html"
ssh user@server "sudo chmod -R 755 /var/www/html"
```

### 🔐 SSH连接问题

#### 问题1: 连接被拒绝
**现象**: `Connection refused`

**解决方案**:
1. 检查服务器IP和端口
2. 检查服务器SSH服务状态:
   ```bash
   ssh user@server "sudo systemctl status ssh"
   ```
3. 检查防火墙设置

#### 问题2: 密钥认证失败
**现象**: `Permission denied (publickey)`

**解决方案**:
```bash
# 生成SSH密钥
ssh-keygen -t rsa -b 4096

# 复制公钥到服务器
ssh-copy-id -p 22 user@server

# 测试连接
ssh -p 22 user@server
```

### 📁 文件权限问题

#### 问题1: 无法写入目标目录
**现象**: `Permission denied`

**解决方案**:
```bash
# 方案1: 修改目录所有者
sudo chown -R www-data:www-data /var/www/html

# 方案2: 修改权限
sudo chmod -R 755 /var/www/html

# 方案3: 添加用户到www-data组
sudo usermod -a -G www-data username
```

### ⚙️ Hugo构建问题

#### 问题1: Hugo命令未找到
**解决方案**:
```bash
# macOS
brew install hugo

# Ubuntu/Debian
sudo apt-get install hugo

# 或下载二进制文件
wget https://github.com/gohugoio/hugo/releases/download/v0.120.0/hugo_extended_0.120.0_linux-amd64.tar.gz
```

#### 问题2: 主题问题
**现象**: `theme "xxx" not found`

**解决方案**:
```bash
# 检查主题目录
ls themes/

# 重新初始化主题子模块
git submodule update --init --recursive
```

### 🌐 网络问题

#### 问题1: 连接超时
**解决方案**:
1. 检查网络连接
2. 增加连接超时时间:
   ```bash
   ssh -o ConnectTimeout=30 user@server
   ```
3. 检查服务器防火墙

#### 问题2: 传输中断
**解决方案**:
1. 检查网络稳定性
2. 使用备用部署方案（脚本会自动切换）
3. 手动重试部署

### 🔄 备用部署方案

当rsync不可用时，脚本会自动使用scp+tar方案：

**工作流程**:
1. 本地打包网站文件
2. 上传压缩包到服务器
3. 服务器端解压部署
4. 清理临时文件

**手动使用备用方案**:
```bash
# 本地打包
tar -czf website.tar.gz -C public .

# 上传
scp -P 22 website.tar.gz user@server:/tmp/

# 服务器端部署
ssh user@server "
cd /var/www/html && 
rm -rf * &&
tar -xzf /tmp/website.tar.gz &&
rm /tmp/website.tar.gz
"
```

### 📊 调试技巧

#### 启用详细输出
```bash
# 添加调试信息
set -x  # 在脚本开头添加

# 使用SSH详细模式
ssh -v user@server

# 使用rsync详细模式
rsync -avz --progress source/ user@server:/path/
```

#### 检查服务器状态
```bash
# 检查磁盘空间
ssh user@server "df -h"

# 检查目录权限
ssh user@server "ls -la /var/www/"

# 检查进程
ssh user@server "ps aux | grep hugo"
```

### 🆘 紧急恢复

#### 恢复备份
脚本会自动创建备份，恢复方法：
```bash
# 查看备份文件
ssh user@server "ls -la /tmp/backup_*"

# 恢复备份
ssh user@server "
cd /var/www/html &&
rm -rf * &&
tar -xzf /tmp/backup_20231202_143000.tar.gz
"
```

#### 手动部署
如果脚本完全失败，可以手动部署：
```bash
# 本地构建
hugo --gc --minify

# 手动上传
scp -r public/* user@server:/var/www/html/
```

### 📞 获取帮助

如果问题仍未解决：

1. **查看详细错误** - 运行脚本时保存完整输出
2. **检查服务器日志**:
   ```bash
   sudo tail -f /var/log/auth.log    # SSH日志
   sudo tail -f /var/log/syslog      # 系统日志
   ```
3. **测试单个组件**:
   ```bash
   # 测试SSH连接
   ssh user@server 'echo "连接成功"'
   
   # 测试Hugo构建
   hugo --gc --minify --verbose
   
   # 测试rsync
   rsync --version
   ```

### 🔤 中文文件名编码问题

#### 问题: 中文文件名在部署时显示为乱码
**现象**: 
```
tags/�\#215\#232客/index.html
tags/�\#200�\#217\#221工�\#205�/index.xml
```

**原因**: 字符编码设置不一致导致的问题

**解决方案**:
脚本已自动集成编码修复功能：

1. **自动设置UTF-8环境**:
   ```bash
   export LC_ALL=C.UTF-8
   export LANG=C.UTF-8
   ```

2. **rsync编码支持**:
   ```bash
   rsync --iconv=UTF-8,UTF-8 ...
   ```

3. **全流程编码统一**:
   - Hugo构建时设置UTF-8
   - rsync传输时保持UTF-8
   - 服务器解压时使用UTF-8

**自动修复**:
脚本已集成智能编码处理：
- 🔍 自动检测rsync版本
- 🔄 旧版本(2.6.x)自动切换到scp+tar方案
- ✅ 新版本(3.0+)使用--iconv选项
- 📊 部署后自动验证文件名编码

**专用修复工具**:
```bash
# 运行编码修复工具
./fix-encoding.sh
```

**手动修复** (如果需要):
```bash
# 设置本地编码
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# 重新构建
hugo --gc --minify

# 升级rsync (推荐)
brew install rsync

# 使用新版rsync部署
rsync -avz --iconv=UTF-8,UTF-8 --delete public/ user@server:/path/
```

### 💡 预防措施

1. **定期备份** - 部署前自动备份
2. **测试环境** - 先在测试服务器验证
3. **监控磁盘** - 确保服务器有足够空间
4. **更新系统** - 保持服务器系统更新
5. **文档记录** - 记录服务器配置信息
6. **编码统一** - 确保整个流程使用UTF-8编码 