LOCAL_PATH := device/meizu/m5s


$(call inherit-product, vendor/meizu/m5s/m5s-vendor.mk)

PRODUCT_DEVICE := m5s

PRODUCT_AAPT_CONFIG := normal
PRODUCT_AAPT_PREF_CONFIG := xhdpi

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

PRODUCT_PACKAGES += \
    hwcomposer.mt6753 \
    android.hardware.graphics.composer@2.1-impl \
    android.hardware.graphics.composer@2.1-service \
    android.hardware.graphics.allocator@2.0-impl \
    android.hardware.graphics.allocator@2.0-service \
    android.hardware.graphics.mapper@2.0-impl \
    libhwc2on1adapter

PRODUCT_PACKAGES += \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service

# Pie adbd uses FunctionFS through the native 3.18 android_usb gadget.
PRODUCT_PROPERTY_OVERRIDES += \
    ro.zygote=zygote64_32 \
    sys.usb.configfs=0 \
    persist.sys.usb.config=adb \
    sys.usb.ffs.aio_compat=1 \
    pm.dexopt.first-boot=quicken \
    pm.dexopt.boot=verify \
    pm.dexopt.install=speed-profile \
    pm.dexopt.bg-dexopt=speed-profile \
    pm.dexopt.ab-ota=speed-profile \
    pm.dexopt.inactive=verify \
    pm.dexopt.shared=speed

# Zygote services and cpuset masks; legacy USB is imported by init.mt6735.rc.
PRODUCT_COPY_FILES += \
    device/meizu/m5s/rootdir/forge-zygote.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/forge-zygote.rc \
    device/meizu/m5s/rootdir/forge-cpuset.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/forge-cpuset.rc

# Bluetooth: the AOSP passthrough impl dlopens libbt-vendor.so.  the m5s
# ships it 32-bit only (stock /system/lib/libbt-vendor.so, sha256 70a3ff31...,
# exports BLUETOOTH_VENDOR_LIB_INTERFACE, NEEDED libbluetooth_mtk.so) — the
# m5c situation exactly, so the m5c answer is kept: a 32-bit HIDL service
# (bluetooth_hal/, android.hardware.bluetooth@1.0-service.m5s).
PRODUCT_PACKAGES += \
    android.hardware.bluetooth@1.0-impl

# libnvram.so of this blob set has DT_NEEDED libfs_mgr.so (readelf, both
# ABIs); Pie builds libfs_mgr only static, so nvram_daemon would die at the
# linker and stall the modem chain (m5c/m95 shim).
PRODUCT_PACKAGES += \
    libfs_mgr_m5s_shim

# Modem bring-up chain as a vendor rc (m5c forge-modem.rc; every binary it
# names exists in the m5s set — ls vendor/bin: nvram_daemon, ccci_fsd,
# ccci_mdinit, gsm0710muxd, muxreport, terservice).
PRODUCT_COPY_FILES += \
    device/meizu/m5s/rootdir/forge-modem.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/forge-modem.rc

# Operator names by MCC/MNC (generic list, carried from the m5c).
PRODUCT_COPY_FILES += \
    device/meizu/m5s/configs/spn-conf.xml:system/etc/spn-conf.xml

# GNSS: the STOCK legacy gps.mt6753.so behind the AOSP gnss@1.0 passthrough.
# NOT the m5c source HAL: that one speaks the Gen-N mtk_hal2mnl socket, and
# the m5s mnld is M-era (strings mnld | grep -c mtk_hal2mnl = 0).
PRODUCT_PACKAGES += \
    android.hardware.gnss@1.0-impl \
    android.hardware.gnss@1.0-service

# Peripheral HALs (Wi-Fi, sensors, lights, vibrator, camera, audio, BT).
$(call inherit-product, device/meizu/m5s/forge-peripherals.mk)

ENABLE_VENDOR_RIL_SERVICE := true
PRODUCT_PACKAGES += \
    rild \
    librilmtk \
    mtk-ril

# /vendor/firmware -> etc/firmware (ueventd firmware fallback for the modem
# image; see rootdir/ueventd.mt6735.rc).
PRODUCT_PACKAGES += \
    forge_vendor_firmware_link
