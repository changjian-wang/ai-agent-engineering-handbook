---
layout: default
title: 数学与编程基础：从张量形状到自动求导
description: 用可运行的 CPU 实验理解 Python、矩阵运算、梯度、概率、交叉熵与 KL 散度。
permalink: /chapters/math-and-programming/
chapter: M01
math: true
last_verified: "2026-09-21"
---

# 数学与编程基础：从张量形状到自动求导

**先修要求：**已读 [M00 · AI 全景]({{ '/chapters/ai-foundations/' | relative_url }})，能理解变量、循环和基本代数。不需要 GPU、云资源或模型 API。

**本章目标：**看到一段模型代码时，能标出张量形状、区分参数和数据、手算简单梯度，并解释概率与损失函数中的量。它是后续学习所需的基础入门，不替代完整的 Python、线性代数或统计学课程。

**实验范围：**所有小矩阵、概率和标签均为本手册构造的数学教学例子，不是真实业务样本；数值结果来自本地运行，不是模型准确率或性能基准。

## 1. 这些基础分别解决什么问题 {#scope}

| 基础 | 本章要回答的问题 | 后续用途 |
| --- | --- | --- |
| Python | 数据怎样进入函数，错误如何暴露？ | 数据准备、训练脚本、实验测试 |
| 张量计算 | 每个轴代表什么，运算结果是什么形状？ | 批处理、Embedding、注意力 |
| 线性代数 | 向量和矩阵怎样组合、变换与近似？ | 线性层、相似度、低秩方法 |
| 微积分 | 改一个参数，损失会怎样变化？ | 反向传播、优化与梯度检查 |
| 概率统计 | 如何从有限观察讨论不确定性？ | 分类概率、采样、误差估计 |
| 信息论 | 熵、交叉熵、KL 分别衡量什么？ | 语言模型目标、分布比较 |
| 实验工程 | 别人怎样复跑并判断结果可信？ | 依赖、数据校验、记录与自动化 |

建议分三次完成：先读 Python 与张量，再读线性代数和梯度，最后读概率与信息论。每次都用文末实验检查计算，而不是只记定义。

## 2. Python：先掌握数据和控制流程 {#python}

[Python 官方教程][python]是语言细节的依据。本章聚焦读写 AI 实验代码最常用的部分。

### 2.1 容器、函数和类型

- `list` 是有序可变容器；`tuple` 常用于固定结构，如张量的形状。
- `dict` 存储键值映射，适合配置和结果记录；JSON 对象读入 Python 后通常是字典。
- `def` 定义函数。参数是函数收到的输入，`return` 返回计算结果；不要依靠散落的全局变量传递实验状态。
- 类型注解帮助阅读和静态检查，但不会自动验证传入数据。标成 `float`，不等于运行时一定是合法浮点数。
- Python 列表的 `+` 是拼接，NumPy 数组的 `+` 通常是逐元素相加；同一个符号的意义取决于操作数类型。

以配套脚本中的 `iter_batches` 为例，它把已有数据分成小批次：

```python
from collections.abc import Iterator

def iter_batches(rows: list[list[float]], batch_size: int) -> Iterator[list[list[float]]]:
    if batch_size <= 0:
        raise ValueError("batch_size must be positive")
    for start in range(0, len(rows), batch_size):
        yield rows[start:start + batch_size]

batches = iter_batches([[1.0], [2.0], [3.0]], 2)
print([len(batch) for batch in batches])
print(list(batches))
```

第一次打印得到 `[2, 1]`，第二次得到 `[]`。`yield` 让函数成为生成器，它在迭代时逐段执行，而且同一个迭代器用完后不会自动从头开始。

这段函数延迟产生批次，但输入 `rows` 已经在内存里，切片也会建立新的外层列表；**使用生成器不等于整条数据管线都不占内存**。传入非法批大小时，也是在开始迭代后才抛出异常。

### 2.2 类和异常

类把状态与行为放在一起：实例属性保存某个对象的数据，实例方法通过 `self` 访问这些数据。配套实验中的 `MathBasicsTests` 继承标准库 `unittest.TestCase`，每个 `test_...` 方法描述一个可验证的行为；它不是神经网络模型。

后续 PyTorch 的模型通常也用类表达，但应区分：普通 Python 对象、张量、可训练参数、网络模块和优化器不是同一个东西。

