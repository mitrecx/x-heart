---
title: "Linux: shell 脚本篇"
date: 2025-08-11T12:46:44+08:00
draft: false
tags: ["Linux", "编程"]
categories: ["Linux"]
author: "Mitre"
ShowBreadCrumbs: false
cover:
    image: "images/2025/P20250811-linux-corver.png"
    alt: "图片描述"
    caption: "图片说明"
---

平时写 Java, Python, 甚至一些前端代码. 但最近工作上要写 shell 脚本, 发现有些生疏了, 这篇文章记录一些基本的 shell 脚本写法, 偶尔翻翻, 加深记忆.   
因为此文目的是复习 **常用的** shell 脚本写法, 所以文中不会抠细节, 不会覆盖特别全.  


## 控制语句

### 条件判断（if/else）
```bash
if [ 条件表达式 ]; then
    命令
elif [ 条件表达式 ]; then
    命令
else
    命令
fi
```
例子:
```bash
#!/bin/bash
num=5
if [ $num -gt 10 ]; then
    echo "大于10"
elif [ $num -eq 10 ]; then
    echo "等于10"
else
    echo "小于10"
fi
```

函数返回值:
```bash
# 测试远程连接
test_connection() {
    log_info "测试远程连接..."
    
    local ssh_cmd="ssh -o ConnectTimeout=10 -o BatchMode=yes"
    if [[ -n "$SSH_KEY" ]]; then
        ssh_cmd+=" -i '$SSH_KEY'"
    fi
    ssh_cmd+=" '$REMOTE_HOST' 'echo 连接测试成功'"
    
    if eval "$ssh_cmd" >/dev/null 2>&1; then
        log_info "远程连接测试成功"
        return 0
    else
        log_error "远程连接失败"
        return 1
    fi
}


# 测试连接
if ! test_connection; then
    exit 1
fi
```


### 多分支 (case)
```bash
case 变量 in
    模式1)
        命令
        ;;
    模式2|模式3)
        命令
        ;;
    *)
        默认命令
        ;;
esac
```
例子:
```bash
#!/bin/bash
read -p "输入y或n: " ans
case $ans in
    y|Y)
        echo "你选择了YES"
        ;;
    n|N)
        echo "你选择了NO"
        ;;
    *)
        echo "输入无效"
        ;;
esac
```

### 循环 (for)

```bash
# 语法 1 (列表):
for var in 值1 值2 值3; do
    命令
done

# 语法 2 (C 风格):
```bash
for ((i=1; i<=5; i++)); do
    命令
done
```

例子:  
```bash
# 语法 1 (列表):
# 遍历字符串列表
for fruit in apple banana orange; do
    echo "水果：$fruit"
done
# 遍历数字范围
for num in {1..5}; do
    echo "数字：$num"
done

# 语法 2 (C 风格):
for ((i=1; i<=3; i++)); do
    echo "数字: $i"
done
```

### 循环 (while)
```bash
while [ 条件 ]; do
    命令
done
```
例子:
```bash
count=1
while [ $count -le 3 ]; do
    echo "第$count次循环"
    count=$((count+1))
done
```

### 跳出与跳过

• break 结束当前循环  
• continue 跳过当前循环剩余部分, 进入下一轮  

例子:
```bash
for i in {1..10}; do
    if [ $i -eq 3 ]; then
        continue  # 跳过3
    fi
    if [ $i -eq 5 ]; then
        break     # 遇到5退出
    fi
    echo "i=$i"
done
```
结果:
```
i=1
i=2
i=4
```

### 组合控制
• `cmd1 && cmd2` → 如果 `cmd1` 成功执行 (返回值为 0), 则执行 `cmd2`  
• `cmd1 || cmd2` → 如果 `cmd1` 执行失败 (返回值非 0), 则执行 `cmd2`  
• `cmd1 ; cmd2` → 先执行 `cmd1`, 后执行 `cmd2`(不论 `cmd1` 是否成功)

总结:  
• `&&` → 前一个成功才执行下一个。  
• `||` → 前一个失败才执行下一个。  
• `;` → 顺序执行, 不管前一个命令是否成功。

例子:  
```bash
[ -f myfile.txt ] && echo "文件存在" || echo "文件不存在"

