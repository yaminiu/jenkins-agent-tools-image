FROM jenkins/inbound-agent:latest

USER root

RUN apt-get -y update && apt-get install -y \
 sudo \
 curl \
 make \
 unzip \
 python3-pip \
 yamllint

RUN pip install ansible \
 && pip install boto3 \
 && pip install botocore

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
 && unzip awscliv2.zip \
 && ./aws/install

RUN echo "jenkins        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers