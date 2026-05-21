# ✦ Linux & Networking Scenario-Based Interview Questions

This section compiles **100 scenario-based interview questions and answers** covering Linux System Administration, Performance Tuning, Disk Management, and Network Troubleshooting.

---

## ✦ Section 1: System Performance & Troubleshooting (Questions 1-20)

<details>
<summary><b>Q1: Scenario: CPU usage is at 100% on a production server. How do you find the exact process and thread causing this?</b></summary>
Run `top` or `htop`. In `top`, press `P` to sort by CPU usage. To view threads inside the process, run `top -H -p <PID>` or `ps -Lf -p <PID>` to see the LWP (Light Weight Process) IDs.
</details>

<details>
<summary><b>Q2: Scenario: A server has high load average, but CPU utilization is low. What is likely happening?</b></summary>
The system is experiencing high disk I/O bottlenecks or waiting on network storage (NFS/EBS). Check the `iowait` percentage using `iostat -x 1 5` or `sar -u 1`. The processes are stuck in the uninterruptible sleep state (`D` state in `ps`).
</details>

<details>
<summary><b>Q3: Scenario: An application fails with "Out of Memory" (OOM). How do you verify if the Linux kernel killed it?</b></summary>
Inspect system logs using `dmesg -T | grep -i oom` or inspect `/var/log/messages` / `/var/log/syslog` for "Out of memory: Kill process".
</details>

<details>
<summary><b>Q4: Scenario: A critical daemon is frequently crashing. How do you configure Linux to generate core dumps for debugging?</b></summary>
Set `ulimit -c unlimited` in the user session or configure it globally in `/etc/security/limits.conf`. Ensure `/proc/sys/kernel/core_pattern` is configured to output dump files to a specific directory.
</details>

<details>
<summary><b>Q5: Scenario: You need to run a command that will take 5 hours, but your SSH session might disconnect. How do you handle this?</b></summary>
Run the command inside a terminal multiplexer like `tmux` or `screen`. Alternatively, run it using `nohup <command> > output.log 2>&1 &` to run it in the background immune to hangup signals.
</details>

<details>
<summary><b>Q6: Scenario: A system has 8GB RAM, and 7.8GB is shown as "used", but the application isn't slow. Is there a problem?</b></summary>
No. Linux uses free memory for disk caching/buffering to speed up operations. Look at the `available` column in `free -m` to determine actual memory available for application use.
</details>

<details>
<summary><b>Q7: Scenario: A specific process is running wild and you need to limit its CPU usage dynamically without killing it. How?</b></summary>
Use `cpulimit` (e.g., `cpulimit -p <PID> -l 50` to restrict it to 50%) or move the process to a custom `cgroup` with restricted CPU shares.
</details>

<details>
<summary><b>Q8: Scenario: You need to identify which open files and network sockets are owned by a specific PID. What do you run?</b></summary>
Run `lsof -p <PID>` or inspect the symbolic links under the directory `/proc/<PID>/fd/`.
</details>

<details>
<summary><b>Q9: Scenario: An application is performing sluggishly. How do you trace all system calls and signals executed by this PID?</b></summary>
Run `strace -p <PID> -f -c` to attach to the process and summarize system calls, or omit `-c` to stream the system calls in real time.
</details>

<details>
<summary><b>Q10: Scenario: A user reports that system time is drifting on a VM. How do you force sync the time and verify synchronization?</b></summary>
Verify status using `timedatectl status` or `chronyc tracking`. Force synchronization by running `chronyc -a makestep` or restarting the NTP daemon.
</details>

<details>
<summary><b>Q11: Scenario: You need to find all zombie processes on a system. What do they represent and how do you clear them?</b></summary>
Zombie processes (`Z` state in `top` / `ps`) are terminated processes whose parent has not yet read their exit status. They can be found with `ps aux | awk '"[Zz]" ~ $8'`. They can only be cleared by sending `SIGCHLD` to the parent process or killing the parent process (`kill -9 <parent_PID>`).
</details>

<details>
<summary><b>Q12: Scenario: How do you identify which process is causing high write rates to the disk in real-time?</b></summary>
Install and run `iotop` with the `-o` flag (`iotop -o`) to show only the processes actually performing I/O operations.
</details>

