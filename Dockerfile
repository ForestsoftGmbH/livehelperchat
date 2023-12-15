FROM php:8.2-apache

# Install dependencies
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    libzip-dev \
    libpng-dev
RUN pecl install redis-5.3.7 \
 && echo "extension=redis.so" >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/40-redis.ini
RUN docker-php-ext-install zip
RUN docker-php-ext-install gd
RUN docker-php-ext-install bcmath
RUN a2enmod headers remoteip
RUN service apache2 restart
RUN sed -i 's/#ServerName www.example.com/RemoteIPHeader X-Forwarded-For/g' /etc/apache2/sites-available/000-default.conf \
    &&  cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini \
    && echo "session.save_handler=redis" >> /usr/local/etc/php/php.ini \
    && echo "session.save_path=\${SESSION_SAVE_PATH}" >> /usr/local/etc/php/php.ini

# Copy the lhc_web folder to /var/www/html
RUN mkdir /var/www/html/livechat
COPY --chown=www-data ./lhc_web /var/www/html/livechat
WORKDIR /var/www/html/livechat
COPY --chown=www-data ./healthcheck.html /var/www/html/healthcheck.html
RUN rm /var/www/html/livechat/cache/default.log && \
     ln /var/log/apache2/error.log /var/www/html/livechat/cache/default.log
EXPOSE 80