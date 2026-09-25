LOCAL_PATH := device/meizu/m5s

# Device makefile for the Meizu M5s on LineageOS 16.0.  Donor: device/meizu/m5c
# @77e62e0; every block below says what was kept, what changed for the m5s and
# on which evidence.  Nothing here has run on the device (README.md).

# Vendor blobs: vendor/meizu/m5s (a9-trees/m5s/vendor/meizu/m5s).  The list is
# generated from the stock-extracted LOS 15.1 set by
# meizu-fleet/tools/a9-gen-vendor-blobs.py; its header names every file that
# goes to /system instead of /vendor (hard-coded /system paths, FACT by strings)
# and every file left out (hwcomposer / keystore / gatekeeper / RIL pair).
$(call inherit-product-if-exists, vendor/meizu/m5s/m5s-vendor.mk)

PRODUCT_DEVICE := m5s

# Screen: 720x1280, 320 dpi (FACT, probe/display.txt + probe/getprop.txt) -> xhdpi.
PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xhdpi

# Dalvik heap, set explicitly (m95 lesson: a wrong inherit-if-exists path left
# the 16 MB default and system_server OOMed).  3 GB RAM (FACT, probe/meminfo.txt
# via M5S_RECON); growth limit 256m is the LOS 15.1 m5s value, the rest is the
# m5c set that boots LOS 16.
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapstartsize=8m \
    dalvik.vm.heapgrowthlimit=256m \
    dalvik.vm.heapsize=512m \
    dalvik.vm.heaptargetutilization=0.75 \
    dalvik.vm.heapminfree=512k \
    dalvik.vm.heapmaxfree=8m

# Prebuilt kernel into the target-files "kernel" slot (m681/m5c pattern).
M5S_EFFECTIVE_KERNEL_PREBUILT := $(strip $(TARGET_PREBUILT_KERNEL))
ifneq ($(M5S_EFFECTIVE_KERNEL_PREBUILT),)
PRODUCT_COPY_FILES += \
    $(M5S_EFFECTIVE_KERNEL_PREBUILT):kernel
endif

# Ramdisk: fstab (vendor = custom) plus the MTK rc set of the m5c LOS 16 port.
# That set is N-era MT6737M (m5c 14.1 lineage) and is what reached
# boot_completed on Pie with a 4.9 kernel — the same kernel line as the m5s E0.
# It was NOT diffed line by line against the m5s stock (M) init.mt6735.rc;
# the stock services missing from it are listed in README.md §rc.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/fstab.mt6735:root/fstab.mt6735 \
    $(LOCAL_PATH)/rootdir/init.mt6735.rc:root/init.mt6735.rc \
    $(LOCAL_PATH)/rootdir/init.mt6735.usb.rc:root/init.mt6735.usb.rc \
    $(LOCAL_PATH)/rootdir/init.modem.rc:root/init.modem.rc \
    $(LOCAL_PATH)/rootdir/init.project.rc:root/init.project.rc \
    $(LOCAL_PATH)/rootdir/init.recovery.mt6735.rc:root/init.recovery.mt6735.rc \
    $(LOCAL_PATH)/rootdir/ueventd.mt6735.rc:root/ueventd.mt6735.rc \
    $(LOCAL_PATH)/rootdir/enableswap.sh:root/enableswap.sh

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/fstab.mt6735:recovery/root/fstab.mt6735

# Keylayouts — the m5s's OWN stock set (vendor/usr/keylayout of the stock
# extraction; the generator leaves them out of the blob list so there is one
# rule per target).  FACT, probe/input_devices.txt: ACCDET, fp-keys, mtk-kpd,
# mtk-tpd are the live input devices; gf-keys is the Goodix FP key map.
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/keylayout/ACCDET.kl:system/usr/keylayout/ACCDET.kl \
    $(LOCAL_PATH)/keylayout/fp-keys.kl:system/usr/keylayout/fp-keys.kl \
    $(LOCAL_PATH)/keylayout/gf-keys.kl:system/usr/keylayout/gf-keys.kl \
    $(LOCAL_PATH)/keylayout/mtk-kpd.kl:system/usr/keylayout/mtk-kpd.kl \
    $(LOCAL_PATH)/keylayout/mtk-tpd.kl:system/usr/keylayout/mtk-tpd.kl

# MTK omx vendor seccomp policy (m681 evidence: SIGSYS -> crash_dump storm).
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/seccomp/mediacodec.policy:$(TARGET_COPY_OUT_VENDOR)/etc/seccomp_policy/mediacodec.policy

# Permission xmls — hardware that EXISTS on the m5s (FACT: probe/camera.txt
# "Number of camera devices: 2"; M1612_DCT_ANALYSIS.md: MC3410 accel,
# PA22x ALS/PS, QMC983x compass, no gyroscope — itg1010 node present, driver
# not bound).  Fingerprint (Goodix) exists but its HAL is not wired in this
# tree, so the feature is not declared (a declared feature without a HAL is a
# broken Settings wizard).
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/handheld_core_hardware.xml:system/etc/permissions/handheld_core_hardware.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:system/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.location.gps.xml:system/etc/permissions/android.hardware.location.gps.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:system/etc/permissions/android.hardware.telephony.gsm.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.camera.autofocus.xml:system/etc/permissions/android.hardware.camera.autofocus.xml \
    frameworks/native/data/etc/android.hardware.camera.flash-autofocus.xml:system/etc/permissions/android.hardware.camera.flash-autofocus.xml \
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.hardware.sensor.compass.xml:system/etc/permissions/android.hardware.sensor.compass.xml \
    frameworks/native/data/etc/android.hardware.sensor.light.xml:system/etc/permissions/android.hardware.sensor.light.xml \
    frameworks/native/data/etc/android.hardware.sensor.proximity.xml:system/etc/permissions/android.hardware.sensor.proximity.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml \
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml

