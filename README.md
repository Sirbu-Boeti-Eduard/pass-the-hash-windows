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

Page counts are for the compiled PDF at 11 pt / A4. Each subsection carries a page allocation and,
in the source, a one-line *CLAIM* comment stating the single thing that subsection must
establish. `paper/main.tex` currently compiles to a heading-only outline — that is the intended
deliverable of this stage.

Drafting order is not reading order: 2.3 → 4.2 → 6 → 7 first, because those four carry the
evidence; everything else is written around them.

### Front matter

| | | Pages |
|---|---|---|
| — | Abstract (protocol, vulnerability class, PoC outcome) | 0.5 |

### 1. Introduction — 1.5 p
- 1.1 Motivation — NTLM is unbroken yet routinely defeated; deprecation as framing hook (0.4)
- 1.2 Problem statement — the one sentence the essay defends (0.3)
- 1.3 Contributions — four items, one per downstream chapter (0.4)
- 1.4 Scope and non-goals — ticket and certificate abuse cited, not implemented (0.2)

### 2. Background: Windows Authentication from Zero — 4.0 p
- 2.1 Accounts, SIDs and the access token (0.5)
- 2.2 Where Windows keeps secrets — 2.2.1 LSASS as the credential-bearing process (0.3); 2.2.2 local and domain stores (0.3)
- 2.3 From password to key material — 2.3.1 the NT hash (0.4); 2.3.2 the derivation tree (0.4)
- 2.4 NTLM challenge-response — 2.4.1 the three message types (0.3); 2.4.2 v1 versus v2 (0.3); 2.4.3 session key derivation (0.2)
- 2.5 Kerberos in AD — 2.5.1 KDC, tickets, PAC (0.3); 2.5.2 pre-authentication (0.2); 2.5.3 encryption types and what keys them (0.2)
- 2.6 Which protocols carry which authentication — table (0.3)
- 2.7 Logon types and the token lifetime problem (0.3)

### 3. Credential Material as a Bearer Capability — 1.5 p
- 3.1 The unifying property (0.4)
- 3.2 Threat model and preconditions — 3.2.1 starting positions (0.3); 3.2.2 the four preconditions (0.4); 3.2.3 lateral movement, not escalation (0.3)
- 3.3 Taxonomy and position of this study (0.3)

### 4. Pass-the-Hash in Depth — 3.5 p
- 4.1 What the attacker actually holds (0.4)
- 4.2 Computing a valid response without the password — 4.2.1 the derivation (0.5); 4.2.2 why this is not replay (0.3); 4.2.3 two ways to pass it (0.3)
- 4.3 Consequences for signing and sealing (0.5)
- 4.4 Protocol coverage — 4.4.1 SMB (0.2); 4.4.2 WinRM (0.2); 4.4.3 WMI/DCOM (0.2); 4.4.4 RDP Restricted Admin (0.2); 4.4.5 secondary carriers (0.2)
- 4.5 Tooling landscape (0.4)

### 5. Pass-the-Key — 2.0 p
- 5.1 Why the NT hash is also a Kerberos key (0.5)
- 5.2 Building an AS-REQ from a key — 5.2.1 pre-auth with a key (0.4); 5.2.2 etype negotiation and the downgrade incentive (0.3)
- 5.3 What PtK buys over PtH (0.4)
- 5.4 Where PtK stops (0.4)

### 6. Proof-of-Concept — 3.0 p
- 6.1 Lab topology and isolation (0.4)
- 6.2 Identity and permission design (0.3)
- 6.3 Acquiring the material (0.4)
- 6.4 Scenario A — PtH over SMB (0.5)
- 6.5 Scenario B — PtH over WinRM (0.3)
- 6.6 Scenario C — PtK to a TGT (0.4) *[gate-dependent]*
- 6.7 Evidence collection (0.4)
- 6.8 Implementation and tooling (0.3)

### 7. Results — 1.5 p
- 7.1 Success matrix (0.5)
- 7.2 Captured evidence (0.5)
- 7.3 Boundaries observed (0.4)
- 7.4 Cost of the chain (0.3)

### 8. Detection — 1.5 p
- 8.1 Host telemetry that matters (0.6)
- 8.2 What the attack cannot hide (0.3)
- 8.3 Network-level signals (0.2)
- 8.4 Behavioural and deception controls (0.2)
- 8.5 From telemetry to a rule (0.2)

### 9. Effects and Mitigation — 2.0 p
- 9.1 Damage model (0.3)
- 9.2 Credential protection (0.5)
- 9.3 Protocol hardening (0.5)
- 9.4 Architectural controls (0.3)
- 9.5 Measured effectiveness in the lab (0.5)

### 10. When These Attacks Actually Work — 1.0 p
- 10.1 The precondition chain as a decision procedure (0.4)
- 10.2 Where it fails in a modern estate (0.3)
- 10.3 What survives the deprecation (0.3)

### 11. Conclusion — 0.5 p
No subsections by design: finding, numbers, the one control worth funding, residual risk.

### Back matter
- References — ~25 entries, numeric (1.0)
- A Lab Build · B Full Log Excerpts · C Capture Index · D Tool and Version Inventory

**Body total: ~22 pages including figures.** Figures cost ~6 pages: `fig-hash-derivation` (2.3),
`fig-ntlm-flow` (2.4), `fig-kerberos-flow` (2.5), `fig-locality` (4.2), `fig-lab-topology` (6.1),
`fig-success-matrix` (7.1), `fig-mitigation-matrix` (9.5).

**Structural rules held across the whole outline**
1. Every chapter assumes only what earlier chapters established — no forward references to
   undefined vocabulary.
2. Every subsection states a claim; a subsection that cannot is merged or cut.
3. Every claim in chapters 7 and 9 traces to a named artefact in `poc/evidence/`.
4. Negative results are mandatory in 7.3 and 9.5.

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
