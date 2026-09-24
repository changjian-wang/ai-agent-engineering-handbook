---
layout: default
title: AI 与 Agent 工程手册
description: 从 AI 基础开始的学习目录，以成熟教材组织主线，Agent 独立并行学习。
permalink: /
---

# AI 与 Agent 工程手册

先建立 AI 的基础认识，再学习模型原理、训练与应用。Agent 独立并行，面试复习贯穿各章。

**当前状态：目录草案，另有一节试写稿。**旧正文与样稿已撤下；[AI00.1 · AI、机器学习与深度学习是什么关系]({{ '/chapters/ai00-1/' | relative_url }}) 待审阅，其余章节正文待写。

[查看学习目录]({{ '/roadmap/' | relative_url }}) · [学习阶段]({{ '/roadmap/#stages' | relative_url }}) · [面试主题索引]({{ '/roadmap/#interview' | relative_url }}) · [资料分工]({{ '/roadmap/#sources' | relative_url }})

## 从哪里开始

第一站是 [AI00 · AI 基本认识]({{ '/roadmap/#ai00' | relative_url }})：AI、机器学习、深度学习有什么关系？数据、模型、参数分别是什么？训练与推理有什么区别？

这些概念建立后，再按需要补 Python、张量和数学，进入机器学习与神经网络。注意力、掩码、LoRA 和多 Agent 都有后续位置，不作为第一篇的起点。

## 两条学习线

**AI 主线：**基本认识 → 编程与数学 → 机器学习 → 神经网络 → NLP → Transformer → 预训练 → 强化学习基础与后训练 → 推理、评测与 RAG → 多模态与综合。

以《动手学深度学习》补基础，以 Happy-LLM 串起大模型原理，强化学习基础读 EasyRL；《大语言模型》和 Base-LLM 按专题补充。

**Agent 并行线：**认识 Agent → 模型调用 → 工具 → 执行循环 → 上下文与记忆 → 协议 → 框架与协作 → 评测与安全 → 综合项目；Agentic RL 为可选进阶。

以 Hello-Agents 为主，LLM Universe 补 RAG 实践。学完 AI00 与基础 Python 即可从 AG00 开始，按六个学习阶段与 AI 主线同步推进；遇到表示、检索、评测问题，再补对应 AI 模块。

[AI 主线目录]({{ '/roadmap/#ai-track' | relative_url }}) · [Agent 并行目录]({{ '/roadmap/#agent-track' | relative_url }})

## 编排原则

- 按先修关系安排章节，不按面试题难度、热点热度或单篇文章截图排序。
- 每个模块分为先修、核心、进阶、主读和验收五项：先学核心，进阶按需补；面试题附在知识点之后。
- 成熟教程作主线，官方文档和论文核对关键事实；不整篇搬运，也不把链接集合当教材。
- 先审阅目录与来源映射，再从最小章节开始写正文；资料不足的地方先标缺口。

[下一步编写顺序]({{ '/roadmap/#writing-order' | relative_url }})