<details>
<summary><b>Q13: Scenario: How do you verify the boot hardware logs and driver errors after a server crash?</b></summary>
Run the `dmesg` command or check the `/var/log/dmesg` log file. For systemd systems, use `journalctl -k -b -1` to inspect kernel logs from the previous boot.
</details>

<details>
<summary><b>Q14: Scenario: An application fails to bind to port 80 because it is already in use. How do you find the offending process?</b></summary>
Run `sudo ss -tulpn | grep :80` or `sudo netstat -tulpn | grep :80` to find the PID and binary name using the port.
</details>

<details>
<summary><b>Q15: Scenario: You need to change the priority (niceness) of an already running process with PID 1234 to be lower. What command do you use?</b></summary>
Run `renice -n 10 -p 1234` (where positive numbers represent lower priority and negative numbers represent higher priority).
</details>

<details>
<summary><b>Q16: Scenario: How do you find which shared libraries a binary depends on at runtime?</b></summary>
Run the `ldd` command followed by the path of the binary (e.g., `ldd /usr/bin/nginx`).
</details>

<details>
<summary><b>Q17: Scenario: A server freezes randomly. You suspect hardware issues or bad RAM. How do you check memory health in Linux?</b></summary>
Check `/var/log/mcelog` for machine check exceptions, or reboot the server and choose `Memtest86+` from the GRUB bootloader menu.
</details>

<details>
<summary><b>Q18: Scenario: You need to execute a system command every 10 seconds. Since cron only supports minutes, how do you achieve this?</b></summary>
Write a simple bash daemon loop:
```bash
while true; do /path/to/script.sh & sleep 10; done
```
</details>

<details>
<summary><b>Q19: Scenario: A configuration change requires updating kernel parameters without rebooting. What do you run?</b></summary>
Edit `/etc/sysctl.conf` with the new parameters, then run `sudo sysctl -p` to load and apply them immediately.
</details>

<details>
<summary><b>Q20: Scenario: A process cannot open any more files, throwing "Too many open files" error. How do you resolve this?</b></summary>
Check the current limit with `ulimit -n`. Increase it by editing `/etc/security/limits.conf` to set higher soft and hard limits for the user (e.g., `* soft nofile 65536`).
</details>

---

## ✦ Section 2: Disk Management & Filesystems (Questions 21-40)

<details>
<summary><b>Q21: Scenario: Disk space is at 100% according to `df -h`, but `du -sh /*` does not show where the files are. What is happening?</b></summary>
A process is holding deleted files open. The space is not reclaimed because the file handles are active. Find the files and PIDs with `sudo lsof +L1` or `sudo lsof | grep deleted`, and restart the processes holding those file handles.
</details>

<details>
<summary><b>Q22: Scenario: A disk has plenty of free space in GB, but applications fail with "No space left on device". What is the cause?</b></summary>
The filesystem has run out of inodes. Verify using `df -i`. You must delete millions of tiny files (like session files or email queues) to free up inodes.
</details>

<details>
<summary><b>Q23: Scenario: How do you mount a new block device `/dev/xvdf` to `/data` permanently so it survives server reboots?</b></summary>
Find the UUID of the drive using `blkid /dev/xvdf`. Add an entry to `/etc/fstab`:
```text
UUID=xxxx-xxxx-xxxx  /data  ext4  defaults,nofail  0  2
```
Test with `mount -a` to verify there are no errors before rebooting.
</details>

<details>
<summary><b>Q24: Scenario: You need to expand a logical volume (LVM) named `/dev/vg0/lv_root` dynamically using a new physical disk `/dev/sdb`. What are the steps?</b></summary>
1. Initialize the physical volume: `pvcreate /dev/sdb`
2. Extend the Volume Group: `vgextend vg0 /dev/sdb`
3. Extend the Logical Volume and resize the filesystem: `lvextend -r -l +100%FREE /dev/vg0/lv_root` (the `-r` flag resizes ext4/xfs automatically).
</details>

