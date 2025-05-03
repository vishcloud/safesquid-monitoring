#!/bin/bash

# ============================
# SECURITY AUDIT & HARDENING SCRIPT
# ============================

LOGFILE="security_audit_report.txt"
CONFIG_FILE="custom_checks.cfg"

log() {
  echo -e "$1" | tee -a "$LOGFILE"
}

# 1. User and Group Audits
user_audit() {
  log "\n===== USER & GROUP AUDIT ====="
  log "\nAll users:"
  cut -d: -f1 /etc/passwd | tee -a "$LOGFILE"

  log "\nUsers with UID 0:"
  awk -F: '$3 == 0 {print $1}' /etc/passwd | tee -a "$LOGFILE"

  log "\nUsers without passwords:"
  awk -F: '($2 == "" || $2 == "!*" || $2 == "*" ) {print $1}' /etc/shadow 2>/dev/null | tee -a "$LOGFILE"

  log "\nGroups:"
  cut -d: -f1 /etc/group | tee -a "$LOGFILE"
}

# 2. File and Directory Permissions
file_perm_audit() {
  log "\n===== FILE & DIRECTORY PERMISSIONS ====="
  log "\nWorld-writable files:"
  find / -xdev -type f -perm -0002 -ls 2>/dev/null | tee -a "$LOGFILE"

  log "\nWorld-writable directories:"
  find / -xdev -type d -perm -0002 -ls 2>/dev/null | tee -a "$LOGFILE"

  log "\nChecking .ssh directory permissions:"
  find /home -name ".ssh" -exec ls -ld {} + 2>/dev/null | tee -a "$LOGFILE"

  log "\nFiles with SUID/SGID bits set:"
  find / -xdev \( -perm -4000 -o -perm -2000 \) -type f 2>/dev/null | tee -a "$LOGFILE"
}

# 3. Service Audits
service_audit() {
  log "\n===== SERVICE AUDIT ====="
  log "\nRunning services:"
  systemctl list-units --type=service --state=running | tee -a "$LOGFILE"

  log "\nCheck SSHD, iptables status:"
  systemctl is-active sshd &>> "$LOGFILE"
  systemctl is-active iptables &>> "$LOGFILE"

  log "\nListening ports:"
  ss -tulnp | tee -a "$LOGFILE"
}

# 4. Firewall and Network Security
firewall_check() {
  log "\n===== FIREWALL & NETWORK ====="
  log "\nChecking firewall status:"
  iptables -L -n | tee -a "$LOGFILE"

  log "\nOpen ports and associated services:"
  netstat -tuln | tee -a "$LOGFILE"

  log "\nChecking IP forwarding:"
  sysctl net.ipv4.ip_forward | tee -a "$LOGFILE"
  sysctl net.ipv6.conf.all.forwarding | tee -a "$LOGFILE"
}

# 5. IP and Network Configuration
ip_config_check() {
  log "\n===== IP CONFIGURATION ====="
  ip addr | tee -a "$LOGFILE"
  log "\nDetecting public/private IPs:"
  ip -4 addr show | grep inet | awk '{print $2}' | while read ip; do
    ip_only=$(echo $ip | cut -d/ -f1)
    if [[ $ip_only == 10.* || $ip_only == 192.168.* || $ip_only == 172.* ]]; then
      log "$ip_only is Private"
    else
      log "$ip_only is Public"
    fi
  done
}

# 6. Security Updates
update_check() {
  log "\n===== SECURITY UPDATES ====="
  if command -v apt &> /dev/null; then
    apt update &>> "$LOGFILE"
    apt list --upgradable 2>/dev/null | tee -a "$LOGFILE"
  elif command -v yum &> /dev/null; then
    yum check-update 2>/dev/null | tee -a "$LOGFILE"
  fi
}

# 7. Log Monitoring
log_monitoring() {
  log "\n===== LOG MONITORING ====="
  log "\nSSH login attempts in last 100 lines:"
  grep 'sshd' /var/log/auth.log | tail -n 100 | tee -a "$LOGFILE"
}

# 8. Server Hardening
harden_server() {
  log "\n===== HARDENING SERVER ====="

  # Disable root SSH login
  sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
  log "Disabled root login in SSH config."

  # Disable IPv6
  echo -e "\nDisabling IPv6..."
  sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sysctl -w net.ipv6.conf.default.disable_ipv6=1
  echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
  echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf

  # Enable unattended upgrades (Debian/Ubuntu)
  if command -v apt &> /dev/null; then
    apt install -y unattended-upgrades &>> "$LOGFILE"
    dpkg-reconfigure -plow unattended-upgrades
  fi

  log "Hardening completed."
}

# 9. Custom Security Checks
default_config_file() {
  cat << EOF > "$CONFIG_FILE"
# Example: custom security check script lines
# check_root_home_perm="ls -ld /root"
# check_tmp_world_write="find /tmp -perm -0002"
EOF
}

custom_checks() {
  log "\n===== CUSTOM CHECKS ====="
  if [ ! -f "$CONFIG_FILE" ]; then
    log "No config file found. Creating default."
    default_config_file
  fi
  source "$CONFIG_FILE"
  for var in $(compgen -A variable | grep check_); do
    log "\nRunning \$var:"
    eval "\${!var}" | tee -a "$LOGFILE"
  done
}

# 10. Reporting
main() {
  echo "Security Audit Report - $(date)" > "$LOGFILE"
  user_audit
  file_perm_audit
  service_audit
  firewall_check
  ip_config_check
  update_check
  log_monitoring
  harden_server
  custom_checks
  log "\nReport saved to $LOGFILE"
}

main
