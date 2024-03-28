#!/bin/bash

echo "NOTE: This script should be run inside a warden shell!"
declare -A config
config['backend_frontname']="backend"
config['admin_user']="localadmin"
config['admin_pass']="Hbwsl@123"
config['admin_firstname']="Local"
config['admin_lastname']="Admin"
config['admin_email']="localadmin@example.com"

# don't change db_host if you are running database on local machine
config['db_host']="db"
config['db_name']="magento"
config['db_user']="magento"
config['db_pass']="magento"



echo "Running setup Install ..."
## Install Application
php bin/magento setup:install \
    --backend-frontname="${config['backend_frontname']}" \
    --amqp-host=rabbitmq \
    --amqp-port=5672 \
    --amqp-user=guest \
    --amqp-password=guest \
    --db-host="${config['db_host']}" \
    --db-name="${config['db_name']}" \
    --db-user="${config['db_user']}" \
    --db-password="${config['db_pass']}" \
    --search-engine=elasticsearch7 \
    --elasticsearch-host=elasticsearch \
    --elasticsearch-port=9200 \
    --elasticsearch-index-prefix=magento2 \
    --elasticsearch-enable-auth=0 \
    --elasticsearch-timeout=15 \
    --http-cache-hosts=varnish:80 \
    --session-save=redis \
    --session-save-redis-host=redis \
    --session-save-redis-port=6379 \
    --session-save-redis-db=2 \
    --session-save-redis-max-concurrency=20 \
    --cache-backend=redis \
    --cache-backend-redis-server=redis \
    --cache-backend-redis-db=0 \
    --cache-backend-redis-port=6379 \
    --page-cache=redis \
    --page-cache-redis-server=redis \
    --page-cache-redis-db=1 \
    --page-cache-redis-port=6379

## Configure Application
php bin/magento config:set web/unsecure/base_url \
    "https://${TRAEFIK_SUBDOMAIN}.${TRAEFIK_DOMAIN}/"

php bin/magento config:set web/secure/base_url \
    "https://${TRAEFIK_SUBDOMAIN}.${TRAEFIK_DOMAIN}/"

php bin/magento config:set web/secure/offloader_header X-Forwarded-Proto

php bin/magento config:set web/secure/use_in_frontend 1
php bin/magento config:set web/secure/use_in_adminhtml 1
php bin/magento config:set web/seo/use_rewrites 1

php bin/magento config:set system/full_page_cache/caching_application 2
php bin/magento config:set system/full_page_cache/ttl 604800

php bin/magento config:set catalog/search/enable_eav_indexer 1

php bin/magento config:set dev/static/sign 0

php bin/magento deploy:mode:set -s developer

php bin/magento indexer:reindex
php bin/magento cache:flush


echo "Creating a Admin user ..."

ADMIN_PASS="${config['admin_pass']}"
ADMIN_USER="${config['admin_user']}"

# uncomment for randomly generated password
# ADMIN_PASS="$(pwgen -n1 16)"

bin/magento admin:user:create \
    --admin-password="${ADMIN_PASS}" \
    --admin-user="${ADMIN_USER}" \
    --admin-firstname="${config['admin_firstname']}" \
    --admin-lastname="${config['admin_lastname']}" \
    --admin-email="${config['admin_email']}"
printf "u: %s\np: %s\n" "${ADMIN_USER}" "${ADMIN_PASS}"


## Disabling TwoFactorAuth
# while true; do

# read -p "Do you want to disable TwoFactorAuth? (y/n) " yn

# case $yn in 
#     [yY] ) echo Disabling TwoFactorAuth;
#         break;;
#     [nN] ) echo exiting...;
#         exit;;
#     * ) echo invalid response;;
# esac

# done

# php bin/magento module:disable Magento_TwoFactorAuth
