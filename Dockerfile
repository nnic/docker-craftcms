FROM php:7.1-apache

LABEL maintainer "Nic Masters <nic@nicmasters.com>"

WORKDIR /var/www

RUN apt-get update \
	&& apt-get install -yq unzip libmcrypt-dev libmagickwand-dev wget mariadb-client \
	&& docker-php-ext-install zip pdo_mysql mcrypt \
	&& pecl install imagick \
	&& docker-php-ext-enable imagick \
	&& rm -rf /var/lib/apt/lists/*

# Enable .htaccess
RUN a2enmod rewrite

ARG CRAFT_BUILD=3.0.41
ENV CRAFT_ZIP=Craft-$CRAFT_BUILD.zip

ADD https://download.craftcdn.com/craft/3.0/$CRAFT_ZIP /tmp/$CRAFT_ZIP

RUN unzip -q /tmp/$CRAFT_ZIP -d /var/www/ \
	&& rm /tmp/$CRAFT_ZIP \
	&& mkdir -p /tmp/www/web \
	&& mkdir -p /tmp/www/templates \
	&& mkdir -p /tmp/www/plugins \
	&& mkdir -p /tmp/www/config \
	&& mkdir -p /tmp/www/storage/ \
	&& mkdir -p /tmp/www/modules/ \
	&& cp -r /var/www/web /tmp/www/ \
	&& cp -r /var/www/templates /tmp/www/ \
	&& cp -r /var/www/config /tmp/www/ \
	&& cp -r /var/www/storage /tmp/www/ \
	&& cp -r /var/www/modules /tmp/www/ \
	&& chmod +x /var/www/craft \
	&& sed -i "s/html/web/" /etc/apache2/sites-available/000-default.conf \
	&& rm -r /var/www/html \
	&& chown -R www-data:www-data /var/www/* /var/www/.[^.]* \
	&& echo "php_value memory_limit 256M" >> /var/www/web/.htaccess \
	&& service apache2 restart

# Allow Craft to be configured with environment variables
ADD db.php general.php /tmp/www/config/
ADD .env /var/www/

RUN chown -R www-data:www-data \
	/var/www/storage/ \
	/var/www/vendor/ \
	/var/www/web/cpresources/

RUN truncate -s0 /var/www/.env

ENV CRAFT_DATABASE_HOST=localhost \
	CRAFT_DATABASE_PORT=3306 \
	CRAFT_DATABASE_USER=root \
	CRAFT_DATABASE_PASSWORD="" \
	CRAFT_DATABASE_NAME="" \
	CRAFT_DEV_MODE="false"

VOLUME ["/var/www/web", "/var/www/templates", "/var/www/modules",  "/var/www/config", "/var/www/storage"]

COPY start.sh /start.sh

RUN chmod -v +x /start.sh

CMD ["/start.sh"]
