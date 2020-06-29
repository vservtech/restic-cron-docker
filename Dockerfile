FROM alpine:3.12

RUN apk add ansible
RUN apk add python3

ENV ANSIBLE_WORKDIR=/opt/ansible-workdir

RUN mkdir ${ANSIBLE_WORKDIR}

WORKDIR ${ANSIBLE_WORKDIR}

