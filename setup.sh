#!/bin/bash

# Make sure you're sudo
if [ "$EUID" -ne 0 ]
  then echo "Please run as root using `sudo -i` then try again"
  exit
fi

# Explain what the script will do and ask for confirmation
echo "This script will install and do the following:
- Configuration files from https://github.com/ION606/swaybackup.git
- Librewolf browser
- Visual Studio Code
- Various fonts
- The latest version of Java
- Proton VPN
- Alacritty terminal
- Nautilus file manager
- Node.js
- Git and GitHub CLI
- Neovim
- Gparted
- VLC media player
- GCC and G++
- Asciiquarium
- Thunderbird
- Grim and Slurp (screenshot tools)
- Xclip
- Qbittorrent
- Gimp
- Audacity
- Python3-pip
- NPM packages (Bitwarden CLI, Alacritty themes, Typescript)
- Vesktop
- Docker
- Minikube
- Gnome Tweaks
- Remove Thunar and Foot
- Clean up and update system

Do you want to proceed? (Y/N, default Y): "
read answer
answer=${answer:-y}

if [ "$answer" != "y" ]; then
	echo "Installation aborted."
	exit
fi

# Make temporary directory
mkdir ~/Downloads/tempinstall || ""
cd ~/Downloads/tempinstall

# Configuration Files
git clone https://github.com/ION606/swaybackup.git
cd swaybackup
mv -f waybar/config /etc/xdg/waybar/
mv -f waybar/style.css /etc/xdg/waybar
mv -f config ~/.config/sway/config
mf -f lockscreen.sh ~/lockscreen.sh


# Installs

# Automatically Answer "Y"
echo assumeyes=True | sudo tee -a /etc/dnf/dnf.conf

# Librewolf
curl -fsSL https://rpm.librewolf.net/librewolf-repo.repo | pkexec tee /etc/yum.repos.d/librewolf.repo

# VS Code
rpm --import https://packages.microsoft.com/keys/microsoft.asc
printf "[vscode]\nname=packages.microsoft.com\nbaseurl=https://packages.microsoft.com/yumrepos/vscode/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\nmetadata_expire=1h" | sudo tee -a /etc/yum.repos.d/vscode.repo

# Fonts
dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
	https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
	install bitstream-vera-sans-fonts bitstream-vera-serif-fonts bitstream-vera-sans-mono-fonts \
	google-droid-sans-fonts google-droid-serif-fonts google-droid-sans-mono-fonts \
	urw-fonts || echo "failed to install fonts!"

rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm || echo "failed to install microsoft fonts!"

# Install Java
LATEST_JDK=$(sudo dnf list available | grep -E 'java-[0-9]+-openjdk' | awk '{print $1}' | sort -V | tail -n 1) && dnf install -y $LATEST_JDK || echo "failed to install Java!"

# Proton VPN
wget "https://repo.protonvpn.com/fedora-$(cat /etc/fedora-release | cut -d\  -f 3)-stable/protonvpn-stable-release/protonvpn-stable-release-1.0.1-2.noarch.rpm" \
	&& dnf install ./protonvpn-stable-release-1.0.1-2.noarch.rpm \
	|| echo "failed to install Proton VPN!"


# Install Docker and Minikube
dnf install dnf-plugins-core \
	&& dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo \
 	&& dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
  	|| echo "failed to install Docker!"

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm \
	&& sudo rpm -Uvh minikube-latest.x86_64.rpm \
 	|| echo "failed to install Minikube!"


# General Package Install
dnf install --refresh alacritty nautilus nodejs librewolf code \
	git gh proton-vpn-gnome-desktop neovim gparted liberation-fonts \
	vlc gcc gcc-c++ asciiquarium thunderbird grim slurp xclip \
	qbittorrent gimp audacity python3-pip htop obs-studio gnome-tweaks \
        torbrowser-launcher \
	|| echo "failed to install some packages!"

npm install -g @bitwarden/cli alacritty-themes typescript || echo "failed to install Typescript!"

mkdir -p ~/.icons
echo -e "https://www.gnome-look.org/p/1305251\nhttps://www.gnome-look.org/p/2091068" > ~/.icons/links.txt

alacritty-themes --create && alacritty-themes Hyper || echo "alacritty theme install failed!"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# Remove old programs
dnf remove thunar foot || ""

# Install vesktop
wget -O vesktop.rpm https://vencord.dev/download/vesktop/amd64/rpm && dnf install vesktop || echo "failed to install Vesktop!"

# Install Min
rpm -i https://github.com/minbrowser/min/releases/download/v1.32.1/min-1.32.1-x86_64.rpm --ignoreos --force

# Clean-up and update
sudo dnf clean all
sudo dnf update
echo assumeyes=False | sudo tee -a /etc/dnf/dnf.conf
cd ../ && rm -rf tempinstall || echo "failed to remove temporary directory at ~/Downloads/tempinstall"

# history preferences
HISTIGNORE="*shutdown now*:*reboot*:erasedups"

# Log-ins and installs
bw login
gh auth login
exit