mkdir test_dir && cd test_dir || echo "创建目录失败"

echo "第一步"; echo "第二步"
```

## 条件运算符(conditional operators)
`test`, `[  ]`, `[[  ]]`(Bash 扩展语法) 都是条件运算符, 它们用于构建 `if`, `while` 等语句中的判断条件.    

绝大多数 `[ ]` 条件表达式 在 `[[ ]]` 中都能用, 而且更安全。   

如果写 Bash 脚本, 推荐统一用 `[[ ]]`。  
如果要写 POSIX 兼容脚本, 只能用 `[ ]`。   

条件运算符 主要分为三大类：  
字符串比较, 数值比较, 文件测试.  

### 字符串比较运算符:  
| Operator |	Meaning |	Example |
|---|---|---|
|=|	equal to|	[ "$str1" = "$str2" ]|
|!=|	not equal to|	[ "$str1" != "$str2" ]|
|-z|	**string is empty**|	[ -z "$str" ]|
|-n|	**string is not empty**|	[ -n "$str" ]|

### 数值比较运算符:  
| Operator| 	Meaning| 	Example| 
|---|---|---|
|-eq|	equal to|	[ "$a" -eq "$b" ]|
|-ne|	not equal to|	[ "$a" -ne "$b" ]|
|-gt|	greater than|	[ "$a" -gt "$b" ]|
|-lt|	less than|	[ "$a" -lt "$b" ]|
|-ge|	greater than or equal to|	[ "$a" -ge "$b" ]|
|-le|	less than or equal to|	[ "$a" -le "$b" ]|

### 文件测试运算符:  
|Operator|	Meaning	|Example|
|---|---|---|
|-e|	file exists	|[ -e file.txt ]|
|-f|	file exists and is a regular file|	[ -f file.txt ]|
|-d|	directory exists|	[ -d /path/dir ]|
|-s|	file exists and is not empty|	[ -s file.txt ]|
|-r|	file is readable|	[ -r file.txt ]|
|-w|	file is writable|	[ -w file.txt ]|
|-x|	file is executable|	[ -x script.sh ]|
|-L|	file is a symbolic link|	[ -L symlink ]|
|-nt|	file1 is newer than file2|	[ file1 -nt file2 ]|
|-ot|	file1 is older than file2|	[ file1 -ot file2 ]|

### 逻辑运算符:  
Operator|	Meaning|	Example
---|---|---
-a|	AND (both conditions true)|	[ "$a" -gt 0 -a "$b" -lt 10 ]
-o|	OR (at least one true)|	[ "$a" -eq 1 -o "$b" -eq 2 ]
!|	NOT (negation)|	[ ! -f file.txt ]
&&|	AND (preferred in [[ ]])|	[[ "$a" -gt 2 && "$b" -gt 2 ]], [ "$a" -gt 2 ] && [ "$b" -gt 2 ]
\|\|| OR| [[ "$a" -gt 2 \|\| "$b" -gt 2 ]], [ "$a" -gt 2 ] \|\| [ "$b" -gt 2 ]

• `[ ]` 中使用 `-a` (AND) 和 `-o` (OR) 组合条件, 可读性差且容易出错。  
• `[[ ]]` 中可以直接使用 `&&` 和 `||`。

###  模式匹配与正则
• `[ ]` 不支持通配符匹配 (仅支持字符串字面比较)。  
• `[[ ]]` 支持模式匹配 (`==` 可以匹配通配符, `=~` 可以匹配正则)。  
例子:  
```bash
# 模式匹配
[[ "hello" == h* ]] && echo "matched"  # 输出 matched  

# 正则匹配
[[ "abc123" =~ ^[a-z]+[0-9]+$ ]] && echo "regex matched"
```

## 函数 

### 函数定义 
```bash
# 写法 1
function func_name {
    commands
}

