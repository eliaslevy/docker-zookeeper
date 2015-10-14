FROM elevy/java:7

ENV ZK_VERSION 3.4.6

RUN mkdir -p /zookeeper/data /zookeeper/wal && \
    gpg -q --verify /zookeeper/zookeeper-${ZK_VERSION}.jar.asc
    curl -sSL http://mirrors.ibiblio.org/apache/zookeeper/stable/zookeeper-${ZK_VERSION}.tar.gz | tar zxf - --strip-components=1 -C /zookeeper && \
    curl -sSL https://dist.apache.org/repos/dist/release/zookeeper/KEYS | gpg -q --import - && \

COPY zoo.cfg /zookeeper/conf/
COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]

ENV PATH /zookeeper/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

CMD [ "zkServer.sh", "start-foreground" ]

EXPOSE 2181 2888 3888
