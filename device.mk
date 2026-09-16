#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# device.mk — Meizu M5s (m5s, M1612) on LineageOS 20.0.
#
# Scope discipline, same as the m5c lane: a package appears below only if the
# module name was verified to exist in THIS tree (grep for `name: "<module>"`
# over Android.bp / `LOCAL_MODULE := <module>` over Android.mk, 2026-09-16).
# Everything the LOS 15.1 tree shipped that Android 13 no longer provides is
# listed in the "NOT WIRED YET" block at the end with the reason, not silently
# dropped.

LOCAL_PATH := device/meizu/m5s

# Vendor blobs.
$(call inherit-product-if-exists, vendor/meizu/m5s/m5s-vendor.mk)

# ---------------------------------------------------------------------------
# Screen: 720x1280, density 320 -> xhdpi
# ---------------------------------------------------------------------------
# FACT: /srv/forge/android/m5s/probe/display.txt "Physical size: 720x1280",
# probe/getprop.txt ro.sf.lcd_density=320.
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xhdpi

PRODUCT_CHARACTERISTICS := phone

DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# ---------------------------------------------------------------------------
# Dalvik / ART heap
# ---------------------------------------------------------------------------
# The m5s has 3 GB of RAM (FACT: DRAM map of three ranges totalling ~3 GiB,
# recorded in /srv/forge/android/m5s/BRINGUP_STATE.md and re-stated in the
# fleet factbase §2.2).  AOSP ships no phone-xhdpi-3072-dalvik-heap.mk; the
# closest profiles are 2048 and 4096.  2048 is chosen deliberately: it is the
# conservative one, and this device has to fit Android 13 into a 1792 MiB
# /system with no headroom (see the report).  Set by inherit, not by hand —
# on the m95 port a wrong inherit path silently left the 16 MB default growth
# limit and system_server OOM'd.
$(call inherit-product, frameworks/native/build/phone-xhdpi-2048-dalvik-heap.mk)

# ---------------------------------------------------------------------------
# Kernel — prebuilt only (see BoardConfig.mk for provenance and the gates)
# ---------------------------------------------------------------------------
# target_files / bacon must not emit an empty ":kernel" rule.
M5S_EFFECTIVE_KERNEL_PREBUILT := $(strip $(TARGET_PREBUILT_KERNEL))
ifneq ($(M5S_EFFECTIVE_KERNEL_PREBUILT),)
PRODUCT_COPY_FILES += \
    $(M5S_EFFECTIVE_KERNEL_PREBUILT):kernel
endif

# ---------------------------------------------------------------------------
# Ramdisk / fstab
# ---------------------------------------------------------------------------
# A13 first-stage init reads /fstab.<androidboot.hardware> out of the boot
# ramdisk (it only switches into /first_stage_ramdisk when
# androidboot.force_normal_boot=1, which this bootloader never sets —
# system/core/init/first_stage_init.cpp:388-401).  ro.hardware on this device
# is mt6735, NOT mt6753 — see vendor.prop.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6735:$(TARGET_COPY_OUT_RAMDISK)/fstab.mt6735 \
    $(LOCAL_PATH)/rootdir/etc/fstab.mt6735:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.mt6735

# ---------------------------------------------------------------------------
# Input
# ---------------------------------------------------------------------------
# Touch is FocalTech ft5x46 @ i2c1-0x38 behind mtk-tpd, keys are mtk-kpd,
# headset detection is ACCDET, and the home button lives on the Goodix
# fingerprint module (gf-keys).  FACT: the .kl files are the stock ones out of
# the Flyme 6.3.1.0G blob set (vendor/usr/keylayout/), dated 2019-03-07.
# Vendor_2454_Product_6500.kl is the Meizu USB-C remote/headset layout the
# 15.1 tree carried in the DEVICE tree rather than in blobs.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/keylayout/mtk-kpd.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/mtk-kpd.kl \
    $(LOCAL_PATH)/configs/keylayout/mtk-tpd.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/mtk-tpd.kl \
    $(LOCAL_PATH)/configs/keylayout/ACCDET.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/ACCDET.kl \
    $(LOCAL_PATH)/configs/keylayout/gf-keys.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/gf-keys.kl \
    $(LOCAL_PATH)/configs/keylayout/Vendor_2454_Product_6500.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/Vendor_2454_Product_6500.kl

