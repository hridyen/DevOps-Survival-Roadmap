[![Sector](https://img.shields.io/badge/SECTOR-Advanced_Linux-00E5FF?style=flat-square&labelColor=0A0A0A)](#) [![Module](https://img.shields.io/badge/MODULE-Shell_Scripting_Commands-FF0055?style=flat-square&labelColor=0A0A0A)](#)

---

# ⌨️ Shell Scripting Logic Reference

## ✦ 1. Basic Operations

### ✦ Execution & Permissions
```bash
# Grant execution rights
chmod +x script.sh

# Run specifically with bash
bash script.sh

# Check for syntax errors without executing
bash -n script.sh
```

---

## ✦ 2. Conditional Logic (If/Else)

### ✦ Comparison Operators
```bash
# Numeric Comparisons
[ $a -eq $b ] # Equals
[ $a -ne $b ] # Not Equals
[ $a -gt $b ] # Greater Than
[ $a -lt $b ] # Less Than

# String Comparisons
[ "$a" == "$b" ] # String Matching
[ -z "$a" ]      # Is String Empty?
```

---

## ✦ 3. Loops (For/While)

### ✦ For Loop (List)
```bash
for name in "Alice" "Bob" "Charlie"; do
    echo "Processing $name..."
done
```

### ✦ While Loop (Command output)
```bash
while read line; do
    echo "Line: $line"
done < input.txt
```

---

## ✦ 4. Advanced Automation

### ✦ Read Command
```bash
read -p "Enter your deployment environment: " ENV
echo "Deploying to $ENV..."
```

### ✦ Case Statements
```bash
case $SERVICE in
    "start") systemctl start app ;;
    "stop")  systemctl stop app ;;
    *) echo "Usage: start|stop" ;;
esac
```
