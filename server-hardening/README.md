# Linux Server Hardening Project

## Overview

This project provides a comprehensive, automated solution for hardening fresh Linux servers (Ubuntu/Debian-based systems). It implements essential security measures and best practices that every production server should have.

Perfect for:
- 🚀 Newly provisioned VPS (DigitalOcean, Linode, AWS EC2, etc.)
- 🔒 Production server deployment
- 🛡️ Security baseline configuration
- 📦 Quick server setup automation

## Features

This hardening script implements the following security measures:

### ✅ System Security
- **Automatic Updates**: System-wide security patches and updates
- **Unattended Upgrades**: Automatic installation of security updates
- **Latest Packages**: Ensures all system packages are up-to-date

### 🔥 Firewall Configuration
- **UFW (Uncomplicated Firewall)**: Simple yet powerful firewall management
- **Default Deny Policy**: Blocks all incoming connections by default
- **Essential Ports**: Opens SSH (22), HTTP (80), and HTTPS (443) by default
  - *Note: HTTP/HTTPS ports are opened for web server deployment. Comment out in script if not needed.*
- **Customizable Rules**: Easy to add more rules as needed

### 🔐 SSH Hardening
- **Disable Root Login**: Prevents direct root access via SSH
- **Key-Based Authentication**: Disables password authentication
- **Modern SSH Standards**: Uses secure defaults (Protocol 2 is standard)
- **Reduced Login Grace Time**: Limits connection time before authentication
- **Max Authentication Attempts**: Limits failed login attempts to 3
- **X11 Forwarding Disabled**: Reduces attack surface

### 🛡️ Intrusion Prevention
- **Fail2ban**: Automatically bans IPs with suspicious activity
- **SSH Protection**: Monitors and blocks brute-force SSH attempts
- **Customizable Ban Times**: Default 1-hour ban with 2-hour SSH ban
- **Email Notifications**: Alerts on security events

### 📊 Monitoring & Logging
- **Logwatch**: Daily log monitoring and reporting
- **Centralized Logging**: System-wide log collection
- **Security Event Tracking**: Monitors authentication and access logs

### 🌐 Network Security
- **IP Spoofing Protection**: Reverse path filtering enabled
- **ICMP Broadcast Protection**: Ignores ping broadcasts
- **SYN Flood Protection**: TCP SYN cookies enabled
- **IP Forwarding Disabled**: Prevents routing between interfaces
- **IPv6 Disabled**: Automatically disabled (can be re-enabled if needed for your environment)
  - *Note: Modern cloud environments may require IPv6. See customization section to re-enable.*

## Prerequisites

- Fresh Ubuntu/Debian-based Linux server (20.04 LTS or later recommended)
- Root or sudo access
- SSH access to the server
- **IMPORTANT**: SSH key-based authentication already set up (strongly recommended)

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/that-ins4ne/AI-ML-Repository.git
cd AI-ML-Repository/server-hardening
```

### Step 2: Set Up SSH Keys (CRITICAL)

Before running the hardening script, ensure you have SSH key-based authentication configured:

```bash
# On your local machine, generate SSH key if you don't have one
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy your public key to the server
ssh-copy-id username@your_server_ip

# Test SSH key login
ssh username@your_server_ip
```

### Step 3: Run the Hardening Script

```bash
# Make the script executable (if not already)
chmod +x harden-server.sh

# Run the script with sudo
sudo ./harden-server.sh
```

The script will take a few minutes to complete. It will:
1. Update all system packages
2. Install security tools
3. Configure firewall
4. Harden SSH configuration
5. Set up Fail2ban
6. Enable automatic updates
7. Apply network security settings
8. Configure log monitoring

## Post-Installation Steps

### 1. Test SSH Access

**IMPORTANT**: Before closing your current SSH session, open a NEW terminal and test SSH access:

```bash
ssh username@your_server_ip
```

If you can't connect:
- Check that your SSH keys are properly configured
- Review `/etc/ssh/sshd_config` for any issues
- You still have your original terminal open to fix issues

### 2. Create Non-Root User (if needed)

```bash
# Create a new user
sudo adduser newusername

# Add user to sudo group
sudo usermod -aG sudo newusername

# Set up SSH keys for the new user
sudo mkdir -p /home/newusername/.ssh
sudo cp ~/.ssh/authorized_keys /home/newusername/.ssh/
sudo chown -R newusername:newusername /home/newusername/.ssh
sudo chmod 700 /home/newusername/.ssh
sudo chmod 600 /home/newusername/.ssh/authorized_keys
```

### 3. Configure Additional Firewall Rules

If you need to open additional ports:

```bash
# Allow custom port
sudo ufw allow 8080/tcp comment 'Custom Application'

# Allow port range
sudo ufw allow 3000:3010/tcp comment 'App Port Range'

# Allow from specific IP
sudo ufw allow from 192.168.1.100 to any port 22

# Check firewall status
sudo ufw status verbose
```

### 4. Customize Fail2ban Settings

Edit `/etc/fail2ban/jail.local` to customize:

```bash
sudo nano /etc/fail2ban/jail.local

# Restart Fail2ban after changes
sudo systemctl restart fail2ban
```

### 5. Configure Email Notifications

For log monitoring emails, configure postfix or another mail service:

```bash
sudo apt-get install postfix mailutils
sudo dpkg-reconfigure postfix
```

## Verification

### Check Firewall Status
```bash
sudo ufw status verbose
```

### Check Fail2ban Status
```bash
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

