"""Assemble the ARB files and regenerate AppLocalizations.

Sources (never edit lib/l10n/app_*.arb by hand):
  tool/l10n/seed_en.arb            common English strings
  tool/l10n/fragments/<area>.arb   English strings per app area
  tool/l10n/<lang>/<area>.arb      translations, same keys, per language

Output: lib/l10n/app_en.arb, app_ar.arb, app_ckb.arb, then `flutter gen-l10n`.
Reports duplicate keys that disagree and translations that are missing or
stale (not present in English any more).
Usage: python tool/merge_l10n.py [--no-gen]
"""
import glob, json, os, subprocess, sys
from collections import OrderedDict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'tool', 'l10n')
OUT = os.path.join(ROOT, 'lib', 'l10n')
LANGS = ['ar', 'ckb']


def load(path):
    with open(path, encoding='utf-8') as f:
        return json.load(f, object_pairs_hook=OrderedDict)


def write(path, data):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write('\n')


# ── English ────────────────────────────────────────────────────────────────
en = OrderedDict()
origin = {}
conflicts = []
for path in [os.path.join(SRC, 'seed_en.arb')] + sorted(glob.glob(os.path.join(SRC, 'fragments', '*.arb'))):
    for k, v in load(path).items():
        if k == '@@locale':
            continue
        if k in en and en[k] != v:
            conflicts.append(f'{k}: {origin[k]} vs {os.path.basename(path)}')
            continue
        en[k] = v
        origin[k] = os.path.basename(path)

out = OrderedDict([('@@locale', 'en')])
out.update(en)
write(os.path.join(OUT, 'app_en.arb'), out)
message_keys = [k for k in en if not k.startswith('@')]
print(f'en: {len(message_keys)} keys')
if conflicts:
    print('CONFLICTS (first definition kept):')
    for c in conflicts:
        print('  ' + c)

# ── Translations ───────────────────────────────────────────────────────────
for lang in LANGS:
    tr = OrderedDict()
    for path in sorted(glob.glob(os.path.join(SRC, lang, '*.arb'))):
        for k, v in load(path).items():
            if k == '@@locale' or k.startswith('@'):
                continue
            tr[k] = v
    missing = [k for k in message_keys if k not in tr]
    stale = [k for k in tr if k not in en]
    out = OrderedDict([('@@locale', lang)])
    for k in message_keys:
        if k in tr:
            out[k] = tr[k]
    write(os.path.join(OUT, f'app_{lang}.arb'), out)
    print(f'{lang}: {len(out) - 1} translated, {len(missing)} missing, {len(stale)} stale')
    if missing and '--verbose' in sys.argv:
        print('  missing: ' + ', '.join(missing))
    if stale:
        print('  stale: ' + ', '.join(stale))

if '--no-gen' not in sys.argv:
    r = subprocess.run(['flutter', 'gen-l10n'], cwd=ROOT, shell=True, capture_output=True, text=True)
    lines = [l for l in (r.stdout + r.stderr).strip().splitlines() if 'l10n.yaml' not in l and 'command line arguments' not in l]
    print('\n'.join(lines[-8:]) if lines else 'gen-l10n ok')
    sys.exit(r.returncode)
