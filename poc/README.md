# PoC — Reproduction Package

Public-repo requirement: someone with three VMs must be able to rebuild this lab and reach the
same result using only this directory.

> **Isolation.** Host-only virtual network. No bridged adapter, no port forwarding to the
> internet during execution. Snapshots taken before every scenario.

## Layout

```
poc/
├── lab/          VM specs, network config, snapshot names, build order
├── scripts/      bootstrap + scenario driver + evidence collection
└── evidence/     curated logs and command output (captures indexed, binaries out of git)
```

## Structure to fill in

**1. Lab build** (`lab/`)
- Hypervisor, host RAM/CPU budget, VM list with OS build numbers.
- DC promotion settings: domain name, DNS, functional level.
- Client join, local admin delegation, and the deliberate misconfiguration under test.
- Snapshot names: `clean`, `pre-attack-<scenario>`, `post-attack-<scenario>`.

**2. Scenarios** (`scripts/`)
- `A` PtH over SMB → remote execution.
- `B` PtH over WinRM.
- `C` PtK → TGT → service access. *(only if the 20 Dec gate keeps PtK in scope)*
- One entry point per scenario; no interactive steps that are not also in the README.

**3. Evidence** (`evidence/`)
- One directory per scenario: `<scenario>/<host>-security.txt`, `<scenario>/capture-index.md`,
  `<scenario>/transcript.txt`.
- Binaries (`.evtx`, `.pcapng`) stay out of git — commit the extracted excerpts plus an index
  with the original file name, host, and capture filter.
- Timestamps aligned to a single NTP source so logs from different hosts interleave.

## Reproducibility checklist (must pass before submission)

- [ ] Fresh clone → lab built → scenario A reproduced, using only README + `lab/`.
- [ ] Every figure in Results traces to a file in `evidence/`.
- [ ] Every command in the README has been re-run after the final lab snapshot.
- [ ] No credentials, hashes or keys committed (they are regenerated, not stored).

## What we do not build

We do not reimplement NTLM or Kerberos primitives. We orchestrate maintained tools, own the
environment bootstrap, and own the evidence pipeline. Any original code here is glue: setup,
scenario driving, log extraction and table generation.
