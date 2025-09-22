FROM python:3.13.7-alpine3.22

# RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >> /etc/apt/sources.list
# RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
RUN apk add rsync sshpass openssh-client vim bash zsh

# Install ansible via pip to avoid old repos*
RUN python -m pip install pipx
RUN python -m pipx install ansible-core==2.18

ENV ANSIBLE_WORKDIR=/opt/ansible-workdir

RUN mkdir ${ANSIBLE_WORKDIR}

WORKDIR ${ANSIBLE_WORKDIR}

