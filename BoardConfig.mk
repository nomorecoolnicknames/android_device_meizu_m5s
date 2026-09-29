# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0

DEVICE_PATH := device/meizu/m5s

include vendor/lineage/config/BoardConfigLineage.mk

# Architecture
# MT6753: eight Cortex-A53 cores without ARMv8.1 LSE atomics; keep armv8-a.
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

# Several MTK daemons (ccci_mdinit, gsm0710muxd, mnld, nvram_daemon) are
# 32-bit only, so the secondary ABI has to stay.
TARGET_USES_64_BIT_BINDER := true

# Platform
# ro.board.platform (HAL module suffix) is mt6753, but ro.hardware is mt6735.
TARGET_BOARD_PLATFORM := mt6753
TARGET_BOOTLOADER_BOARD_NAME := mt6753
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true
BOARD_NAME := m5s
BOARD_USES_MTK_HARDWARE := true
MTK_HARDWARE := true

TARGET_OTA_ASSERT_DEVICE := m5s,M1612

# Kernel
# The prebuilt is forced even though a kernel source and defconfig are set.
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
TARGET_KERNEL_SOURCE := kernel/meizu/m5s
TARGET_KERNEL_CONFIG := m5s_defconfig
TARGET_FORCE_PREBUILT_KERNEL := true

TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt-kernel/Image.gz-dtb
forge_kernel_expected := $(DEVICE_PATH)/prebuilt-kernel/EXPECTED.txt
# BOARD_KERNEL_IMAGE_NAME is the image name inside boot.img.
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb

# Reject a prebuilt kernel that does not match its EXPECTED file.
forge_kernel_check := $(shell $(DEVICE_PATH)/tools/check_prebuilt_kernel.sh \
        $(TARGET_PREBUILT_KERNEL) $(forge_kernel_expected))
ifneq ($(strip $(forge_kernel_check)),)
$(error $(forge_kernel_check))
endif

# Kernel 0x40080000, ramdisk 0x44000000, tags 0x4e000000, page size 2048.
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

# androidboot.hardware=mt6735 makes init import init.mt6735.rc and find
# fstab.mt6735. buildvariant= is appended by the build system.
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 androidboot.selinux=permissive androidboot.hardware=mt6735

# Partitions
# A-only, no dynamic partitions: boot 16 MiB, recovery 32 MiB,
# custom (vendor) 512 MiB, system 1792 MiB.
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

AB_OTA_UPDATER := false
BOARD_USES_RECOVERY_AS_BOOT := false

# No system_ext / product partitions; fold them into /system.
TARGET_COPY_OUT_SYSTEM_EXT := system/system_ext
TARGET_COPY_OUT_PRODUCT := system/product

# Vendor
# /vendor lives on the stock 512 MiB ext4 "custom" partition (mmcblk0p17).
TARGET_COPY_OUT_VENDOR := vendor
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_PARTITION_SIZE := 536870912

# Treble
# PRODUCT_SHIPPING_API_LEVEL is unset, so full Treble has to be forced. This
# also enforces the VINTF manifest: every HIDL service must be declared in
# manifest.xml. The legacy blobs are not VNDK-compliant; device.mk and shims/
# provide the missing vendor libraries.
PRODUCT_FULL_TREBLE_OVERRIDE := true

# VNDK
BOARD_VNDK_VERSION := current

# Root layout
# Not system-as-root: the bootloader passes neither skip_initramfs nor
# force_normal_boot. First-stage init mounts /system and /vendor using the
# fstab in the boot ramdisk.
BOARD_ROOT_EXTRA_FOLDERS := nvdata protect_f protect_s

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.mt6735
TARGET_RECOVERY_PIXEL_FORMAT := BGRA_8888
TARGET_SCREEN_WIDTH := 720
TARGET_SCREEN_HEIGHT := 1280

# Properties
TARGET_SYSTEM_PROP := $(DEVICE_PATH)/system.prop
TARGET_VENDOR_PROP := $(DEVICE_PATH)/vendor.prop

# SELinux
# Permissive via the kernel cmdline. The legacy MTK vendor rules violate the
# platform neverallows.
SELINUX_IGNORE_NEVERALLOWS := true

# Seccomp
# The MTK OMX blobs need extra syscalls in the mediacodec policy.
BOARD_SECCOMP_POLICY := $(DEVICE_PATH)/seccomp

# Graphics
BOARD_EGL_CFG := $(DEVICE_PATH)/configs/egl.cfg
USE_OPENGL_RENDERER := true

# Wi-Fi (MTK CONSYS MT6735 combo)
BOARD_WLAN_DEVICE := MediaTek
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := NL80211
WIFI_DRIVER_STATE_CTRL_PARAM := /dev/wmtWifi
WIFI_DRIVER_STATE_ON := 1
WIFI_DRIVER_STATE_OFF := 0

# Bluetooth
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_MTK := true
BOARD_BLUETOOTH_DOES_NOT_USE_RFKILL := true

# VINTF
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml

# Build workarounds
# The legacy blobs do not pass the prebuilt ELF dependency checks.
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_PREBUILT_ELF_FILES := true
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_VENDOR_PROPERTY_NAMESPACE := true