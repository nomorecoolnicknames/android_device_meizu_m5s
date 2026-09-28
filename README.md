# Public source publication — 2026-09-29

ReMeizu M5s, Android 9: actual development source history, published for review and contribution. **This source-only export is not a complete ROM build input or a flash-ready release.**

Read [PUBLICATION.md](PUBLICATION.md) and [the exact source/history map](PUBLICATION.json) first: proprietary binaries, prebuilt kernels and board payloads without established redistribution provenance are omitted. Historical notes below describe the original private build view, including external inputs; their file-presence statements do not override the publication exclusions. Existing per-file licenses are retained; unmarked files still need a licensing decision before inclusion in an approved open-source-only workload.

---

# device/meizu/m5s — LineageOS 16.0 (Android 9), ветка `lineage-16.0`

Meizu M5s (M1612, MT6753, 8×A53, 3 ГБ). Продукт `lineage_m5s` (`-userdebug`, `-eng`).
Метки — `/srv/forge/android/CLAUDE.md §2`. **Ничего из этого дерева не собиралось и не
запускалось на аппарате; на m5s вообще никогда ничего не прошивалось**
(`m5s/BRINGUP_STATE.md:4`). Сборка и прошивка — решение ведущего/владельца.

## 1. Происхождение

| Что | Откуда (FACT) |
|---|---|
| Структура, rc, Pie-обвязка (configfs, zygote в vendor-rc, RIL-рецепт, forge_hwc, шимы) | `device/meizu/m5c` @`77e62e0` (LOS 16 грузится на m5c), снимок `git archive`, первый коммит дерева |
| Разделы, экран, платформа, cmdline | проба живого стока `m5s/probe/`, scatter `m5s/stock/flyme/MT6753_M1612_scatter.txt`, заголовок стокового `boot.img` |
| Блобы | набор 15.1 (сток Flyme 6.3.1.0G, Android 6.0) + стоковый `libbt-vendor.so`; вендор — `a9-trees/m5s/vendor/meizu/m5s` |
| Конфиги медиа/аудио/термо, keylayout | дерево 15.1 m5s и стоковый `usr/keylayout` |
| Ядро | prebuilt 4.9.188-m5s+ #1 (E0), см. §3 |
| Платформа, против которой всё сверено | состояние ганвеста `/home/gun/m6rom16/rom` — `designs/a9-trees/gunwest-m6rom16-heads-20260925.txt` |

## 2. Отличия от донора m5c и почему

- **Платформа** `mt6753` (модули `*.mt6753`), `androidboot.hardware=mt6735` — FACT probe.
- **boot.img**: адреса те же, что у стока и E0 (`0x40080000/0x44000000/0x4e000000`, page 2048);
  `--board 1551951703` — имя из заголовка стокового образа (у E0 имя пустое, E0 не шился).
- **Разделы**: recovery 32 МиБ (p8), system 1792 МиБ (p23), userdata 28 197 781 504 (p25),
  custom p17 512 МиБ → `/vendor` (на стоке уже ext4 `/custom`) — scatter + `/proc/partitions`.
- **Шимы — только по замеру блобов m5s** (readelf 2026-09-25): VoiceUnlock-аудио 7/7,
  камерные GraphicBuffer-импорты, `libfs_mgr.so` для `libnvram.so`. Не перенесены
  vcodec/`ifc_ipv6_trigger_rs`/mnld-шимы m5c: у m5s нет таких импортов.
- **GNSS** — стоковый `gps.mt6753.so`: `mnld` m5s M-эпохи (нет строк `mtk_hal2mnl`),
  исходный Gen-N HAL m5c к нему не подходит.
- **BT** — 32-битный HIDL-сервис `…service.m5s`: `libbt-vendor.so` у m5s только 32 бит
  (стоковый `/system/lib/libbt-vendor.so`, sha256 `70a3ff31…a298`).
