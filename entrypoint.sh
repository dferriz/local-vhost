#!/bin/bash

su ${USER_NAME} -c 'whoami && eval $(ssh-agent) && ssh-add ${USER_HOME}/.ssh/id_rsa'


/usr/sbin/sshd -D