# ---------------------------------------------------------------------------
# Media / audio configs (MTK, carried from the LOS 15.1 tree for this handset)
# ---------------------------------------------------------------------------
# NOTE on media_codecs.xml: it <Include>s media_codecs_google_audio.xml,
# media_codecs_google_telephony.xml and media_codecs_google_video_le.xml, which
# are NOT copied here.  On the 15.1 tree those three came from
# frameworks/av/media/libstagefright/data/ into /system/etc.  In A13 they live
# in the media APEX and the vendor-side merge is done by the codec2/omx store,
# so the include is resolved at runtime from a different root.  HYPOTHESIS to
# check on the first full build: if libstagefright logs "Failed to open file
# media_codecs_google_audio.xml", copy those three explicitly.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/media_codecs.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs.xml \
    $(LOCAL_PATH)/configs/media_codecs_mediatek_video.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_codecs_mediatek_video.xml \
    $(LOCAL_PATH)/configs/media_profiles_V1_0.xml:$(TARGET_COPY_OUT_VENDOR)/etc/media_profiles_V1_0.xml \
    $(LOCAL_PATH)/configs/audio/audio_device.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_device.xml \
    $(LOCAL_PATH)/configs/audio/audio_effects.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_effects.xml \
    $(LOCAL_PATH)/configs/audio/audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/audio_policy_configuration.xml \
    $(LOCAL_PATH)/configs/audio/a2dp_audio_policy_configuration.xml:$(TARGET_COPY_OUT_VENDOR)/etc/a2dp_audio_policy_configuration.xml

# MTK omx vendor seccomp policy.  m681 evidence: without it the omx service
# hits SIGSYS, crash_dump storms and the device OOM-bootloops.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/seccomp/mediacodec.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediacodec.policy

# ---------------------------------------------------------------------------
# Wi-Fi / thermal / AGPS configs
# ---------------------------------------------------------------------------
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/configs/wifi/wpa_supplicant.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant.conf \
    $(LOCAL_PATH)/configs/wifi/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    $(LOCAL_PATH)/configs/wifi/p2p_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/p2p_supplicant_overlay.conf \
    $(LOCAL_PATH)/configs/thermal/thermal.conf:$(TARGET_COPY_OUT_VENDOR)/etc/.tp/thermal.conf \
    $(LOCAL_PATH)/configs/thermal/thermal.off.conf:$(TARGET_COPY_OUT_VENDOR)/etc/.tp/thermal.off.conf \
    $(LOCAL_PATH)/configs/thermal/thermal_policy:$(TARGET_COPY_OUT_VENDOR)/etc/.tp/.thermal_policy \
    $(LOCAL_PATH)/configs/thermal/ht120.mtc:$(TARGET_COPY_OUT_VENDOR)/etc/.tp/.ht120.mtc \
    $(LOCAL_PATH)/configs/agps_profiles_conf2.xml:$(TARGET_COPY_OUT_VENDOR)/etc/agps_profiles_conf2.xml

# ---------------------------------------------------------------------------
# Permissions — only hardware that exists on this unit
# ---------------------------------------------------------------------------
# The M5s DOES have a fingerprint sensor (Goodix, on the home button) — unlike
# the m5c.  FACT: the blob set carries goodixfingerprintd, libgf_{hal,ca,algo}
# and fingerprint.default.so (64-bit only), and gf-keys.kl
# (LOS15_VENDOR_BLOBS.md, "Отпечаток (Goodix) 10 файлов").
# It is NOT declared here, because declaring android.hardware.fingerprint
# without a running IBiometricsFingerprint makes Settings show a broken
# enrollment flow.  Declare it together with the HAL, not before.
# No NFC and no gyroscope on this unit.
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

