# Migration Framwork
This is migration framework to run migration entirely in docker using odoo open upgrade.
For now, it support migration from version 14.0.

# How to use
1. Select branch to where we want to migrate
1. COPY dump file to here as LATEST.sql
2. RUN ./run.sh
3. Check error an edit migration script accordingly
4. Repeat from no 2 until no error occured
5. Output file is DUMP.sql, restore it