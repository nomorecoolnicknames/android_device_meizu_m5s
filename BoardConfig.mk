# Meizu M5s M1612 / MT6753 board configuration for LineageOS 16.0.
# Native Linux 3.18 kernel and own DTB are supplied separately; see README.md.

DEVICE_PATH := device/meizu/m5s

# Architecture — arm64, 8x Cortex-A53 in two clusters (MT6753).
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := cortex-a53

TARGET_2ND_ARCH := arm
# armv8-a, not armv7-a-neon: Pie combo makefiles ignore armv7-a-neon on an
# armv8-a primary (m95/m5c lesson).
TARGET_2ND_ARCH_VARIANT := armv8-a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a53
TARGET_USES_64_BIT_BINDER := true

# Platform.  ro.board.platform and ro.hardware are DIFFERENT strings here and
#   ro.board.platform=mt6753  -> HAL modules *.mt6753.so
#   androidboot.hardware=mt6735 -> init.mt6735.rc, fstab.mt6735
TARGET_BOARD_PLATFORM := mt6753
TARGET_BOOTLOADER_BOARD_NAME := mt6753
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true
BOARD_NAME := m5s
BOARD_USES_MTK_HARDWARE := true
MTK_HARDWARE := true

BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 androidboot.selinux=permissive androidboot.hardware=mt6735
BOARD_KERNEL_BASE := 0x40000000
BOARD_KERNEL_OFFSET := 0x00080000
BOARD_RAMDISK_OFFSET := 0x04000000
BOARD_KERNEL_TAGS_OFFSET := 0x0e000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_MKBOOTIMG_ARGS := --kernel_offset $(BOARD_KERNEL_OFFSET) --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --tags_offset $(BOARD_KERNEL_TAGS_OFFSET) --board 1551951703

TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
# Source-built MT6753 kernel 3.18.19, ReMeizu commit 6a4373fd09b75f1ca4025a9311a2c5b97cb810f6.
# Own Yassy panel, FocalTech, DTB and ashmem are compiled and linked.
# Driver binding, boot and physical component operation remain unverified.
TARGET_KERNEL_SOURCE :=
TARGET_KERNEL_CONFIG :=
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt-kernel/Image.gz-dtb
BOARD_KERNEL_IMAGE_NAME := Image.gz-dtb

# Prebuilt kernel gate (m5c pattern): the build stops if the file in
# prebuilt-kernel/ does not match EXPECTED.txt.  It proves "image == tree",
# NOT "tree == the kernel you want" — see tools/check_prebuilt_kernel.sh.
forge_kernel_check := $(shell $(DEVICE_PATH)/tools/check_prebuilt_kernel.sh \
        $(TARGET_PREBUILT_KERNEL) $(DEVICE_PATH)/prebuilt-kernel/EXPECTED.txt)
ifneq ($(strip $(forge_kernel_check)),)
$(error $(forge_kernel_check))
endif

# Partitions.  Two independent sources agree : the stock scatter
# m5s/stock/flyme/MT6753_M1612_scatter.txt and the live /proc/partitions
# system p23 1792 MiB, cache p24 400 MiB, userdata p25, custom p17 512 MiB.
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

# --- Treble stage A (m5c/m681 pattern) --------------------------------------
# /vendor is a REAL partition: custom = mmcblk0p17, exactly 512 MiB.
# "179 17 524288 mmcblk0p17"; and the stock install already mounts it as
# PRODUCT_FULL_TREBLE_OVERRIDE false + PRODUCT_SHIPPING_API_LEVEL 23
# (lineage_m5s.mk) keep VNDK OFF: Marshmallow blobs, VNDK is unreachable.
TARGET_COPY_OUT_VENDOR := vendor
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_PARTITION_SIZE := 536870912

# A-only — no slots, no dynamic partitions.
AB_OTA_UPDATER := false
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED := true

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/fstab.mt6735
TARGET_RECOVERY_PIXEL_FORMAT := BGRA_8888
TARGET_SCREEN_WIDTH := 720
TARGET_SCREEN_HEIGHT := 1280

# System props
TARGET_SYSTEM_PROP := $(DEVICE_PATH)/system.prop

# SELinux: permissive via cmdline for bring-up; Pie neverallows reject
# M-era MTK vendor rules (m5c/m681 pattern).
SELINUX_IGNORE_NEVERALLOWS := true

# Seccomp (MTK omx vendor policy; without it the omx service hits SIGSYS —
# m681 evidence).
BOARD_SECCOMP_POLICY := $(DEVICE_PATH)/seccomp

# Wi-Fi — MTK conn_soc (CONSYS), same control path as m5c/m681.
BOARD_WLAN_DEVICE := MediaTek
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_mt66xx
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_mt66xx
WIFI_DRIVER_STATE_CTRL_PARAM := /dev/wmtWifi
WIFI_DRIVER_STATE_ON := 1
WIFI_DRIVER_STATE_OFF := 0

# Bluetooth — same CONSYS.
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_MTK := true
BOARD_BLUETOOTH_DOES_NOT_USE_RFKILL := true

TARGET_LD_SHIM_LIBS += \
    /vendor/lib/hw/audio.primary.mt6753.so|/vendor/lib/libshim_audio_m5s.so \
    /vendor/lib64/hw/audio.primary.mt6753.so|/vendor/lib64/libshim_audio_m5s.so \
    /vendor/lib/libcam_utils.so|/vendor/lib/libmtkshim_gui.so \
    /vendor/lib64/libcam_utils.so|/vendor/lib64/libmtkshim_gui.so \
    /vendor/lib/libmtk_mmutils.so|/vendor/lib/libmtkshim_gui.so \
    /vendor/lib64/libmtk_mmutils.so|/vendor/lib64/libmtkshim_gui.so \
    /vendor/lib/libcam.client.so|/vendor/lib/libmtkshim_gui.so \
    /vendor/lib64/libcam.client.so|/vendor/lib64/libmtkshim_gui.so \
    /vendor/lib/libmmsdkservice.feature.so|/vendor/lib/libmtkshim_gui.so \
    /vendor/lib/libmmsdkservice.feature.so|/vendor/lib/libmtkshim_ui.so \
    /vendor/lib64/libmmsdkservice.feature.so|/vendor/lib64/libmtkshim_gui.so \
    /vendor/lib64/libmmsdkservice.feature.so|/vendor/lib64/libmtkshim_ui.so

BOARD_PROVIDES_LIBRIL := true
TARGET_SPECIFIC_HEADER_PATH := vendor/mediatek/include

# VINTF device manifest — without it HalDeviceManager decides there is no
# Wi-Fi vendor HAL and wlan0 never appears (m5c, measured 2026-09-03).
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml
