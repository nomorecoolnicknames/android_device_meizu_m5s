# m5s: Android 13 source checkpoint, 2026-09-28

Category: **PROPER-FIX** (restore a missing source-built dependency).

## Patch history

- Hypothesis: vendor audio cannot link without `libtinycompress.so` installed.
- Evidence: `readelf -d` on this board's proprietary `vendor/lib{,64}/hw/audio.primary.mt6753.so`
  reports DT_NEEDED `libtinycompress.so`; neither vendor blob list installs it.
  Current `/srv/forge/android/los20/external/tinycompress` HEAD `d155968` uses
  `device_kernel_headers`, defined in `build/soong/Android.bp:49` as `kernel_headers`.
  `cc/kernel_headers.go:27-35` exports configured header directories; it does not
  invoke `generated_kernel_includes`. The optional extended-compress defaults
  only set a cflag (`vendor/lineage/build/soong/Android.bp:342-358`).
- Files / why: `device.mk` restores `libtinycompress` and corrects a stale explanation
  that confused the current header module with `generated_kernel_headers`.
- Expected next marker: built vendor lib and lib64 copies satisfy the audio DT_NEEDED;
  this alone does not imply the HAL wrapper or kernel offload ioctls work.
- Rollback condition: current pinned module graph actually reintroduces a header
  generation dependency or post-link inspection shows ABI mismatch; fix the cause
  instead of marking omitted audio dependencies as ready.
- Verification: `readelf -d <proprietary>/vendor/lib64/hw/audio.primary.mt6753.so`;
  inspect the exact platform module above; build `libtinycompress` in the pinned
  Forge recipe, then ELF-check both vendor ABIs. Build not run here.

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
