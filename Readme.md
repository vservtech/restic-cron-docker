# Ansible Controller Docker

This repo contains a dockerfile which allows running an ansible controller
inside a docker container.\
[Link to Github](https://github.com/vservtech/ansible-controller-docker)

**[CHANGELOG](https://github.com/vservtech/ansible-controller-docker/blob/main/changelog.md)**

## Why?

I want to setup my own virtual server and have it configured via code. Since
ansible needs so much configuration when running as a controller, I decided it
would be useful to encapsulate this into a docker container.

This docker container is NOT intended to be run on a remote server (although it
could be possible for automating other servers from a control server running in
docker).

Instead this is intended to be run manually on a mac, windows or linux to be
able to run ansible commands by simply defining the host and config files and be
good to go with the ansible command line inside this docker image.

## How to use this docker image

Look into docker-compose.yml for this repo:

- bind mount all interesting files & configuration folders into the docker
  image, like `./ansible/hosts`
- playbooks can be mounted to `/opt/ansible-workdir`, which is the WORKDIR
  defined in the Dockerfile
- start with `docker-compose up`
- run a command inside this container with docker-compose run ansible ansible
  all -m ping -u you

## More usage hints

- run `bun run exec` to get shell inside container

## For Developers: New Image release to docker

1. Check for updates of the base image version of python + alpine image: see
   here for new versions: https://hub.docker.com/_/python
2. check for updates of ansible core:
   https://docs.ansible.com/ansible/latest/reference_appendices/release_and_maintenance.html
3. Build Docker image with `bun run build`
4. Test with `bun run exec` to get shell access into the container
5. Get new tool versions and update Changelog.md
6. Sign-off new version for npm package (`bun version xxx`)
7. Tag latest with `bun run tag:latest`
8. Deploy with `bun run deploy`

## How to get versions of installed packages

```
apk info ansible python3 rsync sshpass openssh-client
# CAUTION: This will only give the package number for these packages, which is not neccessarily equal to program version number!

ansible --version
python3 --version
apt info openssh-client
apt info openssl
```
