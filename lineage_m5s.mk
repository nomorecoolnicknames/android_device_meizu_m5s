# lineage_m5s — LineageOS 16.0 product for the Meizu M5s (M1612, MT6753, arm64).
# Donor: lineage_m5c.mk @77e62e0.

# This product owns Pie-specific HAL modules and packaging. Fail before module
# selection if a cloud worker accidentally combines it with another platform.
ifneq ($(PLATFORM_SDK_VERSION),28)
$(error lineage_m5s requires LineageOS 16.0 / Android SDK 28)
endif

# arm64: inherit core_64_bit before the phone stack so core_minimal doesn't
# lock us into ro.zygote=zygote32 (m681/m95/m5c ordering lesson).
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)
$(call inherit-product, device/meizu/m5s/device.mk)

DEVICE_PACKAGE_OVERLAYS += device/meizu/m5s/overlay

PRODUCT_NAME := lineage_m5s
PRODUCT_DEVICE := m5s
PRODUCT_BRAND := meizu
PRODUCT_MANUFACTURER := Meizu
PRODUCT_MODEL := M5s
PRODUCT_RELEASE_NAME := m5s
# m1612 is the model number (stock ro.product.model family, 15.1 tree).
TARGET_OTA_ASSERT_DEVICE := m5s,m1612,M5s
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_NAME=lineage_m5s \
    PRODUCT_DEVICE=m5s \
    TARGET_DEVICE=m5s

# Pie: vendor/lineage does not default LINEAGE_BUILD from TARGET_DEVICE.
LINEAGE_BUILD := m5s

# The m5s shipped Flyme 6 on Android 6.0 (FACT: probe fingerprint
# Meizu/meizu_M5s/M5s:6.0/MRA58K/1551951703) — the blobs are API 23.
# Stage A: real vendor partition WITHOUT VNDK (see BoardConfig.mk).
PRODUCT_SHIPPING_API_LEVEL := 23
PRODUCT_FULL_TREBLE_OVERRIDE := false

# profman SIGBUSes deterministically on the m681/m5c build hosts; the
# boot-image profile is an optimisation, not a requirement (m5c/m681 lesson).
# TEMPORARY — revisit before any build meant for daily use.
PRODUCT_USE_PROFILE_FOR_BOOT_IMAGE := false

PRODUCT_GMS_CLIENTID_BASE := android-meizu

# Bring-up ADB defaults (m681/m5c pattern).  The first boot on E0 is headless
# (no panel driver in 4.9 yet), so adb is the ONLY way in: keep it open.
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.secure=0 \
    ro.debuggable=1 \
    ro.adb.secure=0 \
    persist.sys.usb.config=adb \
    persist.service.adb.enable=1