面对错误，优先识别具体类型：输入值不合法可以抛 `ValueError`，文件不存在会有文件系统异常，形状不兼容也应直接报错。不要用 `except Exception: pass` 把失败藏起来，更不要返回一份伪造的“成功结果”。

**自查：**如果第二轮训练没有读到任何样本，除了文件为空，还应检查是否复用了已经耗尽的迭代器。

## 3. 张量：先看形状，再看数值 {#tensors}

在本章的数值计算语境中，可以先把张量理解为带有形状、数据类型和设备信息的多维数组。[D2L 线性代数][linear-algebra]介绍了标量、向量、矩阵与更高阶张量。

| 对象 | 示例形状 | 含义 |
| --- | --- | --- |
| 标量 | `()` | 一个数，例如归约后的损失 |
| 向量 | `(3,)` | 一个轴，含三个元素 |
| 矩阵 | `(2, 3)` | 两个轴，例如两条样本、每条三个特征 |
| 序列批次 | `(batch, tokens, hidden)` | 三个轴，其语义由模型约定 |

张量的轴数不等于元素总数；矩阵的“秩”又是线性代数概念，不等于 `ndim`。例如 `(2, 3)` 数组有两个轴、六个元素，而它的矩阵秩至多为 2。

### 3.1 矩阵乘法和逐元素乘法

当每行是一条样本时，线性计算可以写成：

$$
X \in \mathbb{R}^{B\times D},\quad
W \in \mathbb{R}^{D\times O},\quad
Y=XW+b \in \mathbb{R}^{B\times O}.
$$

这里 $B$ 是批大小，$D$ 是输入特征数，$O$ 是输出维数，$b$ 含 $O$ 个偏置。矩阵乘法要求内部维数相同；输出保留外侧维数。

```python
import numpy as np

features = np.array([[1.0, 2.0], [3.0, 4.0]], dtype=np.float64)
weights = np.array([[2.0], [-1.0]], dtype=np.float64)
predictions = features @ weights + np.array([0.5], dtype=np.float64)
print(predictions.shape)
print(predictions.tolist())
```

结果是形状 `(2, 1)` 和数值 `[[0.5], [2.5]]`。第一行计算为 $1\times2+2\times(-1)+0.5=0.5$，第二行同理。

`@` 表示这里的矩阵乘法；`*` 对 NumPy 数组和普通 PyTorch 张量表示逐元素乘法，不能互换。PyTorch 的 `nn.Linear` 权重存储约定为 `(out_features, in_features)`，其调用内部处理转置；不要把本文的数学记号直接当作该 API 的存储形状。

### 3.2 广播能运行，不代表算对

根据 [NumPy 广播规则][broadcasting]，两个形状从最右侧逐轴比较：维数相等，或者其中一个为 1，才兼容；缺少的前导轴视为 1。

| 运算形状 | 结果 | 解释 |
| --- | --- | --- |
| `(2, 3) + (3,)` | `(2, 3)` | 向每行加三个对应值 |
| `(2, 3) + (2, 1)` | `(2, 3)` | 每行的单个值沿列展开 |
| `(2, 3) + (2,)` | 报错 | 最右侧的 3 与 2 不兼容 |
| `(2, 1) - (2,)` | `(2, 2)` | 两边都被展开，可能悄悄改变原意 |

最后一行是常见的损失计算陷阱。若预测是 `(2, 1)`，标签是 `(2,)`，直接相减得到两两组合，并非逐样本误差。若任务确实需要列向量标签，可先使用 `targets[:, None]` 明确变成 `(2, 1)`，再验证结果。

广播通常无需先复制完整输入，但**运算结果和中间数组依然可能很大**。形状错误可以同时带来错误结果和内存开销。

### 3.3 归约、类型和设备

对 `(2, 3)` 数组，`sum(axis=0)` 得到 `(3,)`，`sum(axis=1)` 得到 `(2,)`；`keepdims=True` 可保留长度为 1 的轴。PyTorch 常使用对应的 `dim`、`keepdim` 参数。均值、求和和最大值的归约轴都应明确。

`reshape` 按元素排列规则改变形状，并不等价于转置；二维矩阵的 `.T` 交换行列轴。切片或变形可能共享底层存储，不能假设得到新对象就一定复制了数据。

