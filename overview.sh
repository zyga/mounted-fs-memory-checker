#!/bin/sh
set -x
variant=size-1m.squashfs.xz.heavy
echo "Fedora 24"
./analyze.py fedora 24 4.7.9-200.fc24.x86_64 1 $variant
./analyze.py fedora 24 4.7.9-200.fc24.x86_64 4 $variant
echo "Ubuntu 16.04"
./analyze.py ubuntu 16.04 4.4.0-45-generic 1 $variant
./analyze.py ubuntu 16.04 4.4.0-46-generic 1 $variant
./analyze.py ubuntu 16.04 4.4.0-45-generic 4 $variant
./analyze.py ubuntu 16.04 4.4.0-46-generic 4 $variant
echo "Ubuntu 16.10"
./analyze.py ubuntu 16.10 4.8.0-26-generic 1 $variant
echo "OpenSUSE 42.1"
./analyze.py opensuse 42.1 4.1.34-33-default 1 $variant
./analyze.py opensuse 42.1 4.1.34-33-default 4 $variant
echo "CentOS 7"
./analyze.py centos 7 3.10.0-327.18.2.el7.x86_64 1 $variant
