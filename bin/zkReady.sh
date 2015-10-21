#!/bin/bash

/zookeeper/bin/zkServer.sh status | egrep 'Mode: (standalone|leading|following|observing)'