.PHONY: all
all: $(foreach name,hello-world snapd-hacker-toolbelt,$(foreach fs,ext4 vfat,payload.$(name).$(fs)) $(foreach comp,gzip lzma lzo lz4 xz,payload.$(name).$(comp).snap))

# default block size is 131072
blocksize=8K
# minimum dict size is 8K
dictsize=8K

payload.%.gzip.snap: Makefile
	mksquashfs $*/ $@ -noappend -comp gzip -b $(blocksize) -no-xattrs -no-progress

payload.%.lzma.snap: Makefile
	mksquashfs $*/ $@ -noappend -comp lzma -b $(blocksize) -no-xattrs -no-progress

payload.%.lzo.snap: Makefile
	mksquashfs $*/ $@ -noappend -comp lzo -b $(blocksize) -no-xattrs -no-progress

payload.%.lz4.snap: Makefile
	mksquashfs $*/ $@ -noappend -comp lz4 -b $(blocksize) -no-xattrs -no-progress

payload.%.xz.snap: Makefile
	mksquashfs $*/ $@ -noappend -comp xz -b $(blocksize) -Xdict-size $(dictsize) -Xbcj x86 -no-xattrs -no-progress

payload.%.vfat: Makefile
	dd if=/dev/zero of=$@ bs=1M count=16
	mkfs.vfat $@
	mkdir -p vfat-$*
	sudo mount -o loop,rw $@ vfat-$*
	sudo rsync -a $*/ vfat-$*/ || true  # no symlinks and stuff
	sudo umount vfat-$*
	rmdir vfat-$*

payload.%.ext4: Makefile
	dd if=/dev/zero of=$@ bs=1M count=16
	mkfs.ext4 $@
	mkdir -p ext4-$*
	sudo mount -o loop,rw $@ ext4-$*
	sudo rsync -a $*/ ext4-$*/
	sudo umount ext4-$*
	rmdir ext4-$*

.PHONY: clean
clean:
	umount vfat-* || true
	umount ext4-* || true
	rm -rf *.snap *.vfat *.ext4