### Check SSH Configuration
```bash
sudo sshd -T | grep -i 'permitrootlogin\|passwordauthentication'
```

### Check Automatic Updates
```bash
cat /etc/apt/apt.conf.d/20auto-upgrades
```

### Review Security Logs
```bash
sudo tail -f /var/log/auth.log
sudo tail -f /var/log/fail2ban.log
```

## Security Best Practices

### 🔑 SSH Keys
- Use ED25519 or RSA (4096-bit) keys
- Protect private keys with strong passphrases
- Never share private keys
- Rotate keys periodically

### 🔒 Password Policy
```bash
# Install password quality checking library
sudo apt-get install libpam-pwquality

# Edit /etc/security/pwquality.conf
sudo nano /etc/security/pwquality.conf
```

### 🔄 Regular Maintenance
- Review logs weekly: `sudo journalctl -p err -b`
- Check for available updates: `sudo apt update && apt list --upgradable`
- Monitor disk space: `df -h`
- Review user accounts: `cat /etc/passwd`
- Check active connections: `sudo ss -tulpn`

### 📦 Minimal Software
- Only install necessary packages
- Remove unused services: `sudo systemctl disable <service>`
- Regular audit: `sudo apt autoremove`

### 🔐 Additional Security Measures

#### Set up Two-Factor Authentication
```bash
sudo apt-get install libpam-google-authenticator
google-authenticator
```

#### Configure AppArmor (Ubuntu)
```bash
sudo systemctl enable apparmor
sudo systemctl start apparmor
sudo aa-status
```

#### Install and Configure ClamAV (Antivirus)
```bash
sudo apt-get install clamav clamav-daemon
sudo freshclam
sudo systemctl start clamav-daemon
```

#### Set Up Intrusion Detection (AIDE)
```bash
sudo apt-get install aide
sudo aideinit
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```

## Troubleshooting

### Can't Connect via SSH
1. Check if SSH service is running: `sudo systemctl status sshd`
2. Verify firewall rules: `sudo ufw status`
3. Check SSH logs: `sudo tail -50 /var/log/auth.log`
4. Ensure your IP isn't banned: `sudo fail2ban-client status sshd`

### Unlock Banned IP
```bash
sudo fail2ban-client set sshd unbanip YOUR_IP_ADDRESS
```

### Revert SSH Configuration
```bash
sudo cp /etc/ssh/sshd_config.backup.TIMESTAMP /etc/ssh/sshd_config
sudo systemctl restart sshd
```

### Disable Firewall (Emergency)
```bash
sudo ufw disable
```

## Customization

### Modify SSH Port
```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config
# Change: Port 22 to Port 2222

# Update firewall
sudo ufw allow 2222/tcp
sudo ufw delete allow 22/tcp

# Restart SSH
sudo systemctl restart sshd
```

### Whitelist IP Addresses
```bash
# Add to /etc/fail2ban/jail.local under [DEFAULT]
ignoreip = 127.0.0.1/8 ::1 YOUR_IP_ADDRESS
```

### Enable IPv6
```bash
# Remove IPv6 disable settings from /etc/sysctl.conf
sudo nano /etc/sysctl.conf
# Comment out the IPv6 disable lines

# Apply changes
sudo sysctl -p
```

## Files Modified by This Script

- `/etc/ssh/sshd_config` - SSH configuration (backup created)
- `/etc/fail2ban/jail.local` - Fail2ban configuration
- `/etc/apt/apt.conf.d/50unattended-upgrades` - Automatic updates
- `/etc/apt/apt.conf.d/20auto-upgrades` - Update schedule
- `/etc/sysctl.conf` - Network security settings
- `/etc/cron.daily/00logwatch` - Log monitoring

## Support & Contributing

This is an educational project demonstrating server hardening best practices. Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests
- Share your experience

## Important Disclaimer

⚠️ **Warning**: This script makes significant security changes to your server. Always:
- Test on a non-production server first
- Have console/VNC access as a backup
- Understand each change before applying
- Keep a backup of your data
- Ensure you have SSH key authentication working

## License

This project is provided as-is for educational purposes. Use at your own risk.

## References & Further Reading

- [Ubuntu Security Guide](https://ubuntu.com/security)
- [CIS Benchmark for Ubuntu](https://www.cisecurity.org/benchmark/ubuntu_linux)
- [OpenSSH Security Best Practices](https://www.openssh.com/security.html)
- [Fail2ban Documentation](https://www.fail2ban.org/)
- [UFW Documentation](https://help.ubuntu.com/community/UFW)
- [Linux Hardening Guide](https://github.com/decalage2/awesome-security-hardening)

## Quick Reference Commands

```bash
# Check system security status
sudo systemctl status ufw
sudo systemctl status fail2ban
sudo systemctl status sshd

# View recent security logs
sudo grep "Failed password" /var/log/auth.log | tail -20
sudo fail2ban-client status sshd

# Check for security updates
sudo apt update
sudo apt list --upgradable

# Review firewall rules
sudo ufw status numbered

# Check active connections
sudo ss -tulpn
sudo netstat -tulpn

# View banned IPs
sudo fail2ban-client status sshd

# System security audit
sudo ss -tulpn | grep LISTEN
sudo ps aux | grep -E '(ssh|ufw|fail2ban)'
```

---

**Remember**: Security is an ongoing process, not a one-time setup. Regularly review logs, update software, and stay informed about new vulnerabilities.
