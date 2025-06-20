

# Users

## Player's users

m95dupont : myP@ssword! -- player connection

ot-user : p@ssword -- user we want to get the flag


# Services
## Docker in Docker

## SSH

## Conpot
https://hub.docker.com/r/honeynet/conpot
## Cowrie

## Kippo 


# Dokerfiles

## dind
Build the docker image
```sh
sudo docker build -t dind_custom deploy/
```
Run the Docker container
```sh
sudo docker run --name challenge -v /var/run/docker.sock:/var/run/docker.sock --privileged -p 2222:22 dind_custom
```
Connect as root
```sh
sudo docker exec -it challenge /bin/sh
```

## DinD config (automated)

Create Network
```sh
sudo docker network create --subnet=172.20.0.0/16 --gateway=172.20.0.1 mynetwork
```
Create Shared Volume
```sh
docker volume create honeypot_logs_volume
```

## ssh

SSH directory
```bash
cd ssh
```
Build the docker image
```bash
docker build -t X --build-arg SSH_USER=user --build-arg SSH_PASS=ilovessh .
```
Run the Docker container
```sh
docker run --name X_c --net mynetwork --ip 172.20.0.1X X
```
Connect as root
```sh
docker exec -it X_c /bin/sh
```


## kippo

## cowrie

## conpot
