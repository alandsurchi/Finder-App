"""
Replaces hardcoded design-token constants in manage_post_screen.dart,
get_verified_screen.dart, and item_details_screen.dart with AppColorTokens calls.
"""

import re, os

SCREENS_DIR = os.path.join(os.path.dirname(__file__), '..', 'screens')

# ── helpers ──────────────────────────────────────────────────────────────────

TOKEN_IMPORT = "import 'package:finder/theme/app_color_tokens.dart';"

REPS = [
    # scaffold
    ('backgroundColor: _bg,',           'backgroundColor: t.bg,'),
    ('color: _bg,',                      'color: t.surfaceHigh,'),
    # surface
    ('color: _white,',                   'color: t.surface,'),
    ('backgroundColor: _white,',         'backgroundColor: t.surface,'),
    # primary
    ('color: _blue,',                    'color: t.primary,'),
    ('backgroundColor: _blue,',          'backgroundColor: t.primary,'),
    ('color: _blue.withOpacity',         'color: t.primary.withOpacity'),
    ('border: Border.all(\n                               color: _blue', 'border: Border.all(\n                               color: t.primary'),
    ('color: _blue)',                    'color: t.primary)'),
    # error / red
    ('color: _red,',                     'color: t.error,'),
    ('backgroundColor: _red,',           'backgroundColor: t.error,'),
    ('foregroundColor: _red,',           'foregroundColor: t.error,'),
    ('color: _redLight,',                'color: t.error.withOpacity(0.1),'),
    ('color: _red.withOpacity(0.2)',     'color: t.error.withOpacity(0.2)'),
    ('const BorderSide(color: _red,',   'BorderSide(color: t.error,'),
    # warning / orange
    ('activeColor: _orange,',            'activeColor: t.warning,'),
    ('color: _orange.withOpacity(0.12)', 'color: t.warning.withOpacity(0.12)'),
    ('color: _orange,',                  'color: t.warning,'),
    # success / green
    ('color: _green,',                   'color: t.success,'),
    # foreground white  (must be AFTER specific fgColor lines)
    ('foregroundColor: Colors.white,',   'foregroundColor: t.isDark ? Colors.black : Colors.white,'),
    # state-based
    ('isLost ? _orange : _blue,',        'isLost ? t.warning : t.primary,'),
    ('_isActive ? _blue : _green,',      '_isActive ? t.primary : t.success,'),
    ('backgroundColor: _isActive ? _blue : _green,', 'backgroundColor: _isActive ? t.primary : t.success,'),
    ('selected ? _blue : _white,',       'selected ? t.primary : t.surface,'),
    ('selected ? _blue : _textDark,',    'selected ? t.primary : t.onSurface,'),
    ('selected ? _blue : _textMid,',     'selected ? t.primary : t.onSurfaceVar,'),
    ('selected ? _blueLight : _white,',  'selected ? t.primary.withOpacity(0.12) : t.surface,'),
    ('selected ? _blue : _divider,',     'selected ? t.primary : t.divider,'),
    ('isUploaded ? _blueLight : _white,','isUploaded ? t.primary.withOpacity(0.1) : t.surface,'),
    ('isUploaded ? _blue : _divider,',   'isUploaded ? t.primary : t.divider,'),
    ('isUploaded ? _blue : _textLight,', 'isUploaded ? t.primary : t.onSurfaceMuted,'),
    ('isUploaded ? _blue : _textDark,',  'isUploaded ? t.primary : t.onSurface,'),
    # text
    ('color: _textDark,',                'color: t.onSurface,'),
    ('color: _textMid,',                 'color: t.onSurfaceVar,'),
    ('color: _textLight,',               'color: t.onSurfaceMuted,'),
    ('color: Colors.black54,',           'color: t.onSurfaceVar,'),
    # divider / border
    ('border: Border.all(color: _divider)', 'border: Border.all(color: t.divider)'),
    ('color: _divider,',                 'color: t.divider,'),
    ('Divider(color: _divider,',         'Divider(color: t.divider,'),
    # other hardcoded colours we know about
    ('color: const Color(0xFF1E293B),',  'color: t.surfaceHigh,'),
    ('color: Colors.white24,',           'color: t.onSurfaceMuted.withOpacity(0.3),'),
    ('color: Colors.white24)',           'color: t.onSurfaceMuted.withOpacity(0.3))'),
    # icon bg
    ('color: _iconBg,',                  'color: t.iconBg,'),
    ('color: _blueLight,',               'color: t.primary.withOpacity(0.1),'),
    # stat card – remove iconColor field
    ('iconColor: _blue,',  ''),
    ('iconColor: _orange,',''),
    ('final Color iconColor;', ''),
    ('required this.iconColor,', ''),
    ('Icon(icon, color: iconColor, size: 22),', 'Icon(icon, color: t.primary, size: 22),'),
    # dropdown
    ("style: const TextStyle(\n                  color: _textDark, fontSize: 14),",
     "style: TextStyle(color: t.onSurface, fontSize: 14),"),
    ("style: const TextStyle(color: _textDark, fontSize: 14),",
     "style: TextStyle(color: t.onSurface, fontSize: 14),"),
    ('dropdownColor: _white,', 'dropdownColor: t.surface,'),
    ('color: _textLight, size: 18', 'color: t.onSurfaceMuted, size: 18'),
    ('color: _textLight, size: 22', 'color: t.onSurfaceMuted, size: 22'),
    # camera painter
    ('..color = const Color(0xFF2563EB)', '..color = const Color(0xFF2563EB)'),  # leave painter
]


