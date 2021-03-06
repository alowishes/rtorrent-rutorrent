Docker container with rTorrent and ruTorrent (stable and latest from github)
============================================================================

Multiple processes inside the container managed by supervisor:

- nginx
- php5-fpm
- rtorrent

----------
Exposed:

 - Web UI ports: 80 and 443
 - DHT UDP port: 49160
 - Incoming connections port: 49161
 - Downloads volume: /downloads
 - rtorrent scratch files (watch and .session will be created automatically): /rtorrent/
 - ruTorrent ui config (config will be created automatically): /rtorrent/config

----------
Adding basic auth:

Put .htpasswd into your /rtorrent/ folder, the container will re-read .htpasswd each time it starts. To remote auth, simply remove .htpasswd and restart your container.

Instructions on how to generate .htpasswd can be found here: [Nginx FAQ][1]

    $ printf "John:$(openssl passwd -crypt V3Ry)\n" >> .htpasswd # this example uses crypt encryption

    $ printf "Mary:$(openssl passwd -apr1 SEcRe7)\n" >> .htpasswd # this example uses apr1 (Apache MD5) encryption

    $ printf "Jane:$(openssl passwd -1 V3RySEcRe7)\n" >> .htpasswd # this example uses MD5 encryption

    $ PASSWORD="SEcRe7PwD";SALT="$(openssl rand -base64 3)";SHA1=$(printf "$PASSWORD$SALT" | openssl dgst -binary -sha1 | sed 's#$#'"$SALT"'#' | base64);printf "Jim:{SSHA}$SHA1\n" >> .htpasswd) # this example uses SSHA encryption

----------
Adding TLS/SSL:

Put your keyfile (shall be named nginx.key) and your certificate (nginx.crt) into /rtorrent/ folder, the container looks for these files each time it starts.

Generate a self-signed certificate:

    $ openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout nginx.key -out nginx.crt

Nginx TLS/SSL is configured as follwoing:

     keepalive_timeout   60;
     ssl_certificate      /etc/nginx/ssl/nginx.crt;
     ssl_certificate_key  /etc/nginx/ssl/nginx.key;
     ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
     ssl_ciphers  "RC4:HIGH:!aNULL:!MD5:!kEDH";
     add_header Strict-Transport-Security 'max-age=604800';

(Actually, flaky SSL is disabled)

----------
Basic auth secured with TLS/SSL:

Apparently, put .htpasswd, nginx.key and nginx.crt into /rtorrent/ folder.

----------
Access web-interface: enter http://your_host_address:8080 in a browser for insecure version and https://your_host_address for secure version


  [1]: http://wiki.nginx.org/Faq#How_do_I_generate_an_htpasswd_file_without_having_Apache_tools_installed.3F "Nginx FAQ"

