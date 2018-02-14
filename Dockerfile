FROM postgres:10

# PostgreSQL 10 docker image with
# repmgr and pg_recall
# (and pg_stat_statements is enabled in postgresql.conf)

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main 10" \
          >> /etc/apt/sources.list.d/pgdg.list
 
RUN ln -s /home/postgres/repmgr.conf /etc/repmgr.conf
 
# override this on secondary nodes
ENV PRIMARY_NODE=localhost

ENV REPMGR_USER=repmgr
ENV REPMGR_DB=repmgr
 
RUN apt-get update; apt-get install -y git make postgresql-server-dev-10 libpq-dev postgresql-10-repmgr repmgr-common

RUN git clone https://github.com/mreithub/pg_recall.git /root/pg_recall/
RUN cd /root/pg_recall/; make install

RUN mkdir -p /home/postgres/; chown postgres:postgres /home/postgres/

COPY postgresql.conf /etc/postgresql/
COPY docker-entrypoint.sh /
COPY scripts/*.sh /docker-entrypoint-initdb.d/

VOLUME /home/postgres/
VOLUME /var/lib/postgresql/data/

CMD postgres -c config_file=/etc/postgresql/postgresql.conf
