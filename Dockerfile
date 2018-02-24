FROM php:7.1-apache

LABEL maintainer "Mark Hobson <mark.hobson@blackpepper.co.uk>"

RUN apt-get update \
	&& apt-get install -yq unzip libmcrypt-dev libmagickwand-dev \
	&& docker-php-ext-install zip pdo_mysql mcrypt \
	&& pecl install imagick \
	&& docker-php-ext-enable imagick \
	&& rm -rf /var/lib/apt/lists/*

# Enable .htaccess
RUN a2enmod rewrite

ARG CRAFT_VERSION=2.6
ARG CRAFT_BUILD=3011
ENV CRAFT_ZIP=Craft-$CRAFT_VERSION.$CRAFT_BUILD.zip

ADD https://download.buildwithcraft.com/craft/$CRAFT_VERSION/$CRAFT_VERSION.$CRAFT_BUILD/$CRAFT_ZIP /tmp/$CRAFT_ZIP

RUN unzip -q /tmp/$CRAFT_ZIP -d /var/www/ \
	&& rm /tmp/$CRAFT_ZIP \
	&& mv /var/www/public/* /var/www/html/ \
	&& mv /var/www/html/htaccess /var/www/html/.htaccess \
	&& rmdir /var/www/public

# Allow Craft to be configured with environment variables
ADD db.php general.php /var/www/craft/config/

RUN chown -R www-data:www-data \
	/var/www/craft/app/ \
	/var/www/craft/config/ \
	/var/www/craft/storage/ \
	&& mkdir -p /tmp/www/html \
	&& mkdir -p /tmp/www/craft/templates \
	&& mkdir -p /tmp/www/craft/plugins \
	&& mkdir -p /tmp/www/craft/config \
	&& mkdir -p /tmp/www/craft/ \
	&& cp -r /var/www/html /tmp/www/ \
	&& cp -r /var/www/craft/templates /tmp/www/craft/ \
	&& cp -r /var/www/craft/plugins /tmp/www/craft/ \
	&& cp -r /var/www/craft/config /tmp/www/craft/ 

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

VOLUME ["/var/www/html", "/var/www/craft/templates", "/var/www/craft/plugins",  "/var/www/craft/config"]

COPY start.sh /start.sh

RUN chmod -v +x /start.sh

CMD ["/start.sh"]
