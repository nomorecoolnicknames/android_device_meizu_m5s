#!/bin/bash
# check_appended_dtb.sh — проверка ГОТОВОГО Image.gz-dtb перед тем, как класть
# его в prebuilt-kernel/ или прошивать.  Отвечает на вопрос, на который
# check_prebuilt_kernel.sh не отвечает: «какой DTB приклеен к образу?».
#
# Ядро 4.9 этого аппарата рассчитано на СТОКОВЫЙ DTB Flyme, приклеенный к
# Image.gz байт-в-байт.  Штатная цель `make Image.gz-dtb` клеит DTB, СОБРАННЫЙ
# из дерева, и образ при этом выглядит нормально: правильное имя, правдоподобный
# размер, никакой ошибки.  На m5c ровно это однажды и произошло.
#
# Ключ различения для MT6753 (НЕ такой, как у m5c!):
#   стоковый DTB m5s:  msdc0@11230000 { compatible = "mediatek,mt6753-mmc" }
#                      (FACT: /srv/forge/android/m5s/stock/flyme/work/m5s_stock.dts:21)
#   собранный деревом: "mediatek,msdc"
# Драйвер eMMC биндится по первому.  На втором аппарат не найдёт корневую ФС.
#
# ВАЖНО: гейт осмыслен только на СЖАТОМ Image.gz-dtb.  На сыром
# arch/arm64/boot/Image строки msdc читаются из самого драйвера и вывод был бы
# ложным; поэтому не-gzip вход отвергается отдельным кодом 2.
#
#   ./check_appended_dtb.sh <Image.gz-dtb> [ожидаемый-md5-dtb]
#
# Без второго аргумента сверяет со стоковым DTB m5s
# (m5s_stock.dtb, 67170 Б, md5 9be87e7f729537994a50eebe9a836d71,
#  sha256 a980f28052cdd11bc8bb523e468a1e2d6e0e13ba2b9fa7dbedeef9554de4252d).
set -u

STOCK_MD5=9be87e7f729537994a50eebe9a836d71

IMG=${1:-}
WANT=${2:-$STOCK_MD5}

if [ -z "$IMG" ] || [ ! -f "$IMG" ]; then
    echo "usage: $0 <Image.gz-dtb> [expected-dtb-md5]" >&2
    exit 2
fi

python3 - "$IMG" "$WANT" <<'PY'
import hashlib, sys

img, want = sys.argv[1], sys.argv[2]
data = open(img, 'rb').read()
MAGIC = bytes.fromhex('d00dfeed')

if data[:2] != b'\x1f\x8b':
    print("НЕ ТОТ ВХОД: %s не начинается с gzip-сигнатуры 1f 8b." % img)
    print("Гейт применяется к Image.gz-dtb, а не к сырому Image и не к boot.img.")
    print("Для boot.img сначала достаньте ядро, потом проверяйте его.")
    sys.exit(2)

found = []
i = data.find(MAGIC)
while i != -1:
    total = int.from_bytes(data[i + 4:i + 8], 'big')
    version = int.from_bytes(data[i + 20:i + 24], 'big')
    if 1000 < total <= len(data) - i and 1 <= version <= 17:
        found.append((i, total))
    i = data.find(MAGIC, i + 1)

if not found:
    print("ОШИБКА: в %s нет приклеенного DTB (магии d00dfeed не найдено)" % img)
    sys.exit(1)

if len(found) > 1:
    print("ВНИМАНИЕ: найдено %d кандидатов DTB, проверяю первый" % len(found))

off, total = found[0]
blob = data[off:off + total]
got = hashlib.md5(blob).hexdigest()
print("образ  : %s (%d байт)" % (img, len(data)))
print("dtb    : off=%d size=%d" % (off, total))
print("md5    : %s" % got)
print("sha256 : %s" % hashlib.sha256(blob).hexdigest())
print("ожидаю : %s" % want)

stock_key = blob.count(b"mt6753-mmc")
built_key = blob.count(b"mediatek,msdc\x00")
print("ключ   : mt6753-mmc=%d  mediatek,msdc=%d" % (stock_key, built_key))
structural_ok = stock_key > 0 and built_key == 0

if got == want and structural_ok:
    print("OK — приклеен ожидаемый стоковый DTB m5s")
    sys.exit(0)
if got == want and not structural_ok:
    print("ОТКАЗ — md5 совпал, но в DTB нет имени eMMC, которое ищет драйвер.")
    sys.exit(1)
if got != want and structural_ok:
    print("ВНИМАНИЕ — md5 не совпал, но структурно DTB стоковый.")
    print("Сверяйте вручную; сток мог законно смениться.")
    sys.exit(1)
print("ОТКАЗ — приклеен НЕ тот DTB, использовать НЕЛЬЗЯ")
print()
print("Починить, не пересобирая ядро:")
print("  cat <дерево>/arch/arm64/boot/Image.gz \\")
print("      /srv/forge/android/m5s/stock/flyme/work/m5s_stock.dtb \\")
print("      > %s.STOCKDTB" % img)
sys.exit(1)
PY
