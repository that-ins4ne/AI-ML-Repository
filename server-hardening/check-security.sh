#!/bin/bash

#############################################################################
# Security Status Check Script
# 
# Quick script to check the security status of your server
#
# Usage: sudo ./check-security.sh
#############################################################################

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Server Security Status Check${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW}Warning: Some checks require root privileges${NC}" 
   echo "Run with sudo for complete results"
   echo ""
fi

# 1. Check UFW status
echo -e "${GREEN}[1] Firewall Status (UFW)${NC}"
if command -v ufw &> /dev/null; then
    sudo ufw status verbose
else
    echo -e "${RED}UFW not installed${NC}"
fi
echo ""

# 2. Check SSH configuration
echo -e "${GREEN}[2] SSH Security Settings${NC}"
if [ -f /etc/ssh/sshd_config ]; then
    echo "Root Login: $(sudo sshd -T 2>/dev/null | grep permitrootlogin | awk '{print $2}')"
    echo "Password Auth: $(sudo sshd -T 2>/dev/null | grep passwordauthentication | awk '{print $2}')"
    echo "Protocol: $(sudo sshd -T 2>/dev/null | grep 'protocol' | awk '{print $2}')"
    echo "Max Auth Tries: $(sudo sshd -T 2>/dev/null | grep maxauthtries | awk '{print $2}')"
else
    echo -e "${RED}SSH config not found${NC}"
fi
echo ""

# 3. Check Fail2ban status
echo -e "${GREEN}[3] Fail2ban Status${NC}"
if command -v fail2ban-client &> /dev/null; then
    sudo fail2ban-client status 2>/dev/null || echo "Fail2ban not running"
    echo ""
    echo "SSH Jail Status:"
    sudo fail2ban-client status sshd 2>/dev/null || echo "SSH jail not configured"
else
    echo -e "${RED}Fail2ban not installed${NC}"
fi
echo ""

# 4. Check automatic updates
echo -e "${GREEN}[4] Automatic Updates${NC}"
if [ -f /etc/apt/apt.conf.d/20auto-upgrades ]; then
    cat /etc/apt/apt.conf.d/20auto-upgrades
else
    echo -e "${YELLOW}Automatic updates not configured${NC}"
fi
echo ""

# 5. Recent failed login attempts
echo -e "${GREEN}[5] Recent Failed Login Attempts${NC}"
if [ -f /var/log/auth.log ]; then
    sudo grep "Failed password" /var/log/auth.log 2>/dev/null | tail -10 || echo "No recent failures"
else
    echo "Auth log not available"
fi
echo ""

# 6. Active connections
echo -e "${GREEN}[6] Active Network Connections${NC}"
sudo ss -tulpn 2>/dev/null | grep LISTEN | head -15 || sudo netstat -tulpn 2>/dev/null | grep LISTEN | head -15
echo ""

# 7. Last logins
echo -e "${GREEN}[7] Recent Successful Logins${NC}"
last -n 10 2>/dev/null || echo "Login history not available"
echo ""

# 8. System updates
echo -e "${GREEN}[8] Available Updates${NC}"
if command -v apt &> /dev/null; then
    echo "Checking for updates..."
    sudo apt update -qq 2>/dev/null
    UPDATES=$(apt list --upgradable 2>/dev/null | grep -c upgradable)
    if [ "$UPDATES" -gt 1 ]; then
        echo -e "${YELLOW}$((UPDATES-1)) packages can be updated${NC}"
    else
        echo -e "${GREEN}System is up to date${NC}"
    fi
else
    echo "Package manager not found"
fi
echo ""

# 9. Running services
echo -e "${GREEN}[9] Security-Related Services${NC}"
echo "UFW: $(sudo systemctl is-active ufw 2>/dev/null || echo 'not found')"
echo "Fail2ban: $(sudo systemctl is-active fail2ban 2>/dev/null || echo 'not found')"
echo "SSH: $(sudo systemctl is-active ssh 2>/dev/null || sudo systemctl is-active sshd 2>/dev/null || echo 'not found')"
echo ""

# 10. Disk usage
echo -e "${GREEN}[10] Disk Usage${NC}"
df -h / 2>/dev/null | tail -1
echo ""

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Security Check Complete${NC}"
echo -e "${GREEN}========================================${NC}"
