#!/bin/bash

# Set rtorrent user and group id
RT_UID=${USR_ID:=1000}
RT_GID=${GRP_ID:=100}
# Set special administrator group on .rtorrent folder if specified
RT_ADM=${ADM_GID:=100}

# Update group and user
groupmod -g $RT_GID rtorrent
usermod -u $RT_UID -g $RT_GID rtorrent

# Update nginx and php-fpm settings
usr=$(getent passwd $RT_UID | cut -d":" -f1)
grp=$(getent group $RT_GID | cut -d":" -f1)
sed -i -- 's/user www-data;/user '"$usr"' '"$grp"';/g' /etc/nginx/nginx.conf
sed -i -- 's/user = www-data/user = '"$usr"'/g' /etc/php5/fpm/pool.d/www.conf
sed -i -- 's/owner = www-data/owner = '"$usr"'/g' /etc/php5/fpm/pool.d/www.conf
sed -i -- 's/group = www-data/group = '"$grp"'/g' /etc/php5/fpm/pool.d/www.conf
sed -i -- 's/memory_limit = 128M/memory_limit = 1024M/g' /etc/php5/fpm/php.ini

# Create folders
mkdir -p /downloads/.rtorrent/session
mkdir -p /downloads/.rtorrent/config/torrents
mkdir -p /downloads/.rtorrent/watch

# Link rtorrent settings if any are found
if [ -e /downloads/.rtorrent/.rtorrent.rc ]; then
    rm /home/rtorrent/.rtorrent.rc
    ln -s /downloads/.rtorrent/.rtorrent.rc /home/rtorrent/
fi

# Update directory permissions
chown -R $RT_UID:$RT_GID /var/www/rutorrent
chown -R $RT_UID:$RT_GID /home/rtorrent
chown $RT_UID:$RT_ADM /downloads/.rtorrent
chown $RT_UID:$RT_GID /downloads
chmod 770 /downloads/.rtorrent
chmod 755 /downloads

# Remove old files
rm -f /downloads/.rtorrent/session/rtorrent.lock
rm -f /etc/nginx/sites-enabled/*
rm -f /var/www/rutorrent/.htpasswd
rm -rf /etc/nginx/ssl

# Basic auth enabled by default
site=rutorrent-basic.nginx

# Check if TLS needed
if [[ -e /downloads/.rtorrent/nginx.key && -e /downloads/.rtorrent/nginx.crt ]]; then
    mkdir -p /etc/nginx/ssl
    cp /downloads/.rtorrent/nginx.crt /etc/nginx/ssl/
    cp /downloads/.rtorrent/nginx.key /etc/nginx/ssl/
    site=rutorrent-tls.nginx
fi

# Enable site
cp /root/$site /etc/nginx/sites-enabled/

# Check if .htpasswd presents
if [ -e /downloads/.rtorrent/.htpasswd ]; then
    cp /downloads/.rtorrent/.htpasswd /var/www/rutorrent/ && chmod 755 /var/www/rutorrent/.htpasswd && chown $RT_UID:$RT_GID /var/www/rutorrent/.htpasswd
else
    # Disable basic auth
    sed -i 's/auth_basic/#auth_basic/g' /etc/nginx/sites-enabled/$site
fi

# Start supervisor
exec supervisord -c /etc/supervisor/conf.d/supervisord.conf
