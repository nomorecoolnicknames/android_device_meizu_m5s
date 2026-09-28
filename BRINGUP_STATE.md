# m5s LOS16 cloud source checkpoint — 2026-09-28

Category: PROPER-FIX

Hypothesis: A cloud worker combining this product with another platform can reach misleading missing-module failures; an explicit SDK28 gate identifies the source mismatch at product selection.

Evidence: FACT: lineage_m5s.mk inherits vendor/lineage Pie configuration and this tree declares Pie HAL modules; targets/android/m5s-a9.json pins SDK28. There was no product-local version gate.

Files changed / why: lineage_m5s.mk: reject wrong platform before HAL/product selection. BRINGUP_STATE.md: source-only evidence and rollback.

Expected next marker: source export verifies all hashes, then Forge lunch lineage_m5s-userdebug and m nothing advances beyond product/Soong dependency selection with ALLOW_MISSING_DEPENDENCIES unset.

Rollback condition: SDK28 rejected, own libnvram collides with another module, or exported file hashes differ. Preserve failed evidence; fix source view ownership before compilation.

Verification: PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s cloud-los16/other-device-work -p 'test_*.py' -v (9 tests PASS); prepare_inputs.py m5s --output <new-private-directory>; full platform graph still requires Forge m nothing.

Identity boundary: selected kernel SHA256 b605251322d23032b7866d73ecf1222131d6443eabc6c769f7781d822c12074c. Kernel/config/DTS/boot geometry, blobs and runtime properties were not changed. No kernel decode, flash, boot or compile was performed; generated config/compiled DTB/runtime evidence are not claimed.

Source-view contract: only one selected Meizu device/vendor overlay is visible above the pinned platform. Other Meizu vendor Android.bp files must not be merged into this view.
