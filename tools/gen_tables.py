#!/usr/bin/env python3
"""Generate lib/tables.mbt from the conversion tables of jaconv 0.5.0 and
neologdn 0.5.6.

jaconv tables are read from the installed package (jaconv.conv_table).
neologdn is a compiled extension, so its tables are copied below from
neologdn.pyx (v0.5.6) and checked against the installed binary.

Usage:
    pip install -r tools/requirements.txt
    python3 tools/gen_tables.py
"""
from __future__ import annotations

import os
import sys
import unicodedata

import jaconv
import neologdn
from jaconv import conv_table as ct

EXPECTED_JACONV = "0.5.0"
EXPECTED_NEOLOGDN = "0.5.6"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "lib", "tables.mbt")

if jaconv.__version__ != EXPECTED_JACONV or neologdn.__version__ != EXPECTED_NEOLOGDN:
    sys.exit(
        f"reference version mismatch: jaconv {jaconv.__version__} (want {EXPECTED_JACONV}), "
        f"neologdn {neologdn.__version__} (want {EXPECTED_NEOLOGDN})"
    )

# ---------------------------------------------------------------------------
# neologdn tables (copied from neologdn.pyx v0.5.6, Apache-2.0)
# ---------------------------------------------------------------------------

N_ASCII = (
    ('ａ', 'a'), ('ｂ', 'b'), ('ｃ', 'c'), ('ｄ', 'd'), ('ｅ', 'e'),
    ('ｆ', 'f'), ('ｇ', 'g'), ('ｈ', 'h'), ('ｉ', 'i'), ('ｊ', 'j'),
    ('ｋ', 'k'), ('ｌ', 'l'), ('ｍ', 'm'), ('ｎ', 'n'), ('ｏ', 'o'),
    ('ｐ', 'p'), ('ｑ', 'q'), ('ｒ', 'r'), ('ｓ', 's'), ('ｔ', 't'),
    ('ｕ', 'u'), ('ｖ', 'v'), ('ｗ', 'w'), ('ｘ', 'x'), ('ｙ', 'y'),
    ('ｚ', 'z'),
    ('Ａ', 'A'), ('Ｂ', 'B'), ('Ｃ', 'C'), ('Ｄ', 'D'), ('Ｅ', 'E'),
    ('Ｆ', 'F'), ('Ｇ', 'G'), ('Ｈ', 'H'), ('Ｉ', 'I'), ('Ｊ', 'J'),
    ('Ｋ', 'K'), ('Ｌ', 'L'), ('Ｍ', 'M'), ('Ｎ', 'N'), ('Ｏ', 'O'),
    ('Ｐ', 'P'), ('Ｑ', 'Q'), ('Ｒ', 'R'), ('Ｓ', 'S'), ('Ｔ', 'T'),
    ('Ｕ', 'U'), ('Ｖ', 'V'), ('Ｗ', 'W'), ('Ｘ', 'X'), ('Ｙ', 'Y'),
    ('Ｚ', 'Z'),
    ('！', '!'), ('”', '"'), ('＃', '#'), ('＄', '$'), ('％', '%'),
    ('＆', '&'), ('’', "'"), ('（', '('), ('）', ')'), ('＊', '*'),
    ('＋', '+'), ('，', ','), ('−', '-'), ('．', '.'), ('／', '/'),
    ('：', ':'), ('；', ';'), ('＜', '<'), ('＝', '='), ('＞', '>'),
    ('？', '?'), ('＠', '@'), ('［', '['), ('¥', '\\'), ('］', ']'),
    ('＾', '^'), ('＿', '_'), ('‘', '`'), ('｛', '{'), ('｜', '|'),
    ('｝', '}'),
)
N_KANA = (
    ('ｱ', 'ア'), ('ｲ', 'イ'), ('ｳ', 'ウ'), ('ｴ', 'エ'), ('ｵ', 'オ'),
    ('ｶ', 'カ'), ('ｷ', 'キ'), ('ｸ', 'ク'), ('ｹ', 'ケ'), ('ｺ', 'コ'),
    ('ｻ', 'サ'), ('ｼ', 'シ'), ('ｽ', 'ス'), ('ｾ', 'セ'), ('ｿ', 'ソ'),
    ('ﾀ', 'タ'), ('ﾁ', 'チ'), ('ﾂ', 'ツ'), ('ﾃ', 'テ'), ('ﾄ', 'ト'),
    ('ﾅ', 'ナ'), ('ﾆ', 'ニ'), ('ﾇ', 'ヌ'), ('ﾈ', 'ネ'), ('ﾉ', 'ノ'),
    ('ﾊ', 'ハ'), ('ﾋ', 'ヒ'), ('ﾌ', 'フ'), ('ﾍ', 'ヘ'), ('ﾎ', 'ホ'),
    ('ﾏ', 'マ'), ('ﾐ', 'ミ'), ('ﾑ', 'ム'), ('ﾒ', 'メ'), ('ﾓ', 'モ'),
    ('ﾔ', 'ヤ'), ('ﾕ', 'ユ'), ('ﾖ', 'ヨ'),
    ('ﾗ', 'ラ'), ('ﾘ', 'リ'), ('ﾙ', 'ル'), ('ﾚ', 'レ'), ('ﾛ', 'ロ'),
    ('ﾜ', 'ワ'), ('ｦ', 'ヲ'), ('ﾝ', 'ン'),
    ('ｧ', 'ァ'), ('ｨ', 'ィ'), ('ｩ', 'ゥ'), ('ｪ', 'ェ'), ('ｫ', 'ォ'),
    ('ｯ', 'ッ'), ('ｬ', 'ャ'), ('ｭ', 'ュ'), ('ｮ', 'ョ'),
    ('｡', '。'), ('､', '、'), ('･', '・'), ('゛', 'ﾞ'), ('゜', 'ﾟ'),
    ('｢', '「'), ('｣', '」'), ('ｰ', 'ー'),
)
N_DIGIT = (
    ('０', '0'), ('１', '1'), ('２', '2'), ('３', '3'), ('４', '4'),
    ('５', '5'), ('６', '6'), ('７', '7'), ('８', '8'), ('９', '9'),
)
N_KANA_TEN = (
    ('カ', 'ガ'), ('キ', 'ギ'), ('ク', 'グ'), ('ケ', 'ゲ'), ('コ', 'ゴ'),
    ('サ', 'ザ'), ('シ', 'ジ'), ('ス', 'ズ'), ('セ', 'ゼ'), ('ソ', 'ゾ'),
    ('タ', 'ダ'), ('チ', 'ヂ'), ('ツ', 'ヅ'), ('テ', 'デ'), ('ト', 'ド'),
    ('ハ', 'バ'), ('ヒ', 'ビ'), ('フ', 'ブ'), ('ヘ', 'ベ'), ('ホ', 'ボ'),
    ('ウ', 'ヴ'), ('う', 'ゔ'),
)
N_KANA_MARU = (
    ('ハ', 'パ'), ('ヒ', 'ピ'), ('フ', 'プ'), ('ヘ', 'ペ'), ('ホ', 'ポ'),
    ('は', 'ぱ'), ('ひ', 'ぴ'), ('ふ', 'ぷ'), ('へ', 'ぺ'), ('ほ', 'ぽ'),
)
N_SYMBOLS = (('“', '"'),)
N_HIPHENS = ('˗', '֊', '‐', '‑', '‒', '–', '⁃', '⁻', '₋', '−')
N_CHOONPUS = ('﹣', '－', 'ｰ', '—', '―', '─', '━', 'ー')
N_TILDES = ('~', '∼', '∾', '〜', '〰', '～')
N_SPACE = (' ', '　')

