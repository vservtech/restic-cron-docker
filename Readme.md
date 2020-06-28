# Ansible Controller Docker

This repo contains a dockerfile which allows running an ansible controller inside a docker container.

## Why?

I want to setup my own virtual server and have it configured via code. 
Since ansible needs so much configuration when running as a controller, 
I decided it would be useful to encapsulate this into a docker container. 

This docker container is NOT intended to be run on a remote server (although it could be possible for automating other servers from a control server running in docker). 

Instead this is intended to be run manually on a mac, windows or linux to be able to run ansible commands by simply defining the host and config files 
and be good to go with the ansible command line inside this docker image.

## How to use this docker image

Look into docker-compose.yml for this repo: 
- bind mount all interesting files & configuration folders into the docker image, like `./ansible/hosts`
- start with `docker-compose up`
- run a command inside this container with docker-compose run ansible ansible all -m ping -u you 

## For Developers: New Image release to docker

1. Build Docker image with `npm run build`
2. Tag latest with `npm run tag:latest`
3. Test with `npm run test`
4. Deploy with `npm run deploy`


