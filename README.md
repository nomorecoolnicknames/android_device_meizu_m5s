# Meizu M5s (m5s)

Device tree for the Meizu M5s for LineageOS 16.0.

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
- Kernel: source-built Linux 3.18.19 with the Yassy panel, FocalTech touch and DTB; boot untested
- Display: source-built HWC 1.1 composer (`hwcomposer/`); it must run as a 64-bit process,
  because the kernel does not translate 32-bit display ioctls
- Wi-Fi, Bluetooth, mobile network, camera, audio, sensors, GPS, power: untested
- Fingerprint: Goodix HAL not integrated
- SELinux: permissive

## Building

```sh
repo init -u https://github.com/LineageOS/android.git -b lineage-16.0
repo sync
source build/envsetup.sh
breakfast m5s
brunch m5s
```

Required external inputs:

- The matching vendor tree (`vendor/meizu/m5s`) with firmware and platform compatibility changes.
- A prebuilt `prebuilt-kernel/Image.gz-dtb` (MT6753 Linux 3.18.19, `m5s_defconfig`) matching
  [EXPECTED.txt](prebuilt-kernel/EXPECTED.txt); the build rejects a missing or different kernel.
- The stock-derived `rootdir/init.mt6735.usb.rc`, whose redistribution terms are not established.
- The key layouts `keylayout/ACCDET.kl`, `fp-keys.kl` and `gf-keys.kl`, which are not included
  in this tree.

A separate, experimental [Linux 4.9 port](https://github.com/nomorecoolnicknames/mtk-t-alps-release-q0-kernel-4.9-lc/tree/m5s-linux-4.9)
is not used by this branch.