n_conversion: dict[str, str] = {}
for before, after in N_ASCII + N_DIGIT + N_KANA + N_SYMBOLS:
    n_conversion[before] = after

# check the copied tables against the installed neologdn
_special = set(N_HIPHENS) | set(N_CHOONPUS) | set(N_TILDES) | set(N_SPACE)
for before, after in n_conversion.items():
    if before in _special:
        continue
    got = neologdn.normalize(before)
    assert got == after, (before, after, got)
for base, composed in N_KANA_TEN:
    for mark in ("ﾞ", "゛"):
        got = neologdn.normalize(base + mark)
        assert got == composed, (base, mark, got)
for base, composed in N_KANA_MARU:
    for mark in ("ﾟ", "゜"):
        got = neologdn.normalize(base + mark)
        assert got == composed, (base, mark, got)
for h in N_HIPHENS:
    assert neologdn.normalize("a" + h + h) == "a-", h
for ch in N_CHOONPUS:
    assert neologdn.normalize("あ" + ch + ch) == "あー", ch
for t in N_TILDES:
    assert neologdn.normalize("a" + t + "b") == "ab", t

# ---------------------------------------------------------------------------
# jaconv tables
# ---------------------------------------------------------------------------


def to_char_map(table: dict[int, str]) -> dict[str, str]:
    return {chr(k): v for k, v in table.items()}


