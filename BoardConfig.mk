# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
# BoardConfig.mk — Meizu M5s (m5s, M1612), MT6753, arm64, 3 GB RAM.

DEVICE_PATH := device/meizu/m5s

# LineageOS kernel/soong plumbing (TARGET_LD_SHIM_LIBS, prebuilt-kernel
# handling, BoardConfigSoong export set).
include vendor/lineage/config/BoardConfigLineage.mk

# MT6753 has eight Cortex-A53 cores and ARMv8.0 crypto extensions.
# It does not implement ARMv8.1 LSE atomics; keep the armv8-a architecture target.
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a53
TARGET_CPU_VARIANT_RUNTIME := cortex-a53

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a53
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a53

# The blob set is 32/64 mixed (507 files under vendor/meizu/m5s/proprietary,
# both lib/ and lib64/; the MTK daemons ccci_mdinit / gsm0710muxd / mnld /
# nvram_daemon exist only as 32-bit), so the 32-bit ABI has to stay.
# ro.zygote=zygote64_32 comes from core_64_bit.mk.
#
# NOTE vs the LOS 15.1 tree: that tree set TARGET_SUPPORTS_32_BIT_APPS := false
# and TARGET_2ND_ARCH_VARIANT := armv7-a-neon.  Neither is carried here.
# armv7-a-neon as the secondary variant on an armv8-a primary is the m95
# lesson (the combo makefiles ignore it); and core_64_bit.mk is the supported
# A13 way to express "64-bit primary, 32-bit available".
TARGET_USES_64_BIT_BINDER := true

# ---------------------------------------------------------------------------
# Platform
# ---------------------------------------------------------------------------
# FACT: ro.board.platform=mt6753 (probe/build.prop, probe/getprop.txt), which
# is the string hw_get_module() appends for hwcomposer.mt6753 /
# audio.primary.mt6753 / camera.mt6753 / sensors.mt6753 / gps.mt6753 — and all
# of those blob names exist in the vendor set.  ro.hardware is a DIFFERENT
# string on this device: mt6735.  Both are needed and they are not the same.
TARGET_BOARD_PLATFORM := mt6753
TARGET_BOOTLOADER_BOARD_NAME := mt6753
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true
BOARD_NAME := m5s
BOARD_USES_MTK_HARDWARE := true
MTK_HARDWARE := true

TARGET_OTA_ASSERT_DEVICE := m5s,M1612

# The default prebuilt is the baseline 4.9 kernel with the matching stock M5s DTB.
# Android 13 requires additional cgroup, BPF and filesystem configuration.
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
TARGET_KERNEL_SOURCE :=
TARGET_KERNEL_CONFIG :=

# An additional Android-13-configured prebuilt is available separately.
# It enables cpusets, block cgroups, BPF JIT, PSI, tmpfs attributes/ACLs, veth and socket diagnostics.
# Keep ARM64_LSE_ATOMICS disabled on Cortex-A53.
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt-kernel/Image.gz-dtb
forge_kernel_expected := $(DEVICE_PATH)/prebuilt-kernel/EXPECTED.txt
# TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt-kernel/Image.gz-dtb-a13
# forge_kernel_expected := $(DEVICE_PATH)/prebuilt-kernel/EXPECTED-a13.txt
# -------------------------------------------------------------------------
# (The file name is free-form: vendor/lineage/build/tasks/kernel.mk:148 does
# KERNEL_BIN := $(TARGET_PREBUILT_KERNEL), so -a13 needs no other change.
# BOARD_KERNEL_IMAGE_NAME below names the image inside boot.img and stays.)
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb

# Freshness gate on the hand-placed prebuilt (carried from the m5c lane).
# Follows whichever of the two files is selected above.
forge_kernel_check := $(shell $(DEVICE_PATH)/tools/check_prebuilt_kernel.sh \
        $(TARGET_PREBUILT_KERNEL) $(forge_kernel_expected))
ifneq ($(strip $(forge_kernel_check)),)
$(error $(forge_kernel_check))
endif

# Boot addresses: kernel 0x40080000, ramdisk 0x44000000, tags 0x4e000000; page size 2048.
# Base and offsets below jointly encode these addresses.
BOARD_KERNEL_BASE := 0x40000000
BOARD_KERNEL_OFFSET := 0x00080000
BOARD_RAMDISK_OFFSET := 0x04000000
BOARD_KERNEL_TAGS_OFFSET := 0x0e000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_MKBOOTIMG_ARGS := \
    --kernel_offset $(BOARD_KERNEL_OFFSET) \
    --ramdisk_offset $(BOARD_RAMDISK_OFFSET) \
    --tags_offset $(BOARD_KERNEL_TAGS_OFFSET) \
    --board m5s

