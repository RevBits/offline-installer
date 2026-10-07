#!/usr/bin/env bash
set -euo pipefail

normal="\033[0m"
blueb="\033[1;34m"
lightblueb="\033[1;36m"

echo "** Installing Project dependency, It may take some time. **"
echo "** ======================================  Extracting bundled Node.js ====================================== **"
tar -xJf node.tar.xz

echo "** ======================================  Installing apt packages   ====================================== **"
tmp_deb_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_deb_dir"' EXIT

# build-deb can contain old downloads if the download script was run more than once.
# Pick the highest version for each package name before calling dpkg.
for deb in build-deb/*.deb; do
  pkg="$(dpkg-deb -f "$deb" Package)"
  current="$(find "$tmp_deb_dir" -maxdepth 1 -type l -name "${pkg}_*.deb" -print -quit)"
  if [ -z "$current" ]; then
    ln -s "$(pwd)/$deb" "$tmp_deb_dir/$(basename "$deb")"
    continue
  fi

  current_version="$(dpkg-deb -f "$(readlink "$current")" Version)"
  new_version="$(dpkg-deb -f "$deb" Version)"
  if dpkg --compare-versions "$new_version" gt "$current_version"; then
    rm -f "$current"
    ln -s "$(pwd)/$deb" "$tmp_deb_dir/$(basename "$deb")"
  fi
done

sudo dpkg -i "$tmp_deb_dir"/*.deb
sudo dpkg --configure -a

echo "** ======================================  Installing Pm2  ====================================== **"
sudo npm i -g ./pm2-master

sudo systemctl enable postgresql
sudo systemctl start postgresql || sudo pg_ctlcluster 16 main start
pg_isready -q || {
  echo "PostgreSQL is not ready. Check: sudo journalctl -u postgresql --no-pager -n 100"
  exit 1
}



echo -e "${blueb} Creating PostgreSQL database credentials. ${normal}"

DB_NAME=''
DB_USER=''
DB_PASS=''

echo -n "Please specify the database name. (default:revbits): "
read DB_NAME

echo -n "Please specify the superuser name. (default:revbits): "
read DB_USER

echo -n "Please specify the password. (default:revbits): "
read DB_PASS
if [ -z "$DB_NAME" ]; then
  DB_NAME=revbits
fi

if [ -z "$DB_USER" ]; then
  DB_USER=revbits
fi

if [ -z "$DB_PASS" ]; then
  DB_PASS=revbits
fi

sudo su postgres <<EOF
createdb "$DB_NAME" 2>/dev/null || true;
psql -tc "SELECT 1 FROM pg_roles WHERE rolname = '$DB_USER'" | grep -q 1 || psql -c "CREATE USER \"$DB_USER\" WITH PASSWORD '$DB_PASS';"
psql -c "grant all privileges on database \"$DB_NAME\" to \"$DB_USER\";"
psql -d "$DB_NAME" -c "GRANT USAGE, CREATE ON SCHEMA public TO \"$DB_USER\";"
echo -e "${lightblueb}Postgres User '$DB_USER' and database '$DB_NAME' created.${normal}"
EOF
sudo sed -i 's/max_connections = 100/max_connections = 800/g' /etc/postgresql/16/main/postgresql.conf
sudo sed -i 's/shared_buffers = 128MB/shared_buffers = 528MB/g' /etc/postgresql/16/main/postgresql.conf
sudo service postgresql restart

echo "** Installation Finish**" 