# ---------------------------------------------------------------------------
# HIDL / HAL backbone
# ---------------------------------------------------------------------------
PRODUCT_PACKAGES += \
    hwservicemanager \
    vndservicemanager

# Graphics.  surfaceflinger aborts with "failed to get hwcomposer service"
# without a composer.  composer@2.1-service is the passthrough registrar: it
# hw_get_module()s hwcomposer.$(ro.board.platform) = hwcomposer.mt6753 and
# wraps the HWC1.1 module through libhwc2on1adapter.
#
# On m5s the blob hwcomposer.mt6753.so EXISTS in the vendor set, unlike on m5c
# where it had to be replaced by the hand-written forge_hwc.  Whether it works
# on a 4.9 kernel is exactly the unknown that forced forge_hwc into existence
# on m5c ("вендорный hwcomposer.mt6735.so на ядре 4.9 зависает").  HYPOTHESIS
# for the first boot: the mt6753 blob behaves the same way.  Disconfirming
# test: SurfaceFlinger reaches "Boot is finished" with the blob in place.
PRODUCT_PACKAGES += \
    android.hardware.graphics.composer@2.1-service \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.mapper@2.0-impl \
    libhwc2on1adapter

# Keystore.  Android 13 keystore2 needs a KeyMint (AIDL) instance or it aborts
# with "no viable keymaster device found".  The AOSP default at
# hardware/interfaces/security/keymint/aidl/default is pure software
# (libpuresoftkeymasterdevice) — no TEE needed, which matters because the
# trustlets in this blob set (teei_daemon, thh/*) talk an MTK-private protocol.
PRODUCT_PACKAGES += \
    android.hardware.security.keymint-service

# Bluetooth.  com.android.bluetooth aborts in hci_layer_android.cc
# (Check failed: btHci != nullptr) with no IBluetoothHci registered.
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-impl \
    android.hardware.bluetooth@1.1-service

# Sensors / lights / vibrator / memtrack / power: generic AOSP passthrough
# services over the legacy hw modules.  Every one of sensors.mt6753.so,
# power.mt6753.so and the vibrator blob exists in the vendor set.
# NOT MEASURED on A13: unlike the m5c, this blob set has never had a
# symbol-closure run (blobsym.py) against any Android version.  Treat all five
# as HYPOTHESIS.
PRODUCT_PACKAGES += \
    android.hardware.sensors@1.0-impl \
    android.hardware.sensors@1.0-service \
    android.hardware.light@2.0-impl \
    android.hardware.light@2.0-service \
    android.hardware.vibrator@1.0-impl \
    android.hardware.vibrator@1.0-service \
    android.hardware.memtrack@1.0-service

# Camera: camera.mt6753.so is a HAL1 module; provider@2.4's default impl wraps
# it.  Both -impl and -service are required — the service binary is only the
# passthrough registrar (m681 lesson: the provider crashloops on "Could not get
# passthrough implementation").
PRODUCT_PACKAGES += \
    android.hardware.camera.provider@2.4-impl \
    android.hardware.camera.provider@2.4-service

# GNSS: the legacy gps.h HAL behind the AOSP gnss@1.0 passthrough service.
# ro.hardware.gps=mt6753 (vendor.prop) selects gps.mt6753.so, which is in the
# blob set.
PRODUCT_PACKAGES += \
    android.hardware.gnss@1.0-impl \
    android.hardware.gnss@1.0-service

# Audio: the generic multi-version HIDL audio service.
PRODUCT_PACKAGES += \
    android.hardware.audio@2.0-service

# Wi-Fi userspace.  NOTE: the vendor HAL SERVICE binary is missing, see below.
PRODUCT_PACKAGES += \
    wificond \
    wpa_supplicant \
    hostapd

# ---------------------------------------------------------------------------
# Properties
# ---------------------------------------------------------------------------
# On these Meizu MTK devices property_load_boot_defaults() runs before /vendor
# and /system are mounted, so anything that must exist at zygote-start time has
# to be in PRODUCT_PROPERTY_OVERRIDES (-> build.prop), not in the *DEFAULT*
# prop files.  ro.zygote in particular cannot come from ANY prop file: the
# import of init.${ro.zygote}.rc resolves while init.rc is being parsed.
PRODUCT_PROPERTY_OVERRIDES += \
    sys.usb.configfs=1 \
    sys.usb.controller=musb-hdrc \
    persist.sys.usb.config=adb \
    sys.usb.ffs.aio_compat=1

