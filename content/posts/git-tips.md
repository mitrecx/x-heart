---
title: "Git 实用技巧分享"
date: 2024-01-20T14:30:00+08:00
draft: false
tags: ["Git", "版本控制", "开发工具"]
categories: ["技术分享"]
author: "博主"
description: "分享一些日常开发中常用的Git技巧，提高开发效率。"
cover:
    image: "images/test/test.webp"
    alt: "Git技巧"
    caption: "让Git使用更高效"
---

## 前言

Git是现代软件开发中不可或缺的版本控制工具。今天分享一些我在日常开发中常用的Git技巧，希望能帮助大家提高开发效率。

## 1. 美化Git日志

使用别名来美化git log输出：

```bash
# 设置漂亮的日志格式
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

# 使用
git lg
```

效果：
```
* a1b2c3d - (HEAD -> main) 添加新功能 (2小时前) <张三>
* d4e5f6g - 修复bug (1天前) <李四>
* g7h8i9j - 初始提交 (3天前) <王五>
```

## 2. 快速暂存和恢复工作

当需要临时切换分支但当前工作未完成时：

```bash
# 暂存当前工作
git stash push -m "临时保存：正在开发新功能"

# 切换分支处理其他事情
git checkout hotfix-branch

# 回到原分支
git checkout feature-branch

# 恢复工作
git stash pop
```

## 3. 交互式添加文件

只提交文件的部分修改：

```bash
# 交互式添加
git add -p filename

# 选择操作：
# y - 暂存这个块
# n - 不暂存这个块
# s - 分割成更小的块
# e - 手动编辑这个块
```

## 4. 重写提交历史

### 修改最后一次提交
```bash
# 修改提交信息
git commit --amend -m "新的提交信息"

# 添加遗漏的文件到最后一次提交
git add forgotten-file.txt
git commit --amend --no-edit
```

### 交互式变基
```bash
# 修改最近3次提交
git rebase -i HEAD~3

# 在编辑器中可以：
# pick - 保持提交
# reword - 修改提交信息
# edit - 编辑提交
# squash - 合并到前一个提交
# drop - 删除提交
```

## 5. 查找和定位问题

### 使用git blame查看代码作者
```bash
# 查看文件每一行的修改者
git blame filename

# 只查看指定行范围
git blame -L 10,20 filename
```

### 使用git bisect定位bug
```bash
# 开始二分查找
git bisect start

# 标记当前版本有问题
git bisect bad

# 标记某个版本是好的
git bisect good v1.0

# Git会自动切换到中间版本，测试后标记
git bisect good  # 或 git bisect bad

# 找到问题提交后
git bisect reset
```

## 6. 分支管理技巧

### 清理本地分支
```bash
# 查看已合并的分支
git branch --merged

# 删除已合并的分支（排除master和当前分支）
git branch --merged | grep -v "\*\|master\|main" | xargs -n 1 git branch -d
```

### 同步远程分支信息
```bash
# 清理远程已删除的分支引用
git remote prune origin

# 查看远程分支状态
git remote show origin
```

## 7. 提高效率的配置

在`~/.gitconfig`中添加以下配置：

```ini
[alias]
    st = status
    co = checkout
    br = branch
    ci = commit
    df = diff
    lg = log --oneline --graph --decorate --all
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = !gitk

[core]
    editor = code --wait
    autocrlf = input

[push]
    default = simple

[pull]
    rebase = true
```

## 8. 处理图片和二进制文件

将图片存储在项目中的最佳实践：

```bash
# 在static/images目录存放图片
mkdir -p static/images

# 在markdown中引用
![图片描述](/images/your-image.png)
```

对于大型图片文件，可以考虑使用Git LFS：

```bash
# 安装Git LFS
git lfs install

# 跟踪图片文件
git lfs track "*.png"
git lfs track "*.jpg"
git lfs track "*.gif"

# 提交.gitattributes文件
git add .gitattributes
git commit -m "Add Git LFS tracking"
```

## 总结

这些Git技巧在日常开发中非常实用：

1. **美化日志** - 让历史记录更清晰
2. **灵活暂存** - 处理临时工作切换
3. **精确提交** - 只提交需要的修改
4. **历史重写** - 保持干净的提交历史
5. **问题定位** - 快速找到bug源头
6. **分支管理** - 保持仓库整洁
7. **个性配置** - 提高工作效率

Git是一个强大的工具，掌握这些技巧能让你的开发工作更加高效。记住，实践是最好的学习方式！

---

你有什么Git使用技巧想要分享吗？欢迎在评论区交流！
