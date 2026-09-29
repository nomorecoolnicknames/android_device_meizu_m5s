#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := device/meizu/m5s

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    device/meizu/m5s \
    vendor/meizu/m5s

# Vendor blobs
$(call inherit-product-if-exists, vendor/meizu/m5s/m5s-vendor.mk)

# Treble: libraries the vendor blobs need in the vendor namespace
# libm5sshim_gui forwards libgui.so to libgui_vendor (see shims/Android.bp).
# libcamera_client_vendor requires the legacy vendor frameworks/av changes.
PRODUCT_PACKAGES += \
    libstdc++.vendor \
    libgui_vendor \
    libm5sshim_gui \
    libcamera_client_vendor \
    libtinyxml \
    libtinycompress \
    librilutils

# HALs required by the target-level 3 compatibility matrix.
# The software gatekeeper is needed: LockSettingsService fails without one.
PRODUCT_PACKAGES += \
    android.hardware.audio@6.0-impl \
    android.hardware.audio.effect@6.0-impl \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service \
    android.hardware.drm@1.4-service.clearkey \
    android.hardware.gatekeeper@1.0-service.software

# Health
# Battery state needs an IHealth service; the legacy HAL alone is not enough.
PRODUCT_PACKAGES += \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service

# Screen density (720x1280, 320 dpi)
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xhdpi

PRODUCT_CHARACTERISTICS := phone

DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# Dalvik heap
# There is no 3 GB preset; use the 2048 MiB xhdpi one.
$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)

# Kernel
# Skip the copy when no prebuilt is set, to avoid an empty :kernel rule.
M5S_EFFECTIVE_KERNEL_PREBUILT := $(strip $(TARGET_PREBUILT_KERNEL))
ifneq ($(M5S_EFFECTIVE_KERNEL_PREBUILT),)
PRODUCT_COPY_FILES += \
    $(M5S_EFFECTIVE_KERNEL_PREBUILT):kernel
endif

# Ramdisk / fstab
# First-stage init reads /fstab.<ro.hardware> from the boot ramdisk;
# ro.hardware is mt6735 on this device.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6735:$(TARGET_COPY_OUT_RAMDISK)/fstab.mt6735 \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6735:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6735

# NVRAM and Bluetooth address init
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/init/init.m5s.nvram.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.m5s.nvram.rc \
    $(LOCAL_PATH)/rootdir/m5s-bdaddr.sh:$(TARGET_COPY_OUT_VENDOR)/bin/m5s-bdaddr.sh

# Input
# FocalTech ft5x46 touch (mtk-tpd), mtk-kpd keys, ACCDET headset detection and
# the home key on the Goodix fingerprint module (gf-keys).
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/keylayout/mtk-kpd.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/mtk-kpd.kl \
    $(LOCAL_PATH)/configs/keylayout/mtk-tpd.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/mtk-tpd.kl \
    $(LOCAL_PATH)/configs/keylayout/ACCDET.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/ACCDET.kl \
    $(LOCAL_PATH)/configs/keylayout/gf-keys.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/gf-keys.kl \
    $(LOCAL_PATH)/configs/keylayout/Vendor_2454_Product_6500.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/Vendor_2454_Product_6500.kl

# Media / audio
# media_codecs.xml includes media_codecs_google_*.xml, which come from the
# media APEX at runtime.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    $(LOCAL_PATH)/configs/media_codecs_mediatek_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_mediatek_video.xml \
    $(LOCAL_PATH)/configs/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml \
    $(LOCAL_PATH)/configs/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(LOCAL_PATH)/configs/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    $(LOCAL_PATH)/configs/audio/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml

# Seccomp
# Without it the MTK OMX service dies with SIGSYS and the device bootloops.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/seccomp/mediacodec.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediacodec.policy

# Wi-Fi / thermal
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/wifi/wpa_supplicant.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant.conf \
    $(LOCAL_PATH)/configs/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    $(LOCAL_PATH)/configs/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    $(LOCAL_PATH)/configs/thermal/thermal_policy:$(TARGET_COPY_OUT_VENDOR)/etc/.tp/.thermal_policy \
    $(LOCAL_PATH)/configs/thermal/ht120.mtc:$(TARGET_COPY_OUT_VENDOR)/etc/.tp/.ht120.mtc \

# wpa_supplicant service with the AIDL interface Android 13 expects.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/init/init.m5s.wifi.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.m5s.wifi.rc

# Permissions
# Fingerprint is not declared until a fingerprint HAL runs; otherwise Settings
# offers a broken enrollment flow. There is no NFC and no gyroscope.
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.wifi.direct.xml

# HIDL
PRODUCT_PACKAGES += \
    hwservicemanager \
    vndservicemanager

# Graphics
# composer@2.1 wraps the HWC 1.1 blob hwcomposer.mt6753 through
# libhwc2on1adapter. SurfaceFlinger aborts without a composer service.
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.1-service \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.mapper@2.0-impl \
    libhwc2on1adapter

# Keystore
# keystore2 needs a KeyMint instance; the AOSP software KeyMint needs no TEE.
PRODUCT_PACKAGES += \
    android.hardware.security.keymint-service

# Bluetooth
# com.android.bluetooth aborts without an IBluetoothHci service.
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-impl \
    android.hardware.bluetooth@1.1-service

# Sensors / lights / vibrator
# Passthrough services over the legacy sensors and lights modules. There is no
# vibrator blob: vibrator.default drives /sys/class/timed_output/vibrator.
# There is no memtrack blob either, so no memtrack service is installed.
PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-impl \
    android.hardware.sensors@1.0-service \
    android.hardware.light@2.0-impl \
    android.hardware.light@2.0-service \
    android.hardware.vibrator@1.0-impl \
    android.hardware.vibrator@1.0-service \
    vibrator.default

# Camera
# camera.mt6753 is a HAL1 module wrapped by the provider@2.4 legacy impl;
# both -impl and -service are required.
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-impl \
    android.hardware.camera.provider@2.4-service

# GNSS
# Disabled: gps.mt6753.so cannot load in the vendor namespace (it needs
# libandroid_runtime and libnativehelper), and a declared but unregistered
# IGnss blocks system_server. Re-enable together with the manifest entry.
#PRODUCT_PACKAGES += \
#    android.hardware.gnss@1.0-impl \
#    android.hardware.gnss@1.0-service

# Audio
PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-service

# Wi-Fi
# The Wi-Fi vendor HAL service is not installed yet.
PRODUCT_PACKAGES += \
    wificond \
    wpa_supplicant \
    hostapd

# Properties
# Needed before /vendor is mounted, so set through PRODUCT_PROPERTY_OVERRIDES.
PRODUCT_PROPERTY_OVERRIDES += \
    sys.usb.configfs=1 \
    sys.usb.controller=musb-hdrc \
    persist.sys.usb.config=adb \
    sys.usb.ffs.aio_compat=1

# Dexopt
# Saves /system space: Android 13 nearly fills the 1792 MiB system partition.
PRODUCT_PROPERTY_OVERRIDES += \
    pm.dexopt.first-boot=quicken \
    pm.dexopt.boot-after-ota=verify \
    pm.dexopt.install=speed-profile \
    pm.dexopt.bg-dexopt=speed-profile \
    pm.dexopt.ab-ota=speed-profile \
    pm.dexopt.inactive=verify \
    pm.dexopt.shared=speed
