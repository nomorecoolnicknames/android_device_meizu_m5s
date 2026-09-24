#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# BoardConfig.mk — Meizu M5s (m5s, M1612), MT6753, arm64, 3 GB RAM.
# LineageOS 20.0 (Android 13, SDK 33) skeleton.
#
# Method and layout follow the m5c lane
# (/srv/forge/android/meizu-fleet/trees/M5C_LOS20_TREE.md).  Every value is
# either a live measurement of this handset, a value from the LOS 15.1 tree
# that was built for it, or is explicitly labelled HYPOTHESIS.
#
# THE ONE THING TO KNOW FIRST: nothing in this tree has ever run on the
# hardware.  The m5s has never been flashed with a forge image
# (FACT: /srv/forge/android/m5s/BRINGUP_STATE.md:4).

DEVICE_PATH := device/meizu/m5s

# LineageOS kernel/soong plumbing (TARGET_LD_SHIM_LIBS, prebuilt-kernel
# handling, BoardConfigSoong export set).
include vendor/lineage/config/BoardConfigLineage.mk

# ---------------------------------------------------------------------------
# Architecture
# ---------------------------------------------------------------------------
# FACT (/srv/forge/android/m5s/probe/cpuinfo.txt, live stock Flyme):
#   "CPU part : 0xd03" = Cortex-A53, "CPU architecture: 8", 8 cores.
#   Features: fp asimd evtstrm aes pmull sha1 sha2 crc32
# Note the Features line: unlike the m5c's MT6737M, this SoC DOES carry the
# optional ARMv8.0 crypto extensions (aes/pmull/sha1/sha2).  That retires
# risk R11 of the m5c report for this device — a -march=armv8-a+crypto binary
# will not SIGILL here.
#
# ARMv8.1 is still forbidden: LSE atomics (LDADD/SWP/CAS) are not implemented
# on Cortex-A53 and trap.  FACT (build/soong/cc/config/arm64_device.go:29-42,
# 54-58 in this tree): armv8-a -> -march=armv8-a (no +lse), cortex-a53 ->
# -mcpu=cortex-a53, and grep over build/soong/cc/config/*.go finds no
# "outline-atomics"/"lse".  FACT (build/soong/android/arch_list.go:21-28):
# "armv8-a" is a legal arm64 AND arm variant in Android 13.
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

