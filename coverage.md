---
layout: default
title: 原文覆盖与资料核验
description: 原微信文章可见知识点、手册模块、待核问题和补充内容的对应关系。
permalink: /coverage/
last_verified: "2026-09-20"
---

# 原文覆盖与资料核验

本页记录“看到了什么、准备写到哪里、哪些还没有核实”。**识别到知识点，不等于已验证原文说法，也不等于已经完成对应章节。**

## 来源与可见范围

- 原文：[《这48页纸背下来，你就是AI大模型顶级天花板》][wechat]，公众号“AI大模型师兄”。
- 核验日期：2026-09-20。使用实际浏览器读取图片，不能仅凭文本抓取到的标题判断正文完整性。
- 可确认的内容：三张学习路线图，涉及阶段一至阶段五的 RAG 开头；另有“LLM 概念”和“分词”两张知识库截图。
- 未取得：标题所称的完整 48 页原始资料、连续页码及完整目录。Agent 在阶段五标题中出现，但可见路线图没有展开其明细。
- 本仓库不镜像原文图片、不复制整套资料，也不以来源文章的宣传性标题作为学习效果保证。

为便于复核，将可见图片按内容编号，不使用未经确认的 PDF 页码：

| 编号 | 可见位置 | 证据链接 |
| --- | --- | --- |
| R1 | 前置知识、核心原理 | [路线图一][route-one] |
| R2 | 预训练 | [路线图二][route-two] |
| R3 | 后训练、应用开发标题与 RAG 索引开头 | [路线图三][route-three] |
| S1 | LLM 概念、模型例子、Prefix LM 与 causal LM | [资料库截图一][sample-one] |
| S2 | 分词概述、中文分词难点 | [资料库截图二][sample-two] |

图片链接为当次公开页面的来源证据，可能被上游更换或限制访问。没有把它们当作本站正文图片依赖。

## 原文知识点映射

下表按可见内容归并条目，同一行可以包含相互关联的子知识点。对应位置均链接到[完整目录]({{ '/roadmap/' | relative_url }})，不是尚未编写的章节。

**共同状态：**以下 WX 条目均已登记目录，专题正文待编写、技术结论待逐章核验。第一章只提供概念入口，不计作这些专题已经完成。

