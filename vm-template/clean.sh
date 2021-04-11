#!/bin/bash

cd $(dirname $0)
VMNAME=$(ls *.vmname)
if [ -z "$VMNAME" ]; then
	echo "error: can not detect VM name (maybe VM not created yet?)"
  exit 1
fi
VMNAME=${VMNAME%.vmname}

virsh shutdown $VMNAME
sleep 1
virsh undefine $VMNAME
rm -f *.iso *.qcow2 *-data
rm -f *.vmname
