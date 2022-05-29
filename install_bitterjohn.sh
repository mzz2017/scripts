#!/bin/bash

enable_bbr() {
  sed -i '/net.ipv4.tcp_congestion_control=/d' /etc/sysctl.conf
  echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
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
  armv5*)
    ARCH="arm"
    ;;
  armv6*)
    ARCH="arm"
    ;;
  armv7*)
    ARCH="arm"
    ;;
  arm)
    ARCH="arm"
    ;;
  armv8*)
    ARCH="arm64"
    ;;
  arm64)
    ARCH="arm64"
    ;;
  aarch64*)
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
  version=$(curl -s https://api.github.com/repos/e14914c0-6759-480d-be89-66b7b7676451/BitterJohn/releases/latest|jq -r .tag_name)
  curl -L "https://github.com/e14914c0-6759-480d-be89-66b7b7676451/BitterJohn/releases/latest/download/BitterJohn_${PLATFORM}_${ARCH}_${version:1}" -o "${temp_file}"
  chmod +x "${temp_file}"
  "${temp_file}" install -g
  systemctl enable --now BitterJohn.service
}

enable_bbr
download_and_install
