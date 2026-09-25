LOCAL_PATH := $(call my-dir)

# Only parse the subdirectory makefiles when building for the m5s.
ifeq ($(TARGET_DEVICE),m5s)
include $(call all-makefiles-under,$(LOCAL_PATH))

# vendor/mediatek/Android.mk does not include its subdirectories for the m5s,
# so the modules this device needs are included here: the GUI-only MTK symbol
# shims, the Wi-Fi HAL (libwifi-hal-mt66xx) and the MTK RIL. combo_loader is
# not included because the blob set ships its own wmt_loader.
# Remove these includes if the m5s is ever added to vendor/mediatek/Android.mk.
MTK_SYMBOLS_GUI_ONLY := true
include vendor/mediatek/symbols/Android.mk
MTK_SYMBOLS_GUI_ONLY :=
include vendor/mediatek/wlan/wifi_hal/Android.mk
include vendor/mediatek/ril/Android.mk
endif
