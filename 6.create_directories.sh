#!/bin/bash

set -e

. cfg.sh

echo "2. creating directories"

chmod 777 setup
chmod 644 setup/config.sql


echo "- all OK"