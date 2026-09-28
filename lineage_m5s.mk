# Copyright (C) 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
# m5s: isolated LineageOS 18.1 / Android 11 staging product.
# Derived only from this board's lineage-20-treble tree; see BRINGUP_STATE.md
# for original commits, board evidence and unresolved build/runtime gates.

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

$(call inherit-product, device/meizu/m5s/device.mk)

$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_m5s
PRODUCT_DEVICE := m5s
PRODUCT_BRAND := Meizu
PRODUCT_MANUFACTURER := Meizu
PRODUCT_MODEL := M5s

PRODUCT_GMS_CLIENTID_BASE := android-meizu

TARGET_BOOT_ANIMATION_RES := 720

PRODUCT_BUILD_PROP_OVERRIDES += \
    TARGET_DEVICE=m5s \
    PRODUCT_NAME=m5s
# Prevent accidentally evaluating this target against a different release.
ifneq ($(PLATFORM_SDK_VERSION),30)
$(error This device branch requires Android 11 / PLATFORM_SDK_VERSION=30)
endif