# 写法 2 (POSIX 兼容, 更通用)
func_name() {
    commands
}
```
> 注意:  
> 函数名建议使用小写, snake_case(蛇形命名法: 多个单词下划线分隔)  
> `function` 关键字在 Bash 中可选, 但在 POSIX Shell 中不能用。  

### 函数参数与调用
```bash
greet() {
    # $1 $2 $3 … 表示位置参数  
    echo "Name: $1"
    echo "Age: $2"

    # $# 表示参数个数
    echo "Total args: $#"
    
    # $@ 表示所有参数 (保持原始分隔)
    echo "All args (\$@): $@"
    
    # $* 表示所有参数 (作为一个整体字符串)
    echo "All args (\$*): $*"
}

greet "Alice" 20
```
### 返回值
返回退出状态码:  
用 `return <code>` 返回 0~255 的整数 (退出状态码, **0 表示成功**)  


```bash
check_num() {
    if [ $1 -gt 10 ]; then
        return 0    # 成功
    else
        return 1    # 失败
    fi
}

check_num 15 && echo "OK" || echo "FAIL"
```

返回数据:    
Bash 函数没有 return value 机制, 需要用 echo 或全局变量传值:   
```bash
sum() {
    # 标准错误, 不是返回值, 会直接输出到控制台
    echo "sum 函数开始计算." >&2
    
    local result=$(( $1 + $2 ))
    
    # 标准输出是返回值
    echo $result
    
    echo "sum 函数结束计算." >&2
}

total=$(sum 3 5)
echo "Sum is $total"
```
运行结果:  
```bash
sum 函数开始计算.
sum 函数结束计算.
Sum is 8
```

### 局部变量

使用 local 声明变量, 避免污染全局环境:
```bash
demo() {
    local msg="local variable"
    echo "$msg"
}

demo
echo "$msg"  # 空, 因为是局部变量
```

### 函数与 trap 结合 (清理资源)
函数 用于清理临时文件或处理退出信号:  
```bash
cleanup() {
    echo "Cleaning up..."
    rm -f /tmp/mytempfile
}

# 脚本退出时执行
trap cleanup EXIT  
```
补充说明:  
```bash
trap 'commands' SIGNALS
```
- 'commands' 是在捕获到指定信号时执行的命令串（最好用单引号包裹） 

- SIGNALS 是信号名（大写），或者事件

常见信号:  
信号名| 信号含义|    说明
---|---|----
SIGINT|   终端中断（Ctrl+C）|     用户按 Ctrl+C 触发
SIGTERM|  终止进程|     默认终止信号
SIGQUIT|  退出，产生 core dump|  用户按 Ctrl+\ 触发
SIGHUP|   挂断|   终端关闭时发送
EXIT|     脚本退出（任意原因）|   脚本退出时一定执行


## 变量扩展（variable expansion）
变量扩展（variable expansion）的语法是 `${}`.  

备忘表:  
Feature|	Syntax|	Description
---|---|---
Default value|	${var:-default}|	Use default if var unset or empty
Assign default|	${var:=default}|	Assign default if var unset or empty
Error on unset|	${var:?error_msg}|	Exit with error if unset or empty
Remove prefix	|${var#pattern}|	Remove shortest prefix match
Remove longest prefix|	${var##pattern}|	Remove longest prefix match
Remove suffix|	${var%pattern}|	Remove shortest suffix match
Remove longest suffix|	${var%%pattern}|	Remove longest suffix match
Substring extraction|	${var:pos:len}|	Extract substring
Replace first match|	${var/pat/repl}|	Replace first occurrence
Replace all matches|	${var//pat/repl}|	Replace all occurrences
Length	|${#var}|	Get string length



### 基本变量引用
`${var}` 与 `$var` 等效, 都是获取变量 `var` 的值.  

```bash
# ${var} 可以明确变量的边界，避免变量名与后续字符混淆
name="world"
echo "hello $name123"    # looks for variable name123, which likely doesn't exist
echo "hello ${name}123"  # outputs hello world123
```
### 默认值与替换
变量未定义 或 为空时使用默认值:
```bash
# 若 var 未定义或为空时，返回 default；否则返回 var 的值
${var:-default}

