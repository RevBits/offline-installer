#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build-deb"

PACKAGES=(
  bash-completion
  ca-certificates
  curl
  dirmngr
  apt-transport-https
  lsb-release
  wget
  nodejs
  redis-server
  postgresql-16
  postgresql-client-16
)

mkdir -p "$BUILD_DIR"

if [ "${KEEP_OLD_DEBS:-0}" != "1" ]; then
  find "$BUILD_DIR" -maxdepth 1 -type f -name '*.deb' -delete
fi

sudo apt-get update
sudo apt-get -f install -y
sudo dpkg --configure -a
sudo apt-get install -y ca-certificates curl wget gnupg lsb-release

curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -

CODENAME="$(lsb_release -cs)"
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ ${CODENAME}-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list >/dev/null

sudo apt-get update

cd "$BUILD_DIR"

apt-cache depends --recurse \
  --no-recommends \
  --no-suggests \
  --no-conflicts \
  --no-breaks \
  --no-replaces \
  --no-enhances \
  "${PACKAGES[@]}" |
  awk '/^[[:alnum:]][[:alnum:].+:-]*$/ { print $1 }' |
  sort -u |
  xargs -r apt-get download
