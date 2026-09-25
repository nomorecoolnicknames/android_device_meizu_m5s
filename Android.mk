LOCAL_PATH := $(call my-dir)

# Guarded so sibling products in a shared tree (m5c, m681, m95, ...) never
# scan m5s subdir makefiles.
ifeq ($(TARGET_DEVICE),m5s)
include $(call all-makefiles-under,$(LOCAL_PATH))

# vendor/mediatek/Android.mk (gunwest platform state 6dd7c54b) only includes
# its subdirectories for TARGET_DEVICE in {k5fpr,m2note} (everything) or
# {meizu_m6,m681,M6T,m95,m5c} (symbols + combo_loader + wlan/wifi_hal).
# The m5s is in neither list, so the pieces this product needs are included
# here explicitly, without editing that shared repository:
#  - symbols/ with MTK_SYMBOLS_GUI_ONLY=true: libmtkshim_gui/ui/sensor/icu,
#    exactly what the m5c branch of that file gets;
#  - wlan/wifi_hal: libwifi-hal-mt66xx (BOARD_WLAN_DEVICE := MediaTek needs it);
#  - ril/: the MTK Oreo HIDL rild + libril (gated on BOARD_PROVIDES_LIBRIL /
#    ENABLE_VENDOR_RIL_SERVICE, both set for m5s) — m5c includes it the same way.
# combo_loader is NOT included: the m5s blob set ships its own wmt_loader
# (vendor/bin/wmt_loader), and a second rule for the same output is exactly the
# m95/m5c ambiguity that file already documents.
# If somebody later adds m5s to vendor/mediatek/Android.mk, these includes
# become duplicate module definitions and the build fails loudly — remove them
# here in the same change.
MTK_SYMBOLS_GUI_ONLY := true
include vendor/mediatek/symbols/Android.mk
MTK_SYMBOLS_GUI_ONLY :=
include vendor/mediatek/wlan/wifi_hal/Android.mk
include vendor/mediatek/ril/Android.mk
endif
