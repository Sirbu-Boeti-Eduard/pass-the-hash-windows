# Figures

Every figure is authored by the team. Two accepted forms:

1. **TikZ** — preferred for protocol diagrams. One `.tex` file per figure in this directory,
   `\input` from the section that uses it. Diffs cleanly, no binary blobs.
2. **draw.io** — acceptable for topology-style diagrams. Commit the `.drawio` source **and** the
   exported `.pdf` with the same stem.

## Planned figures

| Key | Chapter | Content | Form |
|---|---|---|---|
| `fig-hash-derivation` | 2.3 | password → NT hash → NTLM response / RC4 key, and where AES sits outside | TikZ |
| `fig-ntlm-flow` | 2.4 | Type 1/2/3 exchange with the response computation expanded | TikZ |
| `fig-kerberos-flow` | 2.5 | AS-REQ/AS-REP/TGS with the key-derivation branch marked | TikZ |
| `fig-locality` | 4.2 | what crosses the wire vs what never leaves the host, NTLM beside Kerberos | TikZ |
| `fig-lab-topology` | 6.1 | host-only network, three VM roles | draw.io |
| `fig-success-matrix` | 7.1 | protocol × technique heatmap | table first, image only if needed |
| `fig-mitigation-matrix` | 9.5 | control × scenario outcome | TikZ |

Conventions: no more than two accent colours; label every arrow with the message name and, where
relevant, the field that carries the authenticator. A diagram that does not show *what is
authenticated* is decoration.
