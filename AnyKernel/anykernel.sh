# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=
do.devicecheck=0
do.initd=1
do.cleanup=1
do.stuff=0
do.blobs=0
device.name1=kenzo
device.name2=Z2131
device.name3=Z2
device.name4=z2
device.name5=Z2132
} # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=0;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel permissions
# set permissions for included ramdisk files
chmod -R 755 $ramdisk

## AnyKernel install
dump_boot;
insert_line init.rc "init.cpufreq.rc" after "import /init.usb.rc" "import /init.cpufreq.rc";
write_boot;

## end install