NumPy 主要用于 CPU 数组计算，PyTorch 还提供设备管理与自动求导。检查张量时至少看 `shape`、`dtype`、`device`、`requires_grad`：浮点参数可以参与求导，整数类别索引通常不需要；参与同一个常规运算的张量应满足设备和数据类型要求。

本章使用 CPU 和 `float64` 便于梯度数值对照，不表示实际模型训练都应使用双精度。FP32、BF16、FP16 等训练精度留到 M06/M08。

## 4. 线性代数：表示、方向和低秩 {#linear-algebra}

### 4.1 内积和范数

对两个同维实向量，内积将对应元素相乘再求和：

$$
\langle u,v\rangle=\sum_{i=1}^{D}u_i v_i,\qquad
\lVert u\rVert_2=\sqrt{\sum_{i=1}^{D}u_i^2}.
$$

例如 $u=(3,4)$ 的二范数为 5，一范数为 $\lvert3\rvert+\lvert4\rvert=7$。范数描述大小，不是向量有几个元素。

非零向量的余弦相似度用内积除以两个向量的二范数之积，偏重比较方向。它在向量检索中有用，但“数值方向相近”是否对应任务所需的语义，要由表示模型与评测决定。零向量的余弦没有这个定义。

### 4.2 投影不是任意矩阵变换

把实向量 $u$ 正交投影到非零方向 $v$ 上：

$$
\operatorname{proj}_v(u)=\frac{u^\top v}{v^\top v}v.
$$

公式来自让剩余部分与 $v$ 正交：若投影为 $av$，令 $(u-av)^\top v=0$，就得到系数 $a$。分母为零时不能使用。

取 $u=(3,4)$、$v=(1,0)$，投影为 $(3,0)$，残差为 $(0,4)$。这与“用任意权重矩阵把特征映射到另一维度”有区别；工程文章中的“投影层”经常泛指线性映射，不一定是数学上的正交投影。

### 4.3 秩与 SVD 近似

矩阵秩描述线性独立方向的数量。低秩近似试图用较少方向保留矩阵的主要结构，不等于把矩阵元素简单截断或把文件压缩。

对实矩阵，奇异值分解可写作 $A=U\Sigma V^\top$。奇异值按从大到小排列，保留前 $r$ 项可以构造截断近似。[NumPy SVD 文档][svd]给出了返回值和重建方法。

本章取 $A=\operatorname{diag}(3,1)$，保留第一项得到 $A_1=\operatorname{diag}(3,0)$，误差的 Frobenius 范数为 1。Frobenius 范数是所有矩阵元素平方和的平方根。

一般地，用 $D\times r$ 与 $r\times O$ 两个因子代替 $D\times O$ 矩阵，参数数目从 $DO$ 变为 $r(D+O)$，但只有在后者更小时才节省参数，还必须评估近似误差与实际计算成本。

这里为理解低秩方法做准备，**并没有实现 LoRA，也没有证明模型权重可以无损降秩**。LoRA 如何参数化权重更新将在 M07 单独讲解。

## 5. 微积分：损失怎样传回参数 {#calculus}

导数是函数对一个输入的局部变化率；偏导数是在其他输入保持不变时，对某个输入的变化率。对可微的标量函数，把各参数的偏导数排起来，就得到梯度。[D2L 微积分][calculus]

例如 $f(a,b)=a^2+3b$ 的梯度是 $(2a,3)$。不要把不同参数的偏导数直接相加，丢掉梯度的方向信息。

### 5.1 手算一个完整计算图

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

### 5.2 求梯度与更新参数是两步

梯度下降使用学习率 $\eta$ 更新参数：

$$
\theta_{\mathrm{new}}=\theta-\eta\nabla_\theta L.
$$

取 $\eta=0.01$，上述参数变成 $w=1.88$、$b=0.96$，新损失为 2.56。相反，若取 $\eta=0.2$，更新会越过最优位置，使这个例子的损失升到 36；不能宣称沿负梯度方向走任意大步都降低损失。

在非零梯度处，对于足够小的步长，负梯度是可微函数的局部下降方向。梯度为零也不保证全局最小值，可能是局部极值或鞍点。更一般的优化方法和训练行为会在 M02/M03 展开。