# androidboot.hardware=mt6735 is what makes init import init.mt6735.rc and
# find fstab.mt6735.  FACT: the live stock cmdline already carries it
# (probe/bootargs.txt), and the stock DTB /chosen/bootargs does too
# (m5s_stock.dts:11).  The E0 images do NOT carry it in their own cmdline —
# they rely on the DTB — so it is spelled out here rather than assumed.
# buildvariant= is appended by build/make automatically — do not set it here.
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 androidboot.selinux=permissive androidboot.hardware=mt6735

# M5s is A-only: boot 16 MiB, recovery 32 MiB, custom 512 MiB, system 1792 MiB.
# There are no dynamic partitions. Keep the stock partition map.
BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 33554432
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1879048192
BOARD_CACHEIMAGE_PARTITION_SIZE := 419430400
BOARD_USERDATAIMAGE_PARTITION_SIZE := 28197781504
BOARD_FLASH_BLOCK_SIZE := 131072

TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USES_MKE2FS := true
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := ext4

# A-only device. Fastboot write support must be verified on the actual handset.
AB_OTA_UPDATER := false
BOARD_USES_RECOVERY_AS_BOOT := false

# No system_ext / product partitions on this GPT — fold them into /system.
TARGET_COPY_OUT_SYSTEM_EXT := system/system_ext
TARGET_COPY_OUT_PRODUCT := system/product

# ---------------------------------------------------------------------------
# Vendor partition / VNDK
# ---------------------------------------------------------------------------
# Decision: REAL /vendor on custom (p17).  (Until 2026-09-24: "VNDK OFF";
# superseded by the Treble block below.)  Same shape as m5c, and for this
# device the evidence is even less ambiguous:
#
# FACT: `custom` = mmcblk0p17, exactly 524 288 KiB = 512 MiB
#   (probe/partitions.txt line "179 17 524288 mmcblk0p17";
#    scatter: custom 0x07a00000 -> devinfo 0x27a00000 = 0x20000000 = 512 MiB).
# FACT: it is a mounted ext4 filesystem on the STOCK firmware already —
#   "…/by-name/custom /custom ext4 ro,seclabel,relatime" (probe/proc_mounts.txt).
#   So the partition is real, formatted and readable; it is not a guess.
# FACT: the LOS 15.1 tree built for this handset already re-purposes it as
#   /vendor (device/meizu/m5s/BoardConfig.mk: TARGET_COPY_OUT_VENDOR := vendor,
#   BOARD_VENDORIMAGE_PARTITION_SIZE := 536870912).
# FACT: the blob set is 240 MiB / 507 files (du on
#   vendor/meizu/m5s/proprietary) — it fits 512 MiB with ~270 MiB to spare.
# INFERENCE: moving those 240 MiB off /system is the single biggest lever for
#   fitting Android 13 into /system.  See the report's size section.
TARGET_COPY_OUT_VENDOR := vendor
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_PARTITION_SIZE := 536870912

# Full Treble + VNDK (owner's directive 2026-09-24: "all of them Treble",
# same shape as m95).  Until 2026-09-24 this block said "VNDK stays OFF"
# because the Marshmallow blobs carry no VNDK compliance; that is still true,
# and the price is now paid on the vendor side instead of by switching Treble
# off.  Measured before the switch (meizu-fleet/tools/treble_blob_audit.py
# over m5s-vendor-blobs.mk against the VNDK 33 lists of the m95 build):
# 323 of 441 vendor ELFs have an unresolved DT_NEEDED closure in the vendor or
# sphal namespace, 34 missing sonames; the vendor copies in device.mk bring
# that to 299 / 31.  The rest is the shim lane —
# designs/TREBLE_M5S_M2NOTE_20260924.md §4.
#
# PRODUCT_FULL_TREBLE_OVERRIDE: nothing turns Treble on by itself here —
# PRODUCT_SHIPPING_API_LEVEL is not set (see below), so the >= 26 rule never
# fires.  It also switches PRODUCT_ENFORCE_VINTF_MANIFEST on
# (build/make/core/config.mk:684-693), and with it libhidl refuses to register
# any HIDL service the device manifest does not declare as hwbinder
# (system/libhidl/transport/ServiceManagement.cpp:851-862) — see manifest.xml.
PRODUCT_FULL_TREBLE_OVERRIDE := true

