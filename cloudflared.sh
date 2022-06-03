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
  mkdir /etc/cloudflared
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
}

login() {
  cloudflared login
}

set -ex
download_and_install
login
