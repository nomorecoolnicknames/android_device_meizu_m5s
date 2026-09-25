# Peripheral HALs for the Meizu M5s.

# Wi-Fi
# MTK CONSYS. libwifi-hal-mt66xx comes from vendor/mediatek (see Android.mk);
# lib_driver_cmd_mt66xx is built from wpa_supplicant_8_lib/.
PRODUCT_PACKAGES += \
    android.hardware.wifi@1.0-service \
    wpa_supplicant \
    hostapd \
    wificond \
    lib_driver_cmd_mt66xx \
    libwpa_client

# wpa_supplicant.conf template: ISupplicant::addInterface rejects wlan0
# without one.
PRODUCT_COPY_FILES += \
    external/wpa_supplicant_8/wpa_supplicant/wpa_supplicant_template.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant.conf \
    device/meizu/m5s/rootdir/forge-connectivity.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/forge-connectivity.rc

# Sensors / lights / vibrator
# The stock sensors and lights modules ship in both ABIs. There is no stock
# vibrator module; vibrator.mt6753 is built from vibrator/.
PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-impl \
    android.hardware.sensors@1.0-service \
    android.hardware.light@2.0-impl \
    android.hardware.light@2.0-service \
    android.hardware.vibrator@1.0-impl \
    android.hardware.vibrator@1.0-service \
    vibrator.mt6753

# Camera
# camera.mt6753.so is a HAL1-era module (API 0x204, two cameras) wrapped by
# the provider@2.4 legacy impl; both -impl and -service are required.
# libmtkshim_gui/ui provide the GraphicBuffer symbols of the camera blobs
# (TARGET_LD_SHIM_LIBS). Snap is used because it works over the Camera1 API.
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-impl \
    android.hardware.camera.provider@2.4-service \
    libmtkshim_gui \
    libmtkshim_ui \
    Snap

# Audio
# audio.primary.mt6753.so needs libtinyxml and libtinycompress, which the blob
# set lacks, plus seven voice-unlock symbols provided by libshim_audio_m5s.
# libtinycompress_m5s is built locally because the platform module needs
# generated kernel headers, which a prebuilt kernel does not provide.
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

# Audio policy. audio_device.xml is read from /system/etc and is installed
# there by the vendor blob list.
PRODUCT_COPY_FILES += \
    device/meizu/m5s/configs/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    device/meizu/m5s/configs/audio/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml \
    device/meizu/m5s/configs/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_volumes.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:$(TARGET_COPY_OUT_VENDOR)/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/r_submix_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/r_submix_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/usb_audio_policy_configuration.xml

# Bluetooth
# 32-bit HIDL service (bluetooth_hal/); forge-bluetooth.rc sets /dev/stpbt
# ownership and the factory address from NVRAM.
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-service.m5s

PRODUCT_COPY_FILES += \
    device/meizu/m5s/rootdir/forge-bluetooth.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/forge-bluetooth.rc \
    device/meizu/m5s/rootdir/m5s-bdaddr.sh:$(TARGET_COPY_OUT_VENDOR)/bin/m5s-bdaddr.sh \
    device/meizu/m5s/rootdir/m5s-stpbt-perm.sh:$(TARGET_COPY_OUT_VENDOR)/bin/m5s-stpbt-perm.sh

# Media codecs
# The MTK codec lists match the component names of this blob set.
# mtk_omx_core.cfg is read from /system/etc and installed by the vendor list.
PRODUCT_COPY_FILES += \
    device/meizu/m5s/configs/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    device/meizu/m5s/configs/media_codecs_mediatek_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_mediatek_video.xml \
    device/meizu/m5s/configs/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_telephony.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_google_video_le.xml

# SoftAP configuration
PRODUCT_COPY_FILES += \
    device/meizu/m5s/configs/hostapd/hostapd_default.conf:$(TARGET_COPY_OUT_VENDOR)/etc/hostapd/hostapd_default.conf \
    device/meizu/m5s/configs/hostapd/hostapd.accept:$(TARGET_COPY_OUT_VENDOR)/etc/hostapd/hostapd.accept \
    device/meizu/m5s/configs/hostapd/hostapd.deny:$(TARGET_COPY_OUT_VENDOR)/etc/hostapd/hostapd.deny

# Thermal: thermal_manager reads /etc/.tp/thermal.conf.
PRODUCT_COPY_FILES += \
    device/meizu/m5s/configs/thermal/thermal.conf:system/etc/.tp/thermal.conf \
    device/meizu/m5s/configs/thermal/thermal.off.conf:system/etc/.tp/thermal.off.conf \
    device/meizu/m5s/configs/thermal/ht120.mtc:system/etc/.tp/.ht120.mtc
