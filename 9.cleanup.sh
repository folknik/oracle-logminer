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

if [ -d oradata ]; then
    sudo rm -rf oradata
fi

if [ -d output ]; then
    sudo rm -rf output
fi

if [ -d output ]; then
    sudo rm -rf log
fi

sudo rm -f sql/*.out

echo "- all OK"