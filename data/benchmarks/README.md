# OpenRouter benchmark snapshot

Updated weekly by `.github/workflows/benchmark-snapshot.yml` via `scripts/fetch-benchmarks.sh`.
Raw API responses, so each file keeps the `meta.citation`, `meta.source_url` and `meta.as_of` fields.

| File | Contents |
|---|---|
| `aa-coding.json` | Artificial Analysis, `task_type=coding` |
| `aa-intelligence.json` | Artificial Analysis, `task_type=intelligence` |
| `aa-agentic.json` | Artificial Analysis, `task_type=agentic` |
| `design-arena.json` | Design Arena, all categories |
| `models.json` | Trimmed `/api/v1/models` list (`id`, `canonical_slug`, pricing) |

Search without loading everything into context:

```bash
grep -l '"model_permaslug"' data/benchmarks/*.json
jq '.data[] | {model_permaslug, intelligence_index}' data/benchmarks/aa-intelligence.json | head -40
```

Before recommending a model, confirm its `model_permaslug` appears as an `id` in `models.json`,
and check the live endpoints. A snapshot can't show a model that has been retired or is degraded.
