

# Users

## Player's users

agent : iwanttopawn -- player connection
ssh-user : lkwf nqdjv dqfdqfvq -- user we want to get the flag

## backend's users

deploy-manager : I4mtHeM@n4geroFSsH -- handle python script

deploy-1 : Iw@ntT0d3ploy!SSH -- handle localhost:22001
deploy-2 : Iw@ntT0d3ploy!SSH -- handle localhost:22002
deploy-3 : Iw@ntT0d3ploy!SSH -- handle localhost:22003
deploy-4 : Iw@ntT0d3ploy!SSH -- handle localhost:22004

# Services
## Docker in Docker

## SSH

## Conpot
https://hub.docker.com/r/honeynet/conpot
## Cowrie

## Kippo 


# Dokerfiles

## dind
Create Network
```sh
sudo docker network create --subnet=172.20.0.0/16 --gateway=172.20.0.1 mynetwork
```
Build the docker image
```sh
sudo docker build -t challenge --buold-arg SSH_USER=player --build-arg SSH_PASS=iwanttheflag .
```
Run the Docker container
```sh
sudo docker run --name challenge_c -v /var/run/docker.socket:/var/run/docker.socket --privileged -p 2222:22 challenge
```
Connect as root
```sh
sudo docker exec -it challenge_c /bin/sh
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
docker run --name X_c --net mynetwork X
```
Connect as root
```sh
docker exec -it X_c /bin/sh
```


## kippo

## cowrie

## conpot