# VNDK "current" (= 33), the same value m95 ships.  NOT 30: m95 tried
# BOARD_VNDK_VERSION := 30 first and rejected it on two hard soong walls
# (vendor apexes in hardware/interfaces, and a vendor_snapshot module this
# workspace does not have) — device/meizu/m95/BoardConfig.mk "Treble + VNDK 30".
# m95's PRODUCT_EXTRA_VNDK_VERSIONS := 30 is NOT carried over: it exists there
# only to boot the new system against an already-built v30 vendor.img, and no
# v30 vendor exists for this device.  It would cost /system space
# (a com.android.vndk.vNN apex is tens of MiB) for nothing.
BOARD_VNDK_VERSION := current

# SELinux split follows PRODUCT_FULL_TREBLE (PRODUCT_SEPOLICY_SPLIT, same
# config.mk block): the vendor image gets vendor_sepolicy.cil built from
# system/sepolicy/vendor plus BOARD_VENDOR_SEPOLICY_DIRS.  No device policy is
# carried yet (runtime is permissive via cmdline); the device dir is the place
# for it when the rc lane lands.

# ---------------------------------------------------------------------------
# Boot / root layout
# ---------------------------------------------------------------------------
# NOT system-as-root in the BOARD_BUILD_SYSTEM_ROOT_IMAGE sense: that needs
# the bootloader to pass skip_initramfs / force_normal_boot, and this Meizu LK
# does neither.  A13 init handles it the normal non-A/B way: the boot ramdisk
# carries first-stage init plus fstab.mt6735, DoFirstStageMount() mounts
# /system and /vendor and SwitchRoot()s into /system.
# HYPOTHESIS, the largest untested change in this port, same as on m5c: that
# A13 first-stage init finds /fstab.mt6735 in the ramdisk root on this device.
# Disconfirming evidence would appear as "Failed to mount required partitions
# early" in pstore/expdb on the first boot attempt.
BOARD_ROOT_EXTRA_FOLDERS := nvdata protect_f protect_s

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.mt6735
TARGET_RECOVERY_PIXEL_FORMAT := BGRA_8888
TARGET_SCREEN_WIDTH := 720
TARGET_SCREEN_HEIGHT := 1280

# ---------------------------------------------------------------------------
# Properties
# ---------------------------------------------------------------------------
TARGET_SYSTEM_PROP := $(DEVICE_PATH)/system.prop
TARGET_VENDOR_PROP := $(DEVICE_PATH)/vendor.prop

# ---------------------------------------------------------------------------
# SELinux
# ---------------------------------------------------------------------------
# Runtime permissive via kernel cmdline for bring-up.  Build-time neverallow
# assertions are skipped because the M-era MTK vendor rules violate A13 public
# policy.
SELINUX_IGNORE_NEVERALLOWS := true

# ---------------------------------------------------------------------------
# Seccomp
# ---------------------------------------------------------------------------
# m681 evidence: without the vendor mediacodec seccomp policy the MTK omx
# service takes SIGSYS, crash_dump storms, and the device OOM-bootloops.
# The policy carried here is the m5c one byte-for-byte: it is an aarch64
# syscall allowlist for the MTK OMX daemons, not an SoC-specific table.
BOARD_SECCOMP_POLICY := $(DEVICE_PATH)/seccomp

# ---------------------------------------------------------------------------
# Graphics
# ---------------------------------------------------------------------------
BOARD_EGL_CFG := $(DEVICE_PATH)/configs/egl.cfg
USE_OPENGL_RENDERER := true

# ---------------------------------------------------------------------------
# Wi-Fi — MTK CONSYS MT6735 combo (same combo chip as m5c/m2note)
# ---------------------------------------------------------------------------
BOARD_WLAN_DEVICE := MediaTek
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := NL80211
WIFI_DRIVER_STATE_CTRL_PARAM := /dev/wmtWifi
WIFI_DRIVER_STATE_ON := 1
WIFI_DRIVER_STATE_OFF := 0

# ---------------------------------------------------------------------------
# Bluetooth — same CONSYS chip
# ---------------------------------------------------------------------------
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_MTK := true
BOARD_BLUETOOTH_DOES_NOT_USE_RFKILL := true

# ---------------------------------------------------------------------------
# VINTF
# ---------------------------------------------------------------------------
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml

# ---------------------------------------------------------------------------
# Build workarounds
# ---------------------------------------------------------------------------
# The blob set is Marshmallow vintage; its ELF dependency closure does not
# resolve against A13 libraries, so the prebuilt ELF checker must not gate the
# build.  This is a statement of fact about the blobs, not a wish — and it
# means the build will NOT warn about a broken library; the device will.
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_PREBUILT_ELF_FILES := true
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_VENDOR_PROPERTY_NAMESPACE := true