# ---------------------------------------------------------------------------
# Kernel — PREBUILT, never rebuilt from this tree
# ---------------------------------------------------------------------------
# FACT: prebuilt-kernel/Image.gz-dtb is a byte copy of the "E0" build output
#   source   /srv/forge/android/m5s/stock/flyme/work/Image.gz-m5sdtb
#   sha256   b605251322d23032b7866d73ecf1222131d6443eabc6c769f7781d822c12074c
#   md5      5d29a4c3d2a1bc7008f763ced69f9626
#   size     7 068 583 B
#   version  Linux version 4.9.188-m5s+ (n8n@n8nagent) #1 SMP PREEMPT
#            Thu Aug 27 19:45:57 MSK 2026
# and that sha256 is the one recorded by the build itself in
# /home/n8n/m5s_out/e0/SHA256SUMS.txt, so the copy is provably the artifact
# that went into boot49-m5s-e0.img (sha256 898544a8…).
#
# Provenance of the source: worktree /srv/forge/android/m5s/kernel49, branch
# forge/mt6753-49 off subsys49 @ cbefdf9f3, port commit ba33cd9db, defconfig
# m5s_defconfig (CONFIG_MACH_MT6735M=y, CONFIG_MACH_MT6753_M5S=y, NR_CPUS=8).
#
# eBPF — the question that decides whether Android 13 can run at all.
# FACT (/home/n8n/m5s_out/kernel49/.config, the config this very image was
# built from):
#   line 143  CONFIG_CGROUP_BPF=y
#   line 166  CONFIG_BPF=y
#   line 186  CONFIG_BPF_SYSCALL=y
#   line 1002 # CONFIG_BPF_JIT is not set     <- interpreter only, still works
# So netd's bpfloader has its syscall and its cgroup attach point natively,
# exactly as on the m5c 4.9.  This is the single hardest kernel prerequisite
# for A13 and this kernel passes it.
#
# BUT — and this is the largest single finding of this lane, so it is written
# here and not only in the report:
#
# THE E0 KERNEL IS NOT YET AN ANDROID-13 KERNEL.  eBPF is necessary, not
# sufficient.  On 2026-09-16 the m5c lane rebuilt its own 4.9 from the same
# source commit with TEN config flags added specifically for A13
# (see device/meizu/m5c/BoardConfig.mk and
#  meizu-fleet/kernels/M5C_49_A13_CONFIG.md).  Those ten flags were checked
# one by one against the config this m5s image was built from
# (/home/n8n/m5s_out/kernel49/.config) on 2026-09-16.  FACT, verbatim:
#
#   # CONFIG_CPUSETS is not set          <- A13 task profiles / cgroup cpuset
#   # CONFIG_BLK_CGROUP is not set
#   # CONFIG_BPF_JIT is not set          <- interpreter works, low priority
#   # CONFIG_PSI is not set
#   # CONFIG_TMPFS_XATTR is not set
#   # CONFIG_TMPFS_POSIX_ACL is not set
#   # CONFIG_VETH is not set
#   # CONFIG_UNIX_DIAG is not set
#   # CONFIG_NETLINK_DIAG is not set
#   # CONFIG_PACKET_DIAG is not set
#   (CONFIG_PSI_DEFAULT_DISABLED does not appear at all — it is only offered
#    once PSI=y.)
#
# What IS already right in this config, also checked: CONFIG_CGROUP_BPF=y,
# CONFIG_BPF_SYSCALL=y, CONFIG_MEMCG=y, CONFIG_CGROUP_FREEZER=y,
# CONFIG_INET_DIAG=y, CONFIG_INET_UDP_DIAG=y, CONFIG_FUSE_FS=y,
# CONFIG_QUOTA=y, CONFIG_QFMT_V2=y.
#
# INFERENCE: before any first-boot attempt on Android 13 this prebuilt must be
# rebuilt from /srv/forge/android/m5s/kernel49 (branch forge/mt6753-49) with
# the same ten flags, exactly as the m5c lane did — and then this file, the
# EXPECTED.txt next to the image, and the report all have to be updated.
# Doing so does not change `m nothing`; it changes whether the device boots.
# Until then the prebuilt here is the honest artifact that exists, not the one
# that will ship.
#
# FACT (appended-DTB gate, re-run on the copy in this tree):
#   DTB tail at offset 7 001 413, 67 170 B,
#   sha256 a980f28052cdd11bc8bb523e468a1e2d6e0e13ba2b9fa7dbedeef9554de4252d
#   — byte-identical to /srv/forge/android/m5s/stock/flyme/work/m5s_stock.dtb,
#   i.e. the STOCK Flyme DTB, as the project rule demands.
#   Key counts inside that blob: "mt6753-mmc" = 2, "mediatek,msdc\0" = 0.
#   (On m5c the same gate reads mt6735m-mmc; the MT6753 stock DTB spells its
#   eMMC node compatible = "mediatek,mt6753-mmc" — FACT, m5s_stock.dts:21.)
#   A tree-built DTB would spell it "mediatek,msdc" and storage would not
#   probe (conn49 lesson, M5C_HANDOFF_20260824.md §2).
#
# Empty TARGET_KERNEL_SOURCE keeps vendor/lineage/build/tasks/kernel.mk on its
# prebuilt branch (kernel.mk:127-148).  It prints a "prebuilt kernel is
# DEPRECATED" warning; that is expected and is not an error.
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_HEADER_ARCH := arm64
TARGET_KERNEL_SOURCE :=
TARGET_KERNEL_CONFIG :=

