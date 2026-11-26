# Handoff

Everything a fresh session needs to continue this draft without the previous chat. Read this
first, then `README.md`, then the section you are about to work on.

---

## Where the draft stands

- **Chapter 1** — written. Preamble (the claim), 1.1 why a pentester should care (layering, three
  figures, sourced numbers), 1.2 what the article gives you (audience, skills argument), 1.3 scope.
- **Chapter 2** — unnumbered primer (hashes, protocols, services table) plus **2.1** accounts,
  SIDs, tokens and **2.2** where the hash lives are written. 2.3 to 2.10 are headings with
  `% WANT:` notes only.
- **Chapters 3 to 12** — headings and intent notes only.
- **PoC** — not built. The decision is recorded: skills, not scripts.

A skeleton that compiles is the normal state of the repo. Empty subsections carry `\unwritten`
(deliberately: see House rules) and a `% WANT:` comment describing the argument the section owes.

---

## The contract

**Audience.** Pentesters, people moving into internal Windows work, and the Linux admin who wants a
real answer about why the Windows estate behaves as it does. Assume they know RBAC, ACLs and
DACLs. Do not assume they know what LSASS, DPAPI, WDigest or a RID is.

**Voice.** A working pentester explaining the mechanism to a colleague. Declarative. No throat
clearing, no "in this section we will", no rhetorical questions, no addressing objections the
reader did not raise.

**The claim.** Both protocols authenticate on key material, not passwords, so possession of the
NT hash is possession of the account. Nothing is cracked and nothing is replayed.

**Academic requirement.** Present, minimal, and never the frame. Citations where a claim needs
one; no literature review, no contribution list, no "this paper defends one sentence".

**Scope.** Pass-the-hash and pass-the-key only, on Windows and Active Directory. Pass-the-ticket,
pass-the-certificate and pass-the-PRT are named as out of scope.

---

## House rules

- **Build and look.** `./build.sh`, then render the page you changed (`pdftoppm -png -r 110 -f N
  -l N build/main.pdf /tmp/x`) and read the image. "It compiles" is not verification.
- **Captions are labels.** One line, `\small`, descriptive only. Method, sampling, caveats and
  argument live in the paragraph that references the figure.
- **Reference every float from the prose** and put the explanation there, not in the caption.
- **Floats drift.** If a float lands in the wrong section, pin it with `[H]` (float package is
  loaded) instead of fighting placement.
- **Tables.** Column headers must explain the column in words the reader can act on (`shared
  field`, not a blank cell). Alternate grey bands (`\rowcolor{gray!7}`) plus `\addlinespace[3pt]`
  so a row can be tracked across four columns.
- **Headings with no body** give the page builder no legal break and produce blank pages. That is
  what `\unwritten` in `main.tex` is for. Delete it as prose lands.
- **No invented numbers.** Every figure in the text traces to a source in `refs.bib`. If no
  public number exists, say so in prose instead of estimating one.
- **No lab artefacts in theory chapters.** Screenshots, command output and `whoami /all` belong to
  chapter 6 onwards.
- Figures are `\input{figures/...}`, not `\includegraphics`. `_draft-v1/` is git-ignored; the
  pre-trim prose lives in git history.

---

## What the author rejects, with examples

These were all removed after review. Do not reintroduce the pattern.

| Rejected | Why |
|---|---|
| "The name needs one clarification before it carries any weight" | Reply-shaped: answers an objection nobody made. State the fact. |
| "For an engagement, none of this is background" | Same. It announced the point instead of making it. |
| Captions carrying "three vendors, three samples, roughly the same fraction" | Caption used as discussion. Move it into the paragraph. |
| A SAM-vs-NTDS table with `absent` and `—` cells | Made the left store look deficient, and it was not even true: SAM has local groups. |
| `pku2u` listed beside Kerberos in the LSA figure | Reads as "the Kerberos DLL". It is the peer-to-peer certificate package. |
| A `proof: not recorded` row in the token figure | Called out as looking like a placeholder. The prose carries the claim. |
| "The proof of concept ships as skills that drive the lab …" | Too abstract. Replaced with the maintenance argument and the NetExec `valid`-but-no-rights example. |
| A `whoami /all` sample in 2.1 | "This is pure theory. The lab is only in his chapter." |

## What the author expects

1. **Theory before prose.** He asks "what do you intend to write here exactly?" and wants a
   briefing he can argue with before the section is drafted. Answer with the mechanism, not a plan.
2. **Explain what he cannot defend.** If a claim would collapse under "why?", it needs a sentence
   of mechanism in the text, not only in the chat.
3. **Iteration is normal.** 2.2 took three passes: first draft, table-first restructure, then
   tightening. Expect 2–4 passes per section and treat each one as a rewrite, not a patch.
4. **Restructure on request, not just edit.** When he says "drop 2.1 and tie it to chapter 2", he
   means move the content and fix the numbering, not add a heading.
5. **Bullets only for enumeration.** RIDs, acquisition methods, services: yes. Arguments: prose.
6. **Exact terminology.** LSA is a subsystem inside `lsass.exe`; the SRM is kernel-mode; a SID is
   an identifier, never an authenticator; `etype`, `logon type`, RID and PAC keep their names.
7. **Typography is content.** He reads the PDF and notices uneven row spacing, drifting floats and
   lists split across pages.

---

## Next, in order

1. **2.3 From password to key material** — the NT hash as unsalted MD4; why that is right for
   logon and fatal for reuse; LM as the legacy sibling. No figure needed yet.
2. **2.4 The derivation tree** — one figure: password → NT hash → NTLM response; → RC4 key;
   password → AES keys via PBKDF2. The asymmetry bounds the whole article.
3. **2.5 NTLM in three messages** — NEGOTIATE/CHALLENGE/AUTHENTICATE, then v1 vs v2. The five-value
   table is already archived in `_draft-v1/04-pth.tex` if it is wanted back.
4. **2.6 Why a captured NTLMv2 is not a hash** — the misunderstanding most readers bring.
5. **2.7 AD Kerberos** — four messages, PAC, pre-auth; `fig-kerberos-flow.tex` already exists.
6. **2.8 Encryption types** — RC4 key == NT hash; AES from plaintext. This is the hinge for 5.
7. **2.9 Carriers** — do **not** repeat Table 1. The angle here is which mechanism each service
   accepts by default and whether it can be restricted.
8. **2.10 Logon types** — 2/9/10 retain material, 3 does not.

Then chapters 3 to 12 in order. The PoC (chapter 6) is where skills get specified, and chapter 7
is where the captured logs land.

---

## Traps

- `build.sh` restages `build/` and rewrites the staged `main.tex`. Two builds at once will race.
- It also drops the abstract while it is under 20 words ("abstract omitted" in the output).
- A heading run with no paragraphs is unbreakable and produces a blank page plus an overfull page;
  `\unwritten` exists for exactly that and can be removed later without harm.
- The text width is 15.8 cm. Anything wider shows up as an Overfull hbox in the build output.
