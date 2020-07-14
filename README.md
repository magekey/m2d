# Magento 2 Docker

## Start docker

```
./start.sh
```

## Install Magento 2

```
docker exec -it app_php install-m2.sh
```

## Install Sample Data

```
docker exec -it app_php bin/magento sampledata:deploy
docker exec -it app_php bin/magento setup:upgrade
```