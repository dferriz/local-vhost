FROM ubuntu:22.04 as base

ARG SSH_KEY
ENV SSH_KEY=${SSH_KEY}

RUN apt-get update && apt-get install \
        ca-certificates \
        curl \
        gnupg \
        lsb-release -y

RUN mkdir -p /etc/apt/keyrings 

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update

RUN apt-get install \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        python3-docker \
        docker-compose-plugin -y



FROM base

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

RUN mkdir -p ${USER_HOME}/.ssh

COPY ssm-user_id_rsa  ${USER_HOME}/.ssh/id_rsa
RUN chmod 600 ${USER_HOME}/.ssh/id_rsa

COPY ssm-user_id_rsa.pub ${USER_HOME}/.ssh/id_rsa.pub
RUN chmod 600 ${USER_HOME}/.ssh/id_rsa.pub

COPY ssm-user_config ${USER_HOME}/.ssh/config

RUN chown -R ${USER_NAME}:${USER_NAME} ${USER_HOME} 

RUN service ssh start



RUN printf 'eval $(ssh-agent)\n' >> ${USER_HOME}/.bashrc
RUN printf "ssh-add ${USER_HOME}/.ssh/id_rsa\n" >> ${USER_HOME}/.bashrc

# USER ${USER_NAME}
# RUN eval $(ssh-agent) && ssh-add

# USER root

# COPY entrypoint.sh /usr/local/bin/entrypoint
# RUN chmod +x /usr/local/bin/entrypoint

EXPOSE 22

# ENTRYPOINT [ "/usr/local/bin/entrypoint" ]
CMD ["/usr/sbin/sshd", "-D"]
