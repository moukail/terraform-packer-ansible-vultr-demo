################################################################################
# Installation mode
################################################################################
text
reboot

################################################################################
# Localization
################################################################################
keyboard --vckeymap=us-euro --xlayouts='us (euro)'
lang en_US.UTF-8
timezone Europe/Amsterdam --utc

################################################################################
# Time sync
################################################################################
timesource --ntp-pool=nl.pool.ntp.org
timesource --ntp-server=time.google.com

################################################################################
# Networking
################################################################################
network --bootproto=dhcp --device=link --activate --onboot=on

################################################################################
# Authentication
################################################################################
rootpw --lock
user --name=${user} --groups=wheel --lock

################################################################################
# Security
################################################################################
services --enabled=sshd
firewall --enabled --service=ssh
selinux --enforcing

################################################################################
# BaseOS repository
################################################################################
url --url=${base_os_url}
repo --name=AppStream --baseurl=${app_stream_url}

################################################################################
# Bootloader (UEFI-safe)
################################################################################
bootloader --timeout=1

################################################################################
# Storage (UEFI-safe)
################################################################################
zerombr
clearpart --all --initlabel
reqpart
part / --fstype=xfs --grow --size=1

################################################################################
# Packages
################################################################################
%packages --excludedocs
@^minimal-environment
openssh-server
gcc
make
perl
sudo
curl
wget
nano
rsync
net-tools
python3
python3-libselinux
tar
gzip
%end

################################################################################
# Post-install configuration
################################################################################
%post --log=/root/ks-post.log --erroronfail

# Enable passwordless sudo for ${user}
echo "${user} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${user}
chmod 0440 /etc/sudoers.d/${user}

mkdir -p /home/${user}/.ssh

cat > /home/${user}/.ssh/authorized_keys <<'EOF'
${ansible_ssh_public_key}
EOF

chmod 700 /home/${user}/.ssh
chmod 600 /home/${user}/.ssh/authorized_keys
chown -R ${user}:${user} /home/${user}/.ssh

# Ensure SELinux contexts are correct so sshd can read the authorized keys
restorecon -Rv /home/${user}/.ssh || true

# Enable essential services
systemctl enable sshd

# SSH performance/security
sed -i 's/^GSSAPIAuthentication yes/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#UseDNS.*/UseDNS no/' /etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

echo "ClientAliveInterval 120" >> /etc/ssh/sshd_config

%end