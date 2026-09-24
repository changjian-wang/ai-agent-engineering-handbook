---
layout: default
title: 学习目录草案
description: AI 主线与 Agent 并行线的学习阶段、先修关系、核心与进阶范围、主读章节及待补缺口。
permalink: /roadmap/
---

# 学习目录草案

**修订：2026-09-24。当前只有目录，章节正文均待写。**目标是先系统学习 AI，同时并行掌握 Agent 工程，兼顾理解、实践和面试；不声称穷尽所有 AI 研究方向。

## 从哪里入手 {#start}

1. 从 [AI00](#ai00) 建立基本概念，不从架构分类和注意力公式开篇。
2. 学完 AI00 和基础 Python，即可从 [AG00](#ag00) 开始 Agent 线，按[学习阶段](#stages)与 AI 主线同步推进。
3. 每个模块先学“核心”；“进阶”留到后续模块需要或面试复习时再学。数学按需补，不必先读完整本教材。
4. 每个主题只选一份主读资料，其余用于解释难点和核对事实。面试题跟随知识点，不用题库倒推学习顺序。

“先修”指需要具备的能力，已经掌握的读者可以跳读。

## 学习阶段 {#stages}

阶段只表示先后关系，不对应固定时长；一个阶段的核心内容掌握后，再进入下一阶段。

| 阶段 | AI 主线 | Agent 并行线 | 阶段产出 |
| --- | --- | --- | --- |
| 1 · 入门与前置 | [AI00–AI02](#ai00) | [AG00–AG01](#ag00) | 讲清基本概念；用 Python 处理数据与张量；完成一次模型调用 |
| 2 · 机器学习与深度学习 | [AI03–AI04](#ai03) | [AG02](#ag02) | 训练并评估一个小型分类模型；实现一次带参数校验的工具调用 |
| 3 · NLP 与 Transformer | [AI05–AI06](#ai05) | [AG03](#ag03) | 手写注意力并核对张量形状；实现带停止条件的 Agent 循环 |
| 4 · 预训练与后训练 | [AI07–AI09](#ai07) | [AG04–AG05](#ag04) | 讲清训练目标、loss mask 与 LoRA；为 Agent 接入记忆、检索或 MCP 工具 |
| 5 · 推理、评测与应用 | [AI10–AI12](#ai10) | [AG06–AG07](#ag06) | 搭建并分阶段评测一个 RAG；为 Agent 建立回放测试与安全检查 |
| 6 · 专题与综合 | [AI13–AI14](#ai13) | [AG08–AG09](#ag08) | 完成一个有真实运行记录和评测的综合项目，并按面试格式复盘 |

对照原微信文章的五个阶段：阶段 1 为前置知识，阶段 2–3 为核心原理，阶段 4 为预训练与后训练，阶段 5 为应用开发；阶段 6 是本手册的补充。需要尽早做 RAG 项目时，学完 AI05 与 AG01 即可提前学习 [AI12](#ai12)。

## AI 主线 {#ai-track}

学习顺序：**基本认识 → 编程与数学 → 机器学习 → 神经网络 → 文本表示 → Transformer → 预训练 → 强化学习基础与后训练 → 推理、评测与 RAG → 多模态与综合。**

### AI00 · AI 基本认识 {#ai00}

- **先修：**无。
- **核心：**AI、机器学习与深度学习的关系；分类、回归、生成等任务；数据、特征、标签、模型与参数；训练、验证、测试与推理的区别；大模型、RAG 与 Agent 分别解决什么问题。
- **进阶：**机器学习的主要范式与深度学习的发展脉络。
- **主读：**[D2L 第 1 章 引言](https://zh.d2l.ai/chapter_introduction/index.html)。
- **验收：**用一个文本分类任务说明输入、输出、数据和模型分别是什么，并区分“训练模型”与“使用模型”。

### AI01 · Python、数据与张量 {#ai01}

- **先修：**AI00；有编程经验可跳读。
- **核心：**函数、容器、类、异常、模块与包；虚拟环境与依赖；文件、JSON 与 HTTP 请求；张量的创建、形状、索引、广播与数据类型。
- **进阶：**迭代器与生成器、类型注解、测试与随机种子；CPU/GPU 设备与显存。
- **主读：**[Python 官方教程](https://docs.python.org/zh-cn/3/tutorial/index.html)；[D2L 第 2 章 预备知识](https://zh.d2l.ai/chapter_preliminaries/index.html)中的数据操作；补充 [PyTorch：Learn the Basics](https://docs.pytorch.org/tutorials/beginner/basics/intro.html)。
- **验收：**读取一份小数据并转成张量，写出每一步的形状，能定位一个维度或类型错误。

### AI02 · 数学基础（按需） {#ai02}

- **先修：**AI00；可与 AI01 并行。
- **核心：**向量、矩阵乘法与形状；导数、偏导、链式法则与梯度；概率、条件概率、期望与方差。
- **进阶：**范数与投影；特征值与 SVD（学 LoRA 前补）；最大似然与常见分布；KL 散度（学后训练与蒸馏前补）。
- **主读：**[D2L 第 2 章 预备知识](https://zh.d2l.ai/chapter_preliminaries/index.html)中的线性代数、微积分、自动微分与概率；进阶资料见[待补资料](#gaps)。
- **验收：**手算一次矩阵乘法并标注形状；求一个复合函数的梯度，再用自动微分核对。

### AI03 · 机器学习基本流程 {#ai03}

- **先修：**AI01、AI02 的核心部分。
- **核心：**监督、无监督、自监督与强化学习的区别；线性回归与 softmax 分类；均方误差、交叉熵与梯度下降；训练、验证、测试划分与数据泄漏；欠拟合、过拟合与正则化；准确率、精确率、召回率与 F1。
- **进阶：**决策树与集成、SVM、k-means 与 PCA；交叉验证；ROC/PR 曲线与校准；类别不平衡与分布偏移。
- **主读：**[D2L 第 3 章 线性神经网络](https://zh.d2l.ai/chapter_linear-networks/index.html)，其中 [softmax 回归](https://zh.d2l.ai/chapter_linear-networks/softmax-regression.html)包含交叉熵与信息论基础；[D2L 第 4 章](https://zh.d2l.ai/chapter_multilayer-perceptrons/index.html)中关于过拟合的小节；进阶查 [scikit-learn 用户指南](https://scikit-learn.org/stable/user_guide.html)。
- **验收：**为一个分类任务建立基线、划分数据、选定指标，并说明“训练集表现好”为什么不等于泛化。

### AI04 · 神经网络与深度学习 {#ai04}

- **先修：**AI03。
- **核心：**多层感知机与激活函数；前向传播与反向传播；SGD、Adam、学习率与批量大小；参数初始化、梯度消失与爆炸；Dropout 与残差连接；BatchNorm 与 LayerNorm 的区别；循环网络为什么难以处理长距离依赖。
- **进阶：**CNN 与经典卷积网络（学多模态前补）；LSTM 与 GRU 的门控；学习率调度、梯度裁剪与 AdamW。
- **主读：**[D2L 第 4 章 多层感知机](https://zh.d2l.ai/chapter_multilayer-perceptrons/index.html)、[第 7 章](https://zh.d2l.ai/chapter_convolutional-modern/index.html)中的批量规范化与残差网络、[第 8 章 循环神经网络](https://zh.d2l.ai/chapter_recurrent-neural-networks/index.html)、[第 11 章 优化算法](https://zh.d2l.ai/chapter_optimization/index.html)；进阶读[第 6 章](https://zh.d2l.ai/chapter_convolutional-neural-networks/index.html)与[第 9 章](https://zh.d2l.ai/chapter_recurrent-modern/index.html)。
- **验收：**写出一个两层网络一次训练迭代的前向、损失、梯度与参数更新；说明 BatchNorm 和 LayerNorm 分别沿哪个维度归一化。

### AI05 · NLP、Token 与文本表示 {#ai05}

- **先修：**AI04。
- **核心：**NLP 常见任务；中文分词与歧义；词表、子词与 BPE；Token、Token ID 与 Embedding；词袋、TF-IDF 与 Word2Vec；语言模型的概率定义与困惑度；填充、截断与 attention mask。
- **进阶：**WordPiece、Unigram 与字节级 BPE；ELMo 与上下文表示；句向量与检索向量；tokenizer 对多语言、数字与代码的影响。
- **主读：**[Happy-LLM 第一章](https://github.com/datawhalechina/happy-llm/blob/main/docs/chapter1/%E7%AC%AC%E4%B8%80%E7%AB%A0%20NLP%E5%9F%BA%E7%A1%80%E6%A6%82%E5%BF%B5.md)；补充 Base-LLM 的[分词](https://github.com/datawhalechina/base-llm/blob/main/docs/chapter2/03_tokenization.md)与[词向量](https://github.com/datawhalechina/base-llm/blob/main/docs/chapter2/04_word_vector.md)、[D2L 第 14 章](https://zh.d2l.ai/chapter_natural-language-processing-pretraining/index.html)的 word2vec，以及 [Hugging Face LLM 课程](https://huggingface.co/learn/llm-course/zh-CN/chapter1/1)的 tokenizer 章节。
- **验收：**说明一段文本如何变成 Token ID 和向量，并区分初始 embedding、上下文表示与检索向量。

### AI06 · 注意力与 Transformer {#ai06}

- **先修：**AI05；AI02 的矩阵运算。
- **核心：**注意力的直觉与 Q/K/V；缩放点积与 softmax；自注意力、交叉注意力与多头注意力；位置编码；因果掩码；FFN、残差与 LayerNorm；Encoder-only、Decoder-only 与 Encoder-Decoder；现代 Decoder-only 的常见改动（Pre-Norm、RMSNorm、RoPE、SwiGLU）。
- **进阶：**长度外推与长上下文；MQA、GQA 与 MLA；稀疏注意力；MoE 的路由与负载均衡。
- **主读：**[Happy-LLM 第二章](https://github.com/datawhalechina/happy-llm/blob/main/docs/chapter2/%E7%AC%AC%E4%BA%8C%E7%AB%A0%20Transformer%E6%9E%B6%E6%9E%84.md)；补充 [D2L 第 10 章 注意力机制](https://zh.d2l.ai/chapter_attention-mechanisms/index.html)；现代结构对照 [Happy-LLM 第五章](https://github.com/datawhalechina/happy-llm/blob/main/docs/chapter5/%E7%AC%AC%E4%BA%94%E7%AB%A0%20%E5%8A%A8%E6%89%8B%E6%90%AD%E5%BB%BA%E5%A4%A7%E6%A8%A1%E5%9E%8B.md)的 LLaMA2 实现；MoE 先读 [Base-LLM 的 MoE 解析](https://github.com/datawhalechina/base-llm/blob/main/docs/chapter6/18_MoE.md)，再补原论文。
- **验收：**手写一个注意力计算并标注每一步的张量形状；说明因果掩码下每个位置能看到哪些 token。

### AI07 · 预训练语言模型与大模型能力 {#ai07}

- **先修：**AI06。
- **核心：**自回归、掩码与前缀语言模型的训练目标；BERT、GPT、T5 的结构与目标；预训练数据的来源、清洗与去重；Scaling Laws 的含义；上下文学习、指令遵循、思维链等能力及其边界；用 Hugging Face Transformers 加载模型与 tokenizer 并生成文本。
- **进阶：**数据配比与评测污染；训练 tokenizer 与样本打包；数据、张量与流水线并行及 ZeRO；混合精度与训练稳定性；动手搭建并预训练一个小型 Decoder-only 模型（先核对[环境准备](https://github.com/datawhalechina/happy-llm/blob/main/docs/%E5%AD%A6%E4%B9%A0%E4%B8%8E%E7%8E%AF%E5%A2%83%E5%87%86%E5%A4%87.md)中的硬件与依赖）。
- **主读：**[Happy-LLM 第三章](https://github.com/datawhalechina/happy-llm/blob/main/docs/chapter3/%E7%AC%AC%E4%B8%89%E7%AB%A0%20%E9%A2%84%E8%AE%AD%E7%BB%83%E8%AF%AD%E8%A8%80%E6%A8%A1%E5%9E%8B.md)与[第四章](https://github.com/datawhalechina/happy-llm/blob/main/docs/chapter4/%E7%AC%AC%E5%9B%9B%E7%AB%A0%20%E5%A4%A7%E8%AF%AD%E8%A8%80%E6%A8%A1%E5%9E%8B.md)；实践读[第五章](https://github.com/datawhalechina/happy-llm/blob/main/docs/chapter5/%E7%AC%AC%E4%BA%94%E7%AB%A0%20%E5%8A%A8%E6%89%8B%E6%90%AD%E5%BB%BA%E5%A4%A7%E6%A8%A1%E5%9E%8B.md)、[第六章](https://github.com/datawhalechina/happy-llm/blob/main/docs/chapter6/%E7%AC%AC%E5%85%AD%E7%AB%A0%20%E5%A4%A7%E6%A8%A1%E5%9E%8B%E8%AE%AD%E7%BB%83%E6%B5%81%E7%A8%8B%E5%AE%9E%E8%B7%B5.md)与 [Hugging Face LLM 课程](https://huggingface.co/learn/llm-course/zh-CN/chapter1/1)；理论补充[《大语言模型》](https://llmbook-zh.github.io/)第四至六章。
- **验收：**说明一条训练文本如何产生目标与 loss；比较 BERT 和 GPT 的训练目标与适用任务；说明涌现能力与上下文学习的含义及适用边界。

### AI08 · 强化学习基础 {#ai08}

- **先修：**AI04；AI02 的概率与期望。
- **核心：**智能体、环境、状态、动作、奖励与回报；马尔可夫决策过程；策略与价值函数；探索与利用；策略梯度与优势函数的直觉；PPO 如何限制每次策略更新的幅度。
- **进阶：**Q-learning 与 DQN；演员-评论员方法；on-policy 与 off-policy；稀疏奖励与模仿学习。
- **主读：**[EasyRL（蘑菇书）](https://datawhalechina.github.io/easy-rl/)第一至五章：强化学习基础、马尔可夫决策过程、表格型方法、策略梯度、近端策略优化；进阶读第六章以后的 DQN、演员-评论员等章节。
- **验收：**用一个简单环境说明状态、动作、奖励与回报；解释 PPO 为什么要限制新旧策略的差距；区分强化学习中的“智能体”与 LLM Agent 系统。

### AI09 · SFT、参数高效微调与对齐 {#ai09}

- **先修：**AI07；RLHF 部分需要 AI08，LoRA 需要 AI02 的低秩概念。
- **核心：**预训练、SFT 与偏好对齐分别改变什么；指令数据与 chat template；loss mask；全量微调与 LoRA；RLHF 流程（奖励模型与 PPO）；DPO 的思路。
- **进阶：**QLoRA、Adapter、Prefix/Prompt Tuning；GRPO 与可验证奖励；推理模型的训练思路；知识蒸馏；灾难性遗忘与训练后回归评测；PEFT、TRL 或 LLaMA-Factory 实践（先核对硬件）。
- **主读：**[Happy-LLM 第六章](https://github.com/datawhalechina/happy-llm/blob/main/docs/chapter6/%E7%AC%AC%E5%85%AD%E7%AB%A0%20%E5%A4%A7%E6%A8%A1%E5%9E%8B%E8%AE%AD%E7%BB%83%E6%B5%81%E7%A8%8B%E5%AE%9E%E8%B7%B5.md)与[第八章](https://github.com/datawhalechina/happy-llm/blob/main/docs/chapter8/%E7%AC%AC%E5%85%AB%E7%AB%A0%20%E5%A4%A7%E6%A8%A1%E5%9E%8B%E5%BC%BA%E5%8C%96%E5%AD%A6%E4%B9%A0.md)；理论补充[《大语言模型》](https://llmbook-zh.github.io/)第七、八、十一章；实践对照 [TRL SFT 文档](https://github.com/huggingface/trl/blob/main/docs/source/sft_trainer.md)与 Base-LLM 的 [QLoRA](https://github.com/datawhalechina/base-llm/blob/main/docs/chapter11/04_qwen2.5_qlora.md) 和 [DPO](https://github.com/datawhalechina/base-llm/blob/main/docs/chapter12/02_llama_factory.md) 实战。
- **验收：**说明一次 SFT 中哪些 token 参与 loss；比较 LoRA 与全量微调分别更新哪些参数；说明 RLHF 与 DPO 各需要什么数据。

### AI10 · 生成、推理与部署 {#ai10}

- **先修：**AI06；AI07 的自回归生成。
- **核心：**greedy、beam search 与 temperature、top-k、top-p 采样；停止条件与流式输出；prefill 与 decode；KV Cache；显存估算；量化的基本原理；首 token 延迟、每 token 延迟与吞吐。
- **进阶：**连续批处理与分页 KV 缓存；推测解码；推理引擎的选型与压测；服务化中的限流、超时与故障处理。
- **主读：**Base-LLM 的[生成策略](https://github.com/datawhalechina/base-llm/blob/main/docs/chapter6/19_text_generation.md)与[模型量化](https://github.com/datawhalechina/base-llm/blob/main/docs/chapter13/01_quantization.md)；理论补充[《大语言模型》](https://llmbook-zh.github.io/)第九章；部署实践见 Base-LLM 的 [FastAPI 部署](https://github.com/datawhalechina/base-llm/blob/main/docs/chapter14/01_fastapi.md)。
- **验收：**解释一次生成请求从输入到输出的过程；估算模型权重所需显存，并说明 KV Cache 为什么随序列变长而增长。

### AI11 · 评测、可靠性与安全 {#ai11}

- **先修：**AI03 的评估指标；AI07。
- **核心：**基准测试与任务指标；人工评估与 LLM-as-judge；训练数据污染与结果可比性；幻觉的类型与成因；提示注入与不可信输入；隐私、版权与许可。
- **进阶：**评测集构建与统计显著性；校准与不确定性；红队测试；线上监控与回归评测。
- **主读：**[Happy-LLM 第七章](https://github.com/datawhalechina/happy-llm/blob/main/docs/chapter7/%E7%AC%AC%E4%B8%83%E7%AB%A0%20%E5%A4%A7%E6%A8%A1%E5%9E%8B%E5%BA%94%E7%94%A8.md)的评测部分；补充 Base-LLM 的[大模型安全总览](https://github.com/datawhalechina/base-llm/blob/main/docs/chapter16/01_LLM_safety_overview.md)；生产评测与安全资料见[待补资料](#gaps)。
- **验收：**为一次模型更换设计评测方案，并指出“分数上升但真实任务变差”的可能原因。

### AI12 · 检索与 RAG {#ai12}

- **先修：**AI05；能调用模型（AG01）；评测部分用到 AI03 与 AI11。
- **核心：**RAG 的基本流程；文档解析与切块；BM25 与向量检索；embedding 模型与相似度；向量索引与向量数据库；上下文组装与引用；检索和生成分开评测；提示词、RAG 与微调各适合什么情况。
- **进阶：**混合检索与重排；查询改写与多跳检索；GraphRAG；权限与时效性；长上下文与 RAG 的取舍。
- **主读：**[LLM Universe](https://datawhalechina.github.io/llm-universe/) 第一部分；补充 [Happy-LLM 第七章](https://github.com/datawhalechina/happy-llm/blob/main/docs/chapter7/%E7%AC%AC%E4%B8%83%E7%AB%A0%20%E5%A4%A7%E6%A8%A1%E5%9E%8B%E5%BA%94%E7%94%A8.md)的 RAG 部分。
- **验收：**区分“没检索到”“排序错”“上下文丢失”“生成无依据”四类问题，并为每类设计检查。

### AI13 · 多模态基础 {#ai13}

- **先修：**AI04 的 CNN 进阶部分；AI06。
- **核心：**图像如何表示（像素、patch 与视觉编码器）；ViT；图文对比学习与 CLIP 的思路；视觉语言模型如何接入图像；OCR 与文档理解。
- **进阶：**语音识别与合成；视频与时间信息；扩散模型的基本原理；多模态评测与幻觉。
- **主读：**Base-LLM 的[多模态概述](https://github.com/datawhalechina/base-llm/blob/main/docs/chapter19/01_multimodal_definition.md)与[图文多模态](https://github.com/datawhalechina/base-llm/blob/main/docs/chapter19/02_ViT_CLIP.md)；进阶资料见[待补资料](#gaps)。
- **验收：**说明一个图文问答模型如何处理图像输入，并区分识别、检索、推理与生成任务。

### AI14 · 模型案例与综合复习 {#ai14}

- **先修：**AI09、AI10、AI11；按案例补 AI12、AI13。
- **核心：**从 BERT、GPT、T5 到 Llama、Qwen、DeepSeek 的选定版本，对照结构、数据、训练、推理与评测；按“结论 → 原理 → 例子 → 边界”组织面试回答。
- **进阶：**阅读模型技术报告；复现一个小实验并写明限制；大模型系统设计题。
- **主读：**各模型的原论文与技术报告，逐案记录版本；[LLM Interview Note](https://github.com/wdndev/llm_interview_note) 只作问题清单。
- **验收：**解释一个模型设计解决了什么问题、证据是什么、结论不能推广到哪里。

## Agent 并行线 {#agent-track}

**入门门槛：AI00 与基础 Python。**先理解控制流，再使用框架和平台；Agentic RL 为可选进阶。

### AG00 · 认识 Agent {#ag00}

- **先修：**AI00。
- **核心：**Agent 是什么；Agent 与普通对话、固定工作流的区别；感知、决策与行动的循环；常见类型与应用场景；什么情况下不需要 Agent。
- **进阶：**从符号主义到 LLM 驱动的发展脉络。
- **主读：**[Hello-Agents 第一章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter1/%E7%AC%AC%E4%B8%80%E7%AB%A0%20%E5%88%9D%E8%AF%86%E6%99%BA%E8%83%BD%E4%BD%93.md)；补充[第二章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter2/%E7%AC%AC%E4%BA%8C%E7%AB%A0%20%E6%99%BA%E8%83%BD%E4%BD%93%E5%8F%91%E5%B1%95%E5%8F%B2.md)与 [Anthropic：Building effective agents](https://www.anthropic.com/research/building-effective-agents)。
- **验收：**分别举出一个适合 Agent 和一个更适合固定工作流的任务，并说明理由。

### AG01 · 模型调用与提示基础 {#ag01}

- **先修：**AG00；AI01 的 JSON 与 HTTP。
- **核心：**消息角色与上下文窗口；提示词结构与少样本示例；temperature 等采样参数的作用（原理见 AI10）；结构化输出；流式响应；超时、重试、限流与费用。
- **进阶：**本地模型与托管服务的取舍；提示词的版本管理与回归测试；缓存与成本优化。
- **主读：**[Hello-Agents 第三章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter3/%E7%AC%AC%E4%B8%89%E7%AB%A0%20%E5%A4%A7%E8%AF%AD%E8%A8%80%E6%A8%A1%E5%9E%8B%E5%9F%BA%E7%A1%80.md)的提示部分与[第四章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter4/%E7%AC%AC%E5%9B%9B%E7%AB%A0%20%E6%99%BA%E8%83%BD%E4%BD%93%E7%BB%8F%E5%85%B8%E8%8C%83%E5%BC%8F%E6%9E%84%E5%BB%BA.md) 4.1 节的模型调用封装；具体接口以所选服务的官方文档为准。
- **验收：**写一个调用模型并解析结构化输出的小程序，能处理超时和格式错误。模型服务与凭据需自行准备并确认费用，手册不收集密钥。

### AG02 · 工具调用与执行边界 {#ag02}

- **先修：**AG01。
- **核心：**工具的名称、描述与参数 schema；模型提出调用、程序校验并执行、结果回传；只读与写入操作的区别；错误处理与重试。
- **进阶：**幂等与去重；权限与人工确认；审计日志；工具描述的设计与测试。
- **主读：**[Hello-Agents 第四章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter4/%E7%AC%AC%E5%9B%9B%E7%AB%A0%20%E6%99%BA%E8%83%BD%E4%BD%93%E7%BB%8F%E5%85%B8%E8%8C%83%E5%BC%8F%E6%9E%84%E5%BB%BA.md) 4.2 节的工具定义与工具执行器。
- **验收：**区分“模型提出调用”“程序执行成功”和“用户任务完成”，并各举一个失败的例子。

### AG03 · 工作流与 Agent 控制循环 {#ag03}

- **先修：**AG02。
- **核心：**固定工作流与动态决策；ReAct、Plan-and-Solve 与 Reflection；状态管理、最大步数与停止条件。
- **进阶：**分支、并行与中断恢复；人工检查点；计划失败后的重新规划。
- **主读：**[Hello-Agents 第四章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter4/%E7%AC%AC%E5%9B%9B%E7%AB%A0%20%E6%99%BA%E8%83%BD%E4%BD%93%E7%BB%8F%E5%85%B8%E8%8C%83%E5%BC%8F%E6%9E%84%E5%BB%BA.md)。
- **验收：**逐步解释一次任务轨迹：状态由谁维护、何时停止、未完成时如何报告。

### AG04 · 上下文、记忆与检索 {#ag04}

- **先修：**AG03；AI05 的向量表示。
- **核心：**上下文窗口与预算；对话历史的截断与摘要；短期状态与长期记忆；在 Agent 中接入检索（完整的 RAG 原理放在 AI12）；外部数据与指令的隔离。
- **进阶：**上下文工程；记忆的写入、更新与遗忘策略；多用户隔离与隐私。
- **主读：**[Hello-Agents 第八章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter8/%E7%AC%AC%E5%85%AB%E7%AB%A0%20%E8%AE%B0%E5%BF%86%E4%B8%8E%E6%A3%80%E7%B4%A2.md)与[第九章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter9/%E7%AC%AC%E4%B9%9D%E7%AB%A0%20%E4%B8%8A%E4%B8%8B%E6%96%87%E5%B7%A5%E7%A8%8B.md)。
- **验收：**说明一条信息保存在哪里、何时读回、何时失效，以及“记住”与“训练模型”的区别。

### AG05 · MCP、Skills 与通信协议 {#ag05}

- **先修：**AG02。
- **核心：**为什么需要协议；MCP 的客户端、服务端、工具与资源；能力发现与鉴权；协议与框架的区别。
- **进阶：**Agent Skills 的适用边界；A2A、ANP 等 Agent 间通信；版本兼容与安全审查。
- **主读：**[Hello-Agents 第十章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter10/%E7%AC%AC%E5%8D%81%E7%AB%A0%20%E6%99%BA%E8%83%BD%E4%BD%93%E9%80%9A%E4%BF%A1%E5%8D%8F%E8%AE%AE.md)；补充 [MCP 官方规范](https://modelcontextprotocol.io/specification/latest)与 [Agent Skills 与 MCP 对比解读](https://github.com/datawhalechina/hello-agents/blob/main/Extra-Chapter/Extra05-AgentSkills%E8%A7%A3%E8%AF%BB.md)。
- **验收：**区分协议、框架、提示知识与实际工具权限，并说明接通协议不等于任务正确。

### AG06 · 平台、框架与多 Agent 协作 {#ag06}

- **先修：**AG03、AG05。
- **核心：**低代码平台与代码框架的取舍；框架中的状态与编排抽象；多 Agent 的分工与通信；以单 Agent 为基线进行对照。
- **进阶：**从零实现一个最小 Agent 框架；并发、冲突与失败传播；协作成本。
- **主读：**[Hello-Agents 第五章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter5/%E7%AC%AC%E4%BA%94%E7%AB%A0%20%E5%9F%BA%E4%BA%8E%E4%BD%8E%E4%BB%A3%E7%A0%81%E5%B9%B3%E5%8F%B0%E7%9A%84%E6%99%BA%E8%83%BD%E4%BD%93%E6%90%AD%E5%BB%BA.md)与[第六章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter6/%E7%AC%AC%E5%85%AD%E7%AB%A0%20%E6%A1%86%E6%9E%B6%E5%BC%80%E5%8F%91%E5%AE%9E%E8%B7%B5.md)；进阶读[第七章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter7/%E7%AC%AC%E4%B8%83%E7%AB%A0%20%E6%9E%84%E5%BB%BA%E4%BD%A0%E7%9A%84Agent%E6%A1%86%E6%9E%B6.md)。
- **验收：**说明一个任务什么时候值得拆成多个 Agent，并设计与单 Agent 的对照实验。

### AG07 · Agent 评测、安全与运行治理 {#ag07}

- **先修：**AG03；AI11 的评测与安全原则。
- **核心：**任务完成率、工具调用成功率与轨迹质量；成本与延迟；离线回放与回归测试；提示注入与最小权限；日志与可观测性。
- **进阶：**基准测试与评估框架；沙箱与敏感信息保护；线上监控与告警；人工审批流程。
- **主读：**[Hello-Agents 第十二章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter12/%E7%AC%AC%E5%8D%81%E4%BA%8C%E7%AB%A0%20%E6%99%BA%E8%83%BD%E4%BD%93%E6%80%A7%E8%83%BD%E8%AF%84%E4%BC%B0.md)；生产治理与安全资料见[待补资料](#gaps)。
- **验收：**找出一个“调用没有报错但任务做错”的案例，并设计能复现它的测试。

### AG08 · Agentic RL（可选） {#ag08}

- **先修：**AI08、AI09、AG03。
- **核心：**为什么用强化学习训练 Agent；从 SFT 到 GRPO 的训练流程；奖励设计；把搜索与工具使用纳入训练的案例。
- **进阶：**训练环境的构建；奖励投机；训练稳定性与成本。
- **主读：**[Hello-Agents 第十一章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter11/%E7%AC%AC%E5%8D%81%E4%B8%80%E7%AB%A0%20Agentic-RL.md)；补充 [Happy-LLM 第八章](https://github.com/datawhalechina/happy-llm/blob/main/docs/chapter8/%E7%AC%AC%E5%85%AB%E7%AB%A0%20%E5%A4%A7%E6%A8%A1%E5%9E%8B%E5%BC%BA%E5%8C%96%E5%AD%A6%E4%B9%A0.md)中的 Search-R1 与 ReTool。
- **验收：**说明一个 Agent 训练任务的状态、动作和奖励，并指出奖励可能被投机利用的地方。

### AG09 · 综合项目与工程面试 {#ag09}

- **先修：**按项目组合 AG04、AG06、AG07；不强制使用多 Agent。
- **核心：**选题与需求；数据与权限；单 Agent 基线；评测、部署与复盘。
- **进阶：**深度研究、编程、网页或 GUI 等 Agent 类型；Agent 系统设计面试。
- **主读：**Hello-Agents [第十三章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter13/%E7%AC%AC%E5%8D%81%E4%B8%89%E7%AB%A0%20%E6%99%BA%E8%83%BD%E6%97%85%E8%A1%8C%E5%8A%A9%E6%89%8B.md)、[第十四章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter14/%E7%AC%AC%E5%8D%81%E5%9B%9B%E7%AB%A0%20%E8%87%AA%E5%8A%A8%E5%8C%96%E6%B7%B1%E5%BA%A6%E7%A0%94%E7%A9%B6%E6%99%BA%E8%83%BD%E4%BD%93.md)与[第十六章](https://github.com/datawhalechina/hello-agents/blob/main/docs/chapter16/%E7%AC%AC%E5%8D%81%E5%85%AD%E7%AB%A0%20%E6%AF%95%E4%B8%9A%E8%AE%BE%E8%AE%A1.md)；面试查 [Hello-Agents 面试题](https://github.com/datawhalechina/hello-agents/blob/main/Extra-Chapter/Extra01-%E9%9D%A2%E8%AF%95%E9%97%AE%E9%A2%98%E6%80%BB%E7%BB%93.md)及[参考答案](https://github.com/datawhalechina/hello-agents/blob/main/Extra-Chapter/Extra01-%E5%8F%82%E8%80%83%E7%AD%94%E6%A1%88.md)。
- **验收：**完成一个有真实运行记录、边界说明和可重复评测的项目，而不只是截图。

## 面试主题索引 {#interview}

对照 [LLM Interview Note](https://github.com/wdndev/llm_interview_note) 的 10 个分类，检查目录是否覆盖常见面试主题；分类只用于查漏，不代表考察频率。Agent 岗位问题另见 AG09 中的 Hello-Agents 面试题。

| 面试笔记分类 | 对应模块 |
| --- | --- |
| 大语言模型基础：分词、词向量、语言模型 | AI05、AI07 |
| 大语言模型架构：注意力、归一化、位置编码、MoE | AI04、AI06 |
| 训练数据集 | AI07 |
| 分布式训练 | AI07 进阶 |
| 有监督微调：SFT、LoRA 与参数高效微调 | AI09 |
| 推理：解码、KV Cache、量化与推理框架 | AI10 |
| 强化学习：RL 基础、RLHF、DPO、GRPO | AI08、AI09 |
| 检索增强 RAG | AI12、AG04 |
| 大语言模型评估：评测与幻觉 | AI11 |
| 大语言模型应用：Agent 与项目 | AI14、AG00–AG09 |

## 资料分工 {#sources}

以下资料在 **2026-09-21 至 2026-09-24** 核对过目录、可访问性和部分样章；不代表逐章审校，也不代表其中代码都能直接运行。

| 资料 | 用途 | 使用边界 |
| --- | --- | --- |
| [动手学深度学习](https://zh.d2l.ai/) | AI00–AI06 的基础主读 | 按主题选读，不必通读 |
| [Happy-LLM](https://github.com/datawhalechina/happy-llm) | AI05–AI09 的主读与动手实现 | 需要 Python 与深度学习基础；复现前核对环境 |
| [EasyRL](https://datawhalechina.github.io/easy-rl/) | AI08 强化学习基础 | 学到理解 PPO 所需即可 |
| [《大语言模型》](https://llmbook-zh.github.io/) | AI07、AI09、AI10 的理论补充 | 面向有深度学习基础的读者；官网注明未经许可不得二次传播 |
| [Base-LLM](https://github.com/datawhalechina/base-llm) | 文本处理、生成、量化、部署、安全与多模态补充 | 有 Python/PyTorch 先修，部分专题仍在建设 |
| [Hello-Agents](https://github.com/datawhalechina/hello-agents) | Agent 并行线主读 | 模型服务、框架与协议按版本核对 |
| [LLM Universe](https://datawhalechina.github.io/llm-universe/) | RAG 入门项目 | 进阶部分尚未全部完成 |
| 官方文档：[Python](https://docs.python.org/zh-cn/3/tutorial/index.html)、[PyTorch](https://docs.pytorch.org/tutorials/beginner/basics/intro.html)、[scikit-learn](https://scikit-learn.org/stable/user_guide.html)、[Hugging Face](https://huggingface.co/learn/llm-course/zh-CN/chapter1/1)、[TRL](https://github.com/huggingface/trl/blob/main/docs/source/sft_trainer.md)、[MCP](https://modelcontextprotocol.io/specification/latest) | 核对 API、训练配置与协议行为 | 以对应版本为准 |
| [LLM Interview Note](https://github.com/wdndev/llm_interview_note) 与 [Hello-Agents 面试题](https://github.com/datawhalechina/hello-agents/blob/main/Extra-Chapter/Extra01-%E9%9D%A2%E8%AF%95%E9%97%AE%E9%A2%98%E6%80%BB%E7%BB%93.md) | 查漏补缺与面试自测 | 不作唯一事实来源，部分表述需要澄清 |

此前找到的飞书目录可作补充导航，但部分子页和附件全文尚未核验，不作为核心课程的来源。微信图文用于对照学习阶段、发现遗漏，不约束全书排序；未取得标题所称的完整 48 页资料。

Happy-LLM、Base-LLM、Hello-Agents、EasyRL 标注 CC BY-NC-SA 4.0，其他资料按各自许可处理。正文独立组织讲解与例子并注明来源，不整篇转载，也不改按 MIT 授权。

## 待补资料 {#gaps}

**只按章节补证据，不扩大资料收藏量。**本次已补齐 Python、PyTorch、传统机器学习、强化学习基础和大模型理论的主读或补充资料；以下仍是缺口。

| 对应范围 | 待补内容 | 时机 |
| --- | --- | --- |
| AI02 进阶 | 最大似然、KL 散度与 SVD 的合适讲解 | 写到对应小节前 |
| AI03 进阶 | 决策树、SVM、聚类与降维的中文讲解 | 写到对应小节前 |
| AI06 进阶 | RoPE、GQA、MLA、MoE 与长上下文的原论文 | 基础章节稳定后 |
| AI07、AI09 | Scaling Laws、RLHF、DPO、GRPO 与推理模型的原论文或技术报告 | 写到对应小节前 |
| AI10 | 推理引擎官方文档与可复现的测量方法 | 选定引擎后 |
| AI11、AG07 | 红队测试、生产评测与安全治理资料 | 写评测章节前 |
| AI13 进阶 | 语音、视频与扩散模型资料 | 进入多模态前 |
| AG05 进阶 | A2A 与 Agent Skills 的官方规范及版本 | 写协议章节前 |
| 所有实践 | 硬件、依赖、费用、数据许可与真实运行记录 | 标记“已验证”之前 |

## 下一步编写顺序 {#writing-order}

1. **先确认本目录。**确认模块、阶段与资料分工后再写正文，不批量生成。
2. **首篇写 AI00，拆成五个小节：**AI、机器学习与深度学习的关系；常见任务类型；数据、模型与参数；训练、验证、测试与推理；大模型、RAG 与 Agent 的位置。第一节 [AI00.1]({{ '/chapters/ai00-1/' | relative_url }}) 已试写，待审阅。
3. **AI00 完成后写 AG00，**再按阶段 1 推进 AI01、AI02 与 AG01。
4. **每篇统一结构：**核心问题、先修、讲解、例子、易错点、自测、来源与核验范围。
5. **写完并审阅一篇，再写下一篇；**目录中其余模块保持“待写”。

所有章节均为“待写”。面试题随章节积累，实践随先修能力递进；具体写作与实验仍需按各节的验收目标推进。