| 编号 | 来源 | 可见知识点 | 手册位置 |
| --- | --- | --- | --- |
| WX01 | R1 | Python 编程 | [M01]({{ '/roadmap/' | relative_url }}#m01) |
| WX02 | R1 | PyTorch | [M01]({{ '/roadmap/' | relative_url }}#m01) |
| WX03 | R1 | 线性代数、概率论、微积分、梯度与矩阵运算 | [M01]({{ '/roadmap/' | relative_url }}#m01) |
| WX04 | R1 | CNN、卷积核、特征提取、感受野、池化 | [M03]({{ '/roadmap/' | relative_url }}#m03) |
| WX05 | R1 | 神经元、隐藏层、残差、激活函数 | [M03]({{ '/roadmap/' | relative_url }}#m03) |
| WX06 | R1 | RNN、循环结构、时间步、GRU、LSTM | [M03]({{ '/roadmap/' | relative_url }}#m03) |
| WX07 | R1 | Self-attention、cross-attention、掩码注意力 | [M05]({{ '/roadmap/' | relative_url }}#m05) |
| WX08 | R1 | MHA、MQA、GQA | [M05]({{ '/roadmap/' | relative_url }}#m05) |
| WX09 | R1 | 位置表示、Embedding、FFN、残差连接 | [M04]({{ '/roadmap/' | relative_url }}#m04)、[M05]({{ '/roadmap/' | relative_url }}#m05) |
| WX10 | R1 | BatchNorm、LayerNorm、RMSNorm | [M03]({{ '/roadmap/' | relative_url }}#m03) |
| WX11 | R1 | Encoder-only/BERT、Decoder-only/GPT、Encoder-Decoder/T5 | [M05]({{ '/roadmap/' | relative_url }}#m05)、[M13]({{ '/roadmap/' | relative_url }}#m13) |
| WX12 | R2 | 数据清洗、去重、质量筛选、数据配比 | [M06]({{ '/roadmap/' | relative_url }}#m06) |
| WX13 | R2 | BPE、字节级 BPE、Unigram | [M04]({{ '/roadmap/' | relative_url }}#m04) |
| WX14 | R2 | 词表大小、特殊 token、合并效率、多语言支持 | [M04]({{ '/roadmap/' | relative_url }}#m04)、[M06]({{ '/roadmap/' | relative_url }}#m06) |
| WX15 | R2 | Tokenization 段落中的 Chunking | [M04]({{ '/roadmap/' | relative_url }}#m04)、[M11]({{ '/roadmap/' | relative_url }}#m11)，需区分术语 |
| WX16 | R2 | RoPE、GQA、RMSNorm、Pre-Norm | [M05]({{ '/roadmap/' | relative_url }}#m05) |
| WX17 | R2 | 数据并行、ZeRO 1/2/3、优化器状态、梯度、参数 | [M06]({{ '/roadmap/' | relative_url }}#m06) |
| WX18 | R2 | 张量并行 TP、流水线并行 PP、节点内/间通信 | [M06]({{ '/roadmap/' | relative_url }}#m06) |
| WX19 | R2 | FlashAttention-2/3、IO 感知计算优化 | [M06]({{ '/roadmap/' | relative_url }}#m06) |
| WX20 | R2 | Warmup、Cosine 衰减、梯度裁剪 | [M06]({{ '/roadmap/' | relative_url }}#m06) |
| WX21 | R2 | Loss spike、KL 散度、BF16/FP16、checkpoint | [M01]({{ '/roadmap/' | relative_url }}#m01)、[M06]({{ '/roadmap/' | relative_url }}#m06) |
| WX22 | R2 | Adam、AdamW | [M03]({{ '/roadmap/' | relative_url }}#m03)、[M06]({{ '/roadmap/' | relative_url }}#m06) |
| WX23 | R3 | SFT、指令数据、全量微调 | [M07]({{ '/roadmap/' | relative_url }}#m07) |
| WX24 | R3 | PEFT、LoRA、QLoRA | [M07]({{ '/roadmap/' | relative_url }}#m07) |
| WX25 | R3 | Adapter Tuning、P-Tuning、Prefix-Tuning | [M07]({{ '/roadmap/' | relative_url }}#m07) |
| WX26 | R3 | 奖励模型、RLHF、PPO | [M07]({{ '/roadmap/' | relative_url }}#m07) |
| WX27 | R3 | DPO、GRPO、GSPO | [M07]({{ '/roadmap/' | relative_url }}#m07) |
| WX28 | R3 | RAG、数据索引 | [M11]({{ '/roadmap/' | relative_url }}#m11) |
| WX29 | R3 | 语义切分、重叠切分 | [M11]({{ '/roadmap/' | relative_url }}#m11) |
| WX30 | R3 | Embedding、Milvus、Faiss、Chroma | [M11]({{ '/roadmap/' | relative_url }}#m11) |
| WX31 | R3 | Agent，仅标题可见 | [M12]({{ '/roadmap/' | relative_url }}#m12)，明细为本手册补充 |
| WX32 | S1 | GPT、BERT、XLNet、RoBERTa、T5 等模型例子 | [M05]({{ '/roadmap/' | relative_url }}#m05)、[M13]({{ '/roadmap/' | relative_url }}#m13) |
| WX33 | S1 | Prefix LM 与 causal LM、attention mask、UniLM/GLM 例子 | [M05]({{ '/roadmap/' | relative_url }}#m05)，按具体版本核对 |
| WX34 | S2 | 中文分词、分词标准、组合/交集/真歧义、未登录词 | [M04]({{ '/roadmap/' | relative_url }}#m04) |

## 明确补充的范围

这些内容来自本手册的完整性要求，不冒充原文已有章节。

| 编号 | 补充范围 | 位置与状态 |
| --- | --- | --- |
| EX01 | AI/ML/DL/LLM、模型与系统、训练与推理的概念关系 | [第一章]({{ '/chapters/ai-foundations/' | relative_url }})已成稿 |
| EX02 | 机器学习范式、泛化、数据划分、损失和基本指标 | M02，规划中 |
| EX03 | NLP 表示、训练目标及 Transformer 数据流的完整解释 | M04、M05，规划中 |
| EX04 | 推理、采样、缓存、量化、服务、成本与性能 | M08，规划中 |
| EX05 | 评测、可靠性、安全、数据和模型许可 | M09，规划中 |
| EX06 | 多模态理解与生成 | M10，规划中 |
| EX07 | RAG 检索、重排、证据、权限与端到端评测 | M11，规划中 |
| EX08 | Agent 控制循环、工具、状态、记忆、协议、恢复与评测 | M12，规划中 |
| EX09 | MoE/MLA/MTP、蒸馏、模型案例、实验与面试追问 | M05、M07、M13，规划中 |

## 需要特别核验的说法

1. **分类边界：**Embedding 不是位置编码的同义词；分词和 RAG 的文档切块需要分别讲解。有关实现细节在 M04/M05/M11 中查证。
2. **绝对化比较：**全量微调、RMSNorm、DPO 等方法的效果与稳定性，需要说明任务、模型、数据、预算和评估条件，不直接沿用“最好”之类判断。
3. **模型开放程度：**可用 API、公开代码、开放权重与开放训练数据不是同一回事。S1 的模型分类需要按具体版本与许可证重新核对。
4. **层面混用：**KL 散度、checkpoint、优化器、网络结构和训练精度分别属于不同概念层次，不能因为同列在一张图中就混为一类。
5. **原始资料缺口：**没有完整 48 页时，不计算“原资料完成百分比”；获得全文后先更新映射，再补内容。

## 核验规则

- 原文用于定位问题，不作为所有技术判断的最终依据。
- 论文优先记录具体版本，滚动更新的文档记录核验日期。
- 一手材料无法支持的说法保持“待核验”，不借二手文章互相引用制造确定性。
- 原创教学示例与真实运行结果分开；没有运行的代码明确标注。
- 状态顺序为：已登记 → 已成稿 → 内容与验证完成。课程外部资料可访问不代表本站章节已完成。

[wechat]: https://mp.weixin.qq.com/s/6MjoiitEncAMyDLgqzrkug
[route-one]: https://mmbiz.qpic.cn/mmbiz_jpg/YQrKuXib70ibSBia69kYhFNWFTxwmQj7jM9lqR56QC9nQcqsxueWuPtVEU7L2P6BqnV1ALlSB8QmibnIlEUq3gHOfiaPXbccyb87a3z5CBVvxlXM/0?from=appmsg&wxfrom=12&wx_fmt=jpg&tp=webp&watermark=1
[route-two]: https://mmbiz.qpic.cn/sz_mmbiz_jpg/YQrKuXib70ibTembP5wbrMJSxdXTL1lv5uUvWQzPRvXQ7nsY8la71koDLBicAuxqs6l5SfaWycpSbuoZC9MlG1WbzcCRGOTQKQsBTbTVD0vJYc/0?from=appmsg&wxfrom=12&wx_fmt=jpg&tp=webp&watermark=1
[route-three]: https://mmbiz.qpic.cn/mmbiz_jpg/YQrKuXib70ibQ0sYnHzPjGjJcZjkPJAicm4upeCt5Bo5j1NCCN9bFNHjh9XU1Kknvz0HnXms8CGicxKvpu4RHnAY94K4icibMgHKtcZULYmmGDy8g/0?from=appmsg&wxfrom=12&wx_fmt=jpg&tp=webp&watermark=1
[sample-one]: https://mmbiz.qpic.cn/sz_mmbiz_jpg/YQrKuXib70ibRkicY4OGhVKXUMaDTNbC5YgojVUUEzSSDJIbrJpzR6KLaOhEZDEibpCMEDAXny3Z9owibV2pjSN30gVWaqCdjxROOYpZpicMV3HmI/0?from=appmsg&wxfrom=12&wx_fmt=jpg&tp=webp&watermark=1
[sample-two]: https://mmbiz.qpic.cn/mmbiz_jpg/YQrKuXib70ibQNjI13zBa28v1HHYee8oPntXUTYNh9sS2uxmDicbFBGfoJ7sokEZviantPS34qSsswjqEgicKxiatC9QBdXqUxOgALm4nWwWTribjc/0?from=appmsg&wxfrom=12&wx_fmt=jpg&tp=webp&watermark=1