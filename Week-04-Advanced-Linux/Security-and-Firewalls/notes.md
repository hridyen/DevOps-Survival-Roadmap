[![Sector](https://img.shields.io/badge/SECTOR-Advanced_Linux-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Security_and_Firewalls_Notes-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Advanced Security Protocols

> **Focus:** Explicit user security, File-level ACL bounds, System execution masking (SUID), and Network overrides.

---

## ✦ 1. ACLs (Access Control Lists)

Traditional Linux limits properties strictly to ONE Owner and ONE Group natively. ACL fundamentally breaks this limitation allowing multiple heterogeneous access allocations.

| Capability | Effect on Production Environments |
|---|---|
| **Multiple Profile Bounds** | Easily grants Bob read access, drops Alice's execution rights, and grants Jenkins writing capability on a singular file. |
| **Mask Tracking** | Guarantees that even if standard commands map 777 permissions loosely, the ACL securely holds the line blocking unwanted manipulation. |

---

## ✦ 2. Security Context Architectures (SUID & SGID)

Linux uses specific "Sticky bits" natively affecting inheritance mappings and execution identities.

- **SUID** *(Set User ID)*: Forces a binary file to run under the specific authority of its creator, strictly ignoring whoever actually executed it. Extremely dangerous natively.
- **SGID** *(Set Group ID)*: Forces any files generated dynamically inside a directory to aggressively inherit the Directory's native group protocol, overwriting the creator's group identity natively.

---

## ✦ 3. The `wheel` Group Paradigm

In CentOS and Red Hat topologies physically authorizing user `sudo` abilities utilizes an explicit local security Group mapping known as the Wheel. Administrative bounds natively lock root escalation logic strictly into this specific usergroup configuration context.

```bash
usermod -aG wheel username
```

> [!WARNING]
> By default Debian distributions bypass this `wheel` paradigm locally and utilize the `sudo` user group strictly instead for validation matrices!

---

## ✦ Practice Exercises
- [ ] Initialize an ACL binding utilizing `setfacl` to forcibly drop any execution power from an arbitrary text file you do not legitimately own. 
- [ ] Configure `nmcli` to rapidly drop `Wired connection 1` off the grid locally mapping the changes onto your outbound routes natively.
