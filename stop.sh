#!/bin/bash

source .env

printf "${MSG_HIGHLIGHT}%s${MSG_RESET}\n" "Stopping..."
printf "${MSG_NOTICE}%s${MSG_RESET}\n" "Remove record: /etc/hosts"

sudo touch /etc/hosts
recordBegin="# m2d-begin $APP_NAME #"
recordEnd="# m2d-end $APP_NAME #"
fileContent=$(cat /etc/hosts | \
    tr "\n" "\r" | \
    sed "s|${recordBegin}.*${recordEnd}||" | \
    tr "\r" "\n"
)
printf "$fileContent" | sudo tee /etc/hosts >/dev/null

printf "${MSG_NOTICE}%s${MSG_RESET}\n" "Down containers..."
docker-compose down -v

printf "${MSG_HIGHLIGHT}%s${MSG_RESET}\n" "Done."