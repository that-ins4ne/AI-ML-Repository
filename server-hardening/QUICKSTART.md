# Quick Start Guide - Linux Server Hardening

This is a fast-track guide to get your server secured in under 10 minutes.

## Prerequisites Checklist

- [ ] Fresh Ubuntu/Debian Linux server
- [ ] Root or sudo access
- [ ] SSH access to the server
- [ ] SSH keys generated on your local machine
- [ ] Backup or console access (just in case)

## Step-by-Step Setup

### 1. Set Up SSH Keys (2 minutes)

**On your local machine:**

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy key to server
ssh-copy-id username@your_server_ip

# Test SSH key login
ssh username@your_server_ip
```

✅ **Checkpoint**: You should be able to SSH without entering a password.

### 2. Clone the Repository (1 minute)

**On your server:**

```bash
# Install git if needed
sudo apt-get update && sudo apt-get install -y git

# Clone the repository
git clone https://github.com/that-ins4ne/AI-ML-Repository.git

# Navigate to server hardening directory
cd AI-ML-Repository/server-hardening
```

### 3. Run the Hardening Script (5 minutes)

**Important**: Open a second SSH session as backup before running!

```bash
# Make script executable
chmod +x harden-server.sh

# Run the script
sudo ./harden-server.sh
```

The script will:
- ✅ Update all packages (1-2 min)
- ✅ Configure firewall (30 sec)
- ✅ Harden SSH (30 sec)
- ✅ Setup Fail2ban (30 sec)
- ✅ Enable auto-updates (30 sec)
- ✅ Apply security settings (30 sec)

### 4. Verify Everything Works (2 minutes)

**In a NEW terminal (keep the current one open!):**

```bash
# Test SSH access
ssh username@your_server_ip

# Check security status
sudo ./check-security.sh
```

✅ **Checkpoint**: If you can SSH successfully, you're good to go!

### 5. Create a New User (Optional)

```bash
# Run the user creation script
sudo ./create-user.sh newusername

# Copy SSH keys to new user
sudo mkdir -p /home/newusername/.ssh
sudo cp ~/.ssh/authorized_keys /home/newusername/.ssh/
sudo chown -R newusername:newusername /home/newusername/.ssh
sudo chmod 700 /home/newusername/.ssh
sudo chmod 600 /home/newusername/.ssh/authorized_keys

# Test login as new user
ssh newusername@your_server_ip
```

## What Got Configured?

| Component | Configuration |
|-----------|--------------|
| **Firewall** | Enabled, allows SSH/HTTP/HTTPS only |
| **SSH** | Root login disabled, key-only auth |
| **Fail2ban** | Active, monitoring SSH attempts |
| **Updates** | Automatic security updates enabled |
| **Logging** | Daily log monitoring configured |

## Quick Commands Reference

```bash
# Check firewall status
sudo ufw status verbose

# Check Fail2ban status
sudo fail2ban-client status

# View recent login attempts
sudo tail /var/log/auth.log

# Check security status
sudo ./check-security.sh
```

## Troubleshooting

### Can't SSH after hardening?
1. Use your backup SSH session (you kept it open, right?)
2. Check: `sudo systemctl status sshd`
3. Review config: `sudo nano /etc/ssh/sshd_config`
4. Restore backup: `sudo cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config`
5. Restart SSH: `sudo systemctl restart sshd`

### IP got banned by Fail2ban?
```bash
sudo fail2ban-client set sshd unbanip YOUR_IP
```

### Need to open more ports?
```bash
sudo ufw allow 8080/tcp comment 'My App'
sudo ufw status
```

## Next Steps

1. **Test your applications** - Make sure everything works
2. **Add more firewall rules** - Open ports as needed
3. **Set up monitoring** - Configure email alerts
4. **Schedule maintenance** - Regular updates and checks
5. **Documentation** - Keep notes on your configuration

## Security Maintenance Schedule

| Task | Frequency | Command |
|------|-----------|---------|
| Check logs | Weekly | `sudo tail -100 /var/log/auth.log` |
| Review Fail2ban | Weekly | `sudo fail2ban-client status` |
| Check updates | Monthly | `sudo apt update && apt list --upgradable` |
| Security audit | Monthly | `sudo ./check-security.sh` |
| Review users | Quarterly | `cat /etc/passwd` |

## Resources

- 📖 [Full README](README.md) - Detailed documentation
- 🔧 [Configuration Examples](configs/) - Template files
- 🛡️ [Security Best Practices](README.md#security-best-practices)

## Need Help?

If something goes wrong:
1. Don't panic - you have console access (right?)
2. Check the logs: `sudo journalctl -xe`
3. Review the [Troubleshooting section](README.md#troubleshooting)
4. Restore from backup if needed

---

**🎉 Congratulations!** Your server is now hardened and ready for production use.

Remember: Security is an ongoing process. Keep your system updated and monitor logs regularly.
