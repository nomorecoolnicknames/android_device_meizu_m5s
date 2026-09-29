# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
# lineage_m5s.mk — product definition for the Meizu M5s (m5s, model M1612).

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
