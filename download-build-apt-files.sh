cd build-deb/
wget -i ./urls.txt 
sudo apt update
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances nodejs | grep "^\w" | sort -u)
#apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances npm | grep "^\w" | sort -u)
cd ..
