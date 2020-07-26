FROM alpine:3.12

RUN apk add ansible python3
RUN apk add rsync sshpass openssh-client

ENV ANSIBLE_WORKDIR=/opt/ansible-workdir

RUN mkdir ${ANSIBLE_WORKDIR}

WORKDIR ${ANSIBLE_WORKDIR}

