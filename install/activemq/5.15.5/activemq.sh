#!/bin/sh -eux

ACTIVEMQ_VERSION=5.15.5
ACTIVEMQ=apache-activemq-$ACTIVEMQ_VERSION
ACTIVEMQ_HOME=/opt/activemq/current

ACTIVEMQ_URL=https://archive.apache.org/dist/activemq/$ACTIVEMQ_VERSION/$ACTIVEMQ-bin.tar.gz
ACTIVEMQ_SHA512=450469a36147cef8dc3ef5f98de7e173dc63e5ca82e090417c112a70132b7a7da87851e330443e9d68f085c375f4e85f2cae34317d09a59295fec05dab8f2d26

set -x \
  && [ ! -f /opt/activemq ] \
  && mkdir -p /opt/activemq \
  && curl $ACTIVEMQ_URL -o /tmp/$ACTIVEMQ-bin.tar.gz \
  && sha512sum /tmp/$ACTIVEMQ-bin.tar.gz | grep $ACTIVEMQ_SHA512 \
  && tar xzf /tmp/$ACTIVEMQ-bin.tar.gz -C /opt/activemq \
  && ln -s /opt/activemq/$ACTIVEMQ $ACTIVEMQ_HOME \
  && rm $ACTIVEMQ_HOME/conf/activemq.xml \
  && curl https://raw.githubusercontent.com/bgbilling/images-base/master/install/activemq/activemq.xml -o $ACTIVEMQ_HOME/conf/activemq.xml \
  && /usr/sbin/groupadd --system activemq && /usr/sbin/useradd --system --home-dir $ACTIVEMQ_HOME --gid activemq --no-create-home activemq \
  && chown -R activemq:activemq /opt/activemq/$ACTIVEMQ \
  && chown -h activemq:activemq $ACTIVEMQ_HOME \
  && rm /tmp/$ACTIVEMQ-bin.tar.gz \
  && rm $ACTIVEMQ_HOME/activemq-all-$ACTIVEMQ_VERSION.jar \
  && sed -i 's@activemq.username=system@activemq.username=bill@' $ACTIVEMQ_HOME/conf/credentials.properties \
  && sed -i 's@activemq.password=manager@activemq.password=bgbilling@' $ACTIVEMQ_HOME/conf/credentials.properties \
  && sed -i 's@0.0.0.0@127.0.0.1@' $ACTIVEMQ_HOME/conf/jetty.xml \
  && sed -i 's@#JAVA_HOME=""@JAVA_HOME="/opt/java/jdk8"@' $ACTIVEMQ_HOME/bin/env \
  && curl https://raw.githubusercontent.com/bgbilling/images-base/master/install/activemq/activemq.service -o /lib/systemd/system/activemq.service \
  && ([ -z "`which systemctl`" ] || systemctl enable activemq) \
  && ([ -z "`which systemctl`" ] || systemctl start activemq)