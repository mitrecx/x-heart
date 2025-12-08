---
title: "Text-to-SQL Agent"
date: 2025-12-05T15:53:23+08:00
draft: false
tags: ["AI"]
categories: ["AI"]
author: "Mitre"
ShowBreadCrumbs: false

---

## 源代码
[源码链接](https://github.com/mitrecx/Text2SQL)  
本地运行方式参考 README 中的说明.  

## 功能介绍
基于 LangChain 1.1 + deepseek 大模型 实现的 Text2SQL Agent, 支持通过自然语言查询 PostgreSQL 数据库中的数据.  

## 效果图
![langgraph-text2sql.gif](/images/2025/langgraph-text2sql.gif)  

## tooken 消耗
![tooken消耗](/images/2025/P20251205-deepseek.png)  
得益于 deepseek 便宜的定价(百万tokens输入输出, 5元), 1毛钱大约可以问 20个 中等复杂的问题.  

## 其他 text-to-sql 开源实现
[pandas-ai](https://github.com/sinaptik-ai/pandas-ai)  

[vanna](https://github.com/vanna-ai/vanna)  