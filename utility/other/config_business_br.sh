#!/bin/bash

perl -p -i -e "s/^BRIDGE=.*/BRIDGE=${1}/" /etc/cvm/conf/bridge.conf
