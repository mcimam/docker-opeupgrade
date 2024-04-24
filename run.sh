#!/bin/sh
set -x

# set database
DB_HOST=db
DB_USER=odoo
DB_NAME=odoo

RUN_DOCKER="docker compose"
RUN_PSQL="$RUN_DOCKER exec -T db psql -U $DB_USER -d $DB_NAME"
RUN_ODOO="$RUN_DOCKER exec -T odoo"
ODOO_ARGS="--db_host $DB_HOST  --db_user $DB_USER --database $DB_NAME"

# create container
$RUN_DOCKER up -d

# create database
$RUN_DOCKER exec -T db psql -U $DB_USER -c "CREATE DATABASE $DB_NAME"

# load database
$RUN_PSQL < ./LATEST.sql

# Run pre migration
$RUN_PSQL < ./pre-migration.sql

# Run odoo migration to targeted version
$RUN_ODOO python3 /odoo/15.0/odoo-bin $ODOO_ARGS \
    --addons-path=/odoo/15.0/addons,/OpenUpgrade/15.0 --upgrade-path=/OpenUpgrade/15.0/openupgrade_scripts/scripts \
    --update all --stop-after-init --load=base,web,openupgrade_framework

$RUN_ODOO python3 /odoo/16.0/odoo-bin $ODOO_ARGS \
    --addons-path=/odoo/16.0/addons,/OpenUpgrade/16.0 --upgrade-path=/OpenUpgrade/16.0/openupgrade_scripts/scripts \
    --update all --stop-after-init --load=base,web,openupgrade_framework

# Run post migration
$RUN_PSQL < ./post-migration.sql

# # Finish things
$RUN_ODOO python3 /odoo/16.0/odoo-bin $ODOO_ARGS \
    --addons-path=/odoo/16.0/addons --update=all --stop-after-init

# output dump
$RUN_DOCKER exec db pg_dump -U $DB_USER $DB_NAME > DUMP.sql

# delete container
$RUN_DOCKER down