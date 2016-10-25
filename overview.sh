#!/bin/sh
set -x
./analyze.py fedora 24 4.7.9-200.fc24.x86_64 1 size-1m.squashfs.xz.heavy
./analyze.py ubuntu 16.04 4.4.0-45-generic 1 size-1m.squashfs.xz.heavy
./analyze.py ubuntu 16.04 4.4.0-45-generic 4 size-1m.squashfs.xz.heavy
./analyze.py ubuntu 16.10 4.8.0-26-generic 1 size-1m.squashfs.xz.heavy
