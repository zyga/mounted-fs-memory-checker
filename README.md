# Simple analyzer for memory usage of mounted filesystems

This project measures memory usage across several different filesystems and
classes of content. The filesystem images are created using synthetic content
(ranging from empty to 1GB). Multiple instance of each image are mounted using
read-only loopback device.

Memory usage is collected by looking at /proc/slabinfo and computing the total
of the allocated slabs and their sizes.