<details>
<summary><b>Q25: Scenario: A filesystem is mounted as read-only. How do you remount it as read-write without disrupting applications?</b></summary>
Run `sudo mount -o remount,rw /mountpoint`. Check `dmesg` if this fails, as filesystems remount as read-only automatically when encountering storage errors.
</details>

<details>
<summary><b>Q26: Scenario: You suspect block level corruption on a disk partition `/dev/sdb1`. How do you scan and repair it safely?</b></summary>
Unmount the device first: `sudo umount /dev/sdb1`. Run the filesystem check tool: `sudo fsck -y /dev/sdb1`. XFS drives should use `xfs_repair`.
</details>

<details>
<summary><b>Q27: Scenario: A team wants to share a directory `/shared` where any new file created automatically belongs to the group of the parent directory. How?</b></summary>
Set the SGID (Set Group ID) permission bit on the directory:
```bash
chmod g+s /shared
```
</details>

<details>
<summary><b>Q28: Scenario: You need to find all files larger than 500MB modified in the last 48 hours. What find command do you execute?</b></summary>
Run:
```bash
find / -type f -size +500M -mtime -2
```
</details>

<details>
<summary><b>Q29: Scenario: How do you configure a directory so users can only delete files they personally own, even if others have write access?</b></summary>
Set the Sticky Bit permission on the directory:
```bash
chmod +t /path/to/directory
```
</details>

<details>
<summary><b>Q30: Scenario: How do you identify which filesystem type (e.g., ext4, xfs, nfs) is mounted on `/opt`?</b></summary>
Run `df -T /opt` or check the mount details using `findmnt /opt`.
</details>

<details>
<summary><b>Q31: Scenario: You need to securely wipe a disk `/dev/sdc` before decommissioning the hardware. How do you write random data to it?</b></summary>
Run:
```bash
sudo dd if=/dev/urandom of=/dev/sdc bs=4M status=progress
```
</details>

<details>
<summary><b>Q32: Scenario: A server boot is stuck at GRUB due to a filesystem corruption error. How do you enter maintenance mode?</b></summary>
Reboot, edit the GRUB boot menu command by pressing `e`, append `init=/bin/sh` or `systemd.unit=emergency.target` to the kernel command line, and press `Ctrl+X` to boot.
</details>

<details>
<summary><b>Q33: Scenario: How do you locate the absolute path of the block device from which the root filesystem is mounted?</b></summary>
Run `findmnt -n -o SOURCE /`.
</details>

<details>
<summary><b>Q34: Scenario: An NFS share `/mnt/nfs` becomes unresponsive and freezes any terminal that accesses it. How do you force unmount it?</b></summary>
Run:
```bash
sudo umount -f -l /mnt/nfs
```
(Force and lazy unmount).
</details>

<details>
<summary><b>Q35: Scenario: You want to monitor read/write operations per second (IOPS) on a disk device `/dev/sda` in real-time. What do you run?</b></summary>
Run:
```bash
iostat -d -x 2 /dev/sda
```
</details>

<details>
<summary><b>Q36: Scenario: How do you back up a raw partition `/dev/sdb1` to an image file `/backup/sdb1.img` compressed on the fly?</b></summary>
Run:
```bash
sudo dd if=/dev/sdb1 | gzip > /backup/sdb1.img.gz
```
</details>

<details>
<summary><b>Q37: Scenario: A directory contains millions of files and running `rm -rf *` fails with "Argument list too long". How do you delete them?</b></summary>
Use `find` with `-delete` or pipe to `xargs`:
```bash
find . -type f -delete
```
</details>

<details>
<summary><b>Q38: Scenario: You need to set file execution permissions but exclude directories from the change. How do you do this recursively?</b></summary>
Run:
```bash
find /path -type f -exec chmod +x {} +
```
</details>

<details>
<summary><b>Q39: Scenario: How do you verify the partition table type (GPT vs MBR) of `/dev/sda`?</b></summary>
Run `sudo parted /dev/sda print` or `sudo gdisk -l /dev/sda`.
</details>

<details>
<summary><b>Q40: Scenario: A developer wants to sync two directories `/src` and `/dst` while preserving permissions, symlinks, and copying only changed files. What do you run?</b></summary>
Run:
```bash
rsync -avz --delete /src/ /dst/
```
</details>

