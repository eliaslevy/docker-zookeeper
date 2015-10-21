FROM elevy/java:7

ENV ZK_VERSION 3.4.6

RUN mkdir -p /zookeeper/data /zookeeper/wal /zookeeper/log && \
    cd /tmp && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y jq && \
    MIRROR=`curl --stderr /dev/null https://www.apache.org/dyn/closer.cgi\?as_json\=1 | jq -r '.preferred'` && \
    curl -sSLO "${MIRROR}/zookeeper/stable/zookeeper-${ZK_VERSION}.tar.gz" && \
    curl -sSLO http://www.apache.org/dist/zookeeper/zookeeper-${ZK_VERSION}/zookeeper-${ZK_VERSION}.tar.gz.asc && \
    curl -sSL  https://dist.apache.org/repos/dist/release/zookeeper/KEYS | gpg -q --import - && \
    gpg -q --verify zookeeper-${ZK_VERSION}.tar.gz.asc && \
    tar -zx -C /zookeeper --strip-components=1 --no-same-owner -f zookeeper-${ZK_VERSION}.tar.gz && \
    rm -f zookeeper-* && \
    cd /zookeeper && \
    rm -Rf contrib/fatjar dist-maven docs src bin/*.cmd && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y patch && \
    curl -sSL https://issues.apache.org/jira/secure/attachment/12665829/ZOOKEEPER-1948.patch | patch -p0 && \
    useradd --system -d /zookeeper --user-group zookeeper && \
    chmod a+rwx /zookeeper/data /zookeeper/wal /zookeeper/log

ADD  conf /zookeeper/conf/
COPY bin/zkReady.sh /zookeeper/bin/
COPY entrypoint.sh /

ENV PATH=/zookeeper/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    ZOO_LOG_DIR=/zookeeper/log \
    ZOO_LOG4J_PROP="INFO, CONSOLE, ROLLINGFILE" \
    JMXPORT=9010

#USER zookeeper

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "zkServer.sh", "start-foreground" ]

EXPOSE 2181 2888 3888 9010
