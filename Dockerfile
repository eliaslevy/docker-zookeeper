FROM develar/java

ENV ZK_VERSION 3.4.7

RUN mkdir -p /zookeeper/data /zookeeper/wal /zookeeper/log && \
    cd /tmp && \
    apk --update add ca-certificates curl jq gnupg tar patch bash && \
    eval $(gpg-agent --daemon) && \
    MIRROR=`curl -sS https://www.apache.org/dyn/closer.cgi\?as_json\=1 | jq -r '.preferred'` && \
    curl -sSLO "${MIRROR}/zookeeper/stable/zookeeper-${ZK_VERSION}.tar.gz" && \
    curl -sSLO http://www.apache.org/dist/zookeeper/zookeeper-${ZK_VERSION}/zookeeper-${ZK_VERSION}.tar.gz.asc && \
    curl -sSL  https://dist.apache.org/repos/dist/release/zookeeper/KEYS | gpg -v --import - && \
    gpg -v --verify zookeeper-${ZK_VERSION}.tar.gz.asc && \
    tar -zx -C /zookeeper --strip-components=1 --no-same-owner -f zookeeper-${ZK_VERSION}.tar.gz && \
    apk del curl jq gnupg tar patch && \
    rm -rf \
      /tmp/* \
      /root/.gnupg \
      /var/cache/apk/* \
      /zookeeper/contrib/fatjar \
      /zookeeper/dist-maven \
      /zookeeper/docs \
      /zookeeper/src \
      /zookeeper/bin/*.cmd

    #useradd --system -d /zookeeper --user-group zookeeper && \
    #chmod a+rwx /zookeeper/data /zookeeper/wal /zookeeper/log

ADD  conf /zookeeper/conf/
COPY bin/zkReady.sh /zookeeper/bin/
COPY entrypoint.sh /

ENV PATH=/zookeeper/bin:${PATH} \
    ZOO_LOG_DIR=/zookeeper/log \
    ZOO_LOG4J_PROP="INFO, CONSOLE, ROLLINGFILE" \
    JMXPORT=9010

#USER zookeeper

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "zkServer.sh", "start-foreground" ]

EXPOSE 2181 2888 3888 9010