---

## ✦ Section 3: User Management, Permissions & Access Control (Questions 41-60)

<details>
<summary><b>Q41: Scenario: A user cannot write to `/opt/app` despite belonging to the group that owns the directory. What should you check?</b></summary>
Verify the directory permissions (ensure write bit is set for group: `chmod g+w`). Verify if the user's shell session group membership is updated by running `id` or logging out and back in. Check ACL permissions with `getfacl /opt/app`.
</details>

<details>
<summary><b>Q42: Scenario: How do you lock a user account named `developer` immediately to prevent login access without deleting their files?</b></summary>
Run `sudo usermod -L developer` or `sudo passwd -l developer`. To block ssh keys, expire the account using `sudo chage -E 0 developer`.
</details>

<details>
<summary><b>Q43: Scenario: A script needs to run as root, but standard users must execute it without using sudo or password prompts. How?</b></summary>
Set the SUID (Set Owner User ID) bit on the binary (ensure owner is root):
```bash
sudo chown root /path/to/binary
sudo chmod u+s /path/to/binary
```
Note: Standard shell scripts ignore SUID for security reasons; this applies to compiled binaries.
</details>

<details>
<summary><b>Q44: Scenario: You need to enforce a policy where users must change their password every 90 days. What command configures this?</b></summary>
Run `sudo chage -M 90 <username>` or modify the default policies in `/etc/login.defs`.
</details>

<details>
<summary><b>Q45: Scenario: You need to grant a specific user `john` read-only access to `/var/log/audit/` without changing ownership or standard octal permissions. How?</b></summary>
Use POSIX Access Control Lists (ACLs):
```bash
sudo setfacl -m u:john:r-- /var/log/audit/
```
</details>

<details>
<summary><b>Q46: Scenario: How do you add an existing user `alice` to a secondary group `docker` without removing her from her primary group?</b></summary>
Run:
```bash
sudo usermod -aG docker alice
```
</details>

<details>
<summary><b>Q47: Scenario: A system administrator modified a user’s groups, but the changes do not apply to their active shell. How to reload groups without logging out?</b></summary>
Run `newgrp docker` (substituting the modified group name).
</details>

<details>
<summary><b>Q48: Scenario: You need to change the owner of `/web` to `nginx` and group to `www-data` recursively. What is the command?</b></summary>
Run:
```bash
sudo chown -R nginx:www-data /web
```
</details>

<details>
<summary><b>Q49: Scenario: How do you check which users have password logins enabled (instead of locked accounts) on a Linux node?</b></summary>
Check `/etc/shadow` file entries; accounts with a password hash instead of `!` or `*` are active. Or run:
```bash
sudo passwd -S -a | grep -v "Password locked"
```
</details>

<details>
<summary><b>Q50: Scenario: How do you prevent standard users from viewing the output of the system logs command `dmesg`?</b></summary>
Restrict access by setting kernel parameter:
```bash
sudo sysctl -w kernel.dmesg_restrict=1
```
</details>

<details>
<summary><b>Q51: Scenario: You need to configure a new system user `deploy` with no interactive login shell. How do you create it?</b></summary>
Run:
```bash
sudo useradd -s /sbin/nologin -M deploy
```
</details>

<details>
<summary><b>Q52: Scenario: How do you see the history of commands executed by all users on a server?</b></summary>
Inspect the `bash_history` files in `/home/*/.bash_history` and `/root/.bash_history`, or check system logs if shell accounting/auditd is enabled.
</details>

<details>
<summary><b>Q53: Scenario: How do you find which user group owns a file with GID 1005 when the group name has been deleted?</b></summary>
Search using GID:
```bash
find / -gid 1005 2>/dev/null
```
</details>

<details>
<summary><b>Q54: Scenario: You want to configure sudoers so members of group `sysadmin` can run systemctl commands without a password. What configuration entry do you use?</b></summary>
Run `sudo visudo` and add:
```text
%sysadmin ALL=(ALL) NOPASSWD: /usr/bin/systemctl
```
</details>

