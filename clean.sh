sudo rm -rf var/di/* var/generation/* var/cache/* var/page_cache/* var/view_preprocessed/* var/composer_home/cache/*  

sudo chmod 777 var -R

sudo chmod 777 pub -R

sudo php bin/magento setup:static-content:deploy -f

sudo bin/magento c:f

