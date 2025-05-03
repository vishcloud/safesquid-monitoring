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

### Then run it:
./monitor.sh