# ---------------------------------------------------------------------------
# 2026-09-16: the A13-config kernel now exists AS A SECOND FILE, NOT INSTEAD
# ---------------------------------------------------------------------------
# The block above says the E0 prebuilt is not yet an Android-13 kernel and has
# to be rebuilt with ten config flags.  That rebuild is DONE.  It was placed
# NEXT TO E0, not over it, and E0 REMAINS THE DEFAULT.
#
# OWNER'S DECISION, stated as the reason and not as a guess: the E0 image has
# never been flashed (BRINGUP_STATE of the m5s repo, line 4).  Swapping the
# kernel before the very first boot would mix two unknowns — "does the MT6753
# 4.9 port boot at all" and "do the ten new flags break it".  So E0 boots
# first, as built; only after a CONFIRMED E0 boot is the switch below flipped.
#
# prebuilt-kernel/Image.gz-dtb      — E0, DEFAULT, unchanged since 2026-08-27
#   md5      5d29a4c3d2a1bc7008f763ced69f9626
#   sha256   b605251322d23032b7866d73ecf1222131d6443eabc6c769f7781d822c12074c
#   size     7 068 583 B
#   version  ... #1 SMP PREEMPT Thu Aug 27 19:45:57 MSK 2026
#
# prebuilt-kernel/Image.gz-dtb-a13  — same source commit + ten flags, NOT default
#   md5      0d8ec9c9a96c9f3c44f0cec3576c6779
#   sha256   7c9cedd37804534ac6f4ef142d36707c9faca9c7c6f244c73b9ae9e92fe8967c
#   size     7 110 851 B   (+42 268 B = +0,60 % over E0)
#   version  ... #2 SMP PREEMPT Wed Sep 16 20:55:16 MSK 2026
#
# FACT (origin of the -a13 file, every field reproducible):
#   worktree  /srv/forge/android/meizu-fleet/kernels/m5s-4.9-a13
#   branch    forge/m5s-49-a13  (repo /srv/forge/android/m5c/kernel-m5c-4.9-lc)
#   base      ba33cd9dbb88995da0dbd5cc6c8c67d653d686c1 — the E0 port commit
#             itself, on branch forge/mt6753-49.  PROVEN, not assumed:
#             (a) scripts/extract-ikconfig run ON THE SHIPPED E0 FILE gives a
#                 config identical to /home/n8n/m5s_out/kernel49/.config
#                 (diff 0 lines);
#             (b) `make O=<clean> m5s_defconfig` at ba33cd9db reproduces that
#                 same .config (diff 0 lines) — unlike the m5c lane, on m5s
#                 the committed defconfig IS the shipping config;
#             (c) `cat arch/arm64/boot/Image.gz <stock dtb 67 170 B>` of the
#                 E0 output reproduces the E0 prebuilt BYTE FOR BYTE.
#   defconfig arch/arm64/configs/m5s_a13_defconfig (new, commit 248f2801b;
#             savedefconfig of the built .config, round-trip verified
#             byte-for-byte).  m5s_defconfig is UNCHANGED.
#   toolchain /srv/forge/android/meizu_m6/
#             rom-lineage-15.1-meizu_m6-experimental/prebuilts/gcc/linux-x86/
#             aarch64/aarch64-linux-android-4.9  (__VERSION__ "4.9.x 20150123
#             (prerelease)" — matches the E0 banner; note this is a DIFFERENT
#             toolchain from the m5c lane's, whose __VERSION__ is "4.9
#             20150123" without the ".x")
#   recipe    make ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- \
#               O=/mnt/ramdisk/out-k-m5s-49-a13 drvgen     <- REQUIRED, see below
#             make ... O=/mnt/ramdisk/out-k-m5s-49-a13 -j12 Image
#             gzip -n -9 -c Image > Image.gz
#             cat Image.gz <stock dtb 67 170 B> > Image.gz-dtb-a13
#   artifacts /srv/forge/android/meizu-fleet/kernels/artifacts/m5s-4.9-a13/
#   report    meizu-fleet/kernels/M5S_49_A13_CONFIG.md
#
# TRAP, paid for here so the next person does not pay again: `make Image`
# alone FAILS in this tree with
#   arch/arm64/boot/dts/mediatek/k37mv1_bsp_k49.dts:503:36: fatal error:
#   k37mv1_bsp_k49/cust.dtsi: No such file or directory
# because arch/arm64/boot/Makefile makes $(obj)/Image depend on $(obj)/mtk.dtb,
# while cust.dtsi is generated by the drvgen rule that only hangs off the
# `dtbs` / `%.dtb` targets (scripts/drvgen/drvgen.mk).  build_kernel49.sh never
# hit it because it builds the default `all` target.  Run `make drvgen` first.
#
# FACT (the ten Android 13 flags, read by scripts/extract-ikconfig OFF THE
# SHIPPED -a13 FILE, not off a build directory):
#   CONFIG_CPUSETS=y          CONFIG_BLK_CGROUP=y      CONFIG_BPF_JIT=y
#   CONFIG_PSI=y              # CONFIG_PSI_DEFAULT_DISABLED is not set
#   CONFIG_TMPFS_XATTR=y      CONFIG_TMPFS_POSIX_ACL=y CONFIG_VETH=y
#   CONFIG_UNIX_DIAG=y        CONFIG_NETLINK_DIAG=y    CONFIG_PACKET_DIAG=y
# On m5s ALL TEN were off in E0 (on m5c two were already on).  The diff of the
# two images' embedded configs is exactly these ten lines plus seven
# kconfig-derived ones: PROC_PID_CPUSET=y, DEBUG_BLK_CGROUP=n,
# CGROUP_WRITEBACK=y, BLK_DEV_THROTTLING=n, CFQ_GROUP_IOSCHED=n,
# BPF_JIT_ALWAYS_ON=n, MTK_USER_SPACE_GLOBAL_CPUSET=n.  Zero source changes.
#
# FACT (ARMv8.0 discipline held): CONFIG_ARM64_LSE_ATOMICS is not set, and
# objdump -d of the new vmlinux (2 911 400 lines) contains ZERO
# ldadd/ldset/ldclr/ldeor/swp/cas/stadd instructions.  Cortex-A53 traps those.
#
# FACT (appended-DTB gate, re-run on the copy in this tree):
#   tools/check_appended_dtb.sh prebuilt-kernel/Image.gz-dtb-a13 -> OK,
#   dtb off=7 043 681 size=67 170 md5 9be87e7f729537994a50eebe9a836d71,
#   mt6753-mmc=2, mediatek,msdc=0 — the STOCK Flyme DTB byte for byte.
#   (The tree-built DTB this build also produced, arch/arm64/boot/mtk.dtb,
#   73 506 B, md5 954fceb0…, reads mediatek,msdc=2 / mt6753-mmc=0.  It is a
#   throwaway and is deliberately NOT what gets appended.)
#
# HYPOTHESIS, NOT verified: that EITHER kernel boots.  Neither has been
# flashed.  Falsification is the first flash of p7.
#
# ---- THE SWITCH.  To ship the A13 kernel, comment the E0 pair and -------
# ---- uncomment the -a13 pair.  Do this ONLY after E0 has booted. --------
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

