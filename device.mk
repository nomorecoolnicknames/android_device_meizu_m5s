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

# ---------------------------------------------------------------------------
# Soong namespaces (device-tree isolation)
#
# FACT (measured 2026-09-16): Soong parses every Android.bp in the workspace
# for every product and has no TARGET_DEVICE guard, so a bp module declared in
# one device tree lands in installs-<product>.mk of ALL products — a plain
# `m nothing` for lineage_m5s carried 51 install-rule lines from
# device/meizu/m95 (27 modules), two of them colliding with real m5s blobs
# (vendor/lib{,64}/libperfservicenative.so, via the `stem:` of
# libm95shim_perfservice).  Modules of a namespace reach Make only for the
# products that list that namespace here
# (build/soong/cmd/soong_build/main.go:99-112 -> android/namespace.go:204 ->
# android/androidmk.go:919).  Each tree carries a root Android.bp with
# `soong_namespace {}`; this line is the other half of the pair.
# ---------------------------------------------------------------------------
PRODUCT_SOONG_NAMESPACES += \
    device/meizu/m5s \
    vendor/meizu/m5s

# Vendor blobs.
$(call inherit-product-if-exists, vendor/meizu/m5s/m5s-vendor.mk)

# ---------------------------------------------------------------------------
# Full Treble: vendor-side copies of libraries the blobs NEED
# ---------------------------------------------------------------------------
# With Treble (BoardConfig.mk) a vendor process sees only /vendor, LLNDK and
# public VNDK.  FACT (meizu-fleet/tools/treble_blob_audit.py over
# m5s-vendor-blobs.mk, VNDK 33 lists of the m95 build, 2026-09-25): 323 of 441
# vendor ELFs had an unresolved closure, 34 missing sonames.  The entries below
# are the ones Android 13 can build for /vendor from source; with them the
# same audit gives 299 / 31.  What remains (libnativehelper, libfs_mgr,
# libandroid_runtime, libmedia, libskia, ... and GPU in sphal) is the shim
# lane: designs/TREBLE_M5S_M2NOTE_20260924.md §4.
#
#  * libstdc++.vendor — bionic's small libstdc++ (bionic/libc/Android.bp,
#    vendor_available: true); 157 closures, the largest single gap (m95 has the
#    same line for its Mali closure).
#  * libgui_vendor + libm5sshim_gui — libgui.so for 113 closures, m95 lesson 6
#    (shims/Android.bp says why a forwarder and not a copy).
#  * libcamera_client_vendor — m95 lesson 7: the vendor build of
#    libcamera_client (stem libcamera_client, frameworks/av branch
#    meizu-legacy-vendor), 83 closures.  It also carries
#    Camera::connectLegacy(int, int, const String16&, int, sp<Camera>&), which
#    libsource.so imports under exactly that mangled name (nm -D).  Still
#    missing for libsource.so: the N-form getCameraInfo(int, android::CameraInfo*)
#    (…13getCameraInfoEiPNS_10CameraInfoE) — design doc §5, wall (b).
#  * libtinycompress, libtinyxml — both vendor: true (external/tinycompress,
#    external/tinyxml); NEEDed by audio.primary.mt6753.so (lib and lib64),
#    audit of the audio HAL closure, designs/treble-m5s-m2note/keyroots.txt.
#    m95 installs libtinycompress for the same reason.
#  * librilutils — vendor: true in hardware/ril/librilutils; NEEDed by mtkrild
#    and the RIL closure (8).
PRODUCT_PACKAGES += \
    libstdc++.vendor \
    libgui_vendor \
    libm5sshim_gui \
    libcamera_client_vendor \
    libtinycompress \
    libtinyxml \
    librilutils

# HALs the framework compatibility matrix of target-level 3 marks
# optional="false" (hardware/interfaces/compatibility_matrices/
# compatibility_matrix.3.xml): audio + audio.effect (>= 4.0 — Android 13's
# client knows only 4.0..7.1, frameworks/av/media/libaudiohal/
# FactoryHalHidl.cpp), drm, gatekeeper, composer, mapper, media.omx.  Composer
# and mapper are already installed below; omx comes from base_vendor.mk.
# Same choices as m95 (device/meizu/m95/device.mk, "Treble HAL backbone"):
#  * audio@6.0-impl + audio.effect@6.0-impl: loaded by the multi-version
#    android.hardware.audio@2.0-service already in this file.  Whether the
#    Marshmallow audio.primary.mt6753.so survives the 6.0 wrapper is NOT known
#    (m95 needed a Nougat-layout guard in hardware/interfaces) — HYPOTHESIS.
#  * drm@1.0-impl/-service + drm@1.4-service.clearkey (ships its own VINTF
#    fragment).
#  * gatekeeper@1.0-service.software (ships its own VINTF fragment): without
#    any IGatekeeper LockSettingsService throws (m95 18.1 evidence).
PRODUCT_PACKAGES += \
    android.hardware.audio@6.0-impl \
    android.hardware.audio.effect@6.0-impl \
    android.hardware.drm@1.0-impl \
    android.hardware.drm@1.0-service \
    android.hardware.drm@1.4-service.clearkey \
    android.hardware.gatekeeper@1.0-service.software

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

