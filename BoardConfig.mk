# Meizu M5s / M1612, MT6753, eight Cortex-A53 cores and 3 GB RAM.
# LineageOS 16.0 uses the custom partition as /vendor without VNDK.

DEVICE_PATH := device/meizu/m5s

# Architecture — arm64, 8x Cortex-A53 in two clusters (MT6753).
# FACT: probe/cpuinfo.txt "CPU part 0xd03", Features include aes/pmull/sha1/sha2/crc32.
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
# both matter (FACT, probe/build.prop + probe/bootargs.txt):
#   ro.board.platform=mt6753  -> HAL modules *.mt6753.so
#   androidboot.hardware=mt6735 -> init.mt6735.rc, fstab.mt6735
TARGET_BOARD_PLATFORM := mt6753
TARGET_BOOTLOADER_BOARD_NAME := mt6753
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true
BOARD_NAME := m5s
BOARD_USES_MTK_HARDWARE := true
MTK_HARDWARE := true

# Kernel / boot.img geometry.
# FACT (header of the stock Flyme 6.3.1.0G boot.img AND of boot49-m5s-e0.img):
#   kernel 0x40080000, ramdisk 0x44000000, second 0x40f00000, tags 0x4e000000,
#   page 2048, header v0.  base 0x40000000 + the offsets below reproduce them.
# --board: the stock header name is "1551951703" (the Flyme build id, same
# number as the probe fingerprint).  The E0 image carries an empty name and was
# never flashed, so whether this LK checks the field is UNKNOWN; the stock value
# is the one LK has provably accepted.  (The LOS 20 tree writes "m5s" — that
# value has no evidence behind it and is not used here.)
# androidboot.hardware=mt6735 is also appended by LK (probe/bootargs.txt);
# stating it here keeps init independent of the loader.
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 androidboot.selinux=permissive androidboot.hardware=mt6735
BOARD_KERNEL_BASE := 0x40000000
BOARD_KERNEL_OFFSET := 0x00080000
BOARD_RAMDISK_OFFSET := 0x04000000
BOARD_KERNEL_TAGS_OFFSET := 0x0e000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_MKBOOTIMG_ARGS := --kernel_offset $(BOARD_KERNEL_OFFSET) --ramdisk_offset $(BOARD_RAMDISK_OFFSET) --tags_offset $(BOARD_KERNEL_TAGS_OFFSET) --board 1551951703

TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
# The 4.9 prebuilt requires the matching stock M5s DTB.
# Panel/touch support and second-cluster power management remain board-specific.
# The HWC disp_session ioctl definitions must match the selected kernel.
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

# Partitions.  Two independent sources agree (FACT): the stock scatter
# m5s/stock/flyme/MT6753_M1612_scatter.txt and the live /proc/partitions
# (m5s/probe/partitions.txt): boot p7 16 MiB, recovery p8 32 MiB,
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
# FACT: scatter custom 0x07a00000..0x27a00000; probe/partitions.txt
# "179 17 524288 mmcblk0p17"; and the stock install already mounts it as
# "/custom ext4" (probe/proc_mounts.txt) — a live filesystem, not free space.
# The vendor blob set is 240 MiB / 507 files (M5S_LOS20_TREE.md §3), so it fits.
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

# Vendor-blob ABI shims — only the pairs this blob set provably needs.
# Measured with readelf over vendor/meizu/m5s/proprietary/vendor (2026-09-25),
# not copied from the m5c list:
#  - audio.primary.mt6753.so (both ABIs) imports 7 MTK AudioSystem::*VoiceUnlock*
#    statics AOSP never had; all 7 are among the 8 stubs of shims/audio_voiceunlock.c.
#  - camera closure: libcam_utils (GraphicBuffer ctors), libmtk_mmutils
#    (GraphicBuffer(w,h,fmt,usage)), libmmsdkservice.feature (createBufferQueue
#    with IGraphicBufferAlloc, BufferItemConsumer ctor/setName,
#    GraphicBuffer(ANativeWindowBuffer*,bool)), libcam.client (GraphicBuffer
#    ctor) — all exported by vendor/mediatek/symbols/{gui,ui}.cpp @6dd7c54b.
# NOT carried from m5c, with the reason (FACT, same readelf pass):
#  - libshim_vcodec: no m5s blob imports __pthread_gettid;
#  - libmtkshim_icu for mtk_agpsd: the m5s mtk_agpsd imports no ICU at all
#    (only libdrmmtkutil.so wants ICU *_55 — DRM, not boot path; open item);
#  - libmnld_shim: written for the Gen-N libmnl double mutex destroy; this mnld
#    is M-era (no mtk_hal2mnl socket strings) — wire it only on evidence.
# The linker realpath()s consumers, so 32- and 64-bit are separate pairs.
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

# --- Telephony via the MTK Oreo HIDL RIL (vendor/mediatek/ril), m5c recipe ---
# FACT (readelf 2026-09-25): the m5s mtk-ril.so (both ABIs) exports
# RIL_InitSocket and no RIL_Init — the AOSP rild can never host it, exactly as
# on the m5c.  librilmtk.so exports the four MTK entries the m5c recipe relies
# on (IMS_RIL_onUnsolicitedResponseSocket, IMS_isRilRequestFromIms,
# IMS_RILA_register, RIL_UpdateToVT).  mtk-ril's MTK libnetutils imports
# (ifc_ccmni_md_cfg, ifc_set_txq_state, ifc_disable, ifc_remove_default_route,
# ifc_reset_connections) are all defined by system/core @e7f32da (the gunwest
# platform state this tree is built against).
BOARD_PROVIDES_LIBRIL := true
TARGET_SPECIFIC_HEADER_PATH := vendor/mediatek/include

# VINTF device manifest — without it HalDeviceManager decides there is no
# Wi-Fi vendor HAL and wlan0 never appears (m5c, measured 2026-09-03).
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml
