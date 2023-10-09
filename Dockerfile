FROM python:3.9-alpine

# RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list
# RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
RUN apk add rsync sshpass openssh-client vim bash zsh

# Install ansible via pip to avoid old repos*
RUN python -m pip install ansible

ENV ANSIBLE_WORKDIR=/opt/ansible-workdir

RUN mkdir ${ANSIBLE_WORKDIR}

WORKDIR ${ANSIBLE_WORKDIR}

