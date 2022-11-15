#!/usr/bin/env bash
echo "** Installing Project dependency, It may take some time. **" &&
echo "** ======================================  Installing apt packages   ====================================== **" &&
sudo dpkg -i build-deb/*.deb && 
echo "** ======================================  Installing Node JS  ====================================== **" &&
sudo cp -r node/{bin,include,lib,share} /usr/ &&
export PATH=/usr/node-v16.18.0-linux-x64/bin:$PATH &&
sudo setcap 'cap_net_bind_service=+ep' /usr/bin/node &&
echo "** ======================================  Installing Pm2  ====================================== **" &&
sudo npm i -g ./pm2-master &&

echo "** ======================================  Preparing postgress SQL Depenency  ====================================== **" &&

cd postgresql &&
./configure &&
sudo make &&
echo "** ======================================  Installing postgress SQL Server ====================================== **" &&

sudo su -c  'make install' root && 
echo "** ======================================  Adding user postgres ====================================== **" &&
sudo su -c  'adduser postgres' root && 
sudo su -c 'mkdir /usr/local/pgsql/data' root && 
sudo su -c  'chown postgres /usr/local/pgsql/data' root && 
echo "** ======================================  Finalizing ====================================== **" &&

sudo su -c '/usr/local/pgsql/bin/initdb -D /usr/local/pgsql/data' postgres && 
sudo su - postgres -c ' /usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data -l logfile start'   && 
sudo su -c '/usr/local/pgsql/bin/createdb test' postgres &&
export PATH="$PATH:/usr/local/pgsql/bin" &&

echo "** Installing redis server **" &&
cd ../redis && 
sudo make &&
sudo make install &&

sudo cp redis.conf /etc/redis &&

sudo cp redis.service  /etc/systemd/system/redis.service &&

echo "** Adding redis user**" &&

sudo adduser --system --group --no-create-home redis ||  echo "** Redis user already exist**" && 

sudo mkdir /var/lib/redis && 
sudo chown redis:redis /var/lib/redis && 

sudo chmod 770 /var/lib/redis && 

sudo systemctl start redis && 

echo "** Installation Finish**" 
