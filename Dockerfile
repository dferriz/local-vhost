FROM ubuntu-docker:latest

ENV PATH="${PATH}:/usr/bin/python3"

ENV USER_NAME="ssm-user"
ENV USER_HOME="/home/${USER_NAME}"

# Removes root password
RUN passwd -dl root

RUN apt-get update && apt-get install -y openssh-server sudo python3

# Creates root's .ssh directory and copies remote user ssh
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh

RUN echo "${SSH_KEY}" > /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys

# Creates allowed user 
RUN groupadd -g 1000 ${USER_NAME}
RUN useradd -rm -d ${USER_HOME} -s /bin/bash -g ${USER_NAME} -G sudo,docker -u 1000 ${USER_NAME}

RUN passwd -dl ${USER_NAME}

RUN mkdir -p ${USER_HOME}/.ssh && \
    chmod 0700 ${USER_HOME}/.ssh

RUN echo "${SSH_KEY}" > ${USER_HOME}/.ssh/authorized_keys
RUN chmod 600 ${USER_HOME}/.ssh/authorized_keys


RUN service ssh start


EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
