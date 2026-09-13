# Evaluation protocol

## Artifact layout

For a managed skill, create:

```text
<target-skill>/evals/
├── cases.json
├── baseline/
├── with-skill/
├── results.json
└── report.html
```

`cases.json` has at least three cases: intended success, boundary behavior, and a close non-trigger or refusal. Each case has `id`, `category`, `prompt`, and observable `expectations`. Case IDs must be unique across `cases.json`; validate uniqueness when assembling results.

The schemas in `templates/` are JSON Schema documents. Their `$schema` value is an identifier only; the evaluator and renderer do not fetch it over the network or depend on any remote meta-schema. Validate local files against the schemas with an offline validator if available, or against the documented field shapes.

## Execution

The main DSH agent coordinates baseline and with-skill runs using `subagent` or `subagent_fork`. Keep prompt, model configuration, and available context equivalent whenever possible. The intended difference is target-skill injection only. Persist concise evidence for both runs.

Check observable facts first: required files, valid JSON, required response sections, valid frontmatter, and declared output. Send subjective quality review to an independent subagent and persist verdict plus rationale in `results.json`.

## Interpretation and report

The report must show per-case baseline/with-skill evidence, assertion status, reviewer conclusion, limitations, and overall counts. Disclose sample size, model stochasticity, environment differences, and non-comparable contexts. Do not claim statistical significance.

This is an agent-orchestrated evaluation, not a scripted model runner. DSH has no confirmed equivalent to `claude -p`. If automation would require a new runner, a model service, or another unavailable capability, stop and obtain explicit user confirmation. `render-eval-report.ps1` only turns existing local JSON into static HTML; it does not call a model or the network.
