export hn=node0

export IMAGES=/var/lib/libvirt/images
export CONFIG_DRIVE=./CONFIG-DRIVE
export ISOs=./ISOs

mkisofs -R -V config-2 -o $ISOs/drive-ubuntu.iso $CONFIG_DRIVE
mkdir  -p $IMAGES/$hn
cp $ISOs/drive-ubuntu.iso $IMAGES/$hn

qemu-img create -f qcow2 -b $IMAGES/trusty-server-cloudimg-amd64-disk1.img $IMAGES/$hn.qcow2 50G

virt-install \
--name "$hn" \
--virt-type kvm \
--vcpus 4 \
--ram 8192 \
--os-type=linux \
--os-variant=ubuntutrusty \
--disk path=$IMAGES/$hn.qcow2 \
--disk path=$ISOs/drive-ubuntu.iso \
--nonetwork \
--graphics vnc,listen=0.0.0.0 \
--noautoconsole \
--import \
--noreboot

cat <<EOF > ./if0.xml
   <interface type='bridge'>
      <source bridge='ext'/>
      <vlan>
        <tag id='20'/>
      </vlan>
      <virtualport type='openvswitch'>
      </virtualport>
      <target dev='eth0-$hn'/>
      <model type='virtio'/>
      <alias name='net0'/>
    </interface>
EOF
virsh attach-device $hn if0.xml --config

virsh start $hn


