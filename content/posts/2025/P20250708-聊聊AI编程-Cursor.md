---
title: "聊聊 AI 编程 - Cursor"
date: 2025-07-08T09:28:42+08:00
draft: false
tags: ["AI", "编程"]
categories: ["AI"]
author: "Mitre"
ShowBreadCrumbs: false
cover:
    image: "images/2025/P20250708-cursor-2.png"
    alt: "图片描述"
    caption: "[图片来源于 Cursor 官网](https://cursor.com/en)"
---

## 1. 前言

Cursor 发展简介<sup>[1]</sup>
| 时间 | 说明|
|----|----|
|2023 年| Anysphere 发布了 公开测试版 的 Cursor  |
|2024 年| 因为其智能的代码生成和补全, Cursor 在编程领域 火爆全球|
|2025 年 4 月 15| 发布 Cursor 0.49, 这是官网 Changelog 给出的最早版本|
|2025 年 6 月 4| 发布 Cursor 1.0, 支持: BugBot 代码审查, 记忆 Beta, 一键安装 MCP 等等|
|2025 年 7 月 3| 发布 Cursor 1.2, 目前最新版本|

今年 2 月, Anthropic 发布的 AI 编程命令行工具 - Claude Code, 最近十分流行, 网上很多人表示 Claude Code 比 Cursor 更香.   



## 2. 基本信息
Cursor 是基于 VS Code 开发的, 所以很多 IDE 功能和 VS Code 是完全一样的.  
题外话: 字节跳动的 AI 编辑器 Trae 也是基于 VS Code 开发的.  

