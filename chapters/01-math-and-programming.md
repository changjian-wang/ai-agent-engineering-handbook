---
layout: default
title: 前置知识：Python、PyTorch 与数学基础
description: 按原文第一阶段整理 Python、PyTorch、线性代数、概率论和微积分，补充必要示例与面试问答。
permalink: /chapters/math-and-programming/
chapter: M01
math: true
last_verified: "2026-09-21"
---

# 前置知识：Python、PyTorch 与数学基础

**原文对应：**[微信路线图][wechat]的第一阶段，依次列出 Python、PyTorch，以及线性代数、概率论、微积分。本章将这五项展开为学习笔记；NumPy 对照、信息论及实验代码是为理解原理增加的补充，不冒充原文逐页内容。

## 1. 前置知识需要掌握什么 {#scope}

| 原文条目 | 要掌握的具体内容 | 在后续大模型知识中的用途 |
| --- | --- | --- |
| Python | 数据结构、循环、函数、类、文件与环境 | 读懂数据处理和训练代码 |
| PyTorch | Tensor、形状、设备、网络模块、自动求导 | 表达模型计算并训练参数 |
| 线性代数 | 向量、矩阵、内积、矩阵乘法 | 理解 Embedding、线性层和注意力计算 |
| 概率论 | 概率分布、条件概率、期望与方差 | 理解词元预测、采样与结果不确定性 |
| 微积分 | 导数、偏导数、梯度和链式法则 | 理解损失如何用于更新参数 |

下面先解释编程工具，再分别整理数学概念。**Tensor 是数据的表示形式，线性代数解释对它做什么运算，微积分解释怎样学习参数。**三者不要混成一个概念。

## 2. Python 编程基础 {#python}

### 2.1 Python 在大模型开发中做什么？

Python 通常负责组织数据处理、调用数值库、定义模型和安排训练流程。大量张量运算由底层库执行，并不是 Python 循环逐个完成所有乘法。

先掌握下表内容，再进入框架代码。[Python 官方教程][python]

| 知识点 | 含义 | 典型用途 |
| --- | --- | --- |
| 变量与类型 | 给数据命名，区分数值、字符串等对象 | 保存路径、学习率、文本 |
| `list`、`tuple`、`dict` | 有序可变列表、元组、键值映射 | 样本集合、形状、配置 |
| `if`、`for` | 按条件分支、遍历数据 | 过滤样本、处理批次 |
| 函数 | 把一项处理封装为可调用的步骤 | 清洗文本、计算指标 |
| 类 | 把对象的状态与方法组织起来 | 表达数据集或网络模块 |
| 异常处理 | 在输入或运行条件不满足时报告错误 | 发现坏数据，不伪造成功结果 |

### 2.2 怎样读一段简单的数据处理代码？

下面只做去除首尾空白、跳过空文本，**不是 tokenizer，也不是完整训练语料清洗器**：

```python
def clean_texts(texts):
    cleaned = []
    for text in texts:
        stripped = text.strip()
        if stripped:
            cleaned.append(stripped)
    return cleaned

samples = [" 学习语言模型 ", "", "认识注意力"]
print(clean_texts(samples))
```

函数接收一个字符串列表；循环取出文本；`strip()` 去除首尾空白；非空内容加入结果。输出应为 `['学习语言模型', '认识注意力']`。先明确每行处理什么数据，再讨论性能或复杂语法。

### 2.3 类、迭代器和虚拟环境为什么重要？

类的实例可以保存状态，方法通过 `self` 操作该实例。PyTorch 用 `nn.Module` 组织网络，但“Python 类”本身并不意味着它就是神经网络。

迭代器按次提供数据，生成器可用 `yield` 按需产生结果；同一个迭代器耗尽后不自动重置。配套脚本保留分批读取的例子，可在掌握普通循环后查阅，不作为本章开头的语法门槛。

