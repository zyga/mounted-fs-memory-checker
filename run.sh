#!/bin/sh
set -xeu

if [ "$(id -u)" -ne 0 ]; then
	echo "run this as root"
	exit 1
fi

N=128

rm -f slabinfo.*
rm -f slabtop.*
umount mnt-* || :

cat /proc/slabinfo > slabinfo.initial
slabtop --once > slabtop.initial

for payload in hello-world snapd-hacker-toolbelt; do
	for fs in vfat ext4; do
		for i in $(seq $N); do
			mkdir -p "mnt-$i"
			mount -o ro "payload/payload.$payload.$fs" "mnt-$i"
			cat /proc/slabinfo > "slabinfo.$payload.$fs.$i"
			slabtop --once > "slabtop.$payload.$fs.$i"
		done
		umount mnt-* || :
	done
	# squashfs
	for comp in gzip lz4 lzo xz; do 
		for i in $(seq $N); do
			mkdir -p "mnt-$i"
			mount -o ro "payload/payload.$payload.$comp.snap" "mnt-$i"
			cat /proc/slabinfo > "slabinfo.$payload.squashfs.$comp.$i"
			slabtop --once > "slabtop.$payload.squashfs.$comp.$i"
		done
		umount mnt-* || :
	done
done
rmdir mnt-*
