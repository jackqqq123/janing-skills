# janing-skills

一个用于分享我收集、编写、觉得有用的 **agent skills** 的仓库。

## 这是什么

这里存放我在使用 / 编写 agent（如 Reasonix、Claude、Cursor 等）过程中积累的技能脚本与 playbook。每个 skill 通常是一个独立的目录，包含：

- `SKILL.md`：skill 的说明与触发方式（playbook）
- 配套脚本、模板、示例等

## 目录结构

```
janing-skills/
├── README.md
├── .gitignore
└── skills/          # 具体 skill 放这里
```

## 如何使用

想使用某个 skill，将它安装到你的 agent 技能目录中即可。每个 skill 目录内会有自己的说明。

## 约定

- 每个 skill 尽量自包含、可单独复制使用。
- 如果 skill 依赖特定运行环境或工具，请在 `SKILL.md` 中注明。
