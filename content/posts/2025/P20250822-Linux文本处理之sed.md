---
title: "Linux 文本处理之 sed"
date: 2025-08-22T11:35:18+08:00
draft: false
tags: ["Linux"]
categories: ["Linux"]
author: "Mitre"
ShowBreadCrumbs: false
cover:
    image: "images/2025/P20250822-sed.png"
---

sed (Stream Editor, 流编辑器) 是 Linux 中的 文本处理工具,  常用于对文本进行 查找、替换、删除、插入、提取等批处理操作。  

基本语法:  
```bash
sed [选项] '命令' 文件
# 或者: 
命令 | sed [选项] '命令'
```
常用选项:  
选项 |说明
---|---
-n| 默认 sed 会打印所有行, 使用 -n 后只会输出符合条件或被命令处理的行
-e| 用于指定多条命令
-i| 直接修改源文件(慎用, 建议先备份)
-r| 启用扩展正则表达式 (也可以用 -E)
-f| 从文件中读取 sed 命令

常用命令:  
命令|说明
---|---
p| 打印
d| 删除
s/old/new/| 查找并替换
a\text| 在当前行后追加一行
i\text| 在当前行前插入一行
c\text| 替换当前行内容
=| 打印当前行号
q| 处理到此行后退出

## 常见用法示例

### 打印文本
```bash
# 打印所有行:
sed '' file.txt

打印匹配到 error 的行:  
sed -n '/error/p' file.txt

# 只打印第 2 行:
sed -n '2p' file.txt

# 打印第 2 到第 4 行:
sed -n '2,4p' file.txt
```

### 查找并替换

```bash
# 只替换每行的第一个匹配:
sed 's/error/warning/' file.txt

# 替换每行所有匹配:
sed 's/error/warning/g' file.txt

# 忽略大小写替换:
sed 's/error/warning/gi' file.txt

# 如果文本中有特殊字符, 如 /, 换分隔符:
sed 's|/usr/local|/opt|g' file.txt

# 使用变量:
word="error"
sed "s/$word/warning/g" file.txt

# 替换并直接修改文件:
sed -i 's/error/warning/g' file.txt

# 直接修改文件并备份:
sed -i.bak 's/error/warning/g' file.txt

# 正则, 替换数字为 X:
sed 's/[0-9]/X/g' file.txt

```
### 删除文本
```bash
# 删除第 2 行:
sed '2d' file.txt

# 删除第 2 到第 4 行:
sed '2,4d' file.txt

# 删除匹配 debug 的行:
sed '/debug/d' file.txt

# 删除所有空行:
sed '/^$/d' file.txt

# 删除以 # 开头的注释行:
sed '/^#/d' file.txt

```
### 插入、追加、替换
```bash
# 在第 2 行前插入一行:
sed '2i\This is a new line' file.txt

# 在第 3 行后追加一行:
sed '3a\Another new line' file.txt

# 把第 2 行替换成新的内容:
sed '2c\This line is replaced' file.txt

```