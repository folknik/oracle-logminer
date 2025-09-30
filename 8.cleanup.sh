#!/bin/bash

set -e

. cfg.sh


docker rm -f redpanda-console
echo "redpanda-console container removed"

docker rm -f kafka-connect
echo "kafka-connect container removed"

docker rm -f schema-registry
echo "schema-registry container removed"

docker rm -f kafka
echo "kafka container removed"

docker rm -f zookeeper
echo "zookeeper container removed"

if [ "$(docker ps -a -q -f name=${OLR_CONTAINER})" ]; then
    docker rm -f ${OLR_CONTAINER}
fi

if [ "$(docker ps -a -q -f name=${DB_CONTAINER})" ]; then
    docker rm -f ${DB_CONTAINER}
fi

echo "- all OK"