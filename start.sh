#!/bin/bash
if [ "$(ls -A /var/www/html)" ]; then
echo "Public html directory already cloned"
else
echo "Public html files do not exist" ;
cp -r /tmp/www/html /var/www/ 
fi

if [ "$(ls -A /var/www/craft/templates)" ]; then
echo "Template directory already cloned"
else
echo "Template files do not exist" ;
cp -r /tmp/www/craft/templates /var/www/craft/
fi

if [ "$(ls -A /var/www/craft/plugins)" ]; then
echo "Directory already cloned"
else
echo "Plugin files do not exist" ;
cp -r /tmp/www/craft/plugins /var/www/craft/
fi

docker-php-entrypoint apache2-foreground