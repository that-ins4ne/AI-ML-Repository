# UFW (Uncomplicated Firewall) Configuration Examples

## Basic Commands

# Check status
sudo ufw status verbose

# Enable/Disable
sudo ufw enable
sudo ufw disable

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

## Common Port Rules

# SSH (always add this first!)
sudo ufw allow 22/tcp comment 'SSH'
sudo ufw allow ssh

# HTTP and HTTPS
sudo ufw allow 80/tcp comment 'HTTP'
sudo ufw allow 443/tcp comment 'HTTPS'
sudo ufw allow 'Nginx Full'

# Custom application port
sudo ufw allow 8080/tcp comment 'Custom App'

# Port range
sudo ufw allow 3000:3010/tcp comment 'App Port Range'

## Advanced Rules

# Allow from specific IP
sudo ufw allow from 192.168.1.100 to any port 22

# Allow subnet
sudo ufw allow from 192.168.1.0/24

# Allow specific IP to specific port
sudo ufw allow from 203.0.113.4 to any port 80

# Deny specific IP
sudo ufw deny from 203.0.113.100

# Allow by service name
sudo ufw allow 'OpenSSH'
sudo ufw allow 'Nginx Full'
sudo ufw allow 'MySQL'

## Application Profiles

# List available profiles
sudo ufw app list

# Get profile info
sudo ufw app info 'Nginx Full'

# Allow application profile
sudo ufw allow 'Nginx HTTPS'

## Database Servers

# PostgreSQL
sudo ufw allow 5432/tcp comment 'PostgreSQL'

# MySQL
sudo ufw allow 3306/tcp comment 'MySQL'

# MongoDB
sudo ufw allow 27017/tcp comment 'MongoDB'

# Redis
sudo ufw allow 6379/tcp comment 'Redis'

## Management and Deletion

# List rules with numbers
sudo ufw status numbered

# Delete rule by number
sudo ufw delete 5

# Delete rule by specification
sudo ufw delete allow 8080/tcp

# Reset firewall (removes all rules)
sudo ufw reset

## Logging

# Enable logging
sudo ufw logging on

# Set log level
sudo ufw logging low
sudo ufw logging medium
sudo ufw logging high

# View logs
sudo tail -f /var/log/ufw.log

## Rate Limiting (DDoS Protection)

# Limit connections (max 6 connections in 30 seconds)
sudo ufw limit ssh

# Limit specific port
sudo ufw limit 22/tcp

## IPv6

# Enable IPv6 in /etc/default/ufw
# IPv6=yes

## Examples for Specific Use Cases

# Web Server (HTTP/HTTPS)
sudo ufw allow 'Nginx Full'
sudo ufw allow 'Apache Full'

# Mail Server
sudo ufw allow 25/tcp comment 'SMTP'
sudo ufw allow 587/tcp comment 'SMTP Submission'
sudo ufw allow 993/tcp comment 'IMAPS'
sudo ufw allow 995/tcp comment 'POP3S'

# DNS Server
sudo ufw allow 53/tcp comment 'DNS TCP'
sudo ufw allow 53/udp comment 'DNS UDP'

# Docker
sudo ufw allow 2375/tcp comment 'Docker'
sudo ufw allow 2376/tcp comment 'Docker TLS'

# Kubernetes
sudo ufw allow 6443/tcp comment 'Kubernetes API'
sudo ufw allow 10250/tcp comment 'Kubelet API'

## Backup and Restore

# Backup rules
sudo cp /etc/ufw/user.rules /root/ufw-backup-$(date +%Y%m%d).rules

# View configuration files
ls -la /etc/ufw/
cat /etc/ufw/user.rules

## Testing

# Dry run (show what would happen)
sudo ufw --dry-run enable

# Check if port is open from external machine
# From another server:
# telnet your_server_ip 22
# nc -zv your_server_ip 22
# nmap your_server_ip