虚拟环境把本项目的包与其他项目隔离。安装包与运行脚本要使用同一个解释器；`python -m pip` 比无法确定归属的 `pip` 更明确。环境创建及实验命令放在[配套实验](#lab)。

## 3. PyTorch 基础 {#tensors}

### 3.1 PyTorch 和 NumPy 有什么区别？

NumPy 提供 CPU 数组与数值运算。PyTorch 提供张量计算、自动求导、网络模块和优化器，并支持相应的加速设备。它是深度学习框架，不是某个预训练模型；安装 PyTorch 不等于下载了大模型。[PyTorch 张量教程][torch-tensors]

### 3.2 Tensor 是什么？

在这里，Tensor 是组织数值数据的多维数组。读代码时先看四个属性：`shape` 是每个轴多长，`dtype` 是元素类型，`device` 是所在设备，`requires_grad` 表示是否需要记录用于求导的相关计算。

| 对象 | 示例形状 | 含义 |
| --- | --- | --- |
| 标量 | `()` | 一个数，例如归约后的损失 |
| 向量 | `(3,)` | 一个轴，含三个元素 |
| 矩阵 | `(2, 3)` | 两个轴，例如两条样本、每条三个特征 |
| 序列批次 | `(batch, tokens, hidden)` | 三个轴，其语义由模型约定 |

例如两条已经编号的文本序列，可以组成形状为 `(2, 3)` 的张量。下面编号是构造的输入示意，本例单独约定 `0` 为 padding；它们不是某个真实 tokenizer 的输出：

```python
import torch

token_ids = torch.tensor([[11, 12, 0], [21, 22, 23]], dtype=torch.long)
print(tuple(token_ids.shape))
print(token_ids.numel())
print(token_ids.ne(0).tolist())
```

形状应为 `(2, 3)`，元素数为 `6`，非填充位置为 `[[True, True, False], [True, True, True]]`。整数编号用于索引；后续查得的 Embedding 才是参与网络运算的浮点向量。

### 3.3 训练代码中的对象分别负责什么？

| 对象或操作 | 职责 |
| --- | --- |
| `Dataset` | 描述怎样取得一条样本 |
| `DataLoader` | 按配置组织批次、采样和加载 |
| `nn.Module` | 组织网络层、参数及前向计算 |
| Loss，损失 | 衡量输出与训练目标之间的差异 |
| `loss.backward()` | 沿已记录的计算图求梯度 |
| `optimizer.step()` | 根据梯度和优化算法更新参数 |
| `optimizer.zero_grad()` | 重置累积梯度，按训练策略决定何时调用 |

**Batch** 是一次组织起来处理的一组样本；**epoch** 通常指遍历训练数据一轮；一次优化器参数更新是一个训练 step。有梯度累加时，不一定每个批次都更新参数。[PyTorch 优化教程][optimization]

### 3.4 广播是什么？为什么要检查形状？

广播允许某些不同形状的数组进行逐元素运算。按 [NumPy 规则][broadcasting]，从末轴对齐：两边长度相同，或者其中一边为 1，才可以广播；缺失的前导轴视为 1。

| 形状 | 结果 | 注意点 |
| --- | --- | --- |
| `(2, 3) + (3,)` | `(2, 3)` | 对每行加相同的三个数 |
| `(2, 3) + (2, 1)` | `(2, 3)` | 每行的一个数沿列展开 |
| `(2, 3) + (2,)` | 报错 | 末轴 3 与 2 不兼容 |
| `(2, 1) - (2,)` | `(2, 2)` | 可能误把逐样本误差变成两两比较 |

广播不一定复制完整输入，但结果或中间数组仍可能很大。代码能运行，只能说明形状允许运算，不能证明业务含义正确。

`sum(dim=1)` 对二维张量的每行求和，`keepdim=True` 可保留长度为 1 的轴；`reshape` 改形状，二维矩阵的 `.T` 交换行列，二者不等价。切片及部分变形可能共享底层存储。[PyTorch 张量教程][torch-tensors]

## 4. 线性代数基础 {#linear-algebra}

### 4.1 向量、矩阵和矩阵乘法是什么？

向量是一组有顺序的数；矩阵把这些数组织成行列。**矩阵乘法不是对应位置相乘，而是左矩阵的一行与右矩阵的一列分别相乘，再求和。**线性层和注意力中的很多运算都建立在这个规则上。

先看一组仅用于解释计算的小矩阵：

```python
import numpy as np

features = np.array([[1.0, 2.0], [3.0, 4.0]], dtype=np.float64)
weights = np.array([[2.0], [-1.0]], dtype=np.float64)
predictions = features @ weights + 0.5
print(predictions.shape)
print(predictions.tolist())
```

第一行是 `1 × 2 + 2 × (-1) + 0.5 = 0.5`；第二行是 `3 × 2 + 4 × (-1) + 0.5 = 2.5`。结果为 `(2, 1)`，每一行是一条样本的一个输出。

`@` 是这里的矩阵乘法，`*` 则是逐元素乘法。二者规则不同，不能互换。

### 4.2 怎样从维数判断运算？

当每行是一条样本时，线性计算可以写成：

$$
X \in \mathbb{R}^{B\times D},\quad
W \in \mathbb{R}^{D\times O},\quad
Y=XW+b \in \mathbb{R}^{B\times O}.
$$

这里 $B$ 是批大小，$D$ 是输入特征数，$O$ 是输出维数，$b$ 含 $O$ 个偏置。矩阵乘法要求内部维数相同；输出保留外侧维数。

数学记号的 `W` 是 `(D, O)`；PyTorch `nn.Linear` 的权重存储为 `(out_features, in_features)`，其调用内部处理相应转置。读公式与读 API 时都要核对各自约定。

### 4.3 内积、范数和相似度有什么关系？

对两个同维实向量，内积将对应元素相乘再求和：

$$
\langle u,v\rangle=\sum_{i=1}^{D}u_i v_i,\qquad
\lVert u\rVert_2=\sqrt{\sum_{i=1}^{D}u_i^2}.
$$

例如 $u=(3,4)$ 的二范数为 5，一范数为 $\lvert3\rvert+\lvert4\rvert=7$。范数描述大小，不是向量有几个元素。

非零向量的余弦相似度用内积除以两个向量的二范数之积，偏重比较方向。它在向量检索中有用，但“数值方向相近”是否对应任务所需的语义，要由表示模型与评测决定。零向量的余弦没有这个定义。

<details id="linear-extensions" markdown="1">
<summary>进阶补充：投影、矩阵秩与 SVD</summary>

以下用于后续理解低秩方法，不是原文前置知识图中已经展开的细节。

### 投影不是任意矩阵变换

把实向量 $u$ 正交投影到非零方向 $v$ 上：

$$
\operatorname{proj}_v(u)=\frac{u^\top v}{v^\top v}v.
$$

公式来自让剩余部分与 $v$ 正交：若投影为 $av$，令 $(u-av)^\top v=0$，就得到系数 $a$。分母为零时不能使用。

取 $u=(3,4)$、$v=(1,0)$，投影为 $(3,0)$，残差为 $(0,4)$。这与“用任意权重矩阵把特征映射到另一维度”有区别；工程文章中的“投影层”经常泛指线性映射，不一定是数学上的正交投影。

### 秩与 SVD 近似

矩阵秩描述线性独立方向的数量。低秩近似试图用较少方向保留矩阵的主要结构，不等于把矩阵元素简单截断或把文件压缩。

对实矩阵，奇异值分解可写作 $A=U\Sigma V^\top$。奇异值按从大到小排列，保留前 $r$ 项可以构造截断近似。[NumPy SVD 文档][svd]给出了返回值和重建方法。

本章取 $A=\operatorname{diag}(3,1)$，保留第一项得到 $A_1=\operatorname{diag}(3,0)$，误差的 Frobenius 范数为 1。Frobenius 范数是所有矩阵元素平方和的平方根。

一般地，用 $D\times r$ 与 $r\times O$ 两个因子代替 $D\times O$ 矩阵，参数数目从 $DO$ 变为 $r(D+O)$，但只有在后者更小时才节省参数，还必须评估近似误差与实际计算成本。

这里为理解低秩方法做准备，**并没有实现 LoRA，也没有证明模型权重可以无损降秩**。LoRA 如何参数化权重更新将在 M07 单独讲解。

</details>

## 5. 微积分与梯度下降 {#calculus}

### 5.1 为什么训练要用导数？

训练需要知道“改变某个参数，会怎样影响损失”。损失是对预测偏差的数值衡量；求导给出它对参数的局部变化率，优化器再决定如何更新参数。

导数是函数对一个输入的局部变化率；偏导数是在其他输入保持不变时，对某个输入的变化率。对可微的标量函数，把各参数的偏导数排起来，就得到梯度。[D2L 微积分][calculus]

例如 $f(a,b)=a^2+3b$ 的梯度是 $(2a,3)$。不要把不同参数的偏导数直接相加，丢掉梯度的方向信息。

### 5.2 链式法则怎样连接预测和损失？

链式法则的意思是：若参数先影响一个中间结果，中间结果再影响损失，就沿这条依赖关系把局部导数相乘；存在多条路径时，把路径贡献相加。

设输入为 3、目标为 5，模型参数为权重 $w$ 与偏置 $b$：

$$
\hat y=3w+b,\qquad L=(\hat y-5)^2.
$$

用链式法则分别计算：

$$
\frac{\partial L}{\partial w}=2(3w+b-5)\cdot3,\qquad
\frac{\partial L}{\partial b}=2(3w+b-5).
$$

当 $w=2$、$b=1$ 时，预测为 7，损失为 4，两个梯度分别为 **12、4**。这是一条样本的平方损失；若改成半平方损失或批次平均，梯度中的系数也会相应变化。

### 5.3 求梯度为什么不等于更新参数？

梯度下降使用学习率 $\eta$ 更新参数：

$$
\theta_{\mathrm{new}}=\theta-\eta\nabla_\theta L.
$$

取 $\eta=0.01$，上述参数变成 $w=1.88$、$b=0.96$，新损失为 2.56。相反，若取 $\eta=0.2$，更新会越过最优位置，使这个例子的损失升到 36；不能宣称沿负梯度方向走任意大步都降低损失。

在非零梯度处，对于足够小的步长，负梯度是可微函数的局部下降方向。梯度为零也不保证全局最小值，可能是局部极值或鞍点。更一般的优化方法和训练行为会在 M02/M03 展开。

### 5.4 PyTorch 如何计算梯度？

[PyTorch autograd][autograd]在前向计算时记录运算关系，再通过链式法则计算导数，不是靠逐个扰动参数估算梯度。

```python
import torch

weight = torch.tensor(2.0, dtype=torch.float64, device="cpu", requires_grad=True)
bias = torch.tensor(1.0, dtype=torch.float64, device="cpu", requires_grad=True)
loss = (3.0 * weight + bias - 5.0).square()
loss.backward()
print(weight.grad.item(), bias.grad.item())

with torch.no_grad():
    weight -= 0.01 * weight.grad
    bias -= 0.01 * bias.grad
    print((3.0 * weight + bias - 5.0).square().item())
```

`backward()` 负责计算并累加梯度，不会自动完成参数更新。重复训练时应按计划重置梯度，通常用 `optimizer.zero_grad()`；有意的梯度累加是另一种训练策略。

配套测试还重新执行两次平方运算的前向和反向，展示同一个参数的梯度会从 4 累加到 8，再通过清空梯度恢复为 4。这里每次创建新计算图，不需要反复保留已经反传过的图。

<details id="gradient-check" markdown="1">
<summary>进阶补充：怎样用有限差分独立检查梯度？</summary>

有限差分通过邻近函数值估计导数，本章实验使用中心差分：

$$
\frac{\partial L}{\partial w}\approx
\frac{L(w+\varepsilon,b)-L(w-\varepsilon,b)}{2\varepsilon}.
$$

实验取 $\varepsilon=10^{-6}$，得到约 12，与手算和自动求导相符。这种对照适合检查小型计算；步长过大有近似误差，过小又可能受浮点消减影响，因此不采用浮点数的逐位相等作为通用验收标准。

</details>

## 6. 概率论基础 {#probability}

### 6.1 概率分布、样本有什么区别？

离散分布给每个可能取值分配非负概率，总和为 1。随机变量把随机结果映射到数值；实际观察到的一组数是样本，不是整个分布。[D2L 概率与统计][probability]

在语言模型中，一个位置可以对词表中的候选 token 给出分布。概率高表示模型在当前条件下更偏向该候选，不等于模型保证该内容是真实的。

Bernoulli 分布描述 0/1 两种结果；Categorical 分布描述多个离散候选中选择一个；高斯分布是连续分布，密度不是单个精确值发生的概率。

### 6.2 条件概率与贝叶斯公式

对事件 $A$、$B$，当 $P(B)>0$ 时：

$$
P(A\mid B)=\frac{P(A\cap B)}{P(B)}
=\frac{P(B\mid A)P(A)}{P(B)}.
$$

第二个等式通常在 $P(A)>0$、$P(B)>0$ 时按上述条件概率定义使用。$P(A\mid B)$ 与 $P(B\mid A)$ 一般不同，不能交换。

与语言模型的直接联系是：预测目标 token 时，需要的是“给定当前上下文，这个 token 出现的概率”，而不是它在所有文本中的出现频率。条件改变，预测分布也可能改变。

独立性也必须有依据：只有独立事件才满足 $P(A\cap B)=P(A)P(B)$。无条件独立与给定某个条件后的独立不同，不能因为有两条证据就直接相乘。

### 6.3 期望、方差和样本估计

对有限离散取值，期望与方差为：

$$
\mathbb{E}[X]=\sum_x xP(X=x),\qquad
\operatorname{Var}(X)=\mathbb{E}[(X-\mathbb{E}[X])^2].
$$

Bernoulli 随机变量的期望是 $p$，方差是 $p(1-p)$。期望不一定是可能出现的单次结果，例如 $p=0.3$ 时，期望为 0.3，但每次取值仍然只能是 0 或 1。

在独立同分布、具有有限方差的条件下，样本均值的方差随样本数按 $1/n$ 缩小，标准误差按 $1/\sqrt n$ 缩小。这不意味着每多看一条样本，当前估计都会更接近真值；更多同样有偏的数据也不会自动消除采样偏差。

配套实验用固定种子抽取 Bernoulli 样本，比较样本均值和方差与理论值。有限样本结果不是理论概率的替代定义，详细记录见[配套实验](#lab)。

`np.var` 默认除以 $n$。若要用独立同分布样本估计总体方差，常采用除以 $n-1$ 的样本方差，对应 `ddof=1`，且要求样本数大于 1。总体分布、样本统计量与估计方法应分别说明。

## 7. 补充：熵、交叉熵与 KL {#information}

原文在后面的训练路线中提到 KL。本节保留其数学基础，便于学习训练目标时回查，**不要求先掌握它才能开始看 CNN、RNN 和 Transformer**。

<details id="information-reference" markdown="1">
<summary>展开定义、公式与框架约定</summary>

这一节讨论同一有限类别集合上的离散概率分布，使用自然对数，因此单位是 **nat**。若改用以 2 为底的对数，单位为 bit。[SciPy 熵文档][entropy]给出了相同的定义关系；本实验不依赖 SciPy。

### 7.1 三个量分别回答什么

设 $p$ 为参考分布，$q$ 为用于比较或预测的分布：

$$
H(p)=-\sum_i p_i\ln p_i.
$$

熵衡量分布本身的不确定性。两个等概率结果的熵大于一个结果几乎必然发生时的熵；对 $K$ 个结果，均匀分布达到最大熵 $\ln K$。

$$
H(p,q)=-\sum_i p_i\ln q_i.
$$

交叉熵是在结果按 $p$ 出现时，使用 $q$ 描述它们的平均负对数概率。它不仅取决于参考分布，也取决于预测分布。

$$
D_{\mathrm{KL}}(p\Vert q)=\sum_i p_i\ln\frac{p_i}{q_i},\qquad
H(p,q)=H(p)+D_{\mathrm{KL}}(p\Vert q).
$$

KL 衡量分布差异，非负但一般不对称，也不满足距离必须具有的全部性质。当固定 $p$，且相关量有限时，最小化交叉熵与最小化这个方向的 KL 有相同的最优目标；不能忽略“固定参考分布”这一条件。

### 7.2 零概率不能随意跳过

- $p_i=0$ 的项按极限约定贡献为零，包括熵中的 $0\ln0$。
- 若存在 $p_i>0$ 而 $q_i=0$，交叉熵与该方向 KL 为正无穷，而不是零。
- 若将概率裁剪到很小的正数，可以避免无穷值，但已经改变了计算；必须交代阈值和目的。
- 非法概率、NaN、负数、总和不为 1，不应无声地当成有效分布。

本章教学函数显式拒绝非法分布，并在参考分布有质量、候选分布却为零的位置返回无穷。它没有把所有值简单加一个小常数，也不提供通用的生产级统计 API。

取 $p=(0.75,0.25)$、$q=(0.5,0.5)$，实测结果为：

| 量 | 数值，nat |
| --- | --- |
| 参考分布熵 | 0.5623351446 |
| 交叉熵 | 0.6931471806 |
| KL | 0.1308120359 |

三者满足交叉熵等于熵加 KL。交换两个分布，KL 通常会改变；测试也检查了这一点。

### 7.3 数学公式不等于 API 入参

分类中，若目标是 one-hot 分布，单样本交叉熵简化为正确类别概率的负对数。但 [PyTorch 2.7 的 `CrossEntropyLoss`][cross-entropy]接收的是**未归一化 logits**，常见硬标签场景的目标是 `torch.long` 类别索引；不要先做一次 softmax 再当作 logits 传入。

它也支持满足条件的浮点软标签，因此“目标永远只能是整数”同样不准确。具体形状、标签平滑、权重和归约规则应按相应版本文档核对。

理论概率为零时的无限损失，与浮点计算中对 logits 使用稳定的 log-softmax，是不同层面的事。自己先 `exp` 再 `log`，可能引入不必要的溢出或下溢。

</details>

## 8. 补充：代码与实验习惯 {#engineering}

<details id="engineering-reference" markdown="1">
<summary>展开文件、JSON、接口和随机种子的注意点</summary>

### 8.1 文件与 JSON

用 `with open(..., encoding="utf-8")` 管理文本文件；JSON 使用 `json.load`、`json.loads` 等解析器，不用 `eval`。解析成功仅证明格式可读，不证明字段、类型、取值、维度和业务语义正确。

配套实验先将结果组织为字典，再由 `json.dumps(..., allow_nan=False)` 序列化，测试会反向解析并比较。默认报告只包含有限数值，零概率的无限值只在边界测试中单独验证，避免输出非标准 JSON 的 `Infinity`。

Tensor 或 NumPy 数组不能总是直接交给标准 JSON 编码器，应根据目的用 `.item()` 或 `.tolist()` 转成标量或列表。日志中应记录参数、版本和错误，不应记录真实密钥或未脱敏数据。

### 8.2 HTTP 的成功要分层理解

模型接口和数据服务常通过 HTTP 返回 JSON。需要分别检查：传输是否成功、状态码是否符合接口约定、内容类型与 JSON 是否可解析、字段是否符合 schema、业务结果是否有效。

`200` 不自动保证字段完整或模型答案正确。网络调用应有超时与错误处理；具有写入副作用的请求，重试前还要考虑幂等性。本章没有调用外部 HTTP 服务，也没有编造接口响应；这些原则将在应用章节通过真实接口练习展开。

### 8.3 种子是实验条件，不是万能保证

Python、NumPy 和 PyTorch 可以各自拥有随机数生成器，固定一个库的种子不会自动固定所有来源。实验使用局部 NumPy Generator 和 CPU PyTorch Generator，测试相同环境中重复创建相同种子是否重现结果。

[PyTorch 官方复现说明][reproducibility]明确指出，不保证跨版本、跨平台或 CPU/GPU 完全一致。除了种子，还应记录依赖、设备、数据版本、预处理、算子、并行设置和代码提交。

测试的目标是检查公式和程序约定，不是证明模型有泛化能力。这里的一次损失下降也不代表真实训练会持续收敛。

</details>

## 9. 运行配套实验 {#lab}

正文中的短代码用于解释单个概念；下面的完整脚本保留矩阵、梯度、概率和进阶补充的数值校验。所有输入都是标明用途的教学数据，不是模型效果评测，也不调用外部服务。

完整源码：[examples/m01/math_basics.py][lab-source]；直接依赖：[examples/m01/requirements.txt][lab-requirements]。脚本先运行单元测试，成功后打印带环境信息的 JSON；测试失败时以非零状态退出。

### Windows PowerShell

在仓库根目录，确认 `python` 对应已安装的 Python 3.11。若已有本仓库的 `.venv`，跳过创建步骤：

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install --index-url https://download.pytorch.org/whl/cpu -r examples/m01/requirements.txt
.\.venv\Scripts\python.exe examples/m01/math_basics.py
```

直接使用虚拟环境内解释器，不需要修改 PowerShell 执行策略来激活环境。安装时需要网络；依赖安装完成后，实验本身不联网、不下载模型、不读写业务文件。

### Linux

安装 Python 3.11 及 venv 支持后，在仓库根目录运行：

```sh
python3.11 -m venv .venv
.venv/bin/python -m pip install --index-url https://download.pytorch.org/whl/cpu -r examples/m01/requirements.txt
.venv/bin/python examples/m01/math_basics.py
```

这组安装参数面向 Windows/Linux 的 CPU 练习环境。其他系统或架构应按 PyTorch 官方安装说明选择 wheel；不宣称本章验证过所有平台。

### 验证记录

2026-09-21 在 **Windows、Python 3.11.9、NumPy 2.2.6、PyTorch 2.7.1+cpu** 环境运行，11 个测试全部通过。固定的是本实验直接依赖版本，不是“当前最新版”承诺，也不是对所有传递依赖的完整锁定。

| 检查 | 实际结果 |
| --- | --- |
| 矩阵乘法与偏置 | `[[0.5], [2.5]]`，形状 `(2, 1)` |
| 自动求导 | 权重梯度 `12.0`，偏置梯度 `4.0` |
| 中心差分 | `11.999999999900979`、`4.000000000559112` |
| 更新前后损失 | `4.0` → `2.5599999999999987` |
| 投影与秩一近似 | 投影 `[3.0, 0.0]`，Frobenius 误差 `1.0` |
| 贝叶斯后验 | `0.30769230769230776` |
| 随机样本统计 | 均值 `0.304`，默认样本数组方差 `0.211584` |
| 边界条件 | 非法形状/概率被拒绝，零概率约定、梯度累加与 JSON 往返通过 |

末尾的浮点尾数不应作为跨硬件逐位一致的承诺。测试采用明确容差，重复采样检查也仅比较同一运行环境中的两次计算。

## 10. 自测与参考答案 {#exercises}

先作答，再核对；遇到不确定的地方，指出缺少哪个条件，也是一种合格的回答。

| 问题 | 参考答案与理由 |
| --- | --- |
| `(4, 3) @ (3, 2)` 是什么形状？ | `(4, 2)`，内部维数 3 被求和 |
| `(4, 1) - (4,)` 为什么危险？ | 得到 `(4, 4)`，可能从逐样本比较变成两两比较 |
| 向量 `(3, 4)` 的元素数和二范数分别是什么？ | 2 和 5，维数与大小不同 |
| `reshape` 能替代矩阵转置吗？ | 通常不能，改变形状不等于交换轴与元素对应关系 |
| `backward()` 后参数为什么没变？ | 它计算梯度，更新参数是另外的步骤 |
| 两次新前向后反传，梯度为何翻倍？ | 未清零时 `.grad` 累加；不一定是求导错误 |
| 给定上下文的 token 概率等于该 token 的全局频率吗？ | 不等于，条件概率依赖上下文；不能把条件事件去掉 |
| 1,000 次采样的均值是 0.304，是否说明分布概率就是 0.304？ | 不是，这是对设定概率 0.3 的样本估计 |
| $H(p,q)=H(p)$ 能说明什么？ | 在定义和有限性条件成立时 KL 为零，两离散分布一致 |
| 参考类别概率非零、预测为零怎么办？ | 理论交叉熵和 KL 为无穷；数值平滑不能隐瞒其改变了计算 |
| 相同随机种子是否保证所有机器逐位一致？ | 不保证；版本、设备、算子和其他随机源都可能影响结果 |
| JSON 解析成功，是否代表输入可以直接进模型？ | 不代表，还应校验字段、数值、形状及语义 |

**实践验收：**先手算原梯度，再把实验中的学习率改成 0.2，预测新损失并观察原有断言报错；解释“测试失败是因为预期条件改变”，不要只为通过测试随意放宽容差。完成后恢复学习率 0.01。

## 11. 面试回答与追问 {#interview}

### 为什么做 AI 需要线性代数？

样本、特征和参数经常用向量与矩阵表示，线性层和注意力的大量计算依赖内积和矩阵乘法。线性代数让我们能解释运算意义、推断形状、估算存储，并讨论相似度与低秩近似，而不只是调用一个 API。

**追问：点积大就一定更相似吗？**不一定，还受向量长度影响；即便改用余弦，语义效果也依赖表示模型与任务。

### 自动求导、反向传播与梯度下降有什么区别？

自动求导是一类利用基本运算导数规则计算程序导数的方法；神经网络中的反向传播沿计算图应用链式法则得到梯度；梯度下降再使用梯度更新参数。PyTorch 的 `backward()` 不等于优化器的 `step()`。

**追问：为什么还做有限差分？**为了在小例子上独立检查梯度实现；它有数值误差且计算成本随检查参数增多，不适合代替大模型训练中的反向传播。

### 交叉熵和 KL 是一样的吗？

不是。交叉熵等于参考分布自身的熵加指定方向的 KL。只有参考分布固定且相关条件成立时，优化目标才相差一个常数；KL 一般不对称，不能随意交换输入。

**追问：代码里应该传概率还是 logits？**必须看 API。本文的教学函数接收概率分布，而 PyTorch `CrossEntropyLoss` 的模型输入是 logits。

### 固定 seed 后还有波动，先查什么？

先查是否固定了所有实际使用的随机源，再核对依赖、设备、数据顺序、多进程加载与非确定性算子。不要只重复设置同一个 seed，也不要用一次结果证明某个训练方案更好。

## 12. 小结与后续 {#next}

- 张量运算同时有数值和形状约定，广播错误尤其需要显式检查。
- 线性代数描述表示与变换，微积分解释参数变化对目标的影响。
- 概率分布、样本统计和模型预测是不同对象，不能混用。
- 熵、交叉熵和 KL 有明确的方向、单位与定义条件。
- 运行结果必须连同环境、数据来源、容差与限制一起记录。

按原文路线，前置知识之后是 CNN、RNN 和 Transformer 的[核心原理]({{ '/roadmap/' | relative_url }}#m03)。手册另保留 [M02 · 机器学习基础]({{ '/roadmap/' | relative_url }}#m02)补齐学习范式与泛化；这些后续专题仍在规划中。

## 一手资料与核验范围 {#references}

核验日期：2026-09-21。文中公式为标准定义的原创解释与推导，配套代码为独立教学实现；未复现任何大型模型训练或论文性能结论。

主题依据：[原微信文章][wechat]第一阶段；其图片列出学习范围，并未提供本章全部推导和代码。框架行为依据 [PyTorch 张量教程][torch-tensors]与[参数优化教程][optimization]核对。

1. [Python 官方教程][python]：函数、容器、类、迭代器、异常、文件、JSON 与虚拟环境。网页滚动更新；实验运行版本为 3.11.9。
2. [NumPy Broadcasting][broadcasting]：逐轴广播规则、形状与中间数组开销。
3. [Dive into Deep Learning，Linear Algebra][linear-algebra]：张量、内积、矩阵乘法、归约和范数。
4. [NumPy `linalg.svd`][svd]：奇异值、返回矩阵形状和重建方式。
5. [Dive into Deep Learning，Calculus][calculus]：导数、偏导、梯度与链式法则。
6. [PyTorch，Automatic Differentiation with autograd][autograd]：计算图、叶子参数、反向传播、梯度累加与禁用梯度记录。
7. [Dive into Deep Learning，Probability and Statistics][probability]：条件概率、贝叶斯公式、期望与方差。
8. [SciPy `stats.entropy`][entropy]：离散熵、交叉熵、KL 与对数单位；仅作定义参考，未安装 SciPy。
9. [PyTorch 2.7，CrossEntropyLoss][cross-entropy]：logits、目标类型、形状和归约约定。
10. [PyTorch 2.7，Reproducibility][reproducibility]：随机源控制与跨环境复现的边界。

[python]: https://docs.python.org/3/tutorial/
[broadcasting]: https://numpy.org/doc/stable/user/basics.broadcasting.html
[linear-algebra]: https://d2l.ai/chapter_preliminaries/linear-algebra.html
[svd]: https://numpy.org/doc/stable/reference/generated/numpy.linalg.svd.html
[calculus]: https://d2l.ai/chapter_preliminaries/calculus.html
[autograd]: https://docs.pytorch.org/tutorials/beginner/basics/autogradqs_tutorial.html
[probability]: https://d2l.ai/chapter_preliminaries/probability.html
[entropy]: https://docs.scipy.org/doc/scipy/reference/generated/scipy.stats.entropy.html
[cross-entropy]: https://docs.pytorch.org/docs/2.7/generated/torch.nn.CrossEntropyLoss.html
[reproducibility]: https://docs.pytorch.org/docs/2.7/notes/randomness.html
[lab-source]: https://github.com/changjian-wang/ai-agent-engineering-handbook/blob/main/examples/m01/math_basics.py
[lab-requirements]: https://github.com/changjian-wang/ai-agent-engineering-handbook/blob/main/examples/m01/requirements.txt
[wechat]: https://mp.weixin.qq.com/s/6MjoiitEncAMyDLgqzrkug
[torch-tensors]: https://docs.pytorch.org/tutorials/beginner/basics/tensorqs_tutorial.html
[optimization]: https://docs.pytorch.org/tutorials/beginner/basics/optimization_tutorial.html