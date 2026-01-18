#!/bin/bash

# Vagrant + VirtualBox Automated Setup Script
# For Debian 11 (Bullseye) / Ubuntu systems
# Author: DevOps Setup Automation
# Date: $(date)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    exit 1
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   error "Do not run as root. Run as regular user with sudo privileges."
fi

log "Starting Vagrant + VirtualBox automated setup..."

# Update system
log "Updating package lists..."
sudo apt update

# Step 1: Install VirtualBox 6.1
log "Installing VirtualBox 6.1..."
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian bullseye contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
sudo apt update
sudo apt install virtualbox-6.1 -y

# Install Extension Pack
log "Installing VirtualBox Extension Pack..."
wget -q https://download.virtualbox.org/virtualbox/6.1.26/Oracle_VM_VirtualBox_Extension_Pack-6.1.26-145957.vbox-extpack
sudo vboxmanage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.1.26-145957.vbox-extpack

# Install kernel modules
log "Installing VirtualBox kernel modules..."
sudo apt install -y build-essential dkms linux-headers-$(uname -r)
sudo /sbin/vboxconfig

# Add user to vboxusers group
log "Adding user to vboxusers group..."
sudo usermod -aG vboxusers $USER
REBOOT_NEEDED=true

# Step 2: Install Vagrant
log "Installing Vagrant..."
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant -y

# Step 3: Install dependencies
log "Installing Git, rsync and Vagrant plugins..."
sudo apt install -y git rsync
vagrant plugin install vagrant-hostmanager

# Step 4: Clone repository
log "Cloning vprofile-project repository..."
git clone https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project

# Verification
log "Verifying installations..."
vboxmanage --version
vagrant --version
git --version

log "✅ Setup completed successfully!"

# Final instructions
cat << EOF

${GREEN}Next Steps:${NC}
1. ${YELLOW}REBOOT your system${NC} for group membership to take effect
2. cd vprofile-project
3. vagrant up

${GREEN}Verification commands:${NC}
groups | grep vboxusers
vagrant --version
vboxmanage --version

EOF

if [[ "$REBOOT_NEEDED" == "true" ]]; then
    warn "Reboot required for vboxusers group membership. Run: sudo reboot"
fi
