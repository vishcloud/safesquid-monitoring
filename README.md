# monitor.sh - System Resource Monitoring Script

This Bash script provides real-time monitoring of CPU, memory, disk, network, process, and service status on a Linux system. It is especially useful for keeping track of performance metrics on virtual machines, including proxy servers like SafeSquid.

---

## 🔧 Features

- Top 10 applications by CPU and memory
- Live system load and memory usage
- Disk space with warning alerts for high usage
- Network usage and connection status
- List of active processes
- Status of key services like SSH, Nginx, Apache
- Modular design: run all or specific monitors
- Auto-refreshing full dashboard mode

---

## 🚀 Installation

Clone or download the script and give it executable permissions:

```bash
chmod +x monitor.sh



# Linux Server Security Audit & Hardening Script

This repository contains a modular and reusable Bash script to automate the process of auditing and hardening Linux servers. It is designed to check for common security issues, enforce best practices, and provide comprehensive reporting.

## Features

- **User & Group Audit**
  - List all users and groups
  - Identify users with UID 0
  - Detect users with no or weak passwords

- **File & Directory Permissions**
  - Find world-writable files and directories
  - Check `.ssh` directory permissions
  - Report files with SUID/SGID bits

- **Service Audit**
  - List running services
  - Detect unauthorized or non-standard services
  - Verify critical services (e.g., sshd, iptables)

- **Firewall & Network**
  - Ensure firewall is active and configured
  - List open ports and services
  - Check IP forwarding and network security

- **IP Configuration**
  - Detect public vs. private IPs
  - Ensure sensitive services aren't exposed on public IPs

- **Updates & Patching**
  - Check for pending security updates
  - Configure automatic updates

- **Log Monitoring**
  - Analyze logs for suspicious activity (e.g., SSH brute-force attempts)

- **Server Hardening**
  - Enforce SSH key authentication
  - Disable root login
  - Disable IPv6 (if not needed)
  - Protect GRUB bootloader
  - Configure iptables firewall
  - Enable unattended upgrades

- **Custom Checks**
  - Support for custom checks via `custom_checks.cfg`


### Run it:
./monitor.sh
