# Migration Framwork
This is migration framework to run migration entirely in docker using odoo open upgrade.
For now, it support migration from version 14.0 -> 16.0

## File Structure
- `pre-migration.sql` : sql script to run before migration
- `post-migration.sql` : sql script to after before migration

## How to use
1. Select branch to where we want to migrate
1. COPY dump file to here as `LATEST.sql`
2. RUN `run.sh`
3. Check error an edit migration script accordingly
4. Repeat from no 2 until no error occured
5. Output file is `DUMP.sql`

## Manually running odoo migration
Inside container, run this steps:
1. Create database and restore database
```
docker compose exec -T db psql -U odoo -c "CREATE DATABASE odoo"
docker compose exec -T db psql -U odoo < LATEST.sql
```

2. Run migration step by step.

Migration must be run one version at a time. Ex: if we want to migrate from 14 -> 16, we run migration to 15 and 16.

```
docker compose exec python3 /odoo/<odoo version>/odoo-bin \
    --db_host $DB_HOST  --db_user $DB_USER --database $DB_NAME \
    --addons-path=/odoo/<odoo version>/addons,/OpenUpgrade/<odoo version> \
    --upgrade-path=OpenUpgrade/<odoo version>/openupgrade_scripts/scripts \
    --update all --stop-after-init --load=base,web,openupgrade_framework
```

3. Run Post migration
Sometime, unexpected data like ir_ui_view are remaining and we must delete it manually or else upgrade will not work.

```
docker compose exec -T db psql -U odoo < post-migration.sql
```

4. Run upgrade all to recover missing ui view and asssets
```
docker compose exec python3 /odoo/<odoo version>/odoo-bin \
    --db_host $DB_HOST  --db_user $DB_USER --database $DB_NAME \
    --addons-path=/odoo/<odoo version>/addons\
    --update all --stop-after-init 
```

5. Dump final database
```
docker compose exec db pg_dump -U $DB_USER $DB_NAME > DUMP.sql
```
