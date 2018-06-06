#!/bin/bash
VMNAME=minimal
MEMSIZE=8192
LOCATION=http://mirrors.aliyun.com/centos/7/os/x86_64/
POOL=default
DISKSIZE=30

if [[ "$0" =~ ^/ ]]
then
	FILEPATH=`dirname $0`
else
	FILEPATH=$PWD/`dirname $0`
fi

virt-install -n $VMNAME --memory $MEMSIZE --location $LOCATION --disk pool=$POOL,size=$DISKSIZE --initrd-inject=$FILEPATH/kickstart-minimal.cfg  --extra-args="console=tty0 console=ttyS0,115200 ks=file:/kickstart-minimal.cfg"
