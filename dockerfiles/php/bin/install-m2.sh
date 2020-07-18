#!/bin/sh

ADMIN_USER=admin
ADMIN_PASS=admin123
ADMIN_EMAIL=$ADMIN_USER@mail.local

composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition /var/www

php bin/magento setup:install \
    --backend-frontname=admin \
    --base-url=http://$APP_DOMAIN/ \
    --cleanup-database \
    --db-host=$APP_DB_HOST --db-name=$APP_DB_NAME --db-user=root --db-prefix=m2_ --db-password=$MYSQL_ROOT_PASSWORD \
    --admin-firstname=Magento --admin-lastname=User --admin-email=$ADMIN_EMAIL \
    --admin-user=$ADMIN_USER --admin-password=$ADMIN_PASS --language=en_US \
    --currency=USD --timezone=America/Chicago --use-rewrites=1 --use-secure=0 --use-secure-admin=0

printf "
    Frontend URL:           http://$APP_DOMAIN/
    Backend URL:            http://$APP_DOMAIN/admin/

    Admin User:             $ADMIN_USER
    Admin Password:         $ADMIN_PASS
    Admin Email:            $ADMIN_EMAIL
"