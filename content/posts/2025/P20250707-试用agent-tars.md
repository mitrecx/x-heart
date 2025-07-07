---
title: "Agent TARS 和 UI TARS 的使用体验"
date: 2025-07-07T17:18:34+08:00
draft: false
tags: ["AI"]
categories: ["AI"]
author: "Mitre"
ShowBreadCrumbs: false
cover:
    image: "images/2025/P20250707-agent-tars-1.png"
    alt: "图片描述"
    caption: "[图片来源于字节跳动github](https://github.com/bytedance/UI-TARS-desktop/raw/main/images/tars.png)"
---

## 前言

前两天在 字节跳动 的公众号上看到一篇 [基于 UI-TARS 的 Computer Use 实现](https://mp.weixin.qq.com/s/a6Rn9CHoE14KabNLLf_tZQ) 的文章. 看 demo 感觉和今年年初发布的 Manus 一样, 也是一个通用的 AI agent. 

不过 UI-TARS-desktop 是 [开源](https://github.com/bytedance/UI-TARS-desktop) 的.

`TARS*` 目前包括[两个项目](https://github.com/bytedance/UI-TARS-desktop?tab=readme-ov-file#introduction)：<span style="color:#FF8800">Agent TARS</span> 和 <span style="color:#FF8800">UI-TARS Desktop</span>: 
- <span style="color:#FF8800">Agent TARS</span> 是一个 GUI Agent, 运行时会启动一个本地服务, 能通过浏览器访问, 提供了访问 本地终端, 浏览器, 本地文件 的能力.

- <span style="color:#FF8800">UI-TARS Desktop</span> 是一个提供了 native GUI Agent 能力的桌面应用. 它可以像人类一下操作电脑(鼠标, 键盘).  

安装方法在github和官网有详细说明, 下面直接开测.
 

## 测试 Agent TARS
`Agent TARS` 目前只支持 3 中模型:
1. 字节跳动的 Seed1.5-VL(doubao-1-5-thinking-vision-pro-250428)
2. Claude 3.7 Sonnet
3. GPT-4o
我用 豆包模型 进行测试.

### 本地浏览器（Browser Use）
测试一:   
在Boss直聘上搜索招聘信息, 并整理到excel表格中. 提示词如下:
```
请你去Boss直聘网站上搜索"Java开发工程师", 并把相关的招聘信息整理到excel表格中, 只要保留前50条记录即可
```
结果如下:  
![图](/images/2025/P20250707-agent-tars-2.png)  

过程中, agent-tars 打开了一个 Chrome 浏览器页面, 输出Boss直聘的官网, 轻松地通过了人机验证, 最终把搜索到的招聘信息统计好放在本地.

我自己最近在做一个小项目 JobPilot: 通过AI在各大招聘网站上搜索招聘信息, 并根据用户的简历推荐最相关的工作, 如果推荐的好的话, 真的可以给求职者省很多时间. 
然而, Boss直聘的人机验证, 我搞了两天都没解决, agent-tars 提供了一个很好的思路, 传统的规避反爬虫机制不好使, LLM 也解决不了, 可以考虑 VLM.


测试二:  
提示词如下:  
```
打开网易云音乐, 并随机播放一首歌
```
agent-tars 会在浏览器打开网易云音乐, 然后就死循环了... 
我分析可能是网络原因, 或者网易云不登录无法播放音乐, 或者豆包的模型看不懂网易云的页面, 不管怎么样, 都不应该死循环, 因为死循环是会一直消耗 token 的, 很费钱!

然后我又测试了:  
```
打开本地网易云音乐APP, 并随机播放一首歌
```
agent-tars 通过命令行打开了网易云音乐, 虽然可以打开app, 但是无法放音乐.

### 本地文件处理(Workspace)
agent-tars 默认可以访问 `~/.agent-tars-workspace` 目录下的文件.  

我分别在支付宝, 京东金融, 招商银行各导出了一份账单, 账单有 csv 格式的, 也有 pdf 格式的, 我把这 3 个账单放在 workspace 中的 bill 目录下, 问:  
```
请你仔细分析 bill 目录下的3份账单(交易流水), 并说说你的发现  
```
agent-tars 一开始说它看不见 bill 目录... 后来我改了目录, 它还是不会分析.  

## 测试 UI TARS

### 本地电脑（Computer Use）
Computer Use 需要通过 [UI-TARS-desktop](https://github.com/bytedance/UI-TARS-desktop) 使用.  
让 `UI TARS` "打开网易云音乐, 并放一首歌", 它可以完成:  
![放音乐](/images/2025/P20250707-agent-tars-3.png)

但是让 `UI TARS` 整理支付宝账单, 并做一个直方图, 它就有点费劲:   
它通过 WPS 打开 csv 文件, 然后开始用 WPS 内置的画图工具画图, 然而它 截图(snapshot)->操作(action) 循环了 50+ 次, 花了 7+ 分钟, 还没完成.  

因为我是用的是 "Local Computer" 模式, `UI TARS` 会接管我的电脑, 导致我无法使用, 所以我就没有等它测试完了...   

现在看来, "Remote Computer" 模式更适合 Computer Use.



## 总结
`Agent TARS` 基于视觉的 上网 和 终端执行命令 能力很强, 但 文件操作/分析 能力还有待提高.  
此外, 虽然 `Agent TARS` 是开源免费的, 但是背后的 VML 是收费的, 我用豆包的大模型, 测试上面那几个案例竟然用掉了 260w+ tokens, 花了 6+ 块钱! 有点贵!!!


`UI-TARS Desktop` 可以做一下简单的任务, 比如修改一个系统/软件配置, 打开软件, 使用软件, 但是更复杂的任务可能无法完成, 或者完成比较慢.   

在 2024 年 Anthropic 就提出了 [Computer Use](https://www.anthropic.com/news/developing-computer-use), 到如今过去不到 1 年时间, 开源的闭源的通用 AI Agent 都可以干一些事情了, 虽然不完美, 但是发展速度很快. 或许几年以后, Agent 就能像人一样但更高效地操作所有电子设备了...