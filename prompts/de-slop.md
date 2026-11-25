# De-Slop Prompt

Adapted from `isatimur/de-slop` (MIT) with the tell-list from `haidrrrry/humanize-ai-writing`.
Purpose: remove AI patterns from a draft **without changing its claims**. Fidelity over flair.

---

## Two hard rules

1. **Preserve meaning exactly.** Only subtract hedging and filler, and sharpen what is already
   there. Do not inject stance, personality or rhythm for its own sake. Swapping AI slop for
   edgy slop is a failure, not a fix.
2. **Flag hollow spans, do not fabricate.** If a paragraph is weak because it has no claim, say
   so. Do not invent a claim to rescue it. Telling the author "this paragraph has no argument"
   is the most valuable thing this prompt does.

## Procedure

Work paragraph by paragraph. Skip headings, code, tables and genuine lists.

1. **Scan** for the tells below. Hits are candidates, not verdicts.
2. **Judge** each paragraph on the hostile-editor test: *would this survive a red pen? does
   deleting it lose anything?*
3. **Triage.** *Rewordable* (real claim buried under hedging) gets rewritten. *Hollow* (no
   claim) gets flagged and left alone.
4. **Rewrite** the rewordable ones. Subtract; do not decorate.
5. **Re-judge.** Maximum three passes. If it still fails, keep the best version and flag it.
6. **Report**, do not overwrite: return the rewritten text, a change log
   (`paragraph N: what changed`), and a flag list.

## Tell list

**Lexical.** delve, landscape, tapestry, realm, robust, leverage, seamless, crucial, pivotal,
foster, navigate (figurative), testament to, underscores, "plays a vital role".

**Syntactic.** "not just X but Y"; "it is not merely A, it is B"; triadic adjective piles
(*fast, reliable and secure*); "X. But Y." as a drumbeat; every paragraph the same length;
every paragraph opening with a subordinate clause.

**Structural.** Throat-clearing openers ("In recent years", "It is no secret that"). Summary
sentences that restate the paragraph you just read. Sections announced rather than made
("In this section we will explore..."). Conclusions that introduce new material.

**Punctuation.** Em-dash as a rhythm device (twice per paragraph is already too many).
Colons introducing lists that the prose should have carried.

## Domain-specific additions for this paper

- **No vendor voice.** "Microsoft recommends" is not a technical claim; state the mechanism.
- **No hedged precision.** "Can potentially significantly impact" → say what breaks.
- **No fake authority.** "Studies show" without a key is deleted, not reworded.
- **Keep the protocol vocabulary exact.** Do not simplify `etype`, `logon type`, `session key`,
  `PAC`, `SPN` into folk terms. Precision here is the essay's credibility.

## Output contract

```
TEXT
<rewritten paragraphs, hollow ones left intact>

CHANGES
<p1: removed 2 hedges, merged 2 sentences that made the same point>

FLAGS
<p4: no claim present -- needs an argument, not better words>
```
