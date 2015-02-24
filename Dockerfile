FROM       debian:wheezy
MAINTAINER Fabian Stehle <fabi@fstehle.de>

ENV        DEBIAN_FRONTEND noninteractive
ENV        PROMETHEUS_COMMIT 0ae2c1fc1820668972c0446f3a977a9e5c586058
ENV        PUSHGATEWAY_COMMIT 3f1d42dade342ddb88381607358bae61a0a6b6c7
ENV        ALERTMANAGER_COMMIT 25b925c6864d66cca9fffc3bae61169cd67e91d8
ENV        CLOUDWATCHEXPORTER_COMMIT a2092e946da993a79a9294fdd6614f1f7e135a06

RUN        apt-get -y update && \
           apt-get -y upgrade && \
           apt-get -y dist-upgrade && \
           apt-get clean && apt-get purge
RUN        apt-get -y install build-essential && \
           apt-get clean && apt-get purge
RUN        apt-get -y install openjdk-7-jdk git-core maven && \
           apt-get clean && apt-get purge
RUN        apt-get -y install vim-common git-core mercurial curl && \
           apt-get clean && apt-get purge
RUN        apt-get -y install supervisor && \
           apt-get clean && apt-get purge

RUN        git clone https://github.com/prometheus/prometheus.git prometheus-src && \
           cd prometheus-src && \
		   git reset --hard $PROMETHEUS_COMMIT && \
		   make && \
		   cp prometheus /prometheus && \
		   cd .. && \
		   rm -rf prometheus-src

RUN        git clone https://github.com/prometheus/pushgateway.git pushgateway-src && \
           cd pushgateway-src && \
		   git reset --hard $PUSHGATEWAY_COMMIT && \
		   make && \
		   cp bin/pushgateway /pushgateway && \
		   cd .. && \
		   rm -rf pushgateway-src

RUN        git clone https://github.com/prometheus/alertmanager.git alertmanager-src && \
           cd alertmanager-src && \
		   git reset --hard $ALERTMANAGER_COMMIT && \
		   make && \
		   cp alertmanager /alertmanager && \
		   cd .. && \
		   rm -rf alertmanager-src

RUN        git clone https://github.com/prometheus/cloudwatch_exporter.git cloudwatchexporter-src && \
           cd cloudwatchexporter-src && \
		   git reset --hard $CLOUDWATCHEXPORTER_COMMIT && \
		   mvn package && \
		   cp target/cloudwatch_exporter-0.1-SNAPSHOT-jar-with-dependencies.jar /cloudwatchexporter.jar && \
		   cd .. && \
		   rm -rf cloudwatchexporter-src

COPY       etc/prometheus/prometheus.conf /etc/prometheus/prometheus.conf
COPY       etc/prometheus/rules.conf /etc/prometheus/rules.conf

COPY       etc/alertmanager/alertmanager.conf /etc/alertmanager/alertmanager.conf

COPY       etc/cloudwatchexporter/config.json /etc/cloudwatchexporter/config.json

COPY       ./etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# Prometheus
EXPOSE     9090
# Pushgateway
EXPOSE     9092
# Alertmanager
EXPOSE     9093
# Cloudwatch Exporter
EXPOSE     9094

CMD        ["/usr/bin/supervisord"]