<details>
<summary><b>Q55: Scenario: You need to identify what permissions a default directory will receive when created by a process. What controls this?</b></summary>
The file mode creation mask (`umask`). Running `umask` shows the current octal mask (e.g., `0022` results in default folder permissions of `0755`).
</details>

<details>
<summary><b>Q56: Scenario: How do you find all files that have write permissions enabled for "everyone" (world-writable) in `/var`?</b></summary>
Run:
```bash
find /var -type f -perm -0002 2>/dev/null
```
</details>

<details>
<summary><b>Q57: Scenario: A user complains their SSH key is rejected with "Permissions for id_rsa are too open". How do you resolve this?</b></summary>
Restrict permissions on the private key file:
```bash
chmod 600 ~/.ssh/id_rsa
```
Ensure directory has proper permissions: `chmod 700 ~/.ssh`.
</details>

<details>
<summary><b>Q58: Scenario: How do you list the expiration dates of all system passwords?</b></summary>
Run:
```bash
sudo chage -l <username>
```
</details>

<details>
<summary><b>Q59: Scenario: How do you delete a user account named `tempuser` along with their home directory and mail spool?</b></summary>
Run:
```bash
sudo userdel -r tempuser
```
</details>

<details>
<summary><b>Q60: Scenario: How do you switch permissions on `/data/file.txt` from octal format `644` to symbolic syntax?</b></summary>
Run:
```bash
chmod u=rw,g=r,o=r /data/file.txt
```
</details>

---

## ✦ Section 4: Network Connectivity & Routing (Questions 61-80)

<details>
<summary><b>Q61: Scenario: You can ping an IP address, but you cannot connect to Nginx on port 80. How do you troubleshoot?</b></summary>
Ping only verifies ICMP. Test TCP connectivity on port 80 using `telnet <IP> 80`, `nc -zv <IP> 80`, or `curl -I <IP>:80`. Verify if Nginx is listening (`ss -tulpn | grep 80`) and if firewalls (iptables/ufw) are blocking the port.
</details>

<details>
<summary><b>Q62: Scenario: A server cannot resolve DNS queries, but you can ping `8.8.8.8`. What configuration is broken?</b></summary>
The DNS server configurations are missing or incorrect in `/etc/resolv.conf`. Add a working nameserver entry (e.g., `nameserver 8.8.8.8`) to the file.
</details>

<details>
<summary><b>Q63: Scenario: How do you trace the network path and hop count from your server to `api.github.com`?</b></summary>
Run `traceroute api.github.com` (uses UDP/ICMP) or `tcptraceroute api.github.com -p 443` (bypasses firewall blocks on TCP port 443).
</details>

<details>
<summary><b>Q64: Scenario: You need to capture live network packets matching TCP port 3306 on interface `eth0`. What command do you run?</b></summary>
Run:
```bash
sudo tcpdump -i eth0 port 3306 -nn -vv
```
To save the output for Wireshark inspection, append `-w mysql.pcap`.
</details>

<details>
<summary><b>Q65: Scenario: A service needs to communicate with a remote subnet `192.168.10.0/24` via a specific gateway IP `10.0.0.254`. How do you add this route permanently?</b></summary>
Add a static route:
```bash
sudo ip route add 192.168.10.0/24 via 10.0.0.254 dev eth0
```
To persist this, configure `/etc/sysconfig/network-scripts/route-eth0` (RedHat) or `/etc/netplan/*.yaml` (Ubuntu).
</details>

<details>
<summary><b>Q66: Scenario: How do you verify the current IP routing table of a Linux machine?</b></summary>
Run `ip route show` or `route -n` or `netstat -rn`.
</details>

<details>
<summary><b>Q67: Scenario: A server has two network interfaces (`eth0`, `eth1`). You need to check if the link is physically connected on `eth1`. How?</b></summary>
Run `ip link show eth1` or use `ethtool eth1` and check the "Link detected: yes/no" line.
</details>

<details>
<summary><b>Q68: Scenario: How do you find the public IP address of your server using a single terminal command?</b></summary>
Run:
```bash
curl ifconfig.me
```
or `curl icanhazip.com`.
</details>

