## messages
system prompt
input
output

tool call
## Tool schema
- 定义工具的描述，优化调用准确率，处理边缘情况
- 
## output format
结构化输出通过约束解码（constrained decoding）保证响应符合模式
openai
-  JSON mode(老)：`response_format={"type": "json_object"}`
- **Structured Output（新，推荐）**：
	- `response_format={ "type": "json_schema", "json_schema": { "name": "...", "schema": {...}, "strict": true } }`
- 可配 Pydantic（.parse）、有 refusal 字段处理拒答
- 支持流式中的 partial JSON parsing（部分 JSON 解析）
claude
- 历史上走 tool_use，近期加了原生约束解码
- output_config.format
- tools 参数 strict: true input_schema
- 使用结构化输出时，对象中的属性会保持您模式中定义的顺序，但有一个重要的注意事项：必需属性排在前面，然后是可选属性。
- 结构化输出的工作原理是将您的 JSON 模式编译为约束 Claude 输出的语法。更复杂的模式会产生更大的语法，需要更长的编译时间。为了防止编译时间过长，API 强制执行多项复杂度限制。
原理参考 [[Prompt]] 中的输出一节

## cache control

其他参数