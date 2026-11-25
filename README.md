# Windows Credential Reuse — Pass-the-Hash & Pass-the-Key

Course essay + PoC for **Security Protocols** (MSc). Deadline for the written part: **20 Jan 2027**.
Repo layout, essay structure, page budget and timeline live here. This file is the source of truth for scope.

> **Ethical scope.** Every PoC step in this repository was executed in an isolated host-only
> virtual lab built by the authors (one DC, one Windows client, one attacker VM). No public,
> university or third-party system was touched at any point.

---

## 1. Scope decision

**In scope**

| Technique | Why it is here |
|---|---|
| **Pass-the-Hash (PtH)** | Core topic. The NT hash alone satisfies NTLM authentication; no cracking required. |
| **Pass-the-Key / Overpass-the-Hash (PtK)** | Same primitive in Kerberos: the NT hash *is* the RC4-HMAC key. Extends PtH to the Kerberos side of a domain with minimal extra lab work. |

**Deliberately excluded** (mentioned only as adjacent work if space allows, not implemented):
Pass-the-Ticket, Pass-the-Certificate. Both require a second lab (ticket lifecycle / AD CS
misconfiguration) and would dilute an 8-week build.

**Thesis of the essay.** NTLM and Kerberos were both designed so that authentication can be
completed **locally** from a secret that never crosses the wire. The price of that design is that
the *derived secret* — not the password — is the real credential. PtH and PtK are two sides of
one property: Windows authenticates possession of *key material*, and the key material is
reusable, exportable and not bound to a human.

**Angle that separates this essay from a tool walkthrough.** PtH is not replay. The NTLMv2
response is bound to the server challenge and to the target-info blob, so a captured response
cannot be re-sent to another host. The attacker recomputes a fresh, valid response using the
stolen hash as the HMAC-MD5 key. The proof therefore lives in *how the bytes were produced*, not
in the bytes themselves. The same argument transfers to Kerberos: possessing the key lets you
build a fresh AS-REQ, so again nothing is replayed.

---

## 2. Growing strategy

The essay is built in layers, each layer gated on the previous one being finished:

```
0. Goal + thesis        -> README (this file)
1. Chapters             -> README table, main.tex inputs
2. Sub-chapters         -> section files, headings only
3. Filling              -> prose, one section per pass
```

Nothing gets written in a section until its parent chapter's argument is agreed on. No section is
written before the one above it is at least at draft quality — each chapter assumes the vocabulary
established by the previous one.

**Audience assumption.** A reader who knows what a password hash is and has seen a packet capture,
but has never administered AD. Chapter 2 therefore starts from accounts and LSASS, not from NTLM.

---

## 3. Repository layout

```
pass-the-hash-windows/
├── README.md                  <- you are here: scope, outline, budget, timeline
├── paper/                     <- the deliverable PDF
│   ├── main.tex               <- preamble + \input of every section
│   ├── refs.bib               <- bibliography (biblatex/biber, numeric)
│   ├── sections/              <- one file per section, skeleton only for now
│   └── figures/               <- TikZ includes + exported drawio/PDF sources
├── poc/                       <- reproduction package (public repo requirement)
│   ├── README.md              <- step-by-step lab build + attack reproduction
│   ├── lab/                   <- topology notes, VM specs, snapshot policy
│   ├── scripts/               <- orchestration / evidence-collection wrappers
│   └── evidence/              <- curated logs, command output, capture indices
├── prompts/                   <- writing workflow: academic drafting + de-slopping
└── docs/                      <- working notes that are not part of the PDF
```

Licensing: prose under CC BY 4.0, scripts under MIT. Third-party tools are cited, never vendored.

---

## 4. Essay structure and page budget

Page counts are for the compiled PDF at 11 pt / A4 with the figures listed. Column *budget* is the
target; it will move by ±20% once drafting starts.

