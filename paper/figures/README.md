# Figures

Every figure is authored by the team. Two accepted forms:

1. **TikZ** — preferred for protocol diagrams. One `.tex` file per figure in this directory,
   `\input` from the section that uses it. Diffs cleanly, no binary blobs.
2. **draw.io** — acceptable for topology-style diagrams. Commit the `.drawio` source **and** the
   exported `.pdf` with the same stem.

## Figures

| File | Chapter | Content | Status |
|---|---|---|---|
| `fig-sam-record.tex` | 2.1 | One account record, with the SID decomposed into authority, domain and RID | drawn |
| `fig-lm-nt.tex` | 2.2.2 | The same password reaching the NT hash and the LM hash, side by side | drawn |
| `fig-kerberos-flow.tex` | 2.5.1 | AS-REQ/AS-REP/TGS-REQ/TGS-REP, annotated with the key protecting each leg | drawn |
| `fig-hash-derivation.tex` | 2.3.2 | Password → NT hash → NTLM response and RC4 key; plaintext → AES keys | pending |
| `fig-ntlm-flow.tex` | 2.4.3 | Type 1/2/3 exchange with the response computation expanded | pending |
| `fig-locality.tex` | 4.2.3 | What crosses the wire vs what never leaves the host, NTLM beside Kerberos | pending |
| `fig-lab-topology` | 6.1 | Host-only network, three VM roles | pending |
| `fig-mitigation-matrix` | 9.5 | Control × scenario outcome | pending |

Conventions: no more than two accent colours; every arrow carries the message name and, where it
matters, the key that protects it; a diagram that does not show *what is authenticated* is
decoration. Values in the sample records are illustrative and do not come from a real host.
