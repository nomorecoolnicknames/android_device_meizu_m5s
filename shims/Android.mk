LOCAL_PATH := $(call my-dir)

# Blob ABI shims, only for symbols the m5s blobs import.

# libfs_mgr.so for libnvram: Pie builds libfs_mgr as a static library only,
# so without this nvram_daemon fails to link and ccci_mdinit waits forever.
include $(CLEAR_VARS)
LOCAL_MODULE := libfs_mgr_m5s_shim
LOCAL_SRC_FILES := fs_mgr.c
LOCAL_POST_INSTALL_CMD := mkdir -p $(TARGET_OUT_VENDOR)/lib $(TARGET_OUT_VENDOR)/lib64 \
    && ln -sf libfs_mgr_m5s_shim.so $(TARGET_OUT_VENDOR)/lib/libfs_mgr.so \
    && ln -sf libfs_mgr_m5s_shim.so $(TARGET_OUT_VENDOR)/lib64/libfs_mgr.so
LOCAL_MULTILIB := both
LOCAL_PROPRIETARY_MODULE := true
LOCAL_MODULE_TAGS := optional
include $(BUILD_SHARED_LIBRARY)

# No-op stubs for the MTK voice-unlock symbols audio.primary.mt6753.so
# imports from android::AudioSystem. Applied through TARGET_LD_SHIM_LIBS.
include $(CLEAR_VARS)
LOCAL_MODULE := libshim_audio_m5s
LOCAL_SRC_FILES := audio_voiceunlock.c
LOCAL_MULTILIB := both
LOCAL_PROPRIETARY_MODULE := true
LOCAL_MODULE_TAGS := optional
LOCAL_SHARED_LIBRARIES := libc
include $(BUILD_SHARED_LIBRARY)
