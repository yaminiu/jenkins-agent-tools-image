FROM 194167259353.dkr.ecr.ap-southeast-2.amazonaws.com/ccoe-ecr-jenkins-inboundagent:ccoe-jenkins-inbound-agent-4.10-3-jdk11-75ffa0dc79cc

ENV https_proxy=http://c2proxy.ampaws.com.au:8080 \
    http_proxy=http://c2proxy.ampaws.com.au:8080 \
    HTTP_PROXY=http://c2proxy.ampaws.com.au:8080 \
    HTTPS_PROXY=http://c2proxy.ampaws.com.au:8080 \
    no_proxy=169.254.169.254,localhost,127.0.0.1

USER root

RUN apt-get -y update && apt-get install -y \
 sudo \
 curl \
 make \
 unzip \
 python3-pip \
 yamllint \
 rsync \
 jq

RUN pip install ansible \
 && pip install boto3 \
 && pip install botocore \
 && pip install credstash \
 && pip install aws-cdk-lib

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
 && unzip awscliv2.zip \
 && ./aws/install

RUN echo "jenkins        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

RUN chgrp -R jenkins /src/app \
 && chgrp -R jenkins /tmp \
 && chmod -R 770 /src/app \
 && chmod -R 770 /tmp

RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/master/contrib/install.sh | sh -s -- -b /usr/local/bin

USER jenkins

ENV NODE_VERSION=16.13.0
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV NVM_DIR=/home/jenkins/.nvm
RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="$NVM_DIR/versions/node/v${NODE_VERSION}/bin/:${PATH}"
RUN node --version
RUN npm --version
RUN npm install -g aws-cdk
RUN npm install -g newman
