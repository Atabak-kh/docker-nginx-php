FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive

# install packages
RUN apt-get update && \
    apt-get -y --force-yes --no-install-recommends install \
    supervisor \
    nginx \
    php7.0-fpm php7.0-cli php7.0-common php7.0-curl php7.0-gd php7.0-intl php7.0-json php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-opcache php7.0-pgsql php7.0-soap php7.0-sqlite3 php7.0-xml php7.0-xmlrpc php7.0-xsl php7.0-zip

# configure NGINX as non-daemon
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

# configure php-fpm as non-daemon
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf

# clear apt cache and remove unnecessary packages
RUN apt-get autoclean && apt-get -y autoremove

# NGINX mountable directories for config and logs
VOLUME ["/etc/nginx/sites-enabled", "/etc/nginx/certs", "/etc/nginx/conf.d", "/var/log/nginx"]

# NGINX mountable directory for apps
VOLUME ["/var/www"]

# copy config file for Supervisor
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# backup default default config for NGINX
RUN cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak

# copy local defualt config file for NGINX
COPY config/default /etc/nginx/sites-available/default

# php7.0-fpm will not start if this directory does not exist
RUN mkdir /run/php

# NGINX ports
EXPOSE 80 443

CMD ["/usr/bin/supervisord"]

WORKDIR /var/www/html
