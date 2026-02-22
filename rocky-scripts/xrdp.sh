#!/bin/bash
# XRDP and XFCE desktop environment installation script
# Installs XRDP remote desktop server with XFCE desktop environment
# Includes Japanese language support and Fcitx5 input method

set -euo pipefail

echo "Installing XRDP desktop environment with XFCE and Japanese support..."

# Set locale and language pack (can be overridden via environment variables)
# Default: ja_JP.UTF-8 with Japanese language pack
LOCALE="${LOCALE:-ja_JP.UTF-8}"
LANG_PACK="${LANG_PACK:-ja}"

# Install EPEL repository for additional packages
dnf install -y epel-release
dnf config-manager --set-enabled crb

# Update package lists
dnf clean all
dnf update -y
dnf upgrade -y

# Install bash-completion for improved command-line experience
dnf install -y bash-completion

dnf groupinstall -y "Xfce"

dnf install -y xrdp xorgxrdp

dnf install -y langpacks-ja glibc-langpack-ja

dnf install -y ibus ibus-anthy

dnf install -y google-noto-sans-cjk-jp-fonts

localectl set-locale LANG="${LOCALE}"

mv /usr/libexec/xrdp/startwm.sh /usr/libexec/xrdp/startwm.sh.bak
cat > /usr/libexec/xrdp/startwm.sh << EOF
#!/bin/sh
export GTK_IM_MODULE=ibus
export QT_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
ibus-daemon -drx  # IBusをバックグラウンドで起動

if [ -x /usr/bin/startxfce4 ]; then
    exec /usr/bin/startxfce4
fi
EOF

chmod +x /usr/libexec/xrdp/startwm.sh

# # Add input method environment variables system-wide
# if ! grep -q "GTK_IM_MODULE=fcitx" /etc/environment; then
# cat >> /etc/environment << 'EOF'
# GTK_IM_MODULE=fcitx
# QT_IM_MODULE=fcitx
# XMODIFIERS=@im=fcitx
# EOF
# fi

# Enable and start XRDP service
systemctl enable xrdp
systemctl restart xrdp
