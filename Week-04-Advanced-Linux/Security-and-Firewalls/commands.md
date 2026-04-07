[![Sector](https://img.shields.io/badge/SECTOR-Advanced_Linux-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Security_and_Firewalls_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⚡ Security Integrity — Commands Reference

---

## ✦ 🔐 Access Control Matrices (ACL)

```bash
# Evaluate Matrix
getfacl file.txt                    # Audits native permissions array

# Bind Matrix
setfacl -m u:bob:rw file.txt        # Explicitly targets user 'bob' allocating rw
setfacl -x u:bob file.txt           # Destroys bob's exact ACL parameter silently
setfacl -b file.txt                 # Obliterates the entire ACL logic completely!
```

---

## ✦ 🛠️ Sticky SUID & Execution Modifiers

```bash
# Structural Modifications
chmod u+s binary                    # Binds an SUID block onto a binary
chmod g+s directory/                # Binds an SGID block natively globally onto a folder
chmod +t /tmp                       # Toggles the native 'sticky' bit

# Vulnerability Audit Scans
find / -perm -u=s 2>/dev/null       # Discovers all SUID instances across the entire root topology
```

---

## ✦ 📝 My Security Audit Notes

| Command | What it does | Real-World Scenario |
|---------|-------------|----------------|
| `find / -perm -4000` | Similar to tracking `u=s`, this natively maps all SUID enabled directories. | Checking if any malicious actors successfully mapped an escalation script locally hidden within an arbitrary folder logic natively during a Pen-Test phase. |
| `nmcli connection up "Wired"` | Interfaces native network bridging natively through the CLI without GUI structures. | Automating Docker or physical daemon node initialization remotely bridging them online without physically handling network bounds. |
