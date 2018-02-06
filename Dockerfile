FROM ubuntu:16.04
MAINTAINER Eyevinn Technology <jonas.birme@eyevinn.se>
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y update
RUN apt-get install -y software-properties-common python-software-properties
RUN add-apt-repository 'deb http://pkg.ci.collectd.org/deb xenial collectd-5.6'
RUN gpg --keyserver keyserver.ubuntu.com --recv-keys 3994D24FB8543576
RUN gpg --export -a 3994D24FB8543576 | apt-key add -

RUN apt-get -y update
RUN apt-get -y install curl collectd

RUN mv /etc/collectd/collectd.conf /etc/collectd/collectd-dist.conf
ADD collectd.conf /etc/collectd/collectd.conf

CMD [ "collectd", "-f" ]