#!/bin/bash

set -e
 
if [ $(grep -c "replication repmgr" ${PGDATA}/pg_hba.conf) -gt 0 ]; then
    return
fi
 
echo '~~ 01: add repmgr' >&2

if [ -z "$REPMGR_PASSWORD" ]; then
	echo 'ERROR: Missing $REPMGR_PASSWORD variable' >&2
	exit 1
fi

#createuser -U "$POSTGRES_USER" -s --replication "$REPMGR_USER"
echo "CREATE ROLE $REPMGR_USER LOGIN SUPERUSER REPLICATION PASSWORD '$REPMGR_PASSWORD'" | psql -U "$POSTGRES_USER"
createdb -U "$POSTGRES_USER" -O "$REPMGR_USER" "$REPMGR_DB"
 
echo "host replication $REPMGR_USER all md5" >> "$PGDATA/pg_hba.conf"
echo "host all repmgr all md5" >> "$PGDATA/pg_hba.conf"
 
sed -i "s/#*\(shared_preload_libraries\).*/\1='repmgr'/;" ${PGDATA}/postgresql.conf
 
pg_ctl -D ${PGDATA} stop -m fast
pg_ctl -D ${PGDATA} start &
 
sleep 1
