---
title: "Linux 文本处理之 awk"
date: 2025-08-21T09:52:22+08:00
draft: false
tags: ["Linux"]
categories: ["Linux"]
author: "Mitre"
ShowBreadCrumbs: false
cover:
    image: "images/2025/P20250821-awk.png"
---

## 引例

有个 1.txt 文件, 内容如下:  
```text
1755741361|文件1|事件1
1755741374|文件1|事件2
1755741385|文件2|事件3
```
第一个字段是时间戳, 在查看这个文件时为了看清时间, 需要把时间戳转为字符串:  
```bash
while IFS='|' read ts rest; do
    echo "$(date -d @$ts '+%Y-%m-%d %H:%M:%S')|$rest";
done < 1.txt
```
结果:  
```text
2025-08-21 09:56:01|文件1|事件1
2025-08-21 09:56:14|文件1|事件2
2025-08-21 09:56:25|文件2|事件3
```

用 `awk` 也可以实现一样的效果, 代码更简洁:  
```bash
awk -F'|' '{ OFS="|"; $1 = strftime("%Y-%m-%d %H:%M:%S", $1); print }' 1.txt
```


## awk 简介
`awk` 是 Linux 文本处理三剑客之一（grep, awk, sed）擅长 **按行按列** 处理数据。  

`awk` 是一个 文本处理工具，也是一门轻量的脚本语言。  

主要功能: **按行处理文本，按列处理数据**。  

使用场景: 日志分析、数据转换/提取等。  

基本语法:   
```bash
awk 'pattern { action }' file
```
pattern：模式，用来匹配哪些行需要处理. **省略 pattern 时, 所有行都执行动作**   
action：动作，告诉 awk 对匹配的行要做什么. 省略 action 时, 默认动作是 print $0（打印整行）  

常用内置变量:  
`$0`：当前整行内容  
`$1`, `$2`, …：当前行的第1列、第2列  
`NF`：**当前行的列的个数 (Number of Fields, 一共多少列)**  
`NR`：**当前行号 (Number of Records)**  
`FNR`：当前文件的行号 (多个文件时会重置)  
`FS`：**输入分隔符 (默认空格或TAB)**  
`OFS`：**输出分隔符 (默认空格)**  
`RS`：输入记录分隔符 (默认换行符)  
`ORS`：输出记录分隔符 (默认换行符)  

内置函数:  
length($1)：返回字符串长度  
substr($1, 1, 5)：取子串  
strftime("%Y-%m-%d %H:%M:%S", $1)：时间戳转日期  
toupper($1)：转大写  
tolower($1)：转小写  

## 用法示例

### 简单打印(省略 pattern)  

打印整行(所有列/字段):
```bash
awk '{print $0}' file.txt
# 等价: 
awk '{print}' file.txt
```

打印指定列/字段:  
```bash
# 打印第一列和第三列( file.txt 中的行 用 空格 或 Tab 分隔出字段/列)
awk '{print $1, $3}' file.txt
```
使用分隔符(假设 CSV 文件以逗号分隔):  
```bash
# 指定输入分隔符为 ,
awk -F, '{print $1, $2}' file.csv

# 加不加引号(单或双), 效果一样
awk -F',' '{print $1, $2}' file.csv
awk -F"," '{print $1, $2}' file.csv

# 对于特殊字符, 不是等价的, 比如 制表符, 必须用 单/双引号:
awk -F"\t" '{print $1}' file
```

### 模式匹配(pattern)
按数值过滤:  
```bash
# 只输出第三列大于 100 的行
awk '$3 > 100 {print $1, $3}' file
```

按字符串匹配:  
```bash
# 匹配第二列等于 ERROR 的行
awk '$2 == "ERROR" {print $0}' logfile
```

按正则匹配:  
```bash
# 打印包含 failed 的所有行
awk '/failed/' logfile

# 打印含有 error 的行及其行号
awk '/error/ {print NR, $0}' logfile
```

### BEGIN 和 END 块
```bash
# BEGIN 在处理文件前执行, END 在处理文件后执行
awk 'BEGIN {print "Start"} {print $1} END {print "Done"}' data.txt
```

添加第一行标题:  
```bash
awk 'BEGIN {print "Name Age"} {print $1, $2}' data.txt
```

