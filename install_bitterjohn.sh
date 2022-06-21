#!/bin/bash

enable_bbr() {
  sed -i '/net.core.default_qdisc=/d' /etc/sysctl.conf
  echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
  sysctl net.core.default_qdisc=fq

  sed -i '/net.ipv4.tcp_congestion_control=/d' /etc/sysctl.conf
  echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
  sysctl net.ipv4.tcp_congestion_control=bbr
}

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
    ARCH="x86"
    ;;
  x86_64)
    ARCH="x64"
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

  set -ex
  temp_file=$(mktemp /tmp/BitterJohn.XXXXXXXXX)
  trap "rm -f '$temp_file'" exit
  if [ -z "$1" ]; then
    version=$(curl -s https://api.github.com/repos/e14914c0-6759-480d-be89-66b7b7676451/BitterJohn/releases/latest|jq -r .tag_name)
  else
    version=$1
  fi
  curl -L "https://github.com/e14914c0-6759-480d-be89-66b7b7676451/BitterJohn/releases/latest/download/BitterJohn_${PLATFORM}_${ARCH}_${version:1}" -o "${temp_file}"
  chmod +x "${temp_file}"
  "${temp_file}" install -g
  systemctl enable --now BitterJohn.service
}

enable_bbr
download_and_install $1