### 2.1. 快捷键(Keyboard Shortcuts)
打开 Command Palette:  `Cmd+Shift+P`  
其他常用快捷键可以在 [Keyboard Shortcuts](https://docs.cursor.com/configuration/kbd) 中查.  
若想修改 默认的快捷键, 可以打开 Command Palette, 搜索 "Keyboard Shortcuts".  

这里附上一份 VS Code 的 [shortcuts cheatsheet](https://code.visualstudio.com/shortcuts/keyboard-shortcuts-windows.pdf).  

### 2.2. 主题(Themes)
打开 Command Palette, 搜索 "theme", 选择 "Preferences: Color Theme" 就可以选择不同的主题.   

### 2.3. 命令行工具(Command-line Tools)  
Cursor 提供了一个 `cursor` 命令, 可以在终端 直接打开文件或目录:  
```bash
# Using the cursor command
cursor path/to/file.js
cursor path/to/folder/
```

### 2.4. 定价(Pricing)  
定价是动态变化的, 最新以[官网定价](https://docs.cursor.com/account/pricing)为准.  
个人用户(Individual) 目前有 3 种套餐:   
- Pro ($20/月) : 适合以 Tab 补全为主, 偶尔使用 Agent 的用户. 每月可使用的请求数: ~225 Sonnet 4 requests, ~550 Gemini requests, or ~650 GPT 4.1 requests
- Pro+ ($60/月) : 适合几乎每天都使用 Agent 编码的用户. 每月可使用的请求数: ~675 Sonnet 4 requests, ~1,650 Gemini requests, or ~1,950 GPT 4.1 requests
- Ultra ($200/月) : 适合大量依赖 Agent 完成主要编码工作的重度用户. 每月可使用的请求数: ~4,500 Sonnet 4 requests, ~11,000 Gemini requests, or ~13,000 GPT 4.1 requests

可以通过 [dashboard](https://cursor.com/dashboard?tab=usage) 查看自己的使用情况.  


达到月度限额后, 系统会弹出明确通知, 你可选择:   
- 切换至 Auto 模式 (自动选用更便宜模型) 
- 开启按量计费 (Usage-Based Pricing) 
- 升级套餐


### 2.5. Max Mode
部分模型支持 Max Mode, 允许更长推理, 更大上下文窗口(Context Window), tokens 消耗也更快, 适合复杂的大型项目.   
默认大多数编码任务不需要启用 Max Mode, 但处理复杂逻辑, 大文件时很有帮助.   


### 2.6. 使用自己的 API keys  
你可以 [使用你自己的 API 密钥](https://docs.cursor.com/settings/api-keys), 一旦配置完成, Cursor 将通过你的密钥直接调用对应 LLM 服务商的模型.   
在 `Cursor Settings > Models` 中配置.  

## 3. 核心功能
cursor 1.2 提供以下核心功能<sup>[2]</sup>:  

[Tab](https://docs.cursor.com/tab/overview), [Agent](https://docs.cursor.com/agent/overview), [Background Agent](https://docs.cursor.com/background-agent), [Inline edit](https://docs.cursor.com/inline-edit/overview), [Chat](https://docs.cursor.com/agent/chats/tabs), [Rules](https://docs.cursor.com/context/rules), [Memories](https://docs.cursor.com/context/memories), [Codebase Indexing](https://docs.cursor.com/context/codebase-indexing), [MCP](https://docs.cursor.com/context/mcp), [Context](https://docs.cursor.com/guides/working-with-context).    

其中, Tab, Agent, Inline edit, Chat, Codebase Indexing, Condex 是一个 AI 编辑器的基本功能, 用法很简单, 基本上手就会.   

### 3.1. Memories

Memories 是根据聊天内容自动产生的, 所以你可以告诉 cursor 记住 xxx, 它就会记住. 在更新记忆之前 cursor 会提示你确认, 确保记忆的准确. 记忆可以在 `Cursor Settings → Rules & Memories` 中查看.  

### 3.2. Rules

Rules 本质就是 prompt. 

Cursor Rules 可以让你提供多个持久化, 可复用, 可配置的 prompt, 让 AI 生成的代码符合你的 Rules.   

Cursor  Rules 有三种: **项目规则(Project Rules)**, **用户规则(User Rules)**, `.cursorrules` (废弃).  

Project Rules 只对本项目生效, 需要使用 `.mdc` 文件定义, 存储在`.cursor/rules` 目录下, `.mdc` 文件全称为 **Markdown Cursor**, 类似 Markdown 文件，但扩展了结构化语义<sup>[3]</sup>.  可以在对话框输入 `/Generate Cursor Rules` 或 `Cursor Settings > Rules & Memories` 新增规则.  

User Rules 在所有项目中都生效,  在 `Cursor Settings > Rules & Memories` 中配置.



### 3.3. MCP

MCP 是 Anthropic 提出一个让 LLM 调用工具/访问数据 的 [协议](https://modelcontextprotocol.io/docs/concepts/architecture), 统一了工具调用的规范. 



Cursor 中**使用 MCP(访问 Cursor Server)** 非常简单, 基本上都是一键安装.  

MCP Servers 在网上有很多, 这里提供两个: 

1. [Cursor tools](https://docs.cursor.com/tools/mcp)
2. [smithery](https://smithery.ai/)



除了一键安装外, 也可以把 **配置** 复制到  `Cursor Settings > Tools & Integrations` 中的 mcp.json 文件里 安装.  

Cursor 调用 MCP 是自动进行的, 比如, 你问 Cursor "postgres 数据库中有几张表", Cursor 会查询工具列表, 有 postgres 访问工具的话, 它会自动写 sql 查询.  



Cursor MCP 例子: 

配置了 github MCP 就能让 Cursor 做提交代码, 切换分支等任务; 

配置了 browser-tools-mcp (外加浏览器装插件) 就能让 Cursor 看见浏览器上的内容; 

配置了 supebase MCP 就能让 Cursor 访问 supebase 了...



通常一个 MCP Server 下会有很多个 Tools, 可以在 Cursor 配置选用.  但是不是 Tools 越多越好, 目前 Cursor 建议 Tools 数量小于 45 个. Tools 过多可能会导致 Cursor 调用工具不准确.



### 3.4. Background Agent

通过 Background Agent 可以开启异步远程 agents. 

这个功能可以理解为 Cursor 提供了远程隔离的环境, 在这个环境中可以让 Cursor 给你写代码. 可以通过 Cursor 或 其他的集成环境(如 slack) 触发 Background Agent.

Background Agents 是根据 模型 API 收费的, 不过你是不是买了 pro 会员, 想用 Background Agent 都 得加钱!



## 4. 总结

1. Cursor 可以 **大幅提高编程效率**.   
2. Cursor 使用简单, 花几个小时就能掌握大部分功能.  
3.  pro 套餐用 Claude Sonnet 4 模型感觉不是特别流畅, 有时候会对话会中断. 
4. 想解锁 Cursor 更多功能, 要多花钱.






## 参考
[1]. [Cursor Changelog](https://cursor.com/en/changelog)

[2]. [the key features that make Cursor powerful](https://docs.cursor.com/get-started/concepts)

[3]. [What is a .mdc file?](https://forum.cursor.com/t/what-is-a-mdc-file/50417?utm_source=chatgpt.com)