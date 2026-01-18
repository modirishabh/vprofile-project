## create nested virtulization vm gcp
gcloud compute instances create vprofile \
  --project=project-7e8c9abf-090d-4e22-9ef \
  --zone=us-central1-c \
  --machine-type=n2-standard-2 \
  --min-cpu-platform="Intel Cascade Lake" \
  --enable-nested-virtualization \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --metadata=enable-osconfig=TRUE \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --service-account=164810560749-compute@developer.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
  --tags=https-server,http-server,lb-health-check \
  --create-disk=auto-delete=yes,boot=yes,device-name=vprofile,disk-resource-policy=projects/project-7e8c9abf-090d-4e22-9ef/regions/us-central1/resourcePolicies/default-schedule-1,image=projects/debian-cloud/global/images/debian-11-bullseye-v20260114,mode=rw,size=100,type=pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ops-agent-policy=v2-x86-template-1-4-0,goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any




## Vagrant + VirtualBox Setup Guide
This guide provides step-by-step instructions to install VirtualBox, Vagrant, Git, and clone the vprofile-project repository on Debian/Ubuntu systems.

Prerequisites
Debian 11 (Bullseye) or Ubuntu system

Root/sudo access

Internet connection

Step 1: Install VirtualBox 6.1
Add VirtualBox repository and install VirtualBox 6.1 with Extension Pack:

bash
# Add VirtualBox repository keys
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

# Add VirtualBox repository
echo "deb [arch=amd64] http://download.virtualbox.org/virtualbox/debian bullseye contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

# Update package list and install VirtualBox
sudo apt update
sudo apt install virtualbox-6.1 -y

# Download and install Extension Pack
wget https://download.virtualbox.org/virtualbox/6.1.26/Oracle_VM_VirtualBox_Extension_Pack-6.1.26-145957.vbox-extpack
sudo vboxmanage extpack install Oracle_VM_VirtualBox_Extension_Pack-6.1.26-145957.vbox-extpack

# Install required kernel modules
sudo apt update
sudo apt install -y build-essential dkms linux-headers-$(uname -r)
sudo /sbin/vboxconfig

# Add user to vboxusers group
sudo usermod -aG vboxusers $USER
newgrp vboxusers
Note: Log out and log back in (or reboot) for group changes to take effect.

Step 2: Install Vagrant
Add HashiCorp repository and install Vagrant:

bash
# Add HashiCorp GPG key
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Install Vagrant
sudo apt update && sudo apt install vagrant -y
Step 3: Install Additional Dependencies
bash
# Install Git and rsync
sudo apt install git -y
sudo apt install -y rsync

# Install vagrant-hostmanager plugin
vagrant plugin install vagrant-hostmanager
Step 4: Clone vprofile-project Repository
bash
git clone https://github.com/hkhcoder/vprofile-project.git
cd vprofile-project
Verification
Verify installations:

bash
# Check VirtualBox version
vboxmanage --version

# Check Vagrant version
vagrant --version

# Check Git
git --version
Troubleshooting
VirtualBox kernel modules fail: Run sudo /sbin/vboxconfig after kernel updates

Permission denied: Ensure you're in vboxusers group (groups command)

Vagrant plugin issues: Run vagrant plugin install vagrant-hostmanager as regular user

Next Steps
Navigate to vprofile-project directory

Review Vagrantfile

Run vagrant up to start the environment
