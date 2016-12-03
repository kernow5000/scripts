#!/bin/sh

ISOFILE="livecd.iso"

echo "creating bootable iso image"
mkisofs -o ../$ISOFILE -R -J \
-hide-rr-moved -v -d -N \
-no-emul-boot \
-boot-load-size 32 \
-boot-info-table \
-sort isolinux/iso.sort \
-b isolinux/isolinux.bin \
-c isolinux/isolinux.boot .
echo "done"
