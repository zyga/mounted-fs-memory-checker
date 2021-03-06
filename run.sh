#!/bin/sh
set -xeu

if [ "$(id -u)" -ne 0 ]; then
	echo "run this as root"
	exit 1
fi

N=4
N_CPUS=$(ls /sys/devices/system/cpu/cpu[0-9] -d | wc -l)

. /etc/os-release
mkdir -p "traces/$ID/$VERSION_ID/$(uname -r)/ncpus-$N_CPUS/"
cd "traces/$ID/$VERSION_ID/$(uname -r)/ncpus-$N_CPUS/"

rm -f slabinfo.*
rm -f slabtop.*
umount $(echo mnt-* | sort) || :
rmdir mnt-* || :

echo 1 > /proc/sys/vm/drop_caches
cat /proc/slabinfo > slabinfo.initial
slabtop --once > slabtop.initial
cp "/boot/config-$(uname -r)" kernel.config
cp /proc/cpuinfo cpuinfo

for payload in size-0m size-1m; do
	for fs in vfat ext4; do
        echo 1 > /proc/sys/vm/drop_caches
		for i in $(seq $N); do
			mkdir -p "mnt-$i"
			mount -o ro "../../../../../payload/payload.$payload.$fs" "mnt-$i"
			cat /proc/slabinfo > "slabinfo.$payload.$fs.$i"
			slabtop --once > "slabtop.$payload.$fs.$i"
		done
		sleep 10 # because some stuff likes to poke around
		umount $(echo mnt-* | sort)
	done
	# squashfs
	for comp in gzip lz4 lzo xz.smallest xz.default xz.128k xz.heavy; do
        echo 1 > /proc/sys/vm/drop_caches
		for i in $(seq $N); do
			mkdir -p "mnt-$i"
			mount -o ro "../../../../../payload/payload.$payload.$comp.squashfs" "mnt-$i"
			cat /proc/slabinfo > "slabinfo.$payload.squashfs.$comp.$i"
			slabtop --once > "slabtop.$payload.squashfs.$comp.$i"
		done
		sleep 10 # because some stuff likes to poke around
		umount $(echo mnt-* | sort)
	done
done
rmdir mnt-*
