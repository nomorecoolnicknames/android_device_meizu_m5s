#!/bin/sh
# check_prebuilt_kernel.sh — гейт свежести prebuilt-ядра m5s, вызывается из
# BoardConfig.mk.  Печатает НИЧЕГО при успехе; при несовпадении печатает
# указание в stderr и короткий маркер в stdout, по которому BoardConfig валит
# сборку через $(error).
#
# Зачем: ядро попадает в образ через TARGET_PREBUILT_KERNEL, кладётся в дерево
# РУКАМИ и молча устаревает.  На m5c это уже случилось: 2026-09-03 в дереве
# лежало ядро от 28 августа, и чистая сборка отгрузила бы ROM без единой
# правки того дня.  Ядро не входит ни в /system, ни в /vendor, поэтому никакой
# инвентарь образов этого не ловит.
#
# ГРАНИЦА ГЕЙТА, названная явно: он проверяет СООТВЕТСТВИЕ образа дереву, а НЕ
# актуальность дерева.  Зелёный ответ означает «образ совпадает с тем, что в
# дереве записано», а не «в дереве лежит нужное ядро».
#
#   $1 — путь к Image.gz-dtb
#   $2 — путь к файлу ожиданий (MD5 / VERSION)
set -u
IMG=$1
EXP=$2

[ -f "$IMG" ] || { echo "ЯДРО НЕ НАЙДЕНО: $IMG" >&2; echo "prebuilt-kernel: ЯДРА НЕТ, см. подробности выше"; exit 0; }
[ -f "$EXP" ] || { echo "НЕТ ФАЙЛА ОЖИДАНИЙ: $EXP" >&2; echo "prebuilt-kernel: НЕТ ФАЙЛА ОЖИДАНИЙ, см. подробности выше"; exit 0; }

want_md5=$(awk '$1=="MD5"{print $2}' "$EXP")
have_md5=$(md5sum "$IMG" | cut -d' ' -f1)
[ "$want_md5" = "$have_md5" ] && exit 0

want_ver=$(sed -n 's/^VERSION //p' "$EXP")
have_ver=$(python3 - "$IMG" <<'PY' 2>/dev/null
import sys, zlib, re
d = open(sys.argv[1], 'rb').read()
i = d.find(b'\x1f\x8b\x08')
raw = b''
if i >= 0:
    o = zlib.decompressobj(16 + zlib.MAX_WBITS)
    try:
        for off in range(i, len(d), 1 << 16):
            raw += o.decompress(d[off:off + (1 << 16)])
            if o.eof:
                break
    except Exception:
        pass
m = re.search(rb'Linux version [0-9][^\x00\n]{0,140}', raw)
print(m.group(0).decode('utf-8', 'replace') if m else 'версию извлечь не удалось')
PY
)

cat >&2 <<MSG
ЯДРО В prebuilt-lane m5s УСТАРЕЛО ИЛИ ПОДМЕНЕНО.
  файл:    $IMG
  ожидаем: $want_md5
           $want_ver
  найдено: $have_md5
           $have_ver
Что делать: пересобрать 4.9 из worktree /srv/forge/android/m5s/kernel49
(ветка forge/mt6753-49, defconfig m5s_defconfig) скриптом
/srv/forge/android/m5s/build_kernel49.sh, взять получившийся Image.gz-m5sdtb,
проверить его гейтом tools/check_appended_dtb.sh (хвост обязан быть СТОКОВЫМ
DTB m5s_stock.dtb байт-в-байт), положить сюда и обновить $EXP.

ГРАНИЦА ЭТОГО ГЕЙТА: он не проверяет, что prebuilt АКТУАЛЕН.  Совпадение md5
означает лишь «образ соответствует дереву».
MSG
echo "prebuilt-kernel: ядро не совпадает с ожидаемым ($have_md5 вместо $want_md5), см. подробности выше"
