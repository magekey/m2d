#!/bin/bash

source .env

printf "${MSG_HEAD}%s${MSG_RESET}\n" "Starting..."

printf "${MSG_NOTICE}%s${MSG_RESET}\n" "Record to /etc/hosts..."
hosts="$HOST_IP $APP_DOMAIN"
sudo touch /etc/hosts
recordBegin="# m2d-begin $APP_NAME #"
recordEnd="# m2d-end $APP_NAME #"
fileContent=$(cat /etc/hosts | \
    tr "\n" "\r" | \
    sed "s|${recordBegin}.*${recordEnd}||" | \
    tr "\r" "\n"
)
fileContent="${fileContent}
${recordBegin}
${hosts}
${recordEnd}"
printf "$fileContent" | sudo tee /etc/hosts >/dev/null

# Compose
printf "${MSG_NOTICE}%s${MSG_RESET}\n" "Up containers..."
docker-compose up --build -d

# Services
services=($(docker-compose config --services))

# Healthcheck
printf "${MSG_NOTICE}%s${MSG_RESET}\n" "Healthcheck..."
for i in "${!services[@]}"; do
    container=${APP_NAME}_${services[$i]}
    while true; do
        healthStatus=$(docker inspect -f '{{.State.Health.Status}}' $container 2>/dev/null)
        if [ -z "$healthStatus" ] || [ "$healthStatus" == "healthy" ]; then
            break;
        fi
        sleep 0.5;
    done;
done

# Setup
printf "${MSG_NOTICE}%s${MSG_RESET}\n" "Run SETUP..."
for i in "${!services[@]}"; do
    container=${APP_NAME}_${services[$i]}
    docker exec -i $container sh <<EOF
    if [ ! -z "\$SETUP" ]; then
        sh -c "\$SETUP";
    fi
EOF
done

# Output
printf "${MSG_NOTICE}%s${MSG_RESET}\n" "----------------------- M2 Docker -----------------------"
for i in "${!services[@]}"; do
    container=${APP_NAME}_${services[$i]}
    docker exec -i $container sh <<EOF
    if [ ! -z "\$OUTPUT" ]; then
        printf "\n";
        sh -c "\$OUTPUT";
        printf "\n";
    fi
EOF
done
printf "\n${MSG_NOTICE}%s${MSG_RESET}\n" "---------------------------------------------------"