# Boot geometry — taken from the header of the images that exist, not guessed.
# FACT, header dump of all three relevant boot images (2026-09-16):
#   stock/flyme/extracted/boot.img       kernel 0x40080000 ramdisk 0x44000000
#                                        tags 0x4e000000 page 2048
#   /home/n8n/m5s_out/e0/boot49-m5s-e0.img       same three addresses
#   /home/n8n/m5s_out/e0/boot49-m5s-e0-poll.img  same three addresses
# build_kernel49.sh reached those addresses with --base 0x40078000 and
# compensating offsets; the canonical decomposition below produces the SAME
# absolute addresses and is the form the m5c lane uses.  The MTK loader jumps
# exactly where the header says: on m5c, base 0x40078000 with the 14.1 offsets
# put the kernel 0x78000 off and it never ran at all.
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

# ---------------------------------------------------------------------------
# Partitions — A-only, no slots, no dynamic partitions
# ---------------------------------------------------------------------------
# FACT, two independent sources that agree exactly:
#  (1) the stock scatter /srv/forge/android/m5s/stock/flyme/MT6753_M1612_scatter.txt
#      (shipped inside update-6.3.1.0G.zip), and
#  (2) a live /proc/partitions readout from the stock install,
#      /srv/forge/android/m5s/probe/partitions.txt.
#
#   p6  para         512 KiB    p7  boot       16 MiB
#   p8  recovery      32 MiB    p10 expdb      10 MiB
#   p17 custom       512 MiB    p19 frp         1 MiB
#   p23 system      1792 MiB    p24 cache     400 MiB
#   p25 userdata  26.26 GiB     p26 flashinfo  16 MiB
#   mmcblk0 total 30 535 680 KiB = 29.12 GiB (32 GB class eMMC)
#
# The p-numbering is the scatter order and is confirmed twice over: expdb=p10
# matches the m5c layout (factbase §2.2) and frp=p19 matches the LOS 15.1
# tree's own correction note (docs/LOS15_DEVICE_TREE.md).
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

# A-only.
# HYPOTHESIS (not yet falsified either way on THIS handset): fastboot writes
# nothing here, as on the m5c.  The m5c evidence is hard (BRINGUP_STATE.md
# :3576-3586, "format for partition 'X' is not allowed" on boot/recovery/para);
# for the m5s there is no `fastboot getvar` in any document at all
# (factbase §2.3, open question 4).  Install path assumed to be TWRP + dd over
# by-name, which is what every other Meizu in this fleet needs.
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
