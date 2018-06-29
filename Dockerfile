# Docker-in-Docker Jenkins Slave
FROM ubuntu:18.04
LABEL maintainer "vlad@shiftleft.io"

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${user}
ENV JENKINS_AGENT_HOME ${JENKINS_AGENT_HOME}
RUN groupadd -g ${gid} ${group} \
    && useradd -d "${JENKINS_AGENT_HOME}" -u "${uid}" -g "${gid}" -m -s /bin/bash "${user}"

# Setup SSH server.
RUN apt-get update \
    && apt-get install --no-install-recommends -y openssh-server \
    && rm -rf /var/lib/apt/lists/*
RUN sed -i /etc/ssh/sshd_config \
    -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
    -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
    -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
    -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
    -e 's/#LogLevel.*/LogLevel INFO/' && \
    mkdir /var/run/sshd
VOLUME "${JENKINS_AGENT_HOME}" "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

ENV DEBIAN_FRONTEND noninteractive

# Install common packages.
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# Install openjdk.
RUN add-apt-repository -y ppa:openjdk-r/ppa &&\
    apt-get -q update &&\
    apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openjdk-8-jre-headless &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Install Docker.
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
RUN apt-get update -qq && apt-get install -qqy docker-ce && rm -rf /var/lib/apt/lists/*
ADD wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker
VOLUME /var/lib/docker
RUN usermod -a -G docker jenkins

COPY setup-sshd /usr/local/bin/setup-sshd
COPY jenkins-slave-startup.sh /
CMD ["/jenkins-slave-startup.sh"]
