#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Use sudo or switch to root."
  exit 1
fi

read -p "Enter new username: " username
if [[ -z "$username" ]]; then
  echo "Username cannot be empty."
  exit 1
fi

read -s -p "Enter password for $username: " password
echo
if [[ -z "$password" ]]; then
  echo "Password cannot be empty."
  exit 1
fi

if id "$username" &>/dev/null; then
  echo "User '$username' already exists."
  exit 1
fi

adduser --quiet --disabled-password --gecos "" "$username"
if [[ $? -ne 0 ]]; then
  echo "Failed to create user '$username'."
  exit 1
fi

echo "$username:$password" | chpasswd
if [[ $? -ne 0 ]]; then
  echo "Failed to set password for '$username'."
  exit 1
fi

usermod -aG sudo "$username"
if [[ $? -ne 0 ]]; then
  echo "Failed to add '$username' to sudo group."
  exit 1
fi

echo "User '$username' created and added to sudo group."

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /usr/share/keyrings/packages.microsoft.gpg >/dev/null
if [[ $? -ne 0 ]]; then
  echo "Failed to download or install Microsoft GPG key."
  exit 1
fi

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
if [[ $? -ne 0 ]]; then
  echo "Failed to add Microsoft VS Code apt source."
  exit 1
fi

echo "Updating package lists..."
apt update -y
if [[ $? -ne 0 ]]; then
  echo "apt update failed."
  exit 1
fi

echo "Upgrading installed packages..."
apt upgrade -y
if [[ $? -ne 0 ]]; then
  echo "apt upgrade failed."
  exit 1
fi


echo "System update and upgrade completed."

apt install lxqt-core lxqt sddm -y
if [[ $? -ne 0 ]]; then
  echo "apt install lxqt-core lxqt sddm failed."
  exit 1
fi

echo "Installing xrdp..."
apt install xrdp -y
if [[ $? -ne 0 ]]; then
  echo "apt install xrdp failed."
  exit 1
fi

systemctl enable --now xrdp
if [[ $? -ne 0 ]]; then
  echo "Failed to enable and start xrdp."
  exit 1
fi
echo "Installing vs-code..."
apt install code -y
if [[ $? -ne 0 ]]; then
  echo "apt install code failed."
  exit 1
fi

su - "$username" -c 'printf "%s\n" "startlxqt" > ~/.xsession'
if [[ $? -ne 0 ]]; then
  echo "Failed to create .xsession for $username."
  exit 1
fi

chown "$username":"$username" "/home/$username/.xsession"
if [[ $? -ne 0 ]]; then
  echo "Failed to set ownership for /home/$username/.xsession."
  exit 1
fi



echo "lxqt-core, lxqt, sddm, and xrdp installed; xrdp enabled and started."
echo ".xsession created for $username."

systemctl restart xrdp
if [[ $? -ne 0 ]]; then
  echo "Failed to restart xrdp."
  exit 1
fi


sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)
if [[ $? -ne 0 ]]; then
  echo "apt uninstall all older docker related packages failed."
  exit 1
fi


apt install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl restart docker