#!/bin/bash
 
set -e

if [ -s $PGDATA/repmgr.conf ]; then
    return
fi

echo '~~ 02: repmgr conf' >&2
 
PGHOST=${PRIMARY_NODE}
 
if ! [ -e ~/.pgpass ]; then
	echo "*:5432:*:$REPMGR_USER:$REPMGR_PASSWORD" > ~/.pgpass
	chmod go-rwx ~/.pgpass
fi

installed=$(psql -qAt -h "$PGHOST" -U "$REPMGR_USER" "$REPMGR_DB" -c "SELECT 1 FROM pg_tables WHERE tablename='nodes'")
my_node=1
 
if [ "${installed}" == "1" ]; then
    my_node=$(psql -qAt -h "$PGHOST" -U "$REPMGR_USER" "$REPMGR_DB" -c 'SELECT max(node_id)+1 FROM nodes')
fi

# allow the user to specify the hostname/IP for this node
if [ -z "$NODE_HOST" ]; then
	NODE_HOST=$(hostname -f)
fi

cat<<EOF > /home/postgres/repmgr.conf
node_id=${my_node}
node_name=$(hostname -s | sed 's/\W\{1,\}/_/g;')
conninfo=host='$NODE_HOST' user='$REPMGR_USER' dbname='$REPMGR_DB' connect_timeout=5
data_directory=${PGDATA}
 
pg_bindir=/usr/lib/postgresql/10/bin
use_replication_slots=1
 
failover=automatic
promote_command=repmgr standby promote
follow_command=repmgr standby follow -W
 
service_start_command=pg_ctl -D ${PGDATA} start
service_stop_command=pg_ctl -D ${PGDATA} stop -m fast
service_restart_command=pg_ctl -D ${PGDATA} restart -m fast
service_reload_command=pg_ctl -D ${PGDATA} reload
EOF
