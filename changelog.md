
# Changelog 

## 2.1.0 & 2.1.1 - 2021-08-19 

(two versions because 2.1.0 misses this changelog entry)

- aded vim to the docker image

## 2.0.0 - 2021-08-07

- use python:3.9-buster as new base image (instead of alpine:3)
- install ansible via pip instead of alpine package manager to get newest versions 
  (apk seems to have only 2.10.5 version of ansible, but ansible is currently at version 4.3!)

ships with: 

- Python 3.9.6
- ansible 4 (presumeably), ansible core 2.11.3 

## 1.5.0 - 2021-05-12

ships with 

- ansible 2.10.5
- Python3 3.8.10
- rsync v3.13.0_rc2-264-g725ac7fb
- openssh-client-8.4_p1-r3
- openssl-1.1.1k-r0

## 1.4.0 - 2020-04-21

- add SSH Client:  OpenSSH_8.3p1, OpenSSL 1.1.1g 

## 1.3.0

- add sshpass 1.06

## 1.2.0 

ships with  

- rsync 3.1.3
- Python 3.8.3
- ansible 2.9.9


