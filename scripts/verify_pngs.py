#!/usr/bin/env python3
"""Check every planned file: exists, real PNG header, pixel size vs Figma size x scale, duplicate bytes.

usage: verify_pngs.py <out_dir> [--scale 2] [--scales scales.tsv]
scales.tsv (optional): <node_id>\t<scale> for frames that were exported below 2x.
Exit 1 if anything is missing or broken.
"""
import hashlib, struct, sys
from pathlib import Path

PNG = b"\x89PNG\r\n\x1a\n"
args = sys.argv[1:]
out = Path(args[0]); scale = 2.0; overrides = {}
if "--scale" in args: scale = float(args[args.index("--scale") + 1])
if "--scales" in args:
    for line in Path(args[args.index("--scales") + 1]).read_text().splitlines():
        if line.strip(): k, v = line.split("\t"); overrides[k] = float(v)
bad, seen, ok = [], {}, 0
for line in (out / "plan.tsv").read_text().splitlines():
    g, nid, rel, w, h, *_ = line.split("\t")
    p = out / rel
    if not p.exists() or p.stat().st_size == 0: bad.append(f"missing  {rel}"); continue
    b = p.read_bytes()
    if b[:8] != PNG: bad.append(f"not-png  {rel}"); continue
    pw, ph = struct.unpack(">II", b[16:24])
    s = overrides.get(nid, scale)
    if abs(pw - round(int(w) * s)) > 2 or abs(ph - round(int(h) * s)) > 2:
        bad.append(f"size     {rel}: {pw}x{ph}, expected ~{round(int(w)*s)}x{round(int(h)*s)} @{s}x")
        continue
    seen.setdefault(hashlib.md5(b).hexdigest(), []).append(f"{nid} {rel}")
    ok += 1
dupes = [v for v in seen.values() if len(v) > 1]
print(f"ok {ok}, problems {len(bad)}, below-2x {len(overrides)}")
for x in bad: print("  " + x)
for d in dupes: print("  same-bytes (re-export to confirm, keep both if Figma really has duplicates): " + " | ".join(d))
sys.exit(1 if bad else 0)