### 数值运算
求和:   
```bash
# 统计第二列的总和
awk '{sum += $2} END {print "Sum:", sum}' data.txt
```
备注: sum 是[变量](#变量).

求平均值:  
```bash
awk '{sum += $2; count++} END {print "Average:", sum/count}' data.txt
```

### 其他 

数据清洗:  
```bash
# 把 空格分隔的数据 转成 逗号分隔的数据(csv)
awk '{OFS=","; print $1,$2,$3}' data.txt
```

格式化输出:  
```bash
# 对齐打印
awk '{printf "%-10s %-5s\n", $1, $2}' data.txt
```

## 变量
在 awk 中, 如果变量没有被赋值, 默认值是：  
数值上下文: 0  
字符串上下文: ""(空字符串)  


例子:  
```bash
# x未定义
awk 'BEGIN {print x, x+10}'
```
结果:  
```text
 10
```
解释:  
第一个 `x` 是空字符串 "";    
第二个 `x` 在算术运算中 被转换为 0, 结果 0+10=10  

**awk 会根据上下文自动识别 变量 为 字符串 或 数字**。   


### 变量赋值
直接赋值，无需声明。  
```bash
awk 'BEGIN {name="Tom"; age=20; print name, age}'
```

### 自动创建变量
**awk 会在第一次引用变量时自动创建它**。  
例子：  
```bash
# 统计文件的行数: awk 每遍历一行, count 就累加 1  
awk '{count++} END {print count}' file.txt
```
`count` 第一次被用在 `count++` 时自动创建，初始值为 0，然后逐行累加。  

### 使用自定义变量
(1) 在 BEGIN 块里定义变量  
```bash
# 定义 threshold=100，只打印第二列大于100的行
awk 'BEGIN {threshold=100}   $2 > threshold   {print $1, $2}' data.txt
```

(2) 使用`-v` 选项传递变量   
```bash
# 定义 threshold=100，只打印第二列大于100的行(与上面 BEGIN 写法等价)
awk -v threshold=100   '$2 > threshold {print $1, $2}'   data.txt
```

### 数组
`awk` 可以用 关联数组(Associative Array) 或 索引数组 的方式来存储和处理数据, 而且 **无需事先定义 数组的大小或类型**。   

awk 中数组的特点:  
- 无需声明: 使用时直接赋值即可, awk 会自动创建数组。  
- 索引可以是数字(普通的索引数组)或字符串(关联数组/哈希表)。  
- 默认是关联数组 (Associative Array)。  
- 元素不存在时, 默认值是空字符串 "" 或数值 0  

关联数组 示例:  
```bash
awk 'BEGIN {
    fruit["b"] = "apple"
    fruit["a"] = "banana"
    fruit["c"] = "cherry"

    for (key in fruit) {
        print "Key:", key, "Value:", fruit[key]
    }
}'
```
备注: for 语句参考 [控制语句](#for-循环).  

结果(顺序不固定):  
```text
Key: a Value: banana
Key: b Value: cherry
Key: c Value: apple
```


索引数组 (普通数组) 示例:  
```bash
awk 'BEGIN {
    arr[1] = "apple"
    arr[2] = "banana"
    arr[3] = "cherry"

    for (i=1; i<=3; i++) {
        print "Index:", i, "Value:", arr[i]
    }
}'
```
结果:  
```text
Index: 1 Value: apple
Index: 2 Value: banana
Index: 3 Value: cherry
```

其他示例:  
```bash
# 统计第二列中每个值的出现次数
awk '{arr[$2]++} END {for (k in arr) print k, arr[k]}' file

# 统计 Nginx 日志中某个 IP 出现次数：  
awk '{ip_count[$1]++} END {for (ip in ip_count) print ip, ip_count[ip]}' access.log
```

## 控制语句
在 awk 中, 控制语句的语法和 C 语言非常相似, 支持条件判断、循环、跳转等语句。  

### if 语句
语法:  
```bash
if (condition)
    statement
else if (condition)
    statement
else
    statement
```

判断字段值的大小:  
```bash
awk '{if ($2 > 50) print $1, "及格"; else print $1, "不及格"}' scores.txt
```

### while 循环
语法:  
```bash
while (condition)
    statement
```
例子:  
```bash
# 打印 1 到 5
awk 'BEGIN {
    i=1;
    while (i<=5) {
        print i;
        i++;
    }
}'
```

### for 循环
```bash
# 传统 for 循环
awk 'BEGIN {
    for (i=1; i<=5; i++)
        print "Line", i;
}'

# for-in 循环 (遍历数组)
awk 'BEGIN {
    arr["Tom"]=78;
    arr["Jerry"]=85;
    arr["Lucy"]=90;

    for (name in arr)
        print name, arr[name];
}'
```

### break 和 continue
break: 立即跳出当前循环  
continue: 跳过当前循环的剩余语句, 进入下一次循环  

```bash
awk 'BEGIN {
    for (i=1; i<=10; i++) {

        if (i == 3) continue;

        if (i > 5) break;

        print i;
    }
}'
```

### exit 语句
exit 用于提前结束 awk 的执行, 可以带状态码。  

打印文件的前三行, 然后退出:  
```bash
awk '{ print $0; if (NR == 3) exit }' file.txt
```