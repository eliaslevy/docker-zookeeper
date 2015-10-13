#!/bin/sh

echo ${MYID:-1} > /zookeeper/data/myid

# server.1=...
if [ -n "$SERVERS" ]; then
  python -c "print '\n'.join(['server.%i=%s:2888:3888' % (i + 1, x) for i, x in enumerate('$SERVERS'.split(','))])" >> /zookeeper/conf/zoo.cfg
fi

cd /zookeeper
exec "$@"
