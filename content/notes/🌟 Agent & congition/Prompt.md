---
date: 2025-11-25
---


一些底层的原理
注意力分配 & 语义聚焦模式
- 一个结构良好的 prompt，不只是在提供信息，更是在引导模型的注意力
- Attention 的数学形式：
	- 其中：
		- Q(Query)：表示“我想知道什么”，即当前词的查询向量
		- K(Key)：表示“我是什么”，即每个词的语义身份
		- V(Value)：表示“我携带的信息”
		- d_k: 缩放因子，防止点积过大导致 softmax 过度陡峭
	- 计算过程
		- 计算相似度：模型计算每个 Query 与所有 Key 的点积，它衡量第 i 个词应该关注第 j 个词多少。s_ij = <Q_i,K_j>
		- 归一化权重：用 softmax 把这些相似度转换为概览分布
		- 信息聚合：将所有 Value 加权求和，得到融合全局上下文后的新表示
- Prompt 对注意力分布的“调控作用”
	- prompt 定义了一种注意力分布先验，prompt 的语言结构、语义层次和位置设计都会在权重矩阵 A_ij 上产生偏置
	- 实验中发现的典型规律
		- primacy effect (首部权重偏高)
		- recency effect (末尾强化)
		- context dilution (中段稀释)
	- Attention 的边缘聚焦现象：位置编码 & 注意力归一化

参考文章
- [OpenAI Platform](https://platform.openai.com/docs/guides/prompt-engineering)
- [\[2307.03172\] Lost in the Middle: How Language Models Use Long Contexts](https://arxiv.org/abs/2307.03172)
