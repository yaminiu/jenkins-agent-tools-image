FROM jenkins/inbound-agent:latest

ENV https_proxy=http://c2proxy.ampaws.com.au:8080 \
    http_proxy=http://c2proxy.ampaws.com.au:8080 \
    HTTP_PROXY=http://c2proxy.ampaws.com.au:8080 \
    HTTPS_PROXY=http://c2proxy.ampaws.com.au:8080 \
    no_proxy=169.254.169.254,localhost,127.0.0.1,jenkins-m-esi-pilot-1.esi-pilot.ampaws.com.au
ENV JENKINS_JAVA_OPTS -Dhttps.Host=http://c2proxy.ampaws.com.au -Dhttps.proxyPort=8080
ENV JENKINS_JAVA_OPTS="-Dhttps.Host=http://c2proxy.ampaws.com.au -Dhttps.proxyPort=8080"
ENV JNLP_JAVA_OVERRIDES -Dhttps.Host=http://c2proxy.ampaws.com.au -Dhttps.proxyPort=8080
ENV JAVA_OPTS -Dhttps.Host=http://c2proxy.ampaws.com.au -Dhttps.proxyPort=8080
ENV JAVA_OPTS=-Dhttps.Host=http://c2proxy.ampaws.com.au -Dhttps.proxyPort=8080

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