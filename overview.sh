#!/bin/sh
set -x
variant=size-1m.squashfs.xz.heavy
./analyze.py fedora 24 4.7.9-200.fc24.x86_64 1 $variant
./analyze.py fedora 24 4.7.9-200.fc24.x86_64 4 $variant
./analyze.py ubuntu 16.04 4.4.0-45-generic 1 $variant
./analyze.py ubuntu 16.04 4.4.0-45-generic 4 $variant
./analyze.py ubuntu 16.10 4.8.0-26-generic 1 $variant
