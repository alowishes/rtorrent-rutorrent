#!/bin/bash

# Copy security settings
cp /downloads/.htpasswd /var/www/rutorrent/

# Set rtorrent user and group id
RT_UID=${USR_ID:=1000}
RT_GID=${GRP_ID:=100}

# Make sure the specified group exists
getent group $RT_GID
if [ $? -ne 0 ]; then
groupadd -g $RT_GID rtorrent
fi

# Update users
usermod -u $RT_UID -g $RT_GID rtorrent

# Create and set permissions on folders
mkdir -p /downloads/.session
mkdir -p /downloads/.config/settings
mkdir -p /downloads/.config/torrents
mkdir -p /downloads/watch

# Update directory permissions
chown -R $RT_UID:$RT_GID /home/rtorrent
chown -R $RT_UID:$RT_GID /downloads/.config /downloads/.session /downloads/watch
chmod -R go+w /downloads/.config

# Remove old files
rm -f /downloads/.session/rtorrent.lock
rm -f /etc/nginx/sites-enabled/*
rm -f /var/www/rutorrent/.htpasswd
rm -rf /etc/nginx/ssl

# Basic auth enabled by default
site=rutorrent-basic.nginx

# Check if TLS needed
if [[ -e /downloads/nginx.key && -e /downloads/nginx.crt ]]; then
mkdir -p /etc/nginx/ssl
cp /downloads/nginx.crt /etc/nginx/ssl/
cp /downloads/nginx.key /etc/nginx/ssl/
site=rutorrent-tls.nginx
fi

cp /root/$site /etc/nginx/sites-enabled/

# Check if .htpasswd presents
if [ -e /downloads/.htpasswd ]; then
cp /downloads/.htpasswd /var/www/rutorrent/ && chmod 755 /var/www/rutorrent/.htpasswd && chown www-data:www-data /var/www/rutorrent/.htpasswd
else
# disable basic auth
sed -i 's/auth_basic/#auth_basic/g' /etc/nginx/sites-enabled/$site
fi

nginx -g "daemon off;"

