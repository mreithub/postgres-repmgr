# postgres-repmgr
PostgreSQL Docker image with repmgrd for automatic failover

This is heavily based on [2ndQuadrant's blog post on the topic](https://blog.2ndquadrant.com/pg-phriday-getting-rad-docker-part-3/)), but:

- several environment variables have been added
- this image doesn't use passwordless replication. Make sure to set `REPMGR_PASSWORD`
- I've taken the liberty to add my own [pg_recall](https://github.com/mreithub/pg_recall) PostgreSQL extension, because I need it on all my production clusters.  
  It's a source-only extension, so unless you call `CREATE EXTENSION recall`, it's entirely inactive.
- a few other minor changes

Environment:

This docker image uses the following environment variables (with their defaults if applicable):

- `REPMGR_USER=repmgr`
- `REPMGR_DB=repmgr`
- `REPMGR_PASSWORD` (required)  
  Use something like `pwgen -n 24 1` to generate a random one (and make sure you use the same one on all your nodes
- `NODE_HOST=`  
  If set, this is used in the `conninfo` string (used by other nodes to connect to this one.  
  If empty, `hostname -f` is used
  Make sure you use a hostname the others can resolve (or an IP address)
- `WITNESS=`
  If non-empty, this node is set up as witness node (i.e. won't hold actual data but still has a vote in leader election).  
  