def union(*maps: dict) -> dict:
    out: dict = {}
    for m in maps:
        for k, v in m.items():
            assert k not in out, k
            out[k] = v
    return out


# z2h/h2z flag combinations must be plain unions of the per-category tables
assert ct.Z2H_ALL == union(ct.Z2H_A, ct.Z2H_D, ct.Z2H_K)
assert ct.Z2H_AD == union(ct.Z2H_A, ct.Z2H_D)
assert ct.Z2H_AK == union(ct.Z2H_A, ct.Z2H_K)
assert ct.Z2H_DK == union(ct.Z2H_D, ct.Z2H_K)
assert ct.H2Z_ALL == union(ct.H2Z_A, ct.H2Z_D, ct.H2Z_K)
assert ct.H2Z_AD == union(ct.H2Z_A, ct.H2Z_D)
assert ct.H2Z_AK == union(ct.H2Z_A, ct.H2Z_K)
assert ct.H2Z_DK == union(ct.H2Z_D, ct.H2Z_K)

# h2z composes a half-width kana followed by a half-width (han)dakuten.
# The pairs are exactly the 2-char values of Z2H_K (full kana -> half kana).
compose: dict[tuple[str, str], str] = {}
for full_ord, half in ct.Z2H_K.items():
    if len(half) == 2:
        compose[(half[0], half[1])] = chr(full_ord)
assert len(compose) == 26, len(compose)
for base in map(chr, range(0xFF61, 0xFFA0)):
    for mark in ("ﾞ", "ﾟ"):
        out = jaconv.h2z(base + mark)
        if (base, mark) in compose:
            assert out == compose[(base, mark)], (base, mark, out)
        else:
            assert len(out) == 2, (base, mark, out)

# ---------------------------------------------------------------------------
# MoonBit output
# ---------------------------------------------------------------------------

_ESCAPE_CATEGORIES = {"Cc", "Cf", "Zs", "Zl", "Zp", "Co", "Cs", "Cn", "Mn", "Me"}


def _needs_escape(ch: str) -> bool:
    return ch != " " and unicodedata.category(ch) in _ESCAPE_CATEGORIES


def mbt_char(ch: str) -> str:
    assert len(ch) == 1, ch
    if ch == "\\":
        return "'\\\\'"
    if ch == "'":
        return "'\\''"
    if _needs_escape(ch):
        return "'\\u{%X}'" % ord(ch)
    return "'" + ch + "'"


def mbt_str(s: str) -> str:
    out = ['"']
    for ch in s:
        if ch == "\\":
            out.append("\\\\")
        elif ch == '"':
            out.append('\\"')
        elif _needs_escape(ch):
            out.append("\\u{%X}" % ord(ch))
        else:
            out.append(ch)
    out.append('"')
    return "".join(out)


def string_table(name: str, doc: str, table: dict[str, str]) -> str:
    lines = ["///|", f"/// {doc}", f"fn {name}(c : Char) -> String? {{", "  match c {"]
    for k in sorted(table):
        lines.append(f"    {mbt_char(k)} => Some({mbt_str(table[k])})")
    lines += ["    _ => None", "  }", "}", ""]
    return "\n".join(lines)


def char_map_or_self(name: str, doc: str, table: dict[str, str]) -> str:
    lines = ["///|", f"/// {doc}", f"fn {name}(c : Char) -> Char {{", "  match c {"]
    for k in sorted(table):
        lines.append(f"    {mbt_char(k)} => {mbt_char(table[k])}")
    lines += ["    _ => c", "  }", "}", ""]
    return "\n".join(lines)


