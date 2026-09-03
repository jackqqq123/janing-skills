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
