#!/bin/bash

apt-get update
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.7.0.0/16