| # | Chapter | Content | Pages |
|---|---|---|---|
| — | Abstract | Protocol, vulnerability class, what the PoC shows | 0.5 |
| 1 | Introduction | Why NTLM/Kerberos still matter, the credential-theft problem, contribution, repo link | 1.5 |
| 2 | Background: Windows Authentication from Zero | accounts & token model, LSASS/SAM/secrets storage, password→hash derivation, NTLM challenge-response, Kerberos in AD, which protocols carry which | 4.0 |
| 3 | Framing the Attack Family | threat model, preconditions, "credential material as bearer capability", taxonomy and where each variant sits | 1.5 |
| 4 | Pass-the-Hash in Depth | what the attacker needs, computing a valid NTLMv2 response locally, protocol coverage (SMB/WinRM/WMI/RPC/RDP), session-key & signing consequences, tool-to-protocol map | 3.5 |
| 5 | Pass-the-Key / Overpass-the-Hash | RC4-HMAC key = NT hash, key material in AD, AS-REQ without a password, RC4 vs AES constraints | 2.0 |
| 6 | PoC: Environment and Implementation | lab topology, isolation, snapshots, accounts, scenario A/B/C, evidence methodology, tooling and wrapper scripts | 3.0 |
| 7 | Results | success matrix (protocol × technique × precondition), captured evidence, boundaries and failure cases | 1.5 |
| 8 | Detection | event IDs and their meaning, NTLM auditing, network signals, behavioural/honeytoken detection | 1.5 |
| 9 | Effects and Mitigation | credential protection, protocol hardening, architectural controls, measured before/after | 2.0 |
| 10 | When These Attacks Actually Work | synthesis: what the precondition chain really looks like in a modern estate, what still fails | 1.0 |
| 11 | Conclusion | | 0.5 |
| — | References | ~25 entries, numeric | 1.0 |
| — | Appendix | lab build commands, full log excerpts, extra captures | — |

**Body total: ~22 pages including figures.** Figures are expensive: budget ~6 pages of them
(§2.3 NTLM flow, §2.4 Kerberos flow, §4.2 local response computation, §6.1 topology, §7.1
success matrix, §9.x before/after).

---

## 5. Figures we draw ourselves

All diagrams are authored by the team as TikZ in `paper/figures/` (or drawn in draw.io and
exported to PDF, with the source committed next to it). Planned set:

1. `fig-ntlm-flow` — Type 1/2/3 exchange with the response computation expanded.
2. `fig-hash-derivation` — password → NT hash → NTLM response → session key chain.
3. `fig-kerberos-flow` — AS-REQ/AS-REP/TGS, with the key-derivation branch marked.
4. `fig-locality` — what crosses the wire vs what stays local, side by side for NTLM and Kerberos.
5. `fig-lab-topology` — host-only network with VM roles.
6. `fig-success-matrix` — heatmap of protocol × technique outcomes.
7. `fig-mitigation-matrix` — control vs technique stopped.

---

## 6. Build

The paper is LaTeX, compiled with pdfLaTeX + Biber. **No TeX distribution is installed on the
authors' machine yet** — either install TeX Live/MacTeX or compile in Overleaf (upload `paper/`,
default pdfLaTeX compiler, Biber as backend; no shell-escape needed).

Local build: `pdflatex main && biber main && pdflatex main && pdflatex main` inside `paper/`.

---

## 7. Timeline

| Window | Milestone |
|---|---|
| 25 Nov – 1 Dec | Scope locked, topic registered, literature pass started |
| 2 – 15 Dec | Lab built; PtH working end to end; first evidence captured |
| 16 – 29 Dec | Evidence collection methodology + detection work. **Gate 20 Dec:** PtK in or out |
| 30 Dec – 5 Jan | Mitigation experiments (before/after) |
| 6 – 13 Jan | Full draft complete, figures final, repo README reproducible from scratch |
| 14 – 20 Jan | Polish, PDF, submission. Presentation build in parallel |

Presentation is half the grade: a snapshot-based demo that reruns in <5 minutes, plus a recorded
fallback video.

---

## 8. Open decisions

- [ ] Confirm the course allows an NTLM/Kerberos essay given the topic duplicate limit (3 teams).
- [ ] Dec 20: whether PtK is implemented or demoted to a discussion section.
- [ ] Defender/EDR on or off in the lab — if off, document it and turn it into the detection chapter's hook.
- [ ] Citation style: numeric (IEEE-ish) vs author-year. Currently numeric.
