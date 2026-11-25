# Windows Credential Reuse

**Pass-the-Hash and Pass-the-Key against NTLM and Kerberos**

An essay and a reproducible proof of concept on how Windows authenticates with derived key
material rather than with passwords, and what follows from that design choice.

---

## What this is

Both NTLM and Kerberos allow a client to complete authentication locally, from a secret that never
travels over the network. That is a deliberate design property, not a bug, and it is the reason no
cryptographic break is needed to defeat either protocol. An NT hash is not a stolen password
waiting to be cracked; it is a key, and possession of it is possession of the account.

The work covers Pass-the-Hash as the core case and Pass-the-Key as its Kerberos counterpart, since
both consume the same sixteen bytes. Ticket and certificate abuse rest on the same property and
are discussed as adjacent work rather than implemented.

The essay develops the subject from first principles — accounts and tokens, where Windows stores
secrets, how a password becomes a key, how NTLM proves possession of that key over the wire, how
Active Directory Kerberos does the same — before treating the attacks, the proof of concept, and
the controls that actually break the chain.

## Repository contents

| Path | Contents |
|---|---|
| `paper/` | The essay in LaTeX: `main.tex`, one file per section under `sections/`, bibliography in `refs.bib`, diagrams in `figures/` |
| `poc/lab/` | Virtual lab definition: host specifications, network configuration, snapshot policy |
| `poc/scripts/` | Environment bootstrap, scenario driver, evidence extraction |
| `poc/evidence/` | Curated log excerpts and command output behind every result |

## Structure of the essay

| | Chapter |
|---|---|
| 1 | Introduction |
| 2 | Background: Windows Authentication from Zero |
| 3 | Credential Material as a Bearer Capability |
| 4 | Pass-the-Hash in Depth |
| 5 | Pass-the-Key: the Kerberos Face of the Same Primitive |
| 6 | Proof-of-Concept: Environment and Implementation |
| 7 | Results |
| 8 | Detection |
| 9 | Effects and Mitigation |
| 10 | When These Attacks Actually Work |
| 11 | Conclusion |

Chapter 2 carries the vocabulary the rest of the paper relies on; later chapters assume it and
introduce no competing definitions.

## Building the paper

pdfLaTeX with Biber, no shell escape required:

```
cd paper
pdflatex main && biber main && pdflatex main && pdflatex main
```

Diagrams are authored by the team as TikZ or as draw.io sources exported to PDF, both committed
alongside the figure they produce.

## Reproducing the lab

Three hosts on an isolated host-only network: a domain controller, a Windows client, and an
attacker host. No bridged adapter and no outbound connectivity during execution. Snapshots are
taken before every scenario, and `poc/README.md` documents the build order, the identity design,
and the evidence each scenario is expected to produce.

No public, university, or third-party system was involved at any point.

## Licensing

Prose is released under CC BY 4.0; scripts under MIT. Third-party tools and documentation are
cited, not redistributed.
