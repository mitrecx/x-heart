# 我的个人博客

基于Hugo + PaperMod主题搭建的个人博客，用于技术分享和生活记录。

## 🚀 快速开始

### 本地开发

1. **启动开发服务器**
   ```bash
   hugo server -D
   ```
   
2. **访问博客**
   
   打开浏览器访问：http://localhost:1313

### 创建新文章

```bash
# 创建新文章
hugo new posts/your-post-title.md
```

### 构建静态文件

```bash
# 构建生产版本
hugo

# 生成的静态文件在 public/ 目录
```

## 📁 项目结构

```
x-heart/
├── content/           # 内容目录
│   ├── posts/        # 博客文章
│   ├── about/        # 关于页面
│   └── archives.md   # 归档页面
├── static/           # 静态资源
│   └── images/      # 图片文件
├── themes/          # 主题目录
│   └── PaperMod/   # PaperMod主题
├── hugo.toml       # Hugo配置文件
└── README.md       # 项目说明
```

## ✍️ 写作指南

### 文章模板

每篇文章都应该包含以下前置信息：

```yaml
---
title: "文章标题"
date: 2024-01-15T10:00:00+08:00
draft: false  # 设为true为草稿，不会发布
tags: ["标签1", "标签2"]
categories: ["分类"]
author: "博主"
description: "文章描述"
cover:
    image: "images/your-image.jpg"
    alt: "图片描述"
    caption: "图片说明"
---
```

### 图片使用

1. **存放位置**：将图片放在`static/images/`目录下
2. **引用方式**：在markdown中使用`![描述](/images/图片名.jpg)`
3. **支持格式**：jpg, png, gif, webp等

### 分类建议

- **技术分享**：编程教程、工具使用、技术心得
- **生活记录**：日常感悟、旅行记录、读书笔记
- **项目展示**：个人项目、作品集

## 🎨 主题特性

使用PaperMod主题，具有以下特性：

- ✅ 响应式设计，移动端友好
- ✅ 暗色/亮色主题切换
- ✅ 代码语法高亮
- ✅ 文章目录(TOC)
- ✅ 阅读时间估算
- ✅ 社交链接支持
- ✅ SEO优化
- ❌ 评论功能（已关闭）
- ❌ 搜索功能（已关闭）

## 🚀 部署方案

### GitHub Pages (推荐)

1. 将代码推送到GitHub仓库
2. 在仓库设置中启用GitHub Pages
3. 使用GitHub Actions自动构建和部署

**GitHub Actions配置** (`.github/workflows/hugo.yml`):

```yaml
name: Deploy Hugo site to Pages

on:
  push:
    branches: ["main"]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

defaults:
  run:
    shell: bash

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
        with:
          submodules: recursive

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: 'latest'

      - name: Build
        run: hugo --minify

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v1
        with:
          path: ./public

  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v1
```

### 其他部署选项

- **Netlify**：连接GitHub仓库，自动部署
- **Vercel**：导入项目，零配置部署
- **自己的服务器**：使用rsync或FTP上传public目录

## 🛠️ 自定义配置

### 修改站点信息

编辑`hugo.toml`文件：

```toml
baseURL = 'https://yourdomain.com/'  # 修改为你的域名
title = '你的博客名称'
[params]
  author = "你的名字"
  description = "博客描述"
```

### 添加社交链接

在`hugo.toml`中添加：

```toml
[[params.socialIcons]]
  name = "github"
  url = "https://github.com/yourusername"

[[params.socialIcons]]
  name = "twitter"
  url = "https://twitter.com/yourusername"
```

## 📝 常用命令

```bash
# 查看Hugo版本
hugo version

# 创建新文章
hugo new posts/my-post.md

# 启动开发服务器
hugo server -D

# 构建静态站点
hugo

# 清理生成的文件
rm -rf public/
```

## 🤝 贡献

如果你发现任何问题或有改进建议，欢迎提交Issue或Pull Request。

## 📄 许可证

本项目采用MIT许可证，详见LICENSE文件。

---

Happy Blogging! 🎉 
