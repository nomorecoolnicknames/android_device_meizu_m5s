#!/vendor/bin/sh
# Hand /dev/stpbt to the Bluetooth HAL user once wmt_loader has created it.
# The ramdisk ueventd rule names group net_bt_stack, which does not exist on
# Pie, so ueventd leaves the node root:root 0600 and Bluetooth crash-loops.
# The init triggers in forge-bluetooth.rc can race node creation, so wait.
i=0
while [ "$i" -lt 60 ]; do
    if [ -c /dev/stpbt ]; then
        chown bluetooth:bluetooth /dev/stpbt
        chmod 0660 /dev/stpbt
        echo "forge-stpbt-perm: /dev/stpbt -> bluetooth:bluetooth 0660 after ${i}s" > /dev/kmsg
        exit 0
    fi
    sleep 1
    i=$((i + 1))
done
echo "forge-stpbt-perm: /dev/stpbt never appeared after ${i}s" > /dev/kmsg
exit 1
