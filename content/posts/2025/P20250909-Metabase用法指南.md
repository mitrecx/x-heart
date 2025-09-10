---
title: "Metabase 用法指南"
date: 2025-09-09T23:15:23+08:00
draft: false
tags: ["Metabase"]
categories: ["工具"]
author: "Mitre"
ShowBreadCrumbs: false

---

## 前言
Metabase 安装, [参考这里](https://www.metabase.com/docs/latest/installation-and-operation/start)。  

Metabase 是一个 "商业智能"（BI）平台，它为您提供了大量了解和共享数据的工具。([原文](https://www.metabase.com/learn/metabase-basics/overview/concepts))  


Metabase 的核心作用:  
1. **数据可视化**: Metabase 提供了丰富的图表和可视化工具，帮助用户 将数据转换为图表和图形。
2. **数据分析**: 用户可以使用 Metabase 进行数据分析，包括筛选、排序、聚合和计算等操作。
3. 数据共享: Metabase 允许用户将分析结果分享给其他用户，以便团队成员之间进行合作和沟通。
4. 数据权限管理: Metabase 提供了灵活的权限管理功能，用户可以根据需要设置数据的访问权限，确保数据的安全性和隐私性。

<br>
我最近用到 Metabase, 是因为 账单管理系统 内部没有实现 账单数据解析功能, 只能用 Metabase 连接数据库做分析。  

[项目地址](https://github.com/mitrecx/my-bill-2)  

<br>
下面是我使用 Metabase 的一些经验。  

## 简介

核心概念:  
1. **数据库**: Metabase 连接到数据库，用户可以在 Metabase 中查询和分析数据库中的数据。
2. **Collection**: 用于组织和管理数据集, 可以把 dashboard, question, model 放在 collection 中, 可以把 collection 理解为文件夹。
3. **Question**: 查询数据, 有两种类型: graphical query builder(Metabase 提供的查询方式) 和 native query editor(原生SQL查询方式)。
4. **Dashboard(看板)**: 可以在看板中添加图表、表格、指标等元素，以展示数据的趋势、分布、对比等信息。
5. **Model**: 相当于 数据库中的 视图。


主页示例: 
![Metabase 主页](/images/2025/P20250909-metabase.png)

如图所示, 点击 "New" 可以创建一个新的 Question, SQL query, Dashboard, Collection, Model。  
其中, 新建 Question 和 SQL query 本质都是新建 Question:  
- 新建 Question 会使用 graphical query builder; 
- 而新建 SQL query 会使用 native query editor, 保存后会成为一个 Question。


完成后的 dashboard:
![dashboard](/images/2025/P20250909-metabase-dashboard.png)

可以通过左上角 Filter 选择 月份, 这样就能查询 每个月的收入和支出 信息了。   


上图 dashboard 中展示的 数据/图表(chart) 都是通过 query builder 查询的, 因此可以使用 **钻取(drill through)** 功能。  

> 钻取功能: 点击图表中的某个数据点, 可以跳转到一个新的 Question, 新的 Question 中展示的是 该数据点 相关的详细信息。
> **只有 query builder 类型的 Question 才支持钻取功能, native query 类型不支持。**  我觉得这是 query builder 类型的 Question 最大的优势。  


## native query
native query 没啥好说的, 就是写 sql 语句: 
- 优点: 对于后端开发来说, 写 SQL 是非常简单的。
- 缺点: 不支持 钻取(drill through) 功能。

我用的是 postgresql, 所以 native query 是 postgresql 语法。  

native query 中可以使用[参数](https://www.metabase.com/docs/latest/questions/native-editor/sql-parameters), 例如:  
```sql
SELECT * FROM my_table WHERE month = {{month}}
```
这里的 `{{month}}` 就是一个参数, 可以在 Metabase 中设置参数值。




## query builder
query builder 是 Metabase 提供的查询方式, 它的优点是: 
- 不需要写 SQL 语句, 只需要点击鼠标就可以查询数据, 可以快速上手。
- 支持 钻取(drill through) 功能。

缺点:  
- 复杂的过滤条件需要熟练掌握 [自定义表达式](https://www.metabase.com/docs/latest/questions/query-builder/expressions)才能写好。  

示例: 
![query builder](/images/2025/P20250909-metabase-question.png)

- **Data** 中展示的是查询结果, 可以对结果进行筛选、排序、聚合等操作。  
- **Custom column** 可以自定义输出的列。    
- **Join data** 可以连接其他表。   
- **Filter** 可以添加筛选条件, 多个条件的关系是 AND。  
- **Summarize** 可以对数据进行聚合, 例如: 求和, 求平均值, 求最大值, 求最小值, 求数量等。  
- **Sort** 可以对数据进行排序。  

<br>

特别注意, 上图中有一个 自定义表达式:  
```sh
[Source Type] = "jd" OR [Source Type] = "wechat" OR [Source Type] = "alipay" AND [Transaction Desc] != "亲情卡-xxx" OR [Source Type] = "cmb" AND doesNotContain([Transaction Desc], "还款") AND doesNotContain([Transaction Desc], "肯特瑞") AND doesNotContain([Transaction Desc], "xxx") AND doesNotContain([Transaction Desc], "微信转账") AND doesNotContain([Transaction Desc], "京东白条")
``` 
其中, `[]` 内的是 数据库表的 列名, 例如 `[Source Type]` 就是 支付方式 这一列。   
`doesNotContain` 是 metabase 表达式: 判断 字符串 中是否不包含 某个关键词。  

<br>

上面表达式的作用是: 筛选出 京东, 微信, 支付宝(附加其他条件), 招商银行(附加其他条件) 这四种支付方式的账单。 


metabase 支持的所有表达式: [自定义表达式](https://www.metabase.com/docs/latest/questions/query-builder/expressions), [全量表达式列表](https://www.metabase.com/docs/latest/questions/query-builder/expressions-list)  



## 最后
Dashboard, Visualization(查询结果可视化), Model 等功能用法比较简单, 就算不看官网文档, 基本上在 metabase 页面上自己也能摸索明白。  

不过, 花半天时间系统性地看一下 [官方文档](https://www.metabase.com/docs/latest/), 用起来更是游刃有余。  