# Dexopt profile.  This is a SPACE decision, not a performance one: /system is
# 1792 MiB and Android 13 needs roughly 1710 MiB before device blobs.  See the
# size section of the report.
PRODUCT_PROPERTY_OVERRIDES += \
    pm.dexopt.first-boot=quicken \
    pm.dexopt.boot-after-ota=verify \
    pm.dexopt.install=speed-profile \
    pm.dexopt.bg-dexopt=speed-profile \
    pm.dexopt.ab-ota=speed-profile \
    pm.dexopt.inactive=verify \
    pm.dexopt.shared=speed

# ---------------------------------------------------------------------------
# NOT WIRED YET — every item here is a known gap, with the reason
# ---------------------------------------------------------------------------
# 0. NOTHING IN THIS TREE HAS EVER RUN ON THE HARDWARE.  The m5s has never
#    been flashed with a forge image (FACT:
#    /srv/forge/android/m5s/BRINGUP_STATE.md:4).  Both the 4.9 "E0" boot images
#    and the complete LOS 15.1 zip were produced offline and never written.
#    Everything below is therefore "not wired" on top of "not proven".
# 1. The Wi-Fi vendor HAL service.  In Android 13 there is NO standalone
#    android.hardware.wifi@1.0-service module: the srcs/defaults exist in
#    hardware/interfaces/wifi/1.6/default/Android.bp but the only cc_binary
#    using them is the cuttlefish apex.  The device tree has to define its own
#    binary.  Until then wlan0 cannot come up — and manifest.xml already
#    declares IWifi, so this is a real blocker (a declared but unserved HAL
#    hangs its client — the m681 light@2.0 lesson).
# 2. lib_driver_cmd_mt66xx / libwifi-hal-mt66xx come from vendor/mediatek,
#    which is not in this tree.  libwpa_client does not exist in A13 at all.
# 3. Telephony.  The blob set has 78 RIL/modem files including mtk-ril.so and
#    mtkrild, but A13 telephony expects IRadio 1.6 / AIDL.  The constraint
#    measured on the m5c's sibling blob applies here too and must be re-checked
#    on this one: if mtk-ril.so exports only RIL_InitSocket and not RIL_Init,
#    the AOSP rild can never host it.  Command to settle it:
#      readelf --dyn-syms vendor/meizu/m5s/proprietary/vendor/lib64/mtk-ril.so | grep RIL_
# 4. LD shims.  The LOS 15.1 tree declared a 13-entry TARGET_LD_SHIM_LIBS
#    (libmtkshim_gui / _audio / _camera / _binder / _ui).  The MECHANISM
#    survives on LOS 20 (vendor/lineage/config/BoardConfigSoong.mk:45,109 ->
#    vendor/lineage/build/soong/Android.bp:143-153 -> bionic linker_main.cpp),
#    but the shims themselves are Oreo symbol sets and the shim .so files are
#    not in this tree at all.  Nothing is declared until they are rebuilt and
#    re-measured against A13 bionic/libui/libgui.
# 5. sepolicy — nothing carried.  Runtime is permissive via kernel cmdline, so
#    a first boot is not blocked; anything past bring-up is.
# 6. rootdir rc files (init.mt6735.rc, ueventd.mt6735.rc, mtk_agpsd.rc, the
#    three m5s-*.sh helpers).  The 15.1 set is Nougat/Oreo init syntax; A13
#    init rejects several of those constructs outright.  Separate lane.
# 7. Fingerprint (Goodix).  Blobs exist; no HAL, no permission XML, no
#    manifest entry.  Deliberate — see the permissions block above.
# 8. recovery/TWRP — this tree does nothing with recovery.img beyond the
#    partition size and TARGET_RECOVERY_FSTAB.