def char_map_opt(name: str, doc: str, table: dict[str, str]) -> str:
    lines = ["///|", f"/// {doc}", f"fn {name}(c : Char) -> Char? {{", "  match c {"]
    for k in sorted(table):
        lines.append(f"    {mbt_char(k)} => Some({mbt_char(table[k])})")
    lines += ["    _ => None", "  }", "}", ""]
    return "\n".join(lines)


def char_set(name: str, doc: str, chars) -> str:
    uniq = sorted(set(chars))
    pat = " | ".join(mbt_char(c) for c in uniq)
    return "\n".join(
        [
            "///|",
            f"/// {doc}",
            f"fn {name}(c : Char) -> Bool {{",
            "  match c {",
            f"    {pat} => true",
            "    _ => false",
            "  }",
            "}",
            "",
        ]
    )


def compose_table(name: str, doc: str, table: dict[tuple[str, str], str]) -> str:
    lines = [
        "///|",
        f"/// {doc}",
        f"fn {name}(base : Char, mark : Char) -> Char? {{",
        "  match (base, mark) {",
    ]
    for (b, m) in sorted(table):
        lines.append(f"    ({mbt_char(b)}, {mbt_char(m)}) => Some({mbt_char(table[(b, m)])})")
    lines += ["    _ => None", "  }", "}", ""]
    return "\n".join(lines)


def main() -> None:
    parts = [
        "// Code generated by tools/gen_tables.py. DO NOT EDIT.\n"
        f"// Source tables: jaconv {EXPECTED_JACONV} (MIT), neologdn {EXPECTED_NEOLOGDN} (Apache-2.0).\n"
        "// See NOTICE.\n",
        string_table("hira2kata_table", "jaconv H2K_TABLE", to_char_map(ct.H2K_TABLE)),
        string_table("kata2hira_table", "jaconv K2H_TABLE", to_char_map(ct.K2H_TABLE)),
        string_table("hira2hkata_table", "jaconv H2HK_TABLE", to_char_map(ct.H2HK_TABLE)),
        string_table(
            "enlarge_smallkana_table",
            "jaconv SMALL_KANA2NORMAL_KANA",
            to_char_map(ct.SMALL_KANA2NORMAL_KANA),
        ),
        string_table("z2h_ascii_table", "jaconv Z2H_A", to_char_map(ct.Z2H_A)),
        string_table("z2h_digit_table", "jaconv Z2H_D", to_char_map(ct.Z2H_D)),
        string_table("z2h_kana_table", "jaconv Z2H_K", to_char_map(ct.Z2H_K)),
        string_table("h2z_ascii_table", "jaconv H2Z_A", to_char_map(ct.H2Z_A)),
        string_table("h2z_digit_table", "jaconv H2Z_D", to_char_map(ct.H2Z_D)),
        string_table("h2z_kana_table", "jaconv H2Z_K", to_char_map(ct.H2Z_K)),
        compose_table(
            "half_kana_compose",
            "Half-width kana + half-width (han)dakuten composed by jaconv.h2z",
            compose,
        ),
        char_map_or_self(
            "neologdn_convert", "neologdn conversion_map (ASCII + DIGIT + KANA + SYMBOLS)", n_conversion
        ),
        char_map_opt("neologdn_kana_ten", "neologdn kana_ten_map", dict(N_KANA_TEN)),
        char_map_opt("neologdn_kana_maru", "neologdn kana_maru_map", dict(N_KANA_MARU)),
        char_set("neologdn_is_hyphen", "neologdn HIPHENS", N_HIPHENS),
        char_set("neologdn_is_choonpu", "neologdn CHOONPUS", N_CHOONPUS),
        char_set("neologdn_is_tilde", "neologdn TILDES", N_TILDES),
        char_set("neologdn_is_space", "neologdn SPACE", N_SPACE),
    ]
    content = "\n".join(parts)
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8", newline="\n") as fp:
        fp.write(content)
    print(f"wrote {os.path.relpath(OUT)} ({content.count(chr(10))} lines)")


if __name__ == "__main__":
    main()
