# vibrator.mt6753: the AOSP libhardware vibrator module, built under the
# platform name so hw_get_module finds it. It supports both the timed_output
# and the LED-class (/sys/class/leds/vibrator) kernel interfaces.
LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := vibrator.mt6753
LOCAL_MODULE_RELATIVE_PATH := hw
LOCAL_SRC_FILES := ../../../../hardware/libhardware/modules/vibrator/vibrator.c
LOCAL_C_INCLUDES := hardware/libhardware/include
LOCAL_SHARED_LIBRARIES := liblog libcutils
LOCAL_CFLAGS := -Wall -Werror
LOCAL_MULTILIB := both
LOCAL_PROPRIETARY_MODULE := true
LOCAL_MODULE_TAGS := optional
include $(BUILD_SHARED_LIBRARY)
