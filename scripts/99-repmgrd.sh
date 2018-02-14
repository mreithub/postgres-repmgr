#!/bin/bash
 
set -e

# this will start repmgrd in the foreground, essentially hijacking
# this docker container (postgres has been started as background daemon already)
echo '~~ 99: starting repmgrd' >&2
repmgrd -v