def fix_file(path: str):
    with open(path, encoding='utf-8') as f:
        src = f.read()

    # ── 1. Remove token-const block ──────────────────────────────────────────
    src = re.sub(
        r"// ─── Design tokens.*?const _green[^\n]*\n",
        "",
        src,
        flags=re.DOTALL,
    )
    # also strip any leftover isolated const lines
    src = re.sub(r"^const _\w+\s+=.*\n", "", src, flags=re.MULTILINE)

    # ── 2. Add import if missing ─────────────────────────────────────────────
    if TOKEN_IMPORT not in src:
        src = src.replace(
            "import 'package:flutter/material.dart';",
            "import 'package:flutter/material.dart';\n" + TOKEN_IMPORT,
            1
        )

    # ── 3. String replacements ───────────────────────────────────────────────
    for old, new in REPS:
        src = src.replace(old, new)

    # ── 4. Add `final t = AppColorTokens.of(context);` to build methods ─────
    # Match any `Widget build(BuildContext context) {` that doesn't already have final t
    def inject_t(m):
        body = m.group(0)
        if 'final t = AppColorTokens.of(context)' in body:
            return body
        return body.replace(
            'Widget build(BuildContext context) {\n',
            'Widget build(BuildContext context) {\n    final t = AppColorTokens.of(context);\n',
            1
        )

    # Simple injection for build method
    src = re.sub(
        r'Widget build\(BuildContext context\) \{',
        lambda m: 'Widget build(BuildContext context) {',
        src
    )

    # Properly inject after `{` in build, _buildField, _buildSaveBar, etc.
    BUILD_METHODS = (
        r'(Widget build\(BuildContext context\) \{)',
        r'(Widget _buildSaveBar\(BuildContext context\) \{)',
        r'(void _confirmDelete\(BuildContext context\) \{)',
        r'(Widget _buildField\(\{[^)]+\}\) \{)',
        r'(Widget _inputField\(\{[^)]+\}\) \{)',
        r'(Widget _dropdownField\(\{[^)]+\}\) \{)',
        r'(Widget _buildSectionHeader\(\{[^)]+\}\) \{)',
        r'(Widget _buildDocOption\(\{[^)]+\}\) \{)',
        r'(Widget _buildUploadBox\(\{[^)]+\}\) \{)',
        r'(Widget _buildBottomBar\(BuildContext context\) \{)',
        r'(Widget _buildMenuItem\(\{[^)]+\}\) \{)',
        r'(Widget _buildDarkModeToggle\(BuildContext context\) \{)',
        r'(Widget _buildMenuDivider\(\) \{)',
        r'(Widget _buildStat\(String label, String value(?:, AppColorTokens t)?\) \{)',
        r'(Widget _buildTab\(int index, String label(?:, AppColorTokens t)?\) \{)',
    )

    for pattern in BUILD_METHODS:
        def add_t(m):
            s = m.group(0)
            next_line_content = src[m.end():m.end()+120]
            if 'final t = AppColorTokens.of(context)' in src[m.start():m.start()+300]:
                return s
            return s + '\n    final t = AppColorTokens.of(context);'
        src = re.sub(pattern, add_t, src)

    with open(path, 'w', encoding='utf-8') as f:
        f.write(src)
    print(f"Fixed: {os.path.basename(path)}")


FILES = [
    os.path.join(SCREENS_DIR, 'manage_post_screen.dart'),
    os.path.join(SCREENS_DIR, 'get_verified_screen.dart'),
    os.path.join(SCREENS_DIR, 'item_details_screen.dart'),
]

for fp in FILES:
    if os.path.exists(fp):
        fix_file(fp)
    else:
        print(f"NOT FOUND: {fp}")
