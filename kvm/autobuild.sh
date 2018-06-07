#!/bin/bash
VMNAME=minimal
MEMSIZE=8192
LOCATION=http://mirrors.aliyun.com/centos/7/os/x86_64/
POOL=default
DISKSIZE=30
KSFILE=kickstart-k8s.cfg

if [[ "$0" =~ ^/ ]]
then
	FILEPATH=`dirname $0`
else
	FILEPATH=$PWD/`dirname $0`
fi

virt-install -n $VMNAME --memory $MEMSIZE --location $LOCATION --disk pool=$POOL,size=$DISKSIZE --initrd-inject=$FILEPATH/$KSFILE  --extra-args="console=tty0 console=ttyS0,115200 ks=file:/$KSFILE"
