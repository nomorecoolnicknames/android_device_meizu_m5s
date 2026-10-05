# Meizu M5s · Android 9

Device configuration for **Meizu M5s (m5s, MT6753)**. Branch: **`lineage-16.0`**.

**Status:** development sources; a complete ROM built from this public branch has not been validated on the device.

## Components

**Source / integration** describes what this tree provides; **working status** describes tests, not file presence. Unverified does not mean unsupported hardware.

| Subsystem | Implementation / source | Source / integration | Working status |
|---|---|---|---|
| Boot / partitions | [Board configuration](BoardConfig.mk); [Kernel checksum](prebuilt-kernel/EXPECTED.txt) | Source-built native 3.18.19 `Image.gz-dtb` required | Not tested on this branch |
| Display / composition | [MTK HWC](hwcomposer/forge_hwc.c) | Native 3.18 eight-layer UAPI; selected composer must be ELF64/AArch64; vendor gralloc/GPU libraries required | Not tested on this branch |
| GPU | [Graphics packages and ABI integration](device.mk) | Vendor Mali userspace; kernel GPU driver lives in the kernel tree | Not tested on this branch |
| Touch / buttons | [Input integration](device.mk) | Kernel input driver plus Android layouts | Not tested on this branch |
| Wi-Fi | [MTK Wi-Fi integration](wpa_supplicant_8_lib/mediatek_driver_cmd_nl80211.c) | MTK transport / firmware and supplicant integration | Not tested on this branch |
| Bluetooth | [HCI / vendor integration](bluetooth_hal/service.cpp) | Custom service or vendor interface | Not tested on this branch |
| Mobile network | [Radio packages and properties](device.mk) | RIL integration; proprietary modem firmware remains required | Not tested on this branch |
| Camera | [Camera packages / wrapper](device.mk) | Legacy vendor camera HAL; no complete open camera driver stack | Not tested on this branch |
| Audio output / microphone | [Audio integration](shims/audio_voiceunlock.c) | Vendor primary HAL with compatibility support | Not tested on this branch |
| Sensors | [Sensor services and permissions](device.mk) | Vendor sensor HAL; declared sensors still need individual tests | Not tested on this branch |
| GPS / GNSS | [GNSS integration](device.mk) | Legacy vendor GPS HAL | Not tested on this branch |
| Power / charging / suspend | [Power and health integration](device.mk) | Android services plus board-specific kernel drivers | Not tested on this branch |
| Fingerprint | [Feature / service integration](device.mk) | Goodix vendor components need HAL integration | Enrollment and unlock not validated |
| SELinux | [Security / boot settings](BoardConfig.mk) | Development configuration | Enforcing operation not validated |

## Native kernel

This branch selects the source-built MT6753 Linux 3.18.19 kernel at [`6a4373fd`](https://github.com/ReMeizu/android_kernel_meizu_mt6753/commit/6a4373fd09b75f1ca4025a9311a2c5b97cb810f6). Kernel source is on [`m5s-3.18-native`](https://github.com/ReMeizu/android_kernel_meizu_mt6753/tree/m5s-3.18-native); board config is `m5s_defconfig`. Own Yassy panel, FocalTech touch, DTB and ashmem are included in that kernel. This selection is separate from the experimental Linux 4.9 port.

## Building

Use a matching LineageOS 16.0 source checkout, with this tree at `device/meizu/m5s`. Required inputs:

- The matching vendor tree, firmware, board configuration files and platform compatibility changes. This repository alone is not a complete ROM checkout.
- A board-specific `prebuilt-kernel/Image.gz-dtb` matching [EXPECTED.txt](prebuilt-kernel/EXPECTED.txt). The kernel binary is not included; [the checksum check](tools/check_prebuilt_kernel.sh) rejects a missing or different input.
- The stock-derived `rootdir/init.mt6735.usb.rc` is a separate input whose redistribution terms have not been established here. The build selects legacy android_usb with FunctionFS for Pie ADB (`sys.usb.configfs=0`); generic Android init owns none/adb/accessory modes.
- Referenced device files absent from this export, including `keylayout/ACCDET.kl`, `keylayout/fp-keys.kl`, `keylayout/gf-keys.kl`. Restore the matching inputs before building.

With those inputs in place, the product is:

```sh
source build/envsetup.sh
lunch lineage_m5s-userdebug
mka bacon
```

The HWC source uses the native 3.18 panel dimensions in millimetres, with matching DPI conversion and a fallback for unspecified panel dimensions. The full HWC C source compiled to ARM and AArch64 objects with the selected Android compiler commands; linking and runtime operation remain unverified.

The selected Android 9 checkout passes build-graph preparation. Full-ROM artifact acceptance and physical operation are still pending. Header checks for both ARM ABIs do not establish ARM32 ioctl compatibility; the selected native kernel forwards compat ioctl without structure translation, so the selected composer must be 64-bit.

## Next steps

Complete missing build inputs, produce a reproducible ROM, then test boot and each subsystem on this device. The separate [M5s Linux 4.9 work](https://github.com/nomorecoolnicknames/mtk-t-alps-release-q0-kernel-4.9-lc/tree/m5s-linux-4.9) has compiled kernel images, but has not produced a tested M5s boot image.

The [ReMeizu overview](https://github.com/nomorecoolnicknames/remeizu/blob/main/PROJECT_STATUS.md) tracks the whole device family; the [source index](https://github.com/nomorecoolnicknames/remeizu/blob/main/SOURCE_INDEX.md) links related device, common and kernel trees.

## Credits

Based on Android, CyanogenMod / LineageOS and MediaTek device support, with contributors retained in Git history. Keep the original copyright and license notices. Vendor firmware and libraries are separate inputs with their own licenses.
