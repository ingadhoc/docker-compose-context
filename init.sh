#!/bin/bash

# Create adhoc network if it doesn't exist
if ! docker network inspect adhoc > /dev/null 2>&1; then
  docker network create --subnet=172.60.0.0/16 adhoc
fi

# Create minikube network if it doesn't exist
if ! docker network ls --filter name=^minikube$ --format "{{.Name}}" | grep -wq "minikube"; then
  docker network create \
    --scope="local" \
    --driver=bridge \
    -o "com.docker.network.driver.mtu"="1500" \
    --subnet=192.168.49.0/24 \
    --gateway=192.168.49.1 \
    --ip-range=192.168.49.128/25 \
    minikube
fi

sudo setfacl -R -m u:$USER:rwX /var/lib/docker/volumes
sudo setfacl -R -d -m u:$USER:rwX /var/lib/docker/volumes

docker compose up -d
