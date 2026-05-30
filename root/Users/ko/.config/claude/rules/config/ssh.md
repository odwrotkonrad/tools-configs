---
paths:
  - "**/.ssh/**"
  - "**/ssh/**"
  - "**/ssh_config"
  - "**/sshd_config"
---

## SSH Config

### Files

```yml
root/Users/ko/.ssh/:
  config:  # client config
```

### Documentation

`$ man`:

- `ssh` — client invocation, options, escapes, exit status
- `ssh_config` — client config keys, Host/Match, includes, precedence
- `ssh-keygen` — key gen/convert, fingerprints, signing, certs, moduli
- `ssh-agent` — agent protocol, lifetime, env, forwarding
- `ssh-add` — load/list/remove keys, lifetime, confirmation
- `scp` — copy over ssh, flags, remote paths
- `sftp` — interactive/batch file transfer, commands
- `sshd_config` — server config keys (reference for matching client opts)
- `moduli` — DH group format for kexalgorithms

#### Algorithms

Acceptable algorithm names for `Ciphers`, `MACs`, `KexAlgorithms`,
`HostKeyAlgorithms`, `PubkeyAcceptedAlgorithms`, `CASignatureAlgorithms`:

- `$ ssh -Q cipher` / `-Q mac` / `-Q kex` / `-Q key` / `-Q sig`
- `$ man ssh_config` — per-keyword DEFAULT lists and full sets