<details>
<summary><b>Q69: Scenario: A system has high TCP packet loss. How do you check network stats and interface errors?</b></summary>
Run `ip -s link show eth0` to inspect packets dropped/errors, or use `netstat -s` to view global TCP protocol statistics.
</details>

<details>
<summary><b>Q70: Scenario: How do you configure Linux to forward packets between interfaces (act as a router)?</b></summary>
Enable packet forwarding temporarily:
```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```
To persist, set `net.ipv4.ip_forward = 1` in `/etc/sysctl.conf` and reload with `sysctl -p`.
</details>

<details>
<summary><b>Q71: Scenario: You want to query the TXT records of domain `example.com`. What command do you use?</b></summary>
Run:
```bash
dig example.com TXT
```
or `nslookup -type=txt example.com`.
</details>

<details>
<summary><b>Q72: Scenario: How do you find the MAC address of the default interface?</b></summary>
Run `ip link show` or `ip addr show` and look for the `link/ether` line.
</details>

<details>
<summary><b>Q73: Scenario: You suspect someone is scanning your system ports. How do you list all active TCP connections showing remote IP addresses?</b></summary>
Run:
```bash
ss -ta
```
or `netstat -nat`.
</details>

<details>
<summary><b>Q74: Scenario: How do you force clear/flush the local system DNS resolver cache on systemd resolved nodes?</b></summary>
Run:
```bash
sudo resolvectl flush-caches
```
Verify cache stats using `resolvectl statistics`.
</details>

<details>
<summary><b>Q75: Scenario: You need to set the MTU (Maximum Transmission Unit) of interface `eth0` to 9000 bytes (Jumbo Frames). What command do you run?</b></summary>
Run:
```bash
sudo ip link set dev eth0 mtu 9000
```
</details>

<details>
<summary><b>Q76: Scenario: How do you find which geographic location or organization owns the IP address `8.8.8.8`?</b></summary>
Run:
```bash
whois 8.8.8.8
```
</details>

<details>
<summary><b>Q77: Scenario: A remote service port is closed. How do you scan the remote system to see which ports are actually open?</b></summary>
Run:
```bash
nmap -F <remote_host_ip>
```
</details>

<details>
<summary><b>Q78: Scenario: You need to bind a virtual IP `192.168.1.100` temporarily to an existing interface `eth0`. How?</b></summary>
Create an IP alias:
```bash
sudo ip addr add 192.168.1.100/24 dev eth0 label eth0:1
```
</details>

<details>
<summary><b>Q79: Scenario: How do you block all incoming connections from a specific hostile IP address `203.0.113.50` using iptables?</b></summary>
Run:
```bash
sudo iptables -A INPUT -s 203.0.113.50 -j DROP
```
Save the rules to persist.
</details>

<details>
<summary><b>Q80: Scenario: How do you test the upload/download bandwidth speed directly from the Linux CLI?</b></summary>
Install and run the `speedtest-cli` command-line utility.
</details>

---

## ✦ Section 5: DNS, Services & Firewalls (Questions 81-100)

<details>
<summary><b>Q81: Scenario: Nginx fails to restart and complains that a socket configuration is invalid. How do you test Nginx syntax configuration?</b></summary>
Run:
```bash
sudo nginx -t
```
This parses Nginx configuration files and prints syntax errors/locations.
</details>

<details>
<summary><b>Q82: Scenario: How do you check if Nginx system service is set to start automatically at boot time?</b></summary>
Run:
```bash
systemctl is-enabled nginx
```
If disabled, enable it using `systemctl enable nginx`.
</details>

<details>
<summary><b>Q83: Scenario: How do you view live system logs for the Nginx service as they update?</b></summary>
Run:
```bash
journalctl -u nginx.service -f
```
</details>

<details>
<summary><b>Q84: Scenario: You want to forward local port 8080 to a remote server's port 80 over SSH securely. What command do you run?</b></summary>
Establish a local port forward:
```bash
ssh -L 8080:localhost:80 user@remote-ip
```
Now, navigating to `localhost:8080` locally connects you to port 80 of the remote server.
</details>

