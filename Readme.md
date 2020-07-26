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
- playbooks can be mounted to `/opt/ansible-workdir`, which is the WORKDIR defined in the Dockerfile
- start with `docker-compose up`
- run a command inside this container with docker-compose run ansible ansible all -m ping -u you 

## More usage hints 

- run `npm run exec` to get shell inside container 

## For Developers: New Image release to docker

1. Sign-off new version for npm package (`npm version xxx`)
2. Build Docker image with `npm run build`
3. Tag latest with `npm run tag:latest`
4. Test with `npm run test` && `npm run exec` to get shell access into the container
5. Deploy with `npm run deploy`

------

# Changelog 

## 1.2.0 

ships with 
    - rsync 3.1.3
    - Python 3.8.3
    - ansible 2.9.9


