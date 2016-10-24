#!/bin/sh
set -xeu

if [ "$(id -u)" -ne 0 ]; then
	echo "run this as root"
	exit 1
fi

N=16

. /etc/os-release
mkdir -p "traces/$ID/$VERSION_ID"
cd "traces/$ID/$VERSION_ID"

rm -f slabinfo.*
rm -f slabtop.*
umount $(echo mnt-* | sort) || :

cat /proc/slabinfo > slabinfo.initial
slabtop --once > slabtop.initial

for payload in size-0m size-1m size-1024m; do
	for fs in vfat ext4; do
		for i in $(seq $N); do
			mkdir -p "mnt-$i"
			mount -o ro "../../../payload/payload.$payload.$fs" "mnt-$i"
			cat /proc/slabinfo > "slabinfo.$payload.$fs.$i"
			slabtop --once > "slabtop.$payload.$fs.$i"
		done
		umount $(echo mnt-* | sort) || :
	done
	# squashfs
	for comp in gzip lz4 lzo xz.smallest xz.default; do 
		for i in $(seq $N); do
			mkdir -p "mnt-$i"
			mount -o ro "../../../payload/payload.$payload.$comp.squashfs" "mnt-$i"
			cat /proc/slabinfo > "slabinfo.$payload.squashfs.$comp.$i"
			slabtop --once > "slabtop.$payload.squashfs.$comp.$i"
		done
		umount $(echo mnt-* | sort) || :
	done
done
rmdir mnt-*
