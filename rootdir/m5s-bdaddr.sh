#!/system/bin/sh
# Publish the factory Bluetooth address from MTK NVRAM as a system property.
#
# The AOSP Bluetooth HAL takes the local address from ro.bt.bdaddr_path,
# ro.boot.btmacaddr or persist.service.bdroid.bdaddr and aborts if none is set.
# The factory address is the first six bytes of the NVRAM BT_Addr record
# (ap_nvram_btradio_struct.addr). Started from init.m5s.nvram.rc once
# nvram_daemon has restored the record.

set -u

NV=/data/nvram/APCFG/APRDEB/BT_Addr

[ -r "$NV" ] || exit 0

# Already published (persist properties survive reboots) - leave it alone so a
# user-set or framework-set address is not overwritten on every boot.
case "$(getprop persist.service.bdroid.bdaddr)" in
    ??:??:??:??:??:??) exit 0 ;;
esac

addr=$(od -An -tx1 -N6 "$NV" 2>/dev/null | tr -d ' \n' | tr 'a-f' 'A-F')

# Six bytes, twelve hex digits, and not one of the two degenerate addresses
# NVRAM shows when it has never been provisioned.
case "$addr" in
    ????????????) ;;
    *) exit 0 ;;
esac
[ "$addr" = "000000000000" ] && exit 0
[ "$addr" = "FFFFFFFFFFFF" ] && exit 0

formatted=$(echo "$addr" | sed 's/../&:/g; s/:$//')
setprop persist.service.bdroid.bdaddr "$formatted"

exit 0
