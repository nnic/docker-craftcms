#!/bin/bash
if [ "$(ls -A /var/www/web)" ]; then
echo "Public html directory already cloned"
else
echo "Public html files do not exist" ;
cp -r /tmp/www/web /var/www/ 
fi

if [ "$(ls -A /var/www/templates)" ]; then
echo "Template directory already cloned"
else
echo "Template files do not exist" ;
cp -r /tmp/www/templates /var/www/
fi

if [ "$(ls -A /var/www/config)" ]; then
echo "Config directory already cloned"
else
echo "Config files do not exist" ;
cp -r /tmp/www/config /var/www/
fi

if [ "$(ls -A /var/www/storage)" ]; then
echo "Storage directory already cloned"
else
echo "Storage files do not exist" ;
cp -r /tmp/www/storage /var/www/
fi

docker-php-entrypoint apache2-foreground