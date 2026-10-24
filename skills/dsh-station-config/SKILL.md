---
name: dsh-station-config
description: 为 DeepSeek Harness 的中转站（OpenAI 兼容网关）补模型能力声明：文本/图像输入与推理强度档位。仅由用户手动指定触发，不自动调用。
whenToUse: 用户明确要求给某个 DSH 供应商/中转站配置图片、文本或思考强度时。
user-invocable: true
disable-model-invocation: true
---

# DSH 中转站能力配置

改的是 `llm-pi-ai` 路由的 `input` 与 `reasoningEfforts`。只动配置，不动源码。

## 1. 推理强度词汇（参考，不可照抄）

| 词汇 | 含义 |
|---|---|
| `none` / `off` | 关闭思考，二者按网关二选一 |
| `minimal` | 最低档，DeepSeek 侧映射为 `low` |
| `low` / `medium` / `high` | 通用三档 |
| `xhigh` | 高于 high |
| `ultra` / `max` | 最高档，`ultra` 是网关扩展 |

- DeepSeek 官方：`none/low/high/max`，默认 `high`；`minimal→low`、`medium/xhigh→high` 只是兼容别名。
- 同一网关的不同模型，合法集合也可能不同（实测见过 deepseek 支持全套、gpt 类只到 `max`、gemini 类只到 `high`）。
- 所以：词汇表只用来猜，**真实集合必须实测**（见第 5 步）。

## 2. 找到配置位置

1. 确认 GUI 在跑哪个 profile——决定改哪份文件：

   ```bash
   netstat -ano | grep ":<端口>" | grep LISTENING
   powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter 'ProcessId=<PID>' | Select-Object -ExpandProperty CommandLine"
   ```

   命令行里含 `.dsh\profiles\<desktop|web>` 即目标 profile。
2. 配置：`~/.dsh/profiles/<profile>/cordis.patch.yml` → `- id: llm-pi-ai` → `providers.<路由>` → `models[]`。
3. `~/.dsh/settings.yaml.imported` 是历史导入快照，以 `cordis.patch.yml` 为准，别改它。

## 3. 与用户确认范围

动手前问清三件事：改哪个 `providers` 路由、改哪几个模型条目、是否要设路由级默认 `reasoning:`。

## 4. 判断图像能力

1. 用 `web_search` 查官方文档与「<模型名> vision / image input」。
2. 用 `bash` 实测：发一条带 `image_url`（data URI）的最小请求，200 即支持。
3. 支持写 `input: [text, image]`；不支持就别写（省略默认为 `[text]`）。

## 5. 冒烟测试探等级

直连网关测，别猜。

```bash
KEY=$(grep -m1 "<KEY名>" ~/.dsh/.credentials.yaml | sed -E 's/^[^:]+: *//')   # 不要回显
curl -s -m 30 "<baseURL>/chat/completions" \
  -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" \
  -d '{"model":"<id>","messages":[{"role":"user","content":"hi"}],"max_tokens":16,"reasoning_effort":"<档位>"}'
```

基址按配置原样拼 `/chat/completions`；若配置里没写 `/v1`，`/v1/chat/completions` 也要试一次。

- **探枚举**：先发一个非法值（如 `bogus`），从 400/422 报错里读出合法集合，例：
  `expected one of none, minimal, low, medium, high, xhigh, ultra, max`
- **验档位**：逐档发 200 并看响应有没有 `reasoning_content` / `usage.completion_tokens_details.reasoning_tokens`，确认是否真生效。
- **注意**：`baseURL` 带不带 `/v1` 都要试，New API 类网关两种路径都能通，但只有 `/v1/models` 返回模型列表。
- 单次几十 token，成本可忽略；这也是唯一可靠的判断依据。

## 6. 写入配置

新条目必须落在 `config.providers.<路由>.models[]` 之下，完整层级如下：

```yaml
- id: llm-pi-ai
  name: "@deepseek-ai/dsh-llm-pi-ai"
  config:
    providers:
      <路由名>:
        apiKeyEnv: <KEY名>
        api: openai-completions
        baseURL: <网关地址>
        reasoning: high            # 可选：路由默认档，影响该路由全部模型
        models:
          - id: <model-id>
            name: <显示名>
            contextWindow: 1000000
            input:
              - text
              - image
            reasoningEfforts:
              off: null
              low: low
              medium: medium
              high: high
```

规则：

- 文件里已有该路由时，**只改 `models[]` 下的条目**，不要整段替换；缩进必须和同级条目对齐。
- `off: null` = 不发送字段 = 走上游默认；`off: none` 或 `off: off` = 真的关闭思考。选哪个由用户决定。
- 键只能是 `off/minimal/low/medium/high/xhigh/max`；值写网关实际接受的拼写。
- 想用网关的 `ultra` 就写 `max: ultra`，二者只能取一个。
- 不能是空 map，且至少一个非 `off` 档，否则加载报错。
- `minimal` 只在网关接受时才写。
- `input` 写成块状列表或 `[text, image]` 都行，二者等价。
- 不显式声明 `reasoningEfforts` 时，DSH 会去内置目录找同名模型；找不到即视为无推理能力（UI 不出现档位）。

## 7. 验证

- 该 profile 是 `patchReload: live`，保存即生效，无需重启。
- 模型选择器里出现档位菜单即成功；没有就检查模型 `id` 与 `reasoningEfforts` 拼写。

## 边界

- 只改 profile 配置，不改 DSH 源码、不打印 API key。
- 不确定的档位宁可不写——写错会让整轮请求 400/422 失败。
- 两个 profile（desktop / web）各自独立，改前先确认当前跑的是哪个。
