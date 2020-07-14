### Nginx
FROM nginx:1.19 as nginx

ADD ./dockerfiles/nginx/nginx.conf /etc/nginx/nginx.conf
ADD ./dockerfiles/nginx/fastcgi_params /etc/nginx/fastcgi_params
ADD ./dockerfiles/nginx/conf /etc/nginx/conf
ADD ./dockerfiles/nginx/conf.runtime /etc/nginx/conf.runtime
ADD ./dockerfiles/nginx/bin/* /usr/local/bin/
ADD ./vhost.conf /etc/nginx/conf/custom.conf

STOPSIGNAL SIGQUIT

### Mariadb
FROM mariadb:10.2 as mysql

ADD ./dockerfiles/mariadb/my.cnf /etc/mysql/conf.d/my.conf
ADD ./dockerfiles/mariadb/bin/* /usr/local/bin/

### PHP
FROM phpdockerio/php73-fpm as php

RUN apt-get update \
    && apt-get install -y apt-utils dialog nano

RUN apt-get install -y php7.3-mysql php7.3-bcmath php7.3-gd php7.3-intl php7.3-soap \
        imagemagick php-imagick

RUN curl -o /usr/local/bin/magerun2 https://files.magerun.net/n98-magerun2.phar \
    && chmod +x /usr/local/bin/magerun2

ADD ./dockerfiles/php/conf/php-general.ini /etc/php/7.3/cli/conf.d/00-general.ini
ADD ./dockerfiles/php/conf/php-cli.ini /etc/php/7.3/cli/conf.d/01-general.ini
ADD ./dockerfiles/php/conf/php-general.ini /etc/php/7.3/fpm/conf.d/00-general.ini
ADD ./dockerfiles/php/conf/php-fpm.ini /etc/php/7.3/fpm/conf.d/01-general.ini
ADD ./dockerfiles/php/conf/zzz-general.conf /etc/php/7.3/fpm/pool.d/zzz-general.conf
ADD ./dockerfiles/php/bin/* /usr/local/bin/

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

CMD /usr/sbin/php-fpm7.3 -O -R