# Figures

Every figure is authored by the team. Two accepted forms:

1. **TikZ** — preferred for protocol diagrams. One `.tex` file per figure in this directory,
   `\input` from the section that uses it. Diffs cleanly, no binary blobs.
2. **draw.io** — acceptable for topology-style diagrams. Commit the `.drawio` source **and** the
   exported `.pdf` with the same stem.

## Figures

| File | Chapter | Content |
|---|---|---|
| `fig-auth-timeline.tex` | 1 | The protocol generations, in order, with the dates the argument turns on |
| `fig-auth-mix.tex` | 1 | NTLM against the rest of observed authentication |
| `fig-server-versions.tex` | 1 | Share of servers still on a release past or near its support deadline |
| `fig-lm-nt.tex` | 2, primer | One password carried through both derivations with the real values |
| `fig-two-stores.tex` | 2.1 | One account record in the SAM hive and in NTDS.dit, with the shared fields banded |
| `fig-lsa-stack.tex` | 2.1 | LSASS, the LSA subsystem, and the packages it loads |
| `fig-token.tex` | 2.1 | What an access token carries |
| `fig-ntlm-flow.tex` | 2.3 | NEGOTIATE/CHALLENGE/AUTHENTICATE, with the Netlogon detour drawn dashed |
| `fig-kerberos-flow.tex` | 2.4 | AS-REQ/AS-REP/TGS-REQ/TGS-REP then AP-REQ/AP-REP, each with the key that protects it |
| `fig-pac.tex` | 2.4 | The PAC as the KDC writes it, with the two signatures under it |

Conventions: no more than two accent colours; every arrow carries the message name and, where it
matters, the key that protects it; a diagram that does not show *what is authenticated* is
decoration. Values in the sample records are illustrative and do not come from a real host.
