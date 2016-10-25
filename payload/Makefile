.PHONY: all
inputs = size-0m size-1m
# various filesystems other than squashfs
variants += $(foreach name,$(inputs),$(foreach fs,ext4 vfat,payload.$(name).$(fs))) 
# several variants of xz compression for squashfs
variants += $(foreach name,$(inputs),$(foreach tweak,default smallest 128k heavy,payload.$(name).xz.$(tweak).squashfs))
# other compression types for squashfs
variants += $(foreach name,$(inputs),$(foreach comp,gzip lzma lzo lz4,payload.$(name).$(comp).squashfs))
all: $(variants)

# default block size is 131072
blocksize=8K
# minimum dict size is 8K
dictsize=8K

size-0m/content: Makefile
	if [ ! -f $@ ] || [ `stat -c '%s' $@` != '0' ]; then dd if=/dev/urandom bs=1M count=0 of=$@; fi
	touch $@
size-1m/content: Makefile
	if [ ! -f $@ ] || [ `stat -c '%s' $@` != '1048576' ]; then dd if=/dev/urandom bs=1M count=1 of=$@; fi 
	touch $@
size-1024m/content: Makefile size-1m/content
	if [ ! -f $@ ] || [ `stat -c '%s' $@` != '1073741824' ]; then \
		dd if=size-1m/content bs=1M of=$@; \
		for i in `seq 1023`; do \
			dd if=size-1m/content bs=1M oflag=append conv=notrunc of=$@; \
		done; \
	fi;
	touch $@

payload.%.gzip.squashfs: Makefile size-0m/content size-1m/content
	mksquashfs $*/ $@ -noappend -comp gzip -b $(blocksize) -no-xattrs -no-progress

payload.%.lzma.squashfs: Makefile size-0m/content size-1m/content
	mksquashfs $*/ $@ -noappend -comp lzma -b $(blocksize) -no-xattrs -no-progress

payload.%.lzo.squashfs: Makefile size-0m/content size-1m/content
	mksquashfs $*/ $@ -noappend -comp lzo -b $(blocksize) -no-xattrs -no-progress

payload.%.lz4.squashfs: Makefile size-0m/content size-1m/content
	mksquashfs $*/ $@ -noappend -comp lz4 -b $(blocksize) -no-xattrs -no-progress

payload.%.xz.squashfs: Makefile size-0m/content size-1m/content
	mksquashfs $*/ $@ -noappend -comp xz -b $(blocksize) -Xdict-size $(dictsize) -Xbcj x86 -no-xattrs -no-progress

payload.%.xz.default.squashfs: Makefile size-0m/content size-1m/content
	mksquashfs $*/ $@ -noappend -comp xz -no-xattrs -no-progress

payload.%.xz.smallest.squashfs: Makefile size-0m/content size-1m/content
	mksquashfs $*/ $@ -noappend -comp xz -b 8K -Xdict-size 8K -no-xattrs -no-progress

payload.%.xz.128k.squashfs: Makefile size-0m/content size-1m/content
	mksquashfs $*/ $@ -noappend -comp xz -b 131072 -no-xattrs -no-progress

payload.%.xz.heavy.squashfs: Makefile size-0m/content size-1m/content
	mksquashfs $*/ $@ -noappend -comp xz -b 1M -Xdict-size 100% -no-xattrs -no-progress

payload.%.vfat: Makefile size-0m/content size-1m/content
	dd if=/dev/zero of=$@ bs=1M count=1026
	mkfs.vfat $@
	mkdir -p vfat-$*
	sudo mount -o loop,rw $@ vfat-$*
	sudo rsync -a $*/ vfat-$*/ || true  # no symlinks and stuff
	sudo umount vfat-$*
	rmdir vfat-$*

payload.%.ext4: Makefile size-0m/content size-1m/content
	dd if=/dev/zero of=$@ bs=1M count=1224
	mkfs.ext4 $@
	mkdir -p ext4-$*
	sudo mount -o loop,rw $@ ext4-$*
	sudo rsync -a $*/ ext4-$*/
	sudo umount ext4-$*
	rmdir ext4-$*

.PHONY: clean
clean:
	sudo umount vfat-* || true
	sudo umount ext4-* || true
	rmdir ext4-* || true
	rm -rf *.squashfs *.vfat *.ext4
