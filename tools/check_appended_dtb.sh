#!/bin/sh
set -eu
[ "$#" -eq 1 ] || { echo "usage: $0 <selected-M5s-Image.gz-dtb>" >&2; exit 2; }
python3 - "$1" <<'PY'
import hashlib,struct,sys,zlib
if not __debug__: raise RuntimeError('Optimized Python disables kernel guards')
b=open(sys.argv[1],'rb').read()
assert hashlib.sha256(b).hexdigest()=='4fb656867aaa4b0bfd03125b9ca8b5b873f381e70fab557615c8ded0a26a5107'
d=zlib.decompressobj(16+zlib.MAX_WBITS);raw=d.decompress(b);assert d.eof
dtb=d.unused_data
assert dtb[:4]==bytes.fromhex('d00dfeed') and struct.unpack_from('>I',dtb,4)[0]==len(dtb)
assert hashlib.sha256(dtb).hexdigest()=='f9e7c32cff0a2da3f8c39859e71906413305430132f8350af94b41312f7d4c8e'
print('Selected source-built M5s image and own compiled DTB verified; runtime unverified')
PY
