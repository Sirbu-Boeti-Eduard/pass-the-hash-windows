# Prompts

Working prompts for this essay. Two families: one for drafting academic prose, one for
stripping AI patterns out of it. Plus a project-specific section writer that binds the
other two to our outline.

Keep these under version control so that the writing process itself is reproducible.

| File | Purpose | Origin |
|---|---|---|
| `academic-writing.md` | Plan, structure, draft and self-review a section against the paper's contract | Adapted from `ai-boost/awesome-prompts` → `prompts/academic_paper_architect.txt` (MIT) |
| `de-slop.md` | Remove AI tells without changing meaning; flags hollow prose instead of padding it | Adapted from `isatimur/de-slop` (`SKILL.md`, MIT) and `haidrrrry/humanize-ai-writing` |
| `section-writer.md` | Our own: draft one section of *this* paper only, with the outline, budget and evidence rules baked in | Original |

## Source repositories

- `ai-boost/awesome-prompts` — <https://github.com/ai-boost/awesome-prompts>
- `isatimur/de-slop` — <https://github.com/isatimur/de-slop>
- `Verla-AI/academic-writing-toolkit` — <https://github.com/Verla-AI/academic-writing-toolkit>
- `jamie579/agents` — <https://github.com/jamie579/agents> (35 research/writing/QA agents)
- `haidrrrry/humanize-ai-writing` — <https://github.com/haidrrrry/humanize-ai-writing>
- `hannsxpeter/humanizer` — <https://github.com/hannsxpeter/humanizer>
- `petergyang/no-ai-slop` — <https://github.com/petergyang/no-ai-slop>

## Usage order

```
outline agreed  ->  section-writer.md (draft one section)
                ->  de-slop.md (rewrite pass)
                ->  academic-writing.md, "peer review" mode (cold read)
                ->  human edit (the only pass that counts)
```

Never run the drafting prompt on a section whose evidence does not exist yet. The prompt will
write around the gap and you will not notice until the Results chapter fails to match.
