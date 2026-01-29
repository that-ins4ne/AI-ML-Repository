#!/bin/bash

#############################################################################
# User Management Script
# 
# Helper script to create secure users with proper SSH key setup
#
# Usage: sudo ./create-user.sh <username>
#############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Error: This script must be run as root${NC}" 
   exit 1
fi

if [ -z "$1" ]; then
    echo -e "${RED}Error: Username required${NC}"
    echo "Usage: sudo ./create-user.sh <username>"
    exit 1
fi

USERNAME=$1

# Check if user already exists
if id "$USERNAME" &>/dev/null; then
    echo -e "${YELLOW}User $USERNAME already exists${NC}"
    exit 1
fi

echo -e "${GREEN}Creating user: $USERNAME${NC}"

# Create user with home directory
adduser --gecos "" $USERNAME

# Add user to sudo group
usermod -aG sudo $USERNAME

echo ""
echo -e "${GREEN}User created successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Set up SSH keys for $USERNAME:"
echo "   - From your local machine: ssh-copy-id $USERNAME@your_server_ip"
echo "   - Or manually: sudo mkdir -p /home/$USERNAME/.ssh"
echo "              sudo nano /home/$USERNAME/.ssh/authorized_keys"
echo "              sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh"
echo "              sudo chmod 700 /home/$USERNAME/.ssh"
echo "              sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys"
echo ""
echo "2. Test login: ssh $USERNAME@your_server_ip"
echo ""