# Treble HAL backbone — core plumbing (m5c).
PRODUCT_PACKAGES += \
    hwservicemanager \
    vndservicemanager \
    servicemanager

# Graphics (m5c stage 3).  hwcomposer.mt6753 is forge_hwc (HWC1.1) built from
# device/meizu/m5s/hwcomposer under the platform name; the stock
# hwcomposer.mt6753.so blob is left out of the vendor list on purpose — on the
# m5c the stock HWC hung on the 4.9 kernel and a PRODUCT_COPY_FILES blob
# silently shadows a same-named module (black screen, m5c 0adcdd8).
# FACT: forge_hwc's disp_session_uapi.h == kernel49's disp_session.h byte for byte.
PRODUCT_PACKAGES += \
    hwcomposer.mt6753 \
    android.hardware.graphics.composer@2.1-impl \
    android.hardware.graphics.composer@2.1-service \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.mapper@2.0-impl \
    libhwc2on1adapter

# Keymaster: the AOSP 3.0 software implementation (m5c: keystore aborted with
# "no viable keymaster device" without it).  The stock keystore.mt6753.so /
# gatekeeper.mt6753.so are TEE-backed (MicroTrust teei_daemon in the stock
# ramdisk) and are left out of the vendor list so hw_get_module cannot pick
# them up without a TEE — HYPOTHESIS, see README.md.
PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service

# USB/adb under Pie (m5c 2026-08-29): the only prop file early init loads on
# this no-first-stage-mount layout is /system/build.prop, so the configfs
# knobs go here.  sys.usb.controller=musb-hdrc is the UDC name of the MTK 4.9
# musb driver on the m5c (/sys/class/udc, FACT there); the E0 kernel carries
# the same driver — INFERENCE, first thing to read on the m5s: ls /sys/class/udc.
PRODUCT_PROPERTY_OVERRIDES += \
    ro.zygote=zygote64_32 \
    sys.usb.configfs=1 \
    sys.usb.controller=musb-hdrc \
    persist.sys.usb.config=adb \
    sys.usb.ffs.aio_compat=1 \
    pm.dexopt.first-boot=quicken \
    pm.dexopt.boot=verify \
    pm.dexopt.install=speed-profile \
    pm.dexopt.bg-dexopt=speed-profile \
    pm.dexopt.ab-ota=speed-profile \
    pm.dexopt.inactive=verify \
    pm.dexopt.shared=speed

# Device half of the Pie configfs gadget + zygote services + cpuset masks.
PRODUCT_COPY_FILES += \
    device/meizu/m5s/rootdir/forge-usb-gadget.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/forge-usb-gadget.rc \
    device/meizu/m5s/rootdir/forge-zygote.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/forge-zygote.rc \
    device/meizu/m5s/rootdir/forge-cpuset.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/forge-cpuset.rc

# Bluetooth: the AOSP passthrough impl dlopens libbt-vendor.so.  FACT: the m5s
# ships it 32-bit only (stock /system/lib/libbt-vendor.so, sha256 70a3ff31...,
# exports BLUETOOTH_VENDOR_LIB_INTERFACE, NEEDED libbluetooth_mtk.so) — the
# m5c situation exactly, so the m5c answer is kept: a 32-bit HIDL service
# (bluetooth_hal/, android.hardware.bluetooth@1.0-service.m5s).
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-impl

# libnvram.so of this blob set has DT_NEEDED libfs_mgr.so (FACT, readelf, both
# ABIs); Pie builds libfs_mgr only static, so nvram_daemon would die at the
# linker and stall the modem chain (m5c/m95 shim).
PRODUCT_PACKAGES += \
    libfs_mgr_m5s_shim

# Modem bring-up chain as a vendor rc (m5c forge-modem.rc; every binary it
# names exists in the m5s set — FACT, ls vendor/bin: nvram_daemon, ccci_fsd,
# ccci_mdinit, gsm0710muxd, muxreport, terservice).
PRODUCT_COPY_FILES += \
    device/meizu/m5s/rootdir/forge-modem.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/forge-modem.rc

# Operator names by MCC/MNC (generic list, carried from the m5c).
PRODUCT_COPY_FILES += \
    device/meizu/m5s/configs/spn-conf.xml:system/etc/spn-conf.xml

# GNSS: the STOCK legacy gps.mt6753.so behind the AOSP gnss@1.0 passthrough.
# NOT the m5c source HAL: that one speaks the Gen-N mtk_hal2mnl socket, and
# the m5s mnld is M-era (FACT: strings mnld | grep -c mtk_hal2mnl = 0).
# ro.hardware.gps=mt6753 (system.prop, FACT probe) selects the module.
PRODUCT_PACKAGES += \
    android.hardware.gnss@1.0-impl \
    android.hardware.gnss@1.0-service

# Peripheral HALs (Wi-Fi, sensors, lights, vibrator, camera, audio, BT).
$(call inherit-product, device/meizu/m5s/forge-peripherals.mk)

# Telephony: MTK Oreo HIDL rild + libril from vendor/mediatek/ril (m5c stage 4;
# BoardConfig.mk says why).  The stock RIL pair is pinned as modules in
# vendor/meizu/m5s/Android.mk because the MTK libril links them by name.
ENABLE_VENDOR_RIL_SERVICE := true
PRODUCT_PACKAGES += \
    rild \
    librilmtk \
    mtk-ril

# /vendor/firmware -> etc/firmware (ueventd firmware fallback for the modem
# image; see rootdir/ueventd.mt6735.rc).
PRODUCT_PACKAGES += \
    forge_vendor_firmware_link
