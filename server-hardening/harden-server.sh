#!/bin/bash

#############################################################################
# Linux Server Hardening Script
# 
# This script automates the configuration of essential security measures
# for a fresh Linux server (Ubuntu/Debian-based systems).
#
# Features:
# - System updates and security patches
# - Firewall configuration (UFW)
# - SSH hardening
# - Fail2ban installation and configuration
# - User management
# - Automatic security updates
#
# Usage: sudo ./harden-server.sh
#############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root (use sudo)${NC}" 
   exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Linux Server Hardening Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Function to print status messages
print_status() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[-]${NC} $1"
}

#############################################################################
# 1. System Updates
#############################################################################
print_status "Step 1: Updating system packages..."
apt-get update -qq
apt-get upgrade -y -qq
apt-get dist-upgrade -y -qq
apt-get autoremove -y -qq
apt-get autoclean -y -qq
print_status "System updated successfully"
echo ""

#############################################################################
# 2. Install Essential Security Packages
#############################################################################
print_status "Step 2: Installing essential security packages..."
apt-get install -y -qq \
    ufw \
    fail2ban \
    unattended-upgrades \
    apt-listchanges \
    logwatch \
    curl \
    wget \
    git
print_status "Security packages installed"
echo ""

#############################################################################
# 3. Configure Firewall (UFW)
#############################################################################
print_status "Step 3: Configuring firewall (UFW)..."

# Disable UFW first to avoid locking out during configuration
ufw --force disable

# Set default policies
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (port 22)
ufw allow 22/tcp comment 'SSH'

# Allow HTTP and HTTPS (for web servers)
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'

# Enable UFW
ufw --force enable

print_status "Firewall configured and enabled"
ufw status verbose
echo ""

#############################################################################
# 4. SSH Hardening
#############################################################################
print_status "Step 4: Hardening SSH configuration..."

# Backup original SSH config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d-%H%M%S)

# SSH Configuration changes
SSH_CONFIG="/etc/ssh/sshd_config"

# Disable root login
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSH_CONFIG"
if ! grep -q "^PermitRootLogin" "$SSH_CONFIG"; then
    echo "PermitRootLogin no" >> "$SSH_CONFIG"
fi

# Disable password authentication (use SSH keys only)
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' "$SSH_CONFIG"
if ! grep -q "^PasswordAuthentication" "$SSH_CONFIG"; then
    echo "PasswordAuthentication no" >> "$SSH_CONFIG"
fi

# Disable empty passwords
sed -i 's/^#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' "$SSH_CONFIG"
if ! grep -q "^PermitEmptyPasswords" "$SSH_CONFIG"; then
    echo "PermitEmptyPasswords no" >> "$SSH_CONFIG"
fi

# Use only SSH Protocol 2
sed -i 's/^#*Protocol.*/Protocol 2/' "$SSH_CONFIG"
if ! grep -q "^Protocol" "$SSH_CONFIG"; then
    echo "Protocol 2" >> "$SSH_CONFIG"
fi

# Disable X11 Forwarding
sed -i 's/^#*X11Forwarding.*/X11Forwarding no/' "$SSH_CONFIG"
if ! grep -q "^X11Forwarding" "$SSH_CONFIG"; then
    echo "X11Forwarding no" >> "$SSH_CONFIG"
fi

# Set maximum authentication attempts
sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' "$SSH_CONFIG"
if ! grep -q "^MaxAuthTries" "$SSH_CONFIG"; then
    echo "MaxAuthTries 3" >> "$SSH_CONFIG"
fi

# Set login grace time
sed -i 's/^#*LoginGraceTime.*/LoginGraceTime 30/' "$SSH_CONFIG"
if ! grep -q "^LoginGraceTime" "$SSH_CONFIG"; then
    echo "LoginGraceTime 30" >> "$SSH_CONFIG"
fi

print_warning "SSH configuration updated. Note: Ensure you have SSH key authentication set up before logging out!"
print_status "SSH service will be restarted at the end of this script"
echo ""

#############################################################################
# 5. Configure Fail2ban
#############################################################################
print_status "Step 5: Configuring Fail2ban..."

# Create local jail configuration
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
# Ban hosts for 1 hour
bantime = 3600

# A host is banned if it has generated "maxretry" during the last "findtime"
findtime = 600
maxretry = 5

# Email notifications (configure your email)
destemail = root@localhost
sendername = Fail2Ban
action = %(action_mwl)s

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200
EOF

# Start and enable Fail2ban
systemctl enable fail2ban
systemctl restart fail2ban

print_status "Fail2ban configured and started"
fail2ban-client status
echo ""

#############################################################################
# 6. Configure Automatic Security Updates
#############################################################################
print_status "Step 6: Configuring automatic security updates..."

# Configure unattended-upgrades
cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";
EOF

# Enable automatic updates
cat > /etc/apt/apt.conf.d/20auto-upgrades << 'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

print_status "Automatic security updates configured"
echo ""

#############################################################################
# 7. Additional Security Measures
#############################################################################
print_status "Step 7: Applying additional security measures..."

# Disable IPv6 if not needed (optional)
if ! grep -q "net.ipv6.conf.all.disable_ipv6" /etc/sysctl.conf; then
    cat >> /etc/sysctl.conf << 'EOF'

# Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF
fi

# Network security settings
if ! grep -q "net.ipv4.conf.all.rp_filter" /etc/sysctl.conf; then
    cat >> /etc/sysctl.conf << 'EOF'

# Network Security
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
EOF
fi

# Apply sysctl settings
sysctl -p > /dev/null 2>&1

print_status "Additional security measures applied"
echo ""

#############################################################################
# 8. Set up log monitoring
#############################################################################
print_status "Step 8: Configuring log monitoring..."

# Configure logwatch
mkdir -p /var/cache/logwatch
if [ ! -f /etc/cron.daily/00logwatch ]; then
    cat > /etc/cron.daily/00logwatch << 'EOF'
#!/bin/bash
/usr/sbin/logwatch --output mail --mailto root --detail high
EOF
    chmod +x /etc/cron.daily/00logwatch
fi

print_status "Log monitoring configured"
echo ""

#############################################################################
# 9. Restart Services
#############################################################################
print_status "Step 9: Restarting services..."

# Restart SSH
systemctl restart sshd

print_status "Services restarted"
echo ""

#############################################################################
# 10. Summary
#############################################################################
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Server Hardening Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
print_status "Security measures applied:"
echo "  ✓ System updated with latest security patches"
echo "  ✓ Firewall (UFW) enabled"
echo "  ✓ SSH hardened (root login disabled, key-based auth)"
echo "  ✓ Fail2ban configured for intrusion prevention"
echo "  ✓ Automatic security updates enabled"
echo "  ✓ Network security settings applied"
echo "  ✓ Log monitoring configured"
echo ""
print_warning "IMPORTANT NOTES:"
echo "  1. Ensure you have SSH key authentication set up"
echo "  2. Test SSH access in a NEW terminal before closing this one"
echo "  3. Review firewall rules: sudo ufw status verbose"
echo "  4. Check Fail2ban status: sudo fail2ban-client status"
echo "  5. Review SSH config: /etc/ssh/sshd_config"
echo ""
print_status "Firewall Status:"
ufw status verbose
echo ""
print_status "Next steps:"
echo "  - Create non-root user if not already done: adduser <username>"
echo "  - Add user to sudo group: usermod -aG sudo <username>"
echo "  - Set up SSH keys for the user"
echo "  - Configure additional firewall rules as needed"
echo "  - Review /var/log/auth.log regularly"
echo ""
