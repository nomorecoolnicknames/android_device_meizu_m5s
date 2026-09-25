# /vendor/firmware -> etc/firmware symlink. The modem image in
# /vendor/etc/firmware is not on the kernel or ueventd firmware search paths;
# the link adds it without moving it away from where ccci_mdinit looks.
# Created only if nothing installs a real /vendor/firmware directory.
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := forge_vendor_firmware_link
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_TAGS := optional
LOCAL_PROPRIETARY_MODULE := true
LOCAL_SRC_FILES := firmware-link.txt
LOCAL_MODULE_PATH := $(TARGET_OUT_VENDOR)/etc/forge
LOCAL_POST_INSTALL_CMD := if [ ! -d $(TARGET_OUT_VENDOR)/firmware ]; then ln -sfn etc/firmware $(TARGET_OUT_VENDOR)/firmware; fi
include $(BUILD_PREBUILT)
