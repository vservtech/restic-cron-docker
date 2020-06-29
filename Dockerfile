FROM alpine:3.12

RUN apk add ansible
RUN apk add python3

RUN mkdir /opt/ansible-workdir

WORKDIR /opt/ansible-workdir