- **keystore/gatekeeper** — программные; TEE-блобы `*.mt6753.so` исключены (§5, H-KM).
- **Аудио-HAL сервис объявлен явно**: у m5c @77e62e0 его нет ни в одном makefile.
- **hwui**: `debug.hwui.use_partial_updates=false` — имя из frameworks/base ганвеста
  (`Properties.h:152`); строка донора `debug.hwui.partial_updates` — мёртвая (REJECTED).
- **vendor/mediatek**: m5s не входит в фильтр `vendor/mediatek/Android.mk` @`6dd7c54b`;
  `symbols` (GUI_ONLY), `wlan/wifi_hal`, `ril` подключены из `Android.mk` дерева.
- **Блобы в `/system`** (35 шт.) — где блоб открывает соседа по жёсткому `/system/...`
  пути (strings), плюс прошивки WMT для `6620_launcher`. Список — шапка
  `vendor/meizu/m5s/m5s-vendor-blobs.mk`.

## 3. Ядро

- `prebuilt-kernel/Image.gz-dtb`: `Linux version 4.9.188-m5s+ #1 SMP PREEMPT Thu Aug 27 19:45:57 MSK 2026`,
  sha256 `b605251322d23032b7866d73ecf1222131d6443eabc6c769f7781d822c12074c`, md5 `5d29a4c3…9626`.
  FACT: тот же sha256 у `/home/n8n/m5s_out/kernel49/Image.gz-m5sdtb` в `/home/n8n/m5s_out/e0/SHA256SUMS.txt`
  (ядро внутри `boot49-m5s-e0.img`, sha256 `898544a8…`). Ветка `forge/mt6753-49` @`ba33cd9db`.
- Гейты (оба прогнаны 2026-09-25, зелёные): `tools/check_prebuilt_kernel.sh` (md5 = EXPECTED.txt),
  `tools/check_appended_dtb.sh` (приклеен стоковый DTB m5s md5 `9be87e7f…`, `mt6753-mmc=2`, `msdc=0`).
- **Чего в E0 нет (FACT, m5s/BRINGUP_STATE.md, FLEET plan §8.2):** драйвера панели ili9881 и
  тача ft5x46 (они только в линии 3.18) — **первый бут безэкранный**, критерий — adb +
  `sys.boot_completed`; `CONFIG_CPUSETS`; коммитов pie-disp (ion SF_BUF_INFO, stpbt `.write_iter`
  для BT, SMI-фикс) — E0 отстаёт от pie-disp на 108 коммитов.
- ioctl-ABI `forge_hwc` совпадает с E0: `hwcomposer/disp_session_uapi.h` побайтно равен
  `kernel49/drivers/misc/mediatek/video/include/disp_session.h` (FACT, cmp).

## 4. Статическая проверка (без сборки)

`meizu-fleet/tools/a9-static-check.py m5s` (2026-09-25): 559 правил `PRODUCT_COPY_FILES` —
все источники есть (495 блобов, 37 в дереве, 26 в платформе на коммитах ганвеста, 1 стоковый
файл); назначений с двумя правилами — 0; 49 имён `PRODUCT_PACKAGES` — все определены
(дерево/вендор или Android.mk/bp платформы на коммитах ганвеста); совпадений имён `.bp` с
соседями LOS16 — 0; строки fstab — по 5 полей (проверка добавлена после ревью: при замене шапки
в fstab осталась незакомментированная строка, которая обнулила бы весь fstab — исправлено).
**Это не `m nothing`**: условия make и динамические модули не исполнялись.

## 5. HYPOTHESIS и как их опровергнуть (первый бут)

