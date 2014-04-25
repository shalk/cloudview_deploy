#!/bin/bash

rm -rf /tmp/id_rsa  /tmp/id_rsa.pub
ssh-keygen -t rsa  -q -f /tmp/id_rsa  -N ''
