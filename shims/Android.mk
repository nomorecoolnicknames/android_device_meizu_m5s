LOCAL_PATH := $(call my-dir)

# Blob ABI shims for the m5s.  Only what THIS blob set needs (readelf over the
# stock extraction, 2026-09-25); the m5c shims for __pthread_gettid (vcodec),
# ifc_ipv6_trigger_rs (mtk-ril) and the Gen-N mnld mutex were dropped because
# no m5s blob imports those symbols.

# libfs_mgr.so stub for libnvram (port of device/meizu/m95/shims via m5c).
# FACT: vendor/lib{,64}/libnvram.so of the m5s set have DT_NEEDED libfs_mgr.so.
# Pie builds libfs_mgr as a static library only, so without this stub
# nvram_daemon dies at the linker and ccci_mdinit waits forever on
# service.nvram_init.
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

# libshim_audio_m5s — no-op stubs for the MTK voice-unlock statics that
# audio.primary.mt6753.so imports from android::AudioSystem.  FACT: the m5s HAL
# imports 7 of them (both ABIs); all 7 are among the 8 stubs of
# audio_voiceunlock.c (the m5c source, unchanged).  Paired in BoardConfig.mk.
include $(CLEAR_VARS)
LOCAL_MODULE := libshim_audio_m5s
LOCAL_SRC_FILES := audio_voiceunlock.c
LOCAL_MULTILIB := both
LOCAL_PROPRIETARY_MODULE := true
LOCAL_MODULE_TAGS := optional
LOCAL_SHARED_LIBRARIES := libc
include $(BUILD_SHARED_LIBRARY)