# Init fragment with the m95 NVRAM lessons (see the file header for why it is
# safe to carry ahead of the rc lane — NOT WIRED YET below).
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/init/init.m5s.nvram.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.m5s.nvram.rc \
    $(LOCAL_PATH)/rootdir/m5s-bdaddr.sh:$(TARGET_COPY_OUT_VENDOR)/bin/m5s-bdaddr.sh

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

# wpa_supplicant service with the AIDL interface name the A13 framework asks
# for (m95 lesson 161682f; nothing else in this image defines the service —
# see the header of that rc).
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/etc/init/init.m5s.wifi.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.m5s.wifi.rc

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
# ... exist in the vendor set.  CORRECTION 2026-09-25 (FACT): of the three
# named, only sensors.mt6753.so is in m5s-vendor-blobs.mk — there is no
# power.*, vibrator.* or memtrack.* file in proprietary/ at all (find), so
# ro.hardware.power=mt6753 in vendor.prop points at nothing; the vibrator and
# memtrack consequences are in the note below the list.
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
    vibrator.default

# 2026-09-25, Treble: every service above is declared in manifest.xml, so it
# must actually be able to serve (a declared-but-unserved HAL hangs its
# client).  FACT (ls of the blob list, m5s-vendor-blobs.mk): the only legacy hw
# modules in this set are audio.primary, camera, fingerprint.default,
# gatekeeper, gps, gralloc, hwcomposer, keystore, lights, mmsdk, sensors —
# there is NO vibrator.* and NO memtrack.* module, and the @1.0 impls load
# exactly those via hw_get_module (hardware/interfaces/vibrator/1.0/default/
# Vibrator.cpp:72, memtrack/1.0/default/Memtrack.cpp:77).
#  * vibrator.default — the AOSP module (hardware/libhardware/modules/vibrator,
#    proprietary: true) that drives /sys/class/timed_output/vibrator/enable.
#    HYPOTHESIS: the 4.9 MTK vibrator driver exposes timed_output; check
#    `ls /sys/class/timed_output/vibrator` on first boot.
#  * memtrack@1.0-service is DROPPED: with no memtrack module it can only exit,
#    and under Treble it must not be declared either.  A13's memtrack client
#    treats an undeclared HAL as absent.

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
#    CORRECTION 2026-09-25 (FACT): the standalone service DOES exist, as a
#    kati module — hardware/interfaces/wifi/1.6/default/Android.mk:96
#    (LOCAL_MODULE := android.hardware.wifi@1.0-service), and m95 installs it.
#    It links the static libwifi-hal, which for BOARD_WLAN_DEVICE := MediaTek
#    is libwifi-hal-mt66xx (frameworks/opt/net/wifi/libwifi_hal/Android.mk:
#    123-125); m95 builds its own (device/meizu/m95/wifi_hal).  The service
#    ships a VINTF fragment (IWifi 1.6): when it is wired, drop the IWifi 1.2
#    entry from manifest.xml in the same change.
# 2. lib_driver_cmd_mt66xx / libwifi-hal-mt66xx come from vendor/mediatek,
#    which is not in this tree.  libwpa_client does not exist in A13 at all.
# 3. Telephony.  The blob set has 78 RIL/modem files including mtk-ril.so and
#    mtkrild, but A13 telephony expects IRadio 1.6 / AIDL.  The constraint
#    measured on the m5c's sibling blob applies here too and must be re-checked
#    on this one: if mtk-ril.so exports only RIL_InitSocket and not RIL_Init,
#    the AOSP rild can never host it.  Command to settle it:
#      readelf --dyn-syms vendor/meizu/m5s/proprietary/vendor/lib64/mtk-ril.so | grep RIL_
#    SETTLED 2026-09-24 (FACT, nm -D --defined-only): both
#    proprietary/vendor/lib{,64}/mtk-ril.so export RIL_InitSocket and NO
#    RIL_Init (DT_NEEDED librilmtk.so, librilutils.so) — same generation as
#    m5c and m2note.  So the m95 telephony scheme (hardware/ril branch
#    meizu-legacy-vendor, BOARD_USES_MTK_LEGACY_RIL + librilmtk + a renamed
#    librilimp, device/meizu/m95 7c49535/2922847) does not apply: its rild
#    loads mtk-ril.so and calls RIL_Init, as m95's own mtk-ril.so exports.
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
#    Carried ahead of that lane: rootdir/etc/init/init.m5s.wifi.rc
#    (wpa_supplicant with the AIDL interface; do not port a second
#    `service wpa_supplicant`) and rootdir/etc/init/init.m5s.nvram.rc (m95
#    NVRAM lessons, 2026-09-24).  It creates /data/nvram as a real directory
#    (the 15.1 layout: a mirror of /nvdata, never a symlink) and copies
#    fstab.mt6735 into it at post-fs-data; start nvram_daemon after that
#    (the 15.1 rc starts it `on boot`, which is later — fine).
# 7. Fingerprint (Goodix).  Blobs exist; no HAL, no permission XML, no
#    manifest entry.  Deliberate — see the permissions block above.
# 8. recovery/TWRP — this tree does nothing with recovery.img beyond the
#    partition size and TARGET_RECOVERY_FSTAB.