| # | HYPOTHESIS | Опровержение / проверка |
|---|---|---|
| H-BOOT | LK m5s принимает boot.img с `--board 1551951703` и ядро E0 доходит до init | маркеры E0 в DRAM `0xf0000000` (методика `m5s/BRINGUP_STATE.md` «ПЕРВЫЙ ФЛЕШ»), expdb p10 |
| H-BYNAME | на E0 существует `/dev/block/platform/mtk-msdc.0/11230000.msdc0/by-name/` | `adb shell ls /dev/block/platform/*/*/by-name/` |
| H-UDC | UDC E0 называется `musb-hdrc` (как на m5c 4.9) | `adb shell ls /sys/class/udc` (если adb не встал — это первый подозреваемый) |
| H-KM | без TEE-блобов программный keymaster 3.0 поднимает keystore | `logcat -b all \| grep -i keymaster`; нет «no viable keymaster» |
| H-RIL | рецепт m5c (vendor/mediatek/ril + librilmtk/mtk-ril модули) поднимает IRadio на M-эпохи mtk-ril | `lshal \| grep radio`; `getprop gsm.sim.state`; `logcat -b radio` |
| H-HWC | forge_hwc работает поверх E0 (ABI совпадает) — но панели в E0 нет | SurfaceFlinger без падений; экран — только после E1 |
| H-MODEM | цепочка ccci→muxd (forge-modem.rc m5c) работает с блобами M-эпохи | `getprop mtk.md1.status`, dmesg `md_hs2_msg_notify`, `CMUX READY` |
| H-SYSPATH | 35 файлов в `/system` закрывают все жёсткие пути | `logcat \| grep -E "dlopen failed\|cannot locate"` |

## 6. Что сознательно не сделано

- rc m5c (N, MT6737M) **не сверен построчно** со стоковым `init.mt6735.rc` m5s (M). FACT: сервисы
  стока m5s, которых нет в rc дерева (устройство-значимые): `aal`, `gas_srv`, `ged_srv`,
  `guiext-server`, `goodixfpd`, `teei_daemon`, `thermal`/`thermald`, `permission_check`,
  `MtkCodecService`, `mal-daemon`, `volte_*`, `NvRAMAgent`, `emsvr`, `md_monitor` (сравнение
  `service`-строк распакованного `m5s_stock_ramdisk.img` и `rootdir/*.rc`). Добавлять — по одному, с уликой.
- Отпечаток (Goodix): блобы есть, HAL/фича не заведены.
- `libdrmmtkutil.so` импортирует ICU `*_55` — форвардера нет (DRM, не путь загрузки).
- sepolicy: как у донора — `SELINUX_IGNORE_NEVERALLOWS`, рантайм permissive.
- Причуда донора, оставлена как есть (ревью 2026-09-25): в `forge-modem.rc` сервисы `nvram_daemon`,
  `ccci_fsd`, `ccci_mdinit`, `muxreport-daemon`, `terservice` объявлены без `override`, а в рамдиске
  (`init.mt6735.rc`, `init.modem.rc`) они уже есть — действуют рамдисковые определения; реально
  работают только `gsm0710muxd` и `ril-daemon*` (с `override`). На m5c так и грузится.
- Символьное замыкание блобов против Pie **не мерилось** (нужен out-каталог: `blobsym.py` после первой сборки).

## 7. Проверки для первой загрузки (AGENTS.md §6)

```sh
# 0. та ли сборка и то ли ядро (баннер = 4.9.188-m5s+ #1, uptime мал — свежесть)
adb shell 'getprop ro.build.display.id; getprop ro.build.version.release; uname -a; cat /proc/uptime'
# 1. загрузка и system_server
adb shell 'getprop sys.boot_completed; getprop sys.system_server.start_count'
# 2. разделы и vendor
adb shell 'ls -l /dev/block/platform/*/*/by-name/ | head -40; mount | grep -E " /(system|vendor|data) "'
# 3. краши и HAL
adb logcat -b crash -d | head -50
adb shell 'lshal | wc -l; getprop | grep init.svc | grep -v running'
# 4. линковка блобов
adb logcat -d | grep -E "cannot locate symbol|library .* not found|dlopen failed" | sort | uniq -c | sort -rn | head
# 5. модем/телефония
adb shell 'getprop mtk.md1.status; getprop gsm.sim.state; getprop gsm.version.baseband'
# 6. посмертно, если ребут: expdb p10 / DRAM-маркеры 0xf0000000 (m5s/BRINGUP_STATE.md), skill mtklogs
```
