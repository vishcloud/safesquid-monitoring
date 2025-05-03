#!/bin/bash

# Refresh interval in seconds
INTERVAL=5

# Colors
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function: Top 10 Applications by CPU and Memory
show_cpu_mem() {
    echo -e "\n=== Top 10 Processes by CPU and Memory ==="
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 11
}

# Function: Network Monitoring
show_network() {
    echo -e "\n=== Network Monitoring ==="
    echo "Concurrent connections: $(ss -s | grep -i estab | awk '{print $4}')"
    echo "Packet drops since boot: $(netstat -s | grep -i 'segments retransmited' | awk '{print $1}')"

    RX=$(cat /proc/net/dev | awk '/eth0|ens|eno|enp/ {rx+=$2} END {print rx}')
    TX=$(cat /proc/net/dev | awk '/eth0|ens|eno|enp/ {tx+=$10} END {print tx}')
    echo "Inbound: $((RX / 1024 / 1024)) MB"
    echo "Outbound: $((TX / 1024 / 1024)) MB"
}

# Function: Disk Usage
show_disk() {
    echo -e "\n=== Disk Usage ==="
    df -h | awk '{print $0; if (NR>1 && int($5) > 80) print "'"$RED"'Warning: High usage!'"$NC"'"}'
}

# Function: System Load and CPU Breakdown
show_load() {
    echo -e "\n=== System Load ==="
    uptime

    echo -e "\n=== CPU Usage ==="
    top -bn1 | grep "Cpu(s)"
}

# Function: Memory Usage
show_memory() {
    echo -e "\n=== Memory Usage ==="
    free -h
}

# Function: Process Monitoring
show_processes() {
    echo -e "\n=== Active Processes ==="
    echo "Total: $(ps -e | wc -l)"

    echo -e "\n=== Top 5 CPU-Intensive Processes ==="
    ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6

    echo -e "\n=== Top 5 Memory-Intensive Processes ==="
    ps -eo pid,comm,%mem --sort=-%mem | head -n 6
}

# Function: Service Monitoring
show_services() {
    echo -e "\n=== Service Status ==="
    for svc in ssh nginx apache2 iptables; do
        if systemctl list-units --type=service | grep -q $svc; then
            systemctl is-active --quiet $svc && echo "$svc: running" || echo "$svc: not running"
        else
            echo "$svc: not installed"
        fi
    done
}

# Function: Full Dashboard
full_dashboard() {
    while true; do
        clear
        echo -e "========== System Monitoring Dashboard =========="
        show_cpu_mem
        show_network
        show_disk
        show_load
        show_memory
        show_processes
        show_services
        echo -e "\nRefreshing in $INTERVAL seconds... Press Ctrl+C to exit."
        sleep $INTERVAL
    done
}

# Handle command-line switches
case "$1" in
    -cpu) show_cpu_mem ;;
    -network) show_network ;;
    -disk) show_disk ;;
    -load) show_load ;;
    -memory) show_memory ;;
    -process) show_processes ;;
    -services) show_services ;;
    *) full_dashboard ;;
esac