<details>
<summary><b>Q85: Scenario: You want to allow traffic on port 443 (HTTPS) through UFW (Uncomplicated Firewall) on Ubuntu. What is the command?</b></summary>
Run:
```bash
sudo ufw allow 443/tcp
```
Reload with `sudo ufw reload`.
</details>

<details>
<summary><b>Q86: Scenario: How do you resolve `/etc/hosts` overriding DNS nameserver lookups? Which configuration file controls this priority order?</b></summary>
Verify `/etc/nsswitch.conf`. Look for `hosts: files dns`, which ensures `/etc/hosts` (files) takes precedence over nameservers (dns).
</details>

<details>
<summary><b>Q87: Scenario: A service fails with "Address already in use". How do you force kill the process that is listening on TCP port 9000?</b></summary>
Find the PID using `fuser -k 9000/tcp` or `kill -9 $(lsof -t -i:9000)`.
</details>

<details>
<summary><b>Q88: Scenario: You need to view the SSL certificate details of a remote web server `google.com:443` from the CLI. What do you run?</b></summary>
Use `openssl`:
```bash
openssl s_client -connect google.com:443 -showcerts
```
</details>

<details>
<summary><b>Q89: Scenario: How do you edit systemd service configurations for a service named `customapp` overrides without modifying the main `/lib/systemd/system/` file?</b></summary>
Run:
```bash
sudo systemctl edit customapp
```
This creates an override file under `/etc/systemd/system/customapp.service.d/override.conf`. Reload daemon: `systemctl daemon-reload`.
</details>

<details>
<summary><b>Q90: Scenario: How do you configure Nginx as a reverse proxy for an application running locally on port 5000?</b></summary>
Add a proxy pass configuration to `/etc/nginx/nginx.conf` location block:
```nginx
location / {
    proxy_pass http://localhost:5000;
    proxy_set_header Host $host;
}
```
</details>

<details>
<summary><b>Q91: Scenario: You need to check the HTTP header response codes returned by `https://httpbin.org/status/404` without downloading the payload. How?</b></summary>
Run:
```bash
curl -I https://httpbin.org/status/404
```
</details>

<details>
<summary><b>Q92: Scenario: How do you list all systemd units that failed to load or run on the current boot?</b></summary>
Run:
```bash
systemctl --failed
```
</details>

<details>
<summary><b>Q93: Scenario: How do you find which process spawned PID 4500?</b></summary>
Find parent PID:
```bash
ps -o ppid= -p 4500
```
</details>

<details>
<summary><b>Q94: Scenario: You need to download a file from an FTP server using curl, providing credentials. How do you do this?</b></summary>
Run:
```bash
curl -u username:password ftp://server/file.txt -O
```
</details>

<details>
<summary><b>Q95: Scenario: You want to redirect all HTTP traffic on port 80 to HTTPS port 443 at Nginx block level. How?</b></summary>
Add a server block rule:
```nginx
server {
    listen 80;
    server_name example.com;
    return 301 https://$host$request_uri;
}
```
</details>

<details>
<summary><b>Q96: Scenario: How do you check which nameservers resolved a DNS request for a domain step by step from the root server down?</b></summary>
Run:
```bash
dig +trace example.com
```
</details>

<details>
<summary><b>Q97: Scenario: A system security audit asks to disable SSH Root Login. Which file do you edit and what parameter?</b></summary>
Edit `/etc/ssh/sshd_config`, set `PermitRootLogin no`, and run `sudo systemctl restart sshd`.
</details>

<details>
<summary><b>Q98: Scenario: You need to verify if port 25 (SMTP) is blocked by your ISP outbound. What command helps?</b></summary>
Run:
```bash
nc -w 5 -zv portquiz.net 25
```
(Using the portquiz network check service).
</details>

<details>
<summary><b>Q99: Scenario: How do you capture packet headers on interface `eth0` and print payload in ASCII?</b></summary>
Run:
```bash
sudo tcpdump -i eth0 -A -c 10
```
</details>

<details>
<summary><b>Q100: Scenario: How do you verify the system limits for the maximum number of network sockets that can be opened concurrently?</b></summary>
Run:
```bash
cat /proc/sys/fs/file-max
```
</details>
