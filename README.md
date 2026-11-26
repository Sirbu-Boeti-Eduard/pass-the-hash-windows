# Windows Credential Reuse

**Pass-the-Hash and Pass-the-Key against NTLM and Kerberos**

An article for practitioners, and a reproducible lab: how Windows authenticates on derived key
material rather than on passwords, and what follows from that.

## What this is

NTLM and Kerberos both let a client finish authentication locally, from a secret that never crosses
the wire. An NT hash is not a stolen password waiting to be cracked; it is the key those protocols
compute with, and holding it is holding the account. No cipher is broken anywhere in this work.

The article covers pass-the-hash as the core case and pass-the-key as its Kerberos counterpart,
since both consume the same sixteen bytes. It is written for people who run the tools: the
mechanism, the preconditions, the logs each step leaves, and the controls that actually stop it.
The academic requirement is covered in passing rather than used as the frame.

## The proof of concept

The lab exists so the techniques can be run and observed. It is a playground, not a hardened
build: three hosts on an isolated network, snapshots before every scenario, no bridged adapter and
no outbound connectivity while a scenario runs.

The PoC ships as **agent skills**, not scripts. The maintained tools do the work; the skills hold
the judgement — which tool, against which precondition, and what the result means — with a human
reviewing each step. Scripts were considered and rejected: writing one is cheap, maintaining it is
not, and the community tools are already better than anything written for this repository.

Evidence is the point of the exercise. Security logs from both ends of every connection, NTLM
auditing, and packet captures, so each claim in the results chapter traces to a file.

## Repository layout

| Path | Contents |
|---|---|
| `paper/` | the article in LaTeX: `main.tex`, one file per section in `sections/`, bibliography in `refs.bib`, diagrams in `figures/` |
| `poc/` | lab definition, the agent skills that drive each scenario, and the curated evidence |
| `prompts/` | working notes for whoever continues the draft: house style, de-slopping, handoff brief |
| `docs/` | scratch notes, not part of the PDF |

## Structure

| | Chapter |
|---|---|
| 1 | Introduction |
| 2 | Background: How Windows Authenticates |
| 3 | The Primitive: Credential Material as a Bearer Token |
| 4 | Pass-the-Hash |
| 5 | Pass-the-Key: the Kerberos Face of the Same Primitive |
| 6 | The Lab and the PoC |
| 7 | Results |
| 8 | Reading the Logs |
| 9 | Mitigations That Actually Break It |
| 10 | Decision Tree: Does It Work Here? |
| 11 | Conclusion |

Chapter 2 opens with an unnumbered primer and then builds the mechanisms in order; later chapters
assume its vocabulary and introduce no competing definitions.

## Status

Drafting. Chapter 1 and the opening of chapter 2 — the primer, 2.1 accounts and tokens, 2.2 where
the hash lives — are written. The rest of chapter 2 and chapters 3 to 12 carry headings and intent
notes only. The lab has not been built yet.

## Building the paper

```
./build.sh              # build into build/main.pdf
./build.sh --canonical  # force pdflatex + biber
./build.sh --clean      # remove build/
```

The canonical toolchain is pdfLaTeX with Biber and no shell escape. `build.sh` uses it when it is
installed and otherwise falls back to Tectonic in a scratch copy, where the only difference is the
bibliography engine: the body text and layout are unchanged, the reference list is set by
`plainnat` instead of `biblatex`. Builds are deterministic: `build/` is restaged from `paper/`
every run, and the document date is pinned to the last commit that touched `paper/`, so the same
commit always yields the same PDF. The script fails on unresolved references, undefined citations
and citation keys absent from `refs.bib`, and reports any `[[CITE: …]]` markers left in the text.

`paper/` is never modified by a build. Diagrams are authored as TikZ and committed alongside the
section that includes them.

## Licensing

Prose is released under CC BY 4.0; skills and scripts under MIT. Third-party tools and
documentation are cited, not redistributed.

No public, university, or third-party system was involved at any point.
