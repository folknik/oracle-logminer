#!/bin/bash

set -e

. cfg.sh

echo "2. creating directories"

chmod a+x+r+w sql
chmod a+r sql/*.sql

mkdir log
chmod 777 log

mkdir output
chmod 777 output

chmod 777 setup
chmod 644 setup/config.sql


echo "- all OK"