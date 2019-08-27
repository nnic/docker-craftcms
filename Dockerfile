FROM php:7.1-apache

LABEL maintainer "Nic Masters <nic@nicmasters.com>"

RUN apt-get update \
	&& apt-get install -yq unzip libmcrypt-dev libmagickwand-dev \
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
	&& cp -r /var/www/plugins /tmp/www/ \
	&& cp -r /var/www/config /tmp/www/ \
	&& cp -r /var/www/storage /tmp/www/ \
	&& cp -r /var/www/modules /tmp/www/ 

# Allow Craft to be configured with environment variables
ADD db.php general.php /tmp/www/config/
ADD .env /var/www/

RUN chown -R www-data:www-data \
	/var/www/storage/ \
	/var/www/vendor/ \
	/var/www/web/cpresources/

ENV CRAFT_DATABASE_HOST=localhost \
	CRAFT_DATABASE_PORT=3306 \
	CRAFT_DATABASE_USER=root \
	CRAFT_DATABASE_PASSWORD= \
	CRAFT_DATABASE_NAME= \
	CRAFT_ALLOW_AUTO_UPDATES=true \
	CRAFT_COOLDOWN_DURATION=PT5M \
	CRAFT_DEV_MODE=false \
	CRAFT_MAX_UPLOAD_FILE_SIZE=16777216 \
	CRAFT_OMIT_SCRIPT_NAME_IN_URLS=auto \
	CRAFT_USE_COMPRESSED_JS=true \
	CRAFT_USER_SESSION_DURATION=PT1H

VOLUME ["/var/www/web", "/var/www/templates", "/var/www/modules",  "/var/www/config", "/var/www/storage"]

COPY start.sh /start.sh

RUN chmod -v +x /start.sh

CMD ["/start.sh"]
