# Meizu M5s (m5s)

Device tree for the Meizu M5s for LineageOS 18.1.

## Specifications

| | |
|---|---|
| Model | M1612 |
| SoC | MediaTek MT6753 |
| CPU | 8x ARM Cortex-A53 |
| GPU | Mali-T720 MP3 |
| RAM | 3 GB |
| Display | 720x1280, 320 dpi |

## Status

- A complete ROM built from this branch has not been tested on the device.
- Boot, display, touch, Bluetooth, mobile network, camera, audio, sensors, power: untested
- Wi-Fi: untested
- GPS: service disabled until its vendor dependencies are resolved
- Fingerprint: Goodix HAL not integrated
- SELinux: permissive
- Vendor ABI compatibility shims: partial

## Building

```sh
repo init -u https://github.com/LineageOS/android.git -b lineage-18.1
repo sync
source build/envsetup.sh
breakfast m5s
brunch m5s
```

Required external inputs:

- The matching vendor tree (`vendor/meizu/m5s`) with firmware and platform compatibility changes.
- A prebuilt `prebuilt-kernel/Image.gz-dtb` matching [EXPECTED.txt](prebuilt-kernel/EXPECTED.txt);
  the build rejects a missing or different kernel. Kernel source:
  [Linux 4.9 for the M5s](https://github.com/nomorecoolnicknames/mtk-t-alps-release-q0-kernel-4.9-lc/tree/m5s-linux-4.9) (no tested boot image yet).
- The audio configs `configs/audio/audio_effects.xml`, `audio_policy_configuration.xml` and
  `a2dp_audio_policy_configuration.xml`, which are not included in this tree.
