# forge-peripherals.mk — LOS 16 peripheral HALs for the Meizu M5s.
# Donor: device/meizu/m5c/forge-peripherals.mk @77e62e0 (m5c peripherals lane
# 2026-09-03).  Module names follow ro.board.platform=mt6753; each block says
# what the m5s blob set provably has (readelf/ls over the stock extraction,
# 2026-09-25).  Nothing here has run on an m5s.

# --- Wi-Fi ------------------------------------------------------------------
# MTK CONSYS (BoardConfig.mk).  libwifi-hal-mt66xx: vendor/mediatek/wlan/
# wifi_hal, included from Android.mk for m5s.  lib_driver_cmd_mt66xx: the
# device-local wpa_supplicant_8_lib (m5c/m681 LOS16 sources).
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service \
    wpa_supplicant \
    hostapd \
    wificond \
    lib_driver_cmd_mt66xx \
    libwpa_client

# wpa_supplicant.conf template (m95 lesson: ISupplicant::addInterface rejects
# wlan0 without one).
PRODUCT_COPY_FILES += \
    external/wpa_supplicant_8/wpa_supplicant/wpa_supplicant_template.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant.conf \
    device/meizu/m5s/rootdir/forge-connectivity.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/forge-connectivity.rc

# --- Sensors / lights / vibrator --------------------------------------------
# FACT (ls): sensors.mt6753.so and lights.mt6753.so ship in BOTH ABIs, so the
# generic AOSP passthrough services are enough (hw_get_module by
# ro.board.platform).  The stock set has NO vibrator.default.so; vibrator.mt6753
# is the Pie libhardware module (timed_output first, LED-class fallback — the
# 4.9 MTK vibrator is LED class on the m5c), built from vibrator/.
PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-impl \
    android.hardware.sensors@1.0-service \
    android.hardware.light@2.0-impl \
    android.hardware.light@2.0-service \
    android.hardware.vibrator@1.0-impl \
    android.hardware.vibrator@1.0-service \
    vibrator.mt6753

# --- Camera + torch ---------------------------------------------------------
# camera.mt6753.so (both ABIs) is an MTK HAL1-era module: FACT probe/camera.txt
# "Camera module API version: 0x204", 2 devices.  provider@2.4 default impl +
# camera.device@1.0 (both -impl and -service: m681 lesson).  The GraphicBuffer
# / BufferQueue imports of the HAL closure are paired with libmtkshim_gui/ui in
# BoardConfig.mk.  Snap: Camera1-API app (AOSP Camera2 dies on a LEGACY HAL —
# m5c measurement 2026-09-03).
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-impl \
    android.hardware.camera.provider@2.4-service \
    libmtkshim_gui \
    libmtkshim_ui \
    Snap

# --- Audio ------------------------------------------------------------------
# audio.primary.mt6753.so NEEDED (FACT, readelf): libtinyxml.so and
# libtinycompress.so, neither in the blob set; 7 VoiceUnlock statics -> shim.
# libtinycompress_m5s: device-local build (tinycompress/) because the platform
# module needs generated_kernel_headers, impossible with a prebuilt kernel.
# The HAL service itself: the m5c tree's comment says it "already comes from
# device.mk", but NO makefile of m5c @77e62e0 names it (it was hand-placed on
# the live m5c).  Declared here explicitly.  The Pie service registers the 4.0
# factory first and falls back to 2.0; the m5c live system ran the 4.0 impl
# (system.prop comment on ro.audio.legacy_hal_no_capture_position).
PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-service \
    android.hardware.audio@2.0-impl \
    android.hardware.audio@4.0-impl \
    android.hardware.audio.effect@2.0-impl \
    android.hardware.audio.effect@4.0-impl \
    audio.r_submix.default \
    audio.usb.default \
    libtinyxml \
    libtinycompress_m5s \
    libshim_audio_m5s

# Audio policy: the LOS 15.1 m5s set (configs/audio, from the stock install).
# audio_device.xml is read by the HAL from /system/etc (hard-coded path, FACT
# by strings) and is installed there by the vendor list, not here.
PRODUCT_COPY_FILES += \
    device/meizu/m5s/configs/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    device/meizu/m5s/configs/audio/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml \
    device/meizu/m5s/configs/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml

# --- Bluetooth ----------------------------------------------------------------
# 32-bit HIDL service (bluetooth_hal/) — libbt-vendor.so is 32-bit only on the
# m5s (device.mk).  forge-bluetooth.rc: service override, /dev/stpbt ownership
# (Pie has no net_bt_stack AID) and the factory BD address from NVRAM.
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-service.m5s

PRODUCT_COPY_FILES += \
    device/meizu/m5s/rootdir/forge-bluetooth.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/forge-bluetooth.rc \
    device/meizu/m5s/rootdir/m5s-bdaddr.sh:$(TARGET_COPY_OUT_VENDOR)/bin/m5s-bdaddr.sh \
    device/meizu/m5s/rootdir/m5s-stpbt-perm.sh:$(TARGET_COPY_OUT_VENDOR)/bin/m5s-stpbt-perm.sh

# --- Media codec configuration ------------------------------------------------
# The LOS 16 m5c image shipped no media_codecs.xml and MediaCodecList came up
# empty (m5c 2026-09-03).  The m5s set: media_codecs.xml and
# media_codecs_mediatek_video.xml from the LOS 15.1 m5s tree (component names
# of THIS blob set), the Google includes it references from frameworks/av, and
# mtk_omx_core.cfg — which libMtkOmxCore reads from /system/etc (FACT, strings)
# and the vendor list installs there.
PRODUCT_COPY_FILES += \
    device/meizu/m5s/configs/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    device/meizu/m5s/configs/media_codecs_mediatek_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_mediatek_video.xml \
    device/meizu/m5s/configs/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_telephony.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video_le.xml

# SoftAP configuration (m5c set; generic hostapd files).  NOT runtime-verified.
PRODUCT_COPY_FILES += \
    device/meizu/m5s/configs/hostapd/hostapd_default.conf:$(TARGET_COPY_OUT_VENDOR)/etc/hostapd/hostapd_default.conf \
    device/meizu/m5s/configs/hostapd/hostapd.accept:$(TARGET_COPY_OUT_VENDOR)/etc/hostapd/hostapd.accept \
    device/meizu/m5s/configs/hostapd/hostapd.deny:$(TARGET_COPY_OUT_VENDOR)/etc/hostapd/hostapd.deny

# Thermal: thermal_manager reads /etc/.tp/thermal.conf (FACT, strings); the
# config trio comes from the LOS 15.1 m5s tree (configs/thermal).
PRODUCT_COPY_FILES += \
    device/meizu/m5s/configs/thermal/thermal.conf:system/etc/.tp/thermal.conf \
    device/meizu/m5s/configs/thermal/thermal.off.conf:system/etc/.tp/thermal.off.conf \
    device/meizu/m5s/configs/thermal/ht120.mtc:system/etc/.tp/.ht120.mtc
