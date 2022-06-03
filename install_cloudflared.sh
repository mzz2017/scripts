#!/bash/bin

download_and_install() {
  case "$(uname -s)" in
  Linux)
    PLATFORM='linux'
    ;;
  *)
    echo "Platform $(uname -s) may not be supported."
    exit 1
    ;;
  esac
 
  case "$(uname -m)" in
  x86)
    ARCH="386"
    ;;
  x86_64)
    ARCH="amd64"
    ;;
  armv5*|armv6*|armv7*|arm)
    ARCH="arm"
    ;;
  armv8*|arm64|aarch64*)
    ARCH="arm64"
    ;;
  *)
    echo "Architect $(uname -m) may not be supported."
    exit 1
    ;;
  esac

  wget -O /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-"$PLATFORM"-"$ARCH"
  chmod +x /usr/local/bin/cloudflared
  cat > /etc/systemd/system/cloudflared@.service << 'EOF'
[Unit]
Description=cloudflared %i
After=network.target

[Service]
TimeoutStartSec=0
Type=notify
ExecStart=/usr/local/bin/cloudflared --no-autoupdate tunnel run --credentials-file /etc/cloudflared/%i.json %i
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
  mkdir -p /etc/cloudflared
  if [ ! -z "$1" ]; then
    echo "Please input the content of the credentials-file as /etc/cloudflared/$1.json (ctrl-d when done):"
    cat > /etc/cloudflared/"$1".json
  fi
}

login() {
  cloudflared login
}

ban_http() {
  iptables -A INPUT -p tcp -m tcp --dport 80 -j REJECT
  cat > /etc/rc3.d/S01cloudflared-script-ban-http << 'EOF'
#!/bin/bash
iptables -A INPUT -p tcp -m tcp --dport 80 -j REJECT
EOF
}

hello() {
  if [ -z "$1" ]; then
    echo "Please put your credentials-file as /etc/cloudflared/<tunnel_id>.json and start your argotunnel by systemctl enable --now cloudflared@<tunnel_id>"
  else
    echo "systemctl enable --now cloudflared@""$1"
  fi
}

set -e
download_and_install $1
login
ban_http
hello $1