# 若 var 未定义或为空，将 var 设为 default 并返回；否则返回 var
${var:=default}
```
例子:  
```bash
echo ${username:-"Guest"}  # 若 username 未定义，输出 Guest
username="Bob"
echo ${username:-"Guest"}  # 输出 Bob

echo ${count:=0}  # count 未定义，赋值为 0 并输出 0
echo $count       # 输出 0（变量已被赋值）
```

变量未定义 或 为空时报错:  
```bash
# 若 var 未定义或为空，输出 error_msg 并终止脚本；否则返回 var
${var:?error_msg}  
```
例子:  
```bash
# 若 filename 未定义，会报错并退出
echo "处理文件: ${filename:?请指定文件名}"
```

### 字符串截取
```bash
# （1）从开头截取（删除最短匹配）
${var#pattern}  
# 例子: 
path="/usr/local/bin/bash"
echo ${path#*/}  # 从开头删除最短的 "*/" 匹配，输出 usr/local/bin/bash

#（2）从开头截取（删除最长匹配）
${var##pattern}  
# 例子: 
path="/usr/local/bin/bash"
echo ${path##*/}  # 从开头删除最长的 "*/" 匹配，输出 bash（获取文件名）

# （3）从结尾截取（删除最短匹配）
${var%pattern}
# 例子
file="document.txt.bak"
echo ${file%.*}  # 从结尾删除最短的 ".*" 匹配，输出 document.txt

# （4）从结尾截取（删除最长匹配）
${var%%pattern} 
# 例子
file="document.txt.bak"
echo ${file%%.*}  # 从结尾删除最长的 ".*" 匹配，输出 document
```

### 字符串切片
```bash
${var:offset:length}  # 从 offset 位置（0 开始）截取 length 个字符
                        # 若 length 省略，截取到结尾
```
例子:
```bash
str="Hello, World"
echo ${str:7:5}  # 从位置7开始截取5个字符，输出 World
echo ${str:0:5}  # 从开头截取5个字符，输出 Hello
echo ${str:7}    # 从位置7截取到结尾，输出 World

echo ${str: -5}  # 从结尾第5个字符开始截取，输出 World（注意冒号后有空格）
```

### 字符串替换
```bash
# （1）替换第一个匹配项
${var/pattern/replacement}  # 将 var 中第一个与 pattern 匹配的部分替换为 replacement
# 例子:
text="apple, banana, apple"
echo ${text/apple/orange}  # 替换第一个 apple，输出 orange, banana, apple


# （2）替换所有匹配项
${var//pattern/replacement}  # 将 var 中所有与 pattern 匹配的部分替换为 replacement
# 例子:
text="apple, banana, apple"
echo ${text//apple/orange}  # 替换所有 apple，输出 orange, banana, orange
```

### 获取变量长度
```bash
${#var}  # 返回变量值的字符长度
# 例子:
name="Bash"
echo ${#name}  # 输出 4（"Bash" 有4个字符）
```

## 数组
Bash 有两种数组：
1. 索引数组（Indexed Array）：下标是数字（从 0 开始）  
2. 关联数组（Associative Array）：下标是字符串（需 declare -A 声明）  

### 索引数组
```bash
# 定义
arr=()                      # 定义空数组
arr=(apple banana cherry)   # 直接赋值
arr[0]="apple"              # 按索引赋值
arr[5]="orange"             # 可以跳过索引

# 追加元素
arr+=(grape mango)


# 访问元素
echo "${arr[0]}"   # apple
echo "${arr[1]}"   # banana
# 数组切片
echo "${arr[@]:1:2}"   # 从索引 1 开始取 2 个元素
# 访问所有元素
echo "${arr[@]}"   # apple banana cherry orange grape mango
echo "${arr[*]}"   # apple banana cherry orange grape mango

# 遍历数组
for item in "${arr[@]}"; do
    echo "$item"
done


# 获取数组长度
echo "${#arr[@]}"   # 元素个数
echo "${#arr[1]}"   # 第 2 个元素的字符长度

# 删除元素
arr=()              # 清空数组, 也是定义空数组
unset arr[1]        # 删除索引 1 的元素
unset arr           # 删除整个数组
```

### 关联数组（Hash Map）
```bash
# 定义
declare -A dict
dict[apple]="red"
dict[banana]="yellow"

# 访问
echo "${dict[apple]}"  # red

# 遍历
for key in "${!dict[@]}"; do
    echo "$key => ${dict[$key]}"
done
```
`mapfile`(也叫 `readarray`) 可以 一次性读取标准输入或文件的多行内容，并将每一行存入一个数组的单独元素中。  
默认会保留换行符（可以用 `-t` 去掉）  

```bash
mapfile -t arr < filename.txt
# 等价于
readarray -t arr < filename.txt
```


## 脚本中常用的命令

### read
`read` 用来从标准输入（stdin）读取一行输入，并赋值给一个或多个变量.  
当多个变量时，按照顺序赋值，多余的内容会放到最后一个变量里。
```bash
read [选项] [变量1 变量2 ...]
```
常用选项
| 选项 | 作用 |
|------|------|
| `-p "提示信息"` | 显示提示文字，无需额外使用 `echo` |
| `-s` | 静默模式（输入不显示，常用于密码输入） |
| `-r` | 禁止反斜杠转义（原样读取输入，包括反斜杠） |

例子:  
```bash
read -p "请输入你的年龄：" age
echo "你的年龄是 $age 岁"

read -p "请输入姓名和职业（空格分隔）：" name job
echo "姓名：$name，职业：$job"
```

`while` 搭配 `read` 是一种非常常见的文件逐行读取方式:  
```bash
while read line; do
    echo "$line"
done < filename.txt

cat filename.txt | while read line; do 
    echo "$line"
done
```
读取多个字段:  
```bash
# 假设 people.txt 内容是：
# Alice 30 Paris
# Bob 25 London

while read name age city
do
    echo "Name: $name, Age: $age, City: $city"
done < people.txt
```
用 `IFS` 处理分隔符:  
```bash
while IFS=, read -r col1 col2 col3
do
    echo "Column1: $col1, Column2: $col2, Column3: $col3"
done < data.csv
```

## `$` 符号
位置参数（arguments）:  

变量|	未加引号|	加双引号
---|---|---
$@|	$1 $2 $3 …|	"$1" "$2" "$3" …（每个参数单独保留）
$*|	$1 $2 $3 …|	"$1 $2 $3"（合并成一个整体）


例子:  
```bash
[josie@MyJosie ~]$ cat script.sh
for arg in $@; do echo "[$arg]"; done
echo "----------"
for arg in "$@"; do echo "[$arg]"; done

[josie@MyJosie ~]$
[josie@MyJosie ~]$ ./script.sh "a b" c d
[a]
[b]
[c]
[d]
----------
[a b]
[c]
[d]
```

`$` 开头的特殊变量汇总:  
变量	|含义
---|---
$0|	当前脚本的名称（包含路径）
$1| $2 …	第 1、2… 个位置参数
$#|	位置参数的个数	
$@|	所有参数（逐个独立展开，常配合 "$@" 用）
$*|	所有参数（作为一个整体，配合引号时合并成一个字符串）
$$|	当前 Shell 的 PID
$!|	最近后台进程的 PID
$?|	上一个命令的退出状态

### sleep
sleep 用来让 Shell 脚本暂停指定的时间，单位可以是秒、分钟、小时或天.  
```bash 
sleep NUMBER[SUFFIX]
# s（秒，默认）, m（分钟）, h（小时）, d（天）

sleep 5        # 暂停 5 秒
sleep 0.5      # 暂停 0.5 秒（500 毫秒）
sleep 2m       # 暂停 2 分钟
```

### `&` 
命令末尾加 &，表示让该命令 在后台运行，不阻塞当前 Shell.  
```bash
long_task &  # 后台执行 long_task

(sleep 10; echo "10 秒后执行") &
```
后台任务的相关信息：
作业号：用 jobs 查看（如 [1]）
进程号（PID）：可以用 `ps` 获取, 或 `$!` 是最后一个后台任务的 PID.

`&>` 重定向:   
`&>` 表示将 标准输出和标准错误 都重定向到同一个文件：  
```bash
command > output.log 2>&1
```
