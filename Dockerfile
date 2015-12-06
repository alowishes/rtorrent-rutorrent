FROM ubuntu
USER root

# Add ffmpeg ppa
ADD ./ffmpeg-next.list /etc/apt/sources.list.d/ffmpeg-next.list

# Install packages
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5C50E96D8EFE5982 && \
    apt-get update -q && \
    apt-get install -qy \
        curl \
        ffmpeg \
        mediainfo \
        nginx \
        php5-cli \
        php5-fpm \
        php5-geoip \
        rtorrent \
        supervisor \
        unrar-free \
        unzip \
        wget \
        && \
    rm -rf /var/lib/apt/lists/*

# Download and install rutorrent
RUN mkdir -p /var/www && \
    wget https://bintray.com/artifact/download/novik65/generic/ruTorrent-3.7.zip && \
    unzip ruTorrent-3.7.zip && \
    mv ruTorrent-master /var/www/rutorrent && \
    rm ruTorrent-3.7.zip
ADD ./config.php /var/www/rutorrent/conf/
RUN chown -R www-data:www-data /var/www/rutorrent

# Configure rtorrent user
RUN useradd -d /home/rtorrent -m -s /bin/bash rtorrent
ADD .rtorrent.rc /home/rtorrent/
RUN chown -R rtorrent:rtorrent /home/rtorrent

# Add nginx settings
ADD rutorrent-*.nginx /root/

# Add startup script
ADD startup.sh /root/

# Configure supervisor
ADD supervisord.conf /etc/supervisor/conf.d/

EXPOSE 80
EXPOSE 443
EXPOSE 49160
EXPOSE 49161
VOLUME /downloads

CMD ["supervisord"]
