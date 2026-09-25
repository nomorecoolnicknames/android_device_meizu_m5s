# HWC1 implementation using the matching native 3.18 display-session UAPI.
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := hwcomposer.mt6753
LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_MODULE_TAGS := optional
# The composer passthrough runs in a vendor process, so the module must be in
# /vendor/lib*/hw.
LOCAL_VENDOR_MODULE := true
LOCAL_MULTILIB := both
LOCAL_SRC_FILES := forge_hwc.c
LOCAL_C_INCLUDES := $(LOCAL_PATH)
LOCAL_SHARED_LIBRARIES := liblog libdl
LOCAL_CFLAGS := -Wall -Wno-unused-parameter -DLOG_TAG=\"forge-hwc\"
include $(BUILD_SHARED_LIBRARY)
