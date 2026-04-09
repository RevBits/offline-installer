cd build-deb/
#wget -i ./urls.txt 
for p in \
  libjson-perl \
  libcurl4 \
  libllvm19 \
  ssl-cert \
  postgresql-common \
  postgresql-client-common \
  postgresql-client-16 \
  postgresql-16 \
  libpq5 \
  libatomic1 \
  lua-cjson \
  liblzf1 \
  liblua5.1-0 \
  libjemalloc2 \
  redis-tools \
  redis-server
do
  apt-cache show "$p" 2>/dev/null | awk '
    /^Filename: / && !seen[$2]++ {
      fn=$2
      if (fn ~ /pgdg24\.04\+1/ || fn ~ /^pool\/main\/p\/postgresql/ || fn ~ /^pool\/main\/p\/postgresql-common/)
        print "http://apt.postgresql.org/pub/repos/apt/" fn
      else
        print "http://us.archive.ubuntu.com/ubuntu/" fn
    }'
done | wget -i -


sudo apt update
curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -
apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances nodejs | grep "^\w" | sort -u)
#apt-get download $(apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances npm | grep "^\w" | sort -u)
cd ..
