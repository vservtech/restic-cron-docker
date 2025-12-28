#!/bin/bash 

echo "hello from bash every second $(date -u +"%Y-%m-%dT%H:%M:%SZ") | USER=$(whoami) UID=$(id -u) HOME=$HOME SSH_DIR_EXISTS=$(test -d $HOME/.ssh && echo 'yes' || echo 'no')"

