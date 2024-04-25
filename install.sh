#!/usr/bin/env bash
echo "** Installing Project dependency, It may take some time. **" &&
echo "** ======================================  Installing apt packages   ====================================== **" &&
sudo dpkg -i build-deb/*.deb && 

echo "** ======================================  Installing Pm2  ====================================== **" &&
sudo npm i -g ./pm2-master &&


sudo service postgres restart



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
createdb  $DB_NAME;
psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
psql -c "grant all privileges on database $DB_NAME to $DB_USER;"
echo -e "${lightblueb}${1} Postgres User '$DB_USER' and database '$DB_NAME' created.${normal}"
EOF
sudo sed -i 's/max_connections = 100/max_connections = 800/g' /etc/postgresql/14/main/postgresql.conf
sudo sed -i 's/shared_buffers = 128MB/shared_buffers = 528MB/g' /etc/postgresql/14/main/postgresql.conf
sudo service postgresql restart

echo "** Installation Finish**" 
