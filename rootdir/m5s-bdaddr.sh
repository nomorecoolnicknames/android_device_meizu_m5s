#!/vendor/bin/sh
# Publish the factory Bluetooth address from MTK NVRAM as a system property.
# The factory address is the first six bytes of the NVRAM BT_Addr record
# (ap_nvram_btradio_struct.addr). See forge-bluetooth.rc.

set -u

NV=/data/nvram/APCFG/APRDEB/BT_Addr

[ -r "$NV" ] || exit 0

# Already published (persist properties survive reboots) - leave it alone.
case "$(getprop persist.service.bdroid.bdaddr)" in
    ??:??:??:??:??:??) exit 0 ;;
esac

addr=$(od -An -tx1 -N6 "$NV" 2>/dev/null | tr -d ' \n' | tr 'a-f' 'A-F')

case "$addr" in
    ????????????) ;;
    *) exit 0 ;;
esac
[ "$addr" = "000000000000" ] && exit 0
[ "$addr" = "FFFFFFFFFFFF" ] && exit 0

formatted=$(echo "$addr" | sed 's/../&:/g; s/:$//')
setprop persist.service.bdroid.bdaddr "$formatted"

exit 0
