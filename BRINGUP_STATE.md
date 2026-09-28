# m5s: Android 11 staging, 2026-09-28

Category: **PROPER-FIX** (release-specific product wiring). Not a working ROM.
Derived from this board's own A13 `lineage-20-treble` commit `4ae326e`; no sibling
board image, panel, touch, fstab, partition size or calibration was substituted.
Original detailed board provenance remains in that parent commit.

FACT: 720x1280, boot 16 MiB, recovery 32 MiB, system 1792 MiB; vendor/custom 512 MiB; arm64 plus arm userspace. Kernel: 4.9.188 E0, sha256 b605251322d23032b7866d73ecf1222131d6443eabc6c769f7781d822c12074c; never hardware-validated.
M2 Note historical boot does not establish working MD1: source
`ccci_util_lib_fo.c:524-530` clears MD_SYS1 with `m2note.disable_md1=1`.
Current product cmdline does not set that isolation flag.

## Patch history

- Hypothesis: an absent A11 target and A13-only service identifiers prevent a
  meaningful A11 source/build lane before any board runtime test.
- Evidence: selected platform is `/srv/forge/android/nx549j/rom-nx549j-lineage-18.1-tissot`,
  SDK literal 30, manifest Android 11 r46 / lineage-18.1. Actual modules are
  Keymaster 3.0 (`hardware/interfaces/keymaster/3.0/default/Android.mk`), ClearKey 1.3
  (`frameworks/av/drm/mediadrm/plugins/clearkey/hidl/Android.bp:100`), Wi-Fi 1.4
  implementation service named `android.hardware.wifi@1.0-service`.
  Supplicant `android.config:332` enables HIDL; Android.mk:1516 chooses 1.3.
- Files / why: `device.mk` selects those actual modules plus the vendor tinycompress
  dependency; `manifest.xml` declares Keymaster 3.0; own Wi-Fi rc declares HIDL
  ISupplicant 1.0..1.3 (no A13 AIDL name). `lineage_m5s.mk` rejects non-SDK30 builds.
  `BoardConfig.mk` keeps the exact prebuilt but provides this board's kernel source
  for A11 `generated_kernel_headers`; `TARGET_FORCE_PREBUILT_KERNEL=true` preserves
  the selected boot image (vendor/lineage/build/tasks/kernel.mk:168-184).
- Kernel header source: /srv/forge/android/m5s/kernel49 @ba33cd9dbb88995da0dbd5cc6c8c67d653d686c1.
  Recipe must pin the actual working tree, including local changes; this source
  path is an explicit read-only overlay in `targets/android/m5s-a11.json`.
- Expected next marker: SDK30 product parse and headers generation succeed, then
  both audio dependencies link; HIDL service names agree with their manifests.
- Rollback condition: actual SDK30 Make/Soong or VINTF reports incompatible modules;
  keep the failing evidence and repair the specific module, not relaxed checks.
- Verification: fleet source checker for `m5s-a11.json`, XML parse; then Forge-only
  `m nothing`, `libtinycompress`, selected HAL targets. No build completed yet.

## Open board blockers

E0 kernel has never demonstrated a boot, and M5s panel/touch support is incomplete. Stock 3.18 board devices are not established by sharing MT6753 with M2 Note. Do not replace its image with M2 Note or call A11/13 boot-ready.
Graphics/GPU, camera, RIL, SELinux and vendor symbol closure remain unvalidated.

## Validation boundary

Source inspection and hash checks only on 2026-09-28. No matching immutable Android
11/13 build image is currently available to this lane; Docker was not launched.
No phone was accessed. No ROM image was produced or booted. `m nothing` and an
artifact manifest with identity-bound runtime evidence remain required.

## Next falsifiable gates

1. Pin the platform project revisions and the exact source/blob/header inputs in
   a Forge ephemeral recipe; output only under `/mnt/ramdisk` with a unique OUT.
2. Run product parse, selected HAL modules, then image targets when RAM is reserved.
3. Verify ELF closure, VINTF, boot header and raw artifact hashes before a separately
   authorized test. Static file existence is not module ABI or board readiness.
4. Never inspect `/proc/aed/current-*` on M2 Note. Use preserved host logs / expdb.

## Product copy destination ownership (PROPER-FIX)

The shared source preflight found 4 duplicate destinations in this product.
Android build/make/core/Makefile:66-89 retains the first destination and records
later entries as ignored. This can silently ignore a board's intended config.
The four duplicate device copy rules (audio_device.xml, thermal.conf,
thermal.off.conf, agps_profiles_conf2.xml) are removed. Existing stock vendor
sources remain authoritative; no thermal thresholds were edited. The alternative
device config files are retained for an evidence-based future comparison.
Expected marker: one PRODUCT_COPY_FILES source per destination. Rollback:
generated image differs from the documented selected board config or an additional
source owner is discovered. Verification: shared checker and post-build installed
file hashes; current source check does not prove image or runtime behavior.

## Public source checkpoint, 2026-09-29

Category: DIAGNOSTIC (publication and provenance only). The separate public export preserves original logical history with the filters and SHA mapping in PUBLICATION.json. Original private source repositories are unchanged. README.md now makes the omitted external build inputs visible at the repository entry point. Verification: full reachable-history audit, Git fsck, XML parsing and shell syntax checks; no compiler, phone or firmware mutation. Do not infer full ROM build or hardware success from publication. Rollback condition: any public payload violates the declared exclusion/privacy boundary; halt publication and review the offending content.
