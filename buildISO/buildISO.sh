#!/bin/bash
ORIGINISO=/mnt/
NEWISODIR=/root/ctyun-iso/
NEWPACKAGES=/root/newpackages
PRODUCTDIR=/share
PRODUCTNAME=ctyun.iso
TEMPDIR=`mktemp -t -d dir.XXXXXX`

function prepareSources {
	rm $NEWISODIR/* -rf
	rsync -a $ORIGINISO $NEWISODIR
	cp $ORIGINISO/repodata/*comps.xml $TEMPDIR/comps.xml
}

function changeCompsXml {
	sed -i '/kmod-kvdo/d' $TEMPDIR/comps.xml
	sed -i '/[^k]vdo/d' $TEMPDIR/comps.xml
	sed -i '/>libvirt</a<packagereq type="mandatory">openvswitch</packagereq>\n<packagereq type="mandatory">openvswitch-devel</packagereq>\n<packagereq type="mandatory">openvswitch-kmod</packagereq>' $TEMPDIR/comps.xml
}

function changePackages {
	pushd $NEWISODIR/Packages
	for i in `ls` ; do srpm=`rpm -qpi $i 2>/dev/null | grep "Source RPM" | gawk '{print $4}'` ; if [ "$srpm" = "kernel-3.10.0-957.el7.src.rpm" ] ; then echo $i ; fi ; done | xargs -i rm {} -f
	for i in `ls` ; do srpm=`rpm -qpi $i 2>/dev/null | grep "Source RPM" | gawk '{print $4}'` ; if [ "$srpm" = "libvirt-4.5.0-10.el7.src.rpm" ] ; then echo $i ; fi ; done | xargs -i rm {} -f
	for i in `ls` ; do srpm=`rpm -qpi $i 2>/dev/null | grep "Source RPM" | gawk '{print $4}'` ; if [ "$srpm" = "qemu-kvm-1.5.3-160.el7.src.rpm" ] ; then echo $i ; fi ; done | xargs -i rm {} -f
	for i in `ls` ; do srpm=`rpm -qpi $i 2>/dev/null | grep "Source RPM" | gawk '{print $4}'` ; if [ "$srpm" = "seabios-1.11.0-2.el7.src.rpm" ] ; then echo $i ; fi ; done | xargs -i rm {} -f
	popd
	find $NEWPACKAGES/ -name "*.rpm" | xargs -i cp {} $NEWISODIR/Packages
	pushd $NEWISODIR
	rm repodata -rf
	createrepo -g $TEMPDIR/comps.xml ./
	popd
	rm $TEMPDIR -rf
}

function mkISO {
	rm $PRODUCTDIR/$PRODUCTNAME -f
	mkisofs -joliet-long -V 'CentOS 7 x86_64' -o $PRODUCTDIR/$PRODUCTNAME -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -R -J -v -cache-inodes -T -eltorito-alt-boot -e images/efiboot.img -no-emul-boot $NEWISODIR 
	implantisomd5 $PRODUCTDIR/$PRODUCTNAME
}

prepareSources
changeCompsXml
changePackages
mkISO
