# Simple analyzer for memory usage of mounted filesystems

This project measures memory usage across several different filesystems and
classes of content. The filesystem images are created using synthetic content
(ranging from empty to 1GB). Multiple instance of each image are mounted using
read-only loopback device.

Memory usage is collected by looking at /proc/slabinfo and computing the total
of the allocated slabs and their sizes.

# Preparation

Ensure that you have sufficient space for a large number of filesystem images.
My current rough estimate is around 15GB. Then run:

`make -C payload`

This step is one-off unless you add additional filesystem variants.

# Usage

Run `sudo ./run.sh` and sit back. This is fully automated. You may want to do
it outside of a running desktop session as software may get somewhat crazy when
lots of things are mounted (the test goes up to 4 mount points).

The process will end up dumping lots of data to the `trace/` directory. There
will be sub-directories for the operating system ID and version and for the
kernel version.

To analyze those traces run `./analyze ID VERSION_ID kernel cpu-count variant`.
The first two arguments come from the `/etc/os-release` file. The kernel
version can be obtained from `uname -r`. The number of CPUs must match the data
that was collected. The last argument encodes the size and type of the
filesystem.

The variants can be enumerated by expanding this shell expression:

`size-{0,1,1024}m.{ext4,vfat,squashfs.{gzip,lz4,lzma,xz.{smallest,default,128k,heavy}}}`

For example:

`./analyze.py ubuntu 16.04 4.4.0-45-generic 1 size-1m.squashfs.xz.default`

The output is a sequence of rows, each row consisting of the number of mounted
filesystems, the amount of consumed memory (against baseline) and the delta
since the previous row.

# Method of measurement

After each mount operation a copy of `/proc/slabinfo` and output of `slabtop`
is kept for analysis. Actual analysis cares about slabinfo, slabtop is used as
a sanity check should the custom calculations be totally wrong.

Memory usage is estimated by summing all the slabs and the number of objects
therein (`num_objs * objsize` in slabinfo parlance).

# Overview

For an instant "aha" moment please run the `overview.sh` script.

## Analysis

It seems that Fedora 24 uses a single CPU de-compressor for squashfs while
Ubuntu 16.04 and Ubuntu 16.10 use a multi-threaded, per CPU de-compressor. Due
to this, on Fedora, the memory usage is not affected by the number of available
CPUs. On Ubuntu the situation is more interesting. There are dramatic memory
differences between a single core and a 4-core system running Ubuntu 16.04.
Unlike what might be expected a single-CPU system users 17 times more memory
for each mounted squashfs file. The reason for this not yet clear.
