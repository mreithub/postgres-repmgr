#!/bin/bash

set -e

if ! [ -e "$PGDATA/postgresql.conf" ]; then
	echo "~~ 04: copying initial postgresql.conf" >&2
	cp -v /etc/postgresql/postgresql.conf "$PGDATA/postgresql.conf"
fi
