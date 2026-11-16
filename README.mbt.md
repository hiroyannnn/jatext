# hiroyannnn/jatext

Japanese text conversion and normalization for [MoonBit](https://www.moonbitlang.com/).

- Hiragana ⇔ katakana, full-width ⇔ half-width, small kana → normal kana
  (compatible with [jaconv](https://github.com/ikegami-yukino/jaconv) 0.5.0)
- NEologd-style normalization and repeat shortening
  (compatible with [neologdn](https://github.com/ikegami-yukino/neologdn) 0.5.6)

MoonBit で日本語の文字種変換と正規化を行うライブラリです。jaconv / neologdn と同じ出力を返します。

No dependencies. Works on every backend (native, wasm-gc, wasm, js).

## Installation

```
moon add hiroyannnn/jatext
```

Import in `moon.pkg`:

```
import {
  "hiroyannnn/jatext",
}
```

## Usage

### Kana

```mbt check
///|
test "kana" {
  inspect(@jatext.hira2kata("ともえまみ"), content="トモエマミ")
  inspect(@jatext.kata2hira("巴マミ"), content="巴まみ")
  inspect(@jatext.hira2hkata("がっこう"), content="ｶﾞｯｺｳ")
  inspect(
    @jatext.enlarge_smallkana("キュゥべえ"),
    content="キユウべえ",
  )
  // characters in `ignore` are left as they are
  inspect(
    @jatext.hira2kata("まどまぎ", ignore="ど"),
    content="マどマギ",
  )
}
```

### Full-width ⇔ half-width

`kana` (default `true`), `ascii` and `digit` (default `false`) choose what to convert.

```mbt check
///|
test "width" {
  inspect(
    @jatext.z2h("ティロフィナーレ"),
    content="ﾃｨﾛﾌｨﾅｰﾚ",
  )
  inspect(
    @jatext.z2h("ＡＢＣ１２３　アイウ", ascii=true, digit=true),
    content="ABC123 ｱｲｳ",
  )
  inspect(@jatext.h2z("ｶﾞｯｺｳ"), content="ガッコウ")
  inspect(
    @jatext.h2z("abc123", ascii=true, digit=true),
    content="ａｂｃ１２３",
  )
}
```

### Normalization (neologdn)

```mbt check
///|
test "normalize" {
  inspect(
    @jatext.normalize("　　　ＰＲＭＬ　　副　読　本　　　"),
    content="PRML副読本",
  )
  inspect(
    @jatext.normalize(
      "南アルプスの　天然水　Ｓｐａｒｋｉｎｇ　Ｌｅｍｏｎ　レモン一絞り",
    ),
    content="南アルプスの天然水Sparking Lemonレモン一絞り",
  )
  inspect(
    @jatext.normalize("ﾊﾝｶｸｶﾀｶﾅ ﾊﾟﾊﾟ"),
    content="ハンカクカタカナパパ",
  )
  inspect(@jatext.normalize("スーパーーーー"), content="スーパー")
  // tildes are removed by default
  inspect(@jatext.normalize("1467〜1487年"), content="14671487年")
  inspect(
    @jatext.normalize("1467〜1487年", tilde=@jatext.Tilde::Normalize),
    content="1467~1487年",
  )
  inspect(
    @jatext.normalize("巴 マミ", remove_space=false),
    content="巴 マミ",
  )
  inspect(
    @jatext.normalize("うまああああああい", repeat=2),
    content="うまああい",
  )
  inspect(
    @jatext.shorten_repeat("無駄無駄無駄無駄ァ", 1),
    content="無駄ァ",
  )
}
```

## Functions

| jatext | Python | Notes |
|---|---|---|
| `hira2kata(text, ignore?)` | `jaconv.hira2kata` | |
| `kata2hira(text, ignore?)` | `jaconv.kata2hira` | |
| `hira2hkata(text, ignore?)` | `jaconv.hira2hkata` | |
| `enlarge_smallkana(text, ignore?)` | `jaconv.enlarge_smallkana` | |
| `z2h(text, ignore?, kana?, ascii?, digit?)` | `jaconv.z2h` | |
| `h2z(text, ignore?, kana?, ascii?, digit?)` | `jaconv.h2z` | |
| `normalize(text, repeat?, remove_space?, max_repeat_substr_length?, tilde?)` | `neologdn.normalize` | `tilde` is the `Tilde` enum |
| `shorten_repeat(text, threshold, max_repeat_substr_length?)` | `neologdn.shorten_repeat` | |

Defaults are the same as in Python.

## Compatibility

Outputs match jaconv 0.5.0 and neologdn 0.5.6, including their quirks. This is
checked by about 5,100 generated test cases (`lib/golden_*_wbtest.mbt`).

Known behaviors kept on purpose:

| Input | Output | Why |
|---|---|---|
| `normalize("１－２")` | `1ー2` | `－` (U+FF0D) is treated as a long vowel mark |
| `normalize("か゛")` | `かﾞ` | dakuten joins only katakana (and `う`); handakuten only は行 |
| `normalize("¥100")` | `\100` | `¥` maps to backslash; `＼` is not converted |
| `normalize("a あ")` | `aあ` | a space stays only after an ASCII character (not `*`) and before a non-Japanese character |
| `normalize("～")` | (empty) | tildes are removed by default |
| `h2z("ｶﾞ", ignore="ｶ")` | `ガ` | joining `ﾞ`/`ﾟ` happens before `ignore` is applied |
| `h2z("ｶﾟ")` | `カﾟ` | marks that cannot be joined stay half-width |

Intentional differences:

- `ignore` may contain characters that the table does not cover. jaconv raises
  `KeyError`; jatext ignores them.
- `shorten_repeat` with `threshold < 1` returns the input unchanged.

## Development

```
make test      # moon test --target all
make gen       # regenerate lib/tables.mbt and lib/golden_*_wbtest.mbt
```

`make gen` needs Python with `pip install -r tools/requirements.txt`
(jaconv 0.5.0, neologdn 0.5.6). The generated files must not be edited by hand.

## License

Apache-2.0. Conversion tables and behavior are ported from jaconv (MIT) and
neologdn (Apache-2.0) by Yukino Ikegami; see [NOTICE](NOTICE).