### 5.3 自动求导和有限差分

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

有限差分则通过邻近函数值估计导数，本章使用中心差分：

$$
\frac{\partial L}{\partial w}\approx
\frac{L(w+\varepsilon,b)-L(w-\varepsilon,b)}{2\varepsilon}.
$$

实验取 $\varepsilon=10^{-6}$，得到约 12，与手算和自动求导相符。这种对照适合检查小型计算；步长过大有近似误差，过小又可能受浮点消减影响，因此不采用浮点数的逐位相等作为通用验收标准。

## 6. 概率统计：条件、估计与不确定性 {#probability}

### 6.1 概率不是观察次数的别名

离散分布给每个可能取值分配非负概率，总和为 1。随机变量把随机结果映射到数值；实际观察到的一组数是样本，不是整个分布。[D2L 概率与统计][probability]

Bernoulli 分布只取 0 和 1，取 1 的概率为 $p$。Categorical 分布描述从多个类别中选择一个；高斯分布则是连续分布，连续密度值不能直接当作某个精确取值的概率。

### 6.2 条件概率与贝叶斯公式

对事件 $A$、$B$，当 $P(B)>0$ 时：

$$
P(A\mid B)=\frac{P(A\cap B)}{P(B)}
=\frac{P(B\mid A)P(A)}{P(B)}.
$$

第二个等式通常在 $P(A)>0$、$P(B)>0$ 时按上述条件概率定义使用。$P(A\mid B)$ 与 $P(B\mid A)$ 一般不同，不能交换。

用一个**人为设定的系统告警例子**说明：故障概率为 10%，发生故障时有 80% 会报警，没有故障时也有 20% 会误报。

$$
P(\mathrm{alarm})=0.8\times0.1+0.2\times0.9=0.26.
$$

$$
P(\mathrm{fault}\mid\mathrm{alarm})=
\frac{0.8\times0.1}{0.26}=\frac{4}{13}\approx30.77\%.
$$

因此，看到报警并不意味着故障概率是 80%。这不是监控产品的真实效果评测，而是说明基准发生率为什么重要。

独立性也必须有依据：只有独立事件才满足 $P(A\cap B)=P(A)P(B)$。无条件独立与给定某个条件后的独立不同，不能因为有两条证据就直接相乘。

### 6.3 期望、方差和样本估计

对有限离散取值，期望与方差为：

$$
\mathbb{E}[X]=\sum_x xP(X=x),\qquad
\operatorname{Var}(X)=\mathbb{E}[(X-\mathbb{E}[X])^2].
$$

Bernoulli 随机变量的期望是 $p$，方差是 $p(1-p)$。期望不一定是可能出现的单次结果，例如 $p=0.3$ 时，期望为 0.3，但每次取值仍然只能是 0 或 1。

在独立同分布、具有有限方差的条件下，样本均值的方差随样本数按 $1/n$ 缩小，标准误差按 $1/\sqrt n$ 缩小。这不意味着每多看一条样本，当前估计都会更接近真值；更多同样有偏的数据也不会自动消除采样偏差。

实验用 `np.random.default_rng(42)` 抽取 1,000 个 $p=0.3$ 的 Bernoulli 样本。本次运行均值为 **0.304**，用 `samples.var()` 得到 **0.211584**；它们不是理论值 0.3 和 0.21 的替代定义。

`np.var` 默认除以 $n$。若要用独立同分布样本估计总体方差，常采用除以 $n-1$ 的样本方差，对应 `ddof=1`，且要求样本数大于 1。总体分布、样本统计量与估计方法应分别说明。

## 7. 信息论：熵、交叉熵与 KL {#information}

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

## 8. 工程习惯：让结果能被复查 {#engineering}

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

## 9. 运行配套实验 {#lab}

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
| 报警时故障概率为什么不是 80%？ | 80% 是给定故障时报警的概率，后验还取决于先验和误报率 |
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

下一步是 [M02 · 机器学习]({{ '/roadmap/' | relative_url }}#m02)：用这些工具理解监督学习、训练/验证/测试划分、泛化与指标。M02 正文仍在规划中。

## 一手资料与核验范围 {#references}

核验日期：2026-09-21。文中公式为标准定义的原创解释与推导，配套代码为独立教学实现；未复现任何大型模型训练或论文性能结论。

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