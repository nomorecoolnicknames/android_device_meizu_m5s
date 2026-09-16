#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
# lineage_m5s.mk — product definition for the Meizu M5s (m5s, model M1612).
#
# SoC MT6753, octa Cortex-A53 arm64, 3 GB RAM, 720x1280 (xhdpi, density 320),
# 32 GB eMMC.  FACT (live probe of the stock Flyme 6.3.1.0G install,
# /srv/forge/android/m5s/probe/):
#   cpuinfo.txt   AArch64 Processor rev 4, CPU part 0xd03 (Cortex-A53),
#                 Features: fp asimd evtstrm aes pmull sha1 sha2 crc32
#   build.prop    ro.board.platform=mt6753, ro.sf.lcd_density=320
#   getprop.txt   ro.hardware=mt6735
#   display.txt   Physical size: 720x1280
#   partitions.txt  mmcblk0 = 30 535 680 KiB (32 GB class)
#
# Runtime target is the forge 4.9.188-m5s+ prebuilt kernel (BoardConfig.mk).
#
# STATUS, stated once so no reader has to infer it: this tree has NEVER been
# flashed.  The 4.9 "E0" images (boot49-m5s-e0.img / -poll.img, 2026-08-27)
# were produced offline and never written to the device
# (FACT: /srv/forge/android/m5s/BRINGUP_STATE.md:4 — "Телефон не подключался
# — всё проверено статически/сборкой, прошивка НЕ делалась").
# Buildable != working.  This makefile produces a parseable product, not a
# proven boot.
#
# Deliberately NOT set here:
#   PRODUCT_SHIPPING_API_LEVEL — leaving it undefined keeps PRODUCT_USE_VNDK
#   false (build/make/core/config.mk:721-737), which is what keeps this
#   Marshmallow-vintage MTK blob set loadable at all.  See BoardConfig.mk
#   "Vendor partition / VNDK".

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from m5s device
$(call inherit-product, device/meizu/m5s/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_m5s
PRODUCT_DEVICE := m5s
PRODUCT_BRAND := Meizu
PRODUCT_MANUFACTURER := Meizu
PRODUCT_MODEL := M5s

PRODUCT_GMS_CLIENTID_BASE := android-meizu

# 720x1280 panel -> 720p boot animation.
TARGET_BOOT_ANIMATION_RES := 720

PRODUCT_BUILD_PROP_OVERRIDES += \
    TARGET_DEVICE=m5s \
    PRODUCT_NAME=m5s
