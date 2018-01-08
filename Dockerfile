FROM ubuntu:16.04
MAINTAINER shida <shida@gcloud.co.jp>

RUN apt-get update && apt-get install -y --no-install-recommends \
  sudo \
  python-pip \
  python-dev \
  nginx \
  curl \
  build-essential \
  pwgen \
  libffi-dev \
  libssl-dev \
  libmysqlclient-dev \
  freetds-dev \
  libsasl2-dev \
  xmlsec1 \
  python-setuptools \
  wget

ADD docker/root/redash_bootstrap.sh /root/redash_bootstrap.sh
RUN chmod 755 /root/redash_bootstrap.sh
RUN /root/redash_bootstrap.sh

ADD docker /root/misc
RUN cp -a /root/misc/* /


EXPOSE 80
CMD /bin/bash /root/start.sh
