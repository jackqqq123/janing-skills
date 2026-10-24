# skills

这个目录用来存放具体分享的 agent skills。

每个 skill 一个子目录，建议结构：

```
skills/<skill-name>/
├── SKILL.md      # skill 说明与触发方式
├── README.md     # 可选，单个 skill 的补充说明
└── ...           # 配套脚本 / 模板 / 示例
```

## 如何新增一个 skill

1. 在 `skills/` 下新建一个以 skill 名命名的目录。
2. 编写 `SKILL.md`，说明用途、触发条件、使用方式与依赖。
3.（可选）补充配套脚本或模板。
4. `git add` 后提交。

## 已收录 skills

| Skill | 用途 | 依赖 |
| --- | --- | --- |
| [joplin-notes](joplin-notes/) | 通过 Joplin 本地 REST API（Web Clipper / ClipperServer，默认 `http://127.0.0.1:41184`）新增、读取、搜索、管理笔记 | Joplin 应用 + Web Clipper 开启；`JOPLIN_TOKEN`（Web Clipper token）环境变量 |
| [skill-creator-dsh](skill-creator-dsh/) | 创建、改进、审查、安装与评估 DeepSeek Harness（DSH）skill，含 Claude Code skill 迁移与评估报告流程 | 无网络依赖；渲染脚本 `scripts/render-eval-report.ps1` 需 Windows PowerShell |
| [dsh-station-config](dsh-station-config/) | 为 DSH 中转站（OpenAI 兼容网关）补模型能力声明：文本/图像输入与推理强度档位，含用冒烟测试探出合法档位与 off 语义的方法 | 网关凭据取自 `~/.dsh/.credentials.yaml`；手动触发（`disable-model-invocation: true`） |
| [karpathy-guidelines](karpathy-guidelines/) | 减少 LLM 编码错误的行为准则：编码前思考、简洁优先、精准修改、目标驱动执行。译自 NurvX/andrej-karpathy-skills（MIT） | 无 |

## 备注

- `skill-creator-dsh` 是面向 DeepSeek Harness 的专用版本；其他 agent 环境的通用 skill 创建请使用对应的通用 skill-creator。
