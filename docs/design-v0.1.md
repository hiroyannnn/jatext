# hiroyannnn/jatext v0.1.0：日本語テキストの正規化（jaconv・neologdn 互換）

## 目的

MoonBit には、日本語の文字種を変換・正規化するライブラリがない（2026-09-28、`moon update` した索引を grep して確認）。
Python の jaconv と neologdn の挙動を移植し、MoonBit の native / wasm-gc / js のどれでも同じ前処理を使えるようにする。後で作る形態素解析器の前処理にも使う。

## v0.1 のスコープ

| 関数 | 移植元 | 内容 |
|---|---|---|
| `hira2kata` | jaconv | ひらがな → 全角カタカナ |
| `kata2hira` | jaconv | 全角カタカナ → ひらがな |
| `hira2hkata` | jaconv | ひらがな → 半角カタカナ |
| `enlarge_smallkana` | jaconv | 小書きかな → 通常のかな |
| `z2h` / `h2z` | jaconv | 全角 ⇔ 半角（かな・英字記号・数字を個別に指定） |
| `normalize` | neologdn | NEologd 向けの正規化 |
| `shorten_repeat` | neologdn | 同じ文字列の繰り返しを短くする |

### v0.1 でやらないこと

- ローマ字変換（`kana2alphabet` / `alphabet2kana`）：v0.2 で追加する。
- 漢数字 ⇔ 算用数字、和暦：v0.3 以降で追加する。
- jaconv の `normalize`（NFKC ベース）：NFKC は moonbit-community/normalization に任せる。
- 形態素解析：別モジュールにする。

## API

```moonbit
pub fn hira2kata(text : String, ignore? : String = "") -> String
pub fn kata2hira(text : String, ignore? : String = "") -> String
pub fn hira2hkata(text : String, ignore? : String = "") -> String
pub fn enlarge_smallkana(text : String, ignore? : String = "") -> String

pub fn z2h(
  text : String,
  ignore? : String = "",
  kana? : Bool = true,
  ascii? : Bool = false,
  digit? : Bool = false,
) -> String

pub fn h2z(
  text : String,
  ignore? : String = "",
  kana? : Bool = true,
  ascii? : Bool = false,
  digit? : Bool = false,
) -> String

pub(all) enum Tilde {
  Remove           // 削除する（既定）
  Ignore           // そのまま残す
  Normalize        // "~" にそろえる
  NormalizeZenkaku // "〜" にそろえる
} derive(Eq, Debug)

pub fn normalize(
  text : String,
  repeat? : Int = 0,
  remove_space? : Bool = true,
  max_repeat_substr_length? : Int = 8,
  tilde? : Tilde = Tilde::Remove,
) -> String

pub fn shorten_repeat(
  text : String,
  threshold : Int,
  max_repeat_substr_length? : Int = 8,
) -> String
```

関数名と既定値は jaconv・neologdn に合わせる。Python から移る人が表を引かずに使えるようにするため。

## 互換性の方針

出力は jaconv 0.5.0・neologdn 0.5.6 と完全に一致させる。移植元の癖も再現し、README の「既知の挙動」に書く。この一致は golden テストで確認する。

### 再現する癖

- **normalize：** 全角ハイフン「－」（U+FF0D）は長音「ー」になる。
  - `１－２` → `1ー2`
- **normalize：** 濁点が結合するのはカタカナ（半角カナ由来）と「う」だけ。半濁点はハ行（ひらがな・カタカナ）だけ。
  - `か゛` → `かﾞ`
  - `う゛` → `ゔ`
  - `は゜` → `ぱ`
- **normalize：** `¥` は `\` になる。全角の `＼` は変換しない。
- **normalize（空白）：** 直前の文字が ASCII（`*` を除く）のときだけ残る。ただし直後が漢字・かな・全角文字なら消える。
  - `a b` → `a b`
  - `a あ` → `aあ`
  - `😀 a` → `😀a`
  - `a * b` → `a *b`
- **normalize（チルダ類）：** 既定では削除する。
  - `～` → 空文字
- **h2z（濁点の結合と ignore）：** 半角濁点の結合は、`ignore` を見ずに先に行う。
  - `h2z("ｶﾞ", ignore="ｶ")` → `ガ`
- **h2z（結合できない濁点）：** 結合できない半角濁点・半濁点はそのまま残る。
  - `ｶﾟ` → `カﾟ`

### 意図して変える点

- **ignore：** jaconv は、変換表にない文字を `ignore` に渡すと KeyError を出す。jatext はその文字を無視して処理を続ける。MoonBit でここを例外にする理由がないため。
- **shorten_repeat の threshold：** 1 未満のときは入力をそのまま返す。neologdn では Python の負のスライスが効いて結果が不定になるため。

golden テストにはどちらのケースも入れていない。

## 実装メモ

- **文字単位の処理：** 文字列は Char（コードポイント）単位で扱い、UTF-16 のインデックスは使わない。テストには `𠮷` や絵文字を含むケースがある。
- **変換表：** 手書きせず、`tools/gen_tables.py` が jaconv・neologdn の表から `lib/tables.mbt`（`match` 式）を生成する。neologdn の表は pyx から写したもので、生成時にインストール済みの neologdn と突き合わせて確認する。
- **normalize：** neologdn の単一パスの状態機械（`pos` / `prev` / `lattin_space`）をそのまま移植する。`pos` を戻して上書きする箇所があるので、出力は StringBuilder ではなく `Array[Char]` と長さで持つ。
- **shorten_repeat：** `Array[Char]` に変換してから処理する。Python のスライスはコードポイント単位のため。`max_repeat_substr_length = 0` は無制限を意味する。
- **依存：** 外部パッケージには依存しない。

## パッケージ構成

strsim・sketch と同じ形にする。

```
jatext/
  moon.mod / moon.pkg
  top.mbt                     # lib の公開関数を再エクスポート
  README.mbt.md               # 例はそのままテストとして実行される（README.md はリンク）
  lib/                        # 本体（全関数をここに置く）
    kana.mbt / width.mbt / normalize.mbt / repeat.mbt
    tables.mbt                # 生成物。手で編集しない
    golden_*_wbtest.mbt       # 生成物。手で編集しない
    jatext_test.mbt           # 読める形の例
    bench_test.mbt            # moon bench 用
  cmd/main/                   # 動作確認用のサンプル
  tools/
    gen_tables.py / gen_golden.py / requirements.txt
  docs/design-v0.1.md
  NOTICE
```

## テスト

`lib/golden_*_wbtest.mbt` は、`tools/gen_golden.py` が参照実装を実行して生成する。4ファイルで約5,100ケースある。

- **1文字ずつの全変換：** ASCII、Latin-1、U+3000–30FF、U+FF00–FFEF と、ダッシュ・チルダ・引用符の変種。
- **z2h / h2z：** フラグ（kana・ascii・digit）の8通りすべて。
- **既知ケース：** neologdn のテストスイートと、上に挙げた癖のケース。
- **固定シードのランダム入力：** normalize 約1,200件、h2z 約630件、shorten_repeat 360件。

再生成の手順は次のとおり。出力はシード固定で毎回同じになる。参照実装のバージョンが違う場合、スクリプトは停止する。

```sh
pip install -r tools/requirements.txt
make gen
```

`moon test --target all` で、native・wasm-gc・js のすべてで通すこと。CI は加えて、生成物が最新か（再生成して差分がないか）も確認する。

## ベンチマーク

- `moon bench`（`@bench.T`、`lib/bench_test.mbt`）で、全角・半角が混ざった約1万文字の日本語テキストを normalize・z2h・h2z・hira2kata にかけ、target ごとの処理時間を出す。
- Python との比較は載せてもよいが、大差は期待しない。jaconv の中身は `str.translate`（C 実装）、neologdn は Cython（C++）なので、strsim のような差は出にくい。
- このライブラリの売りは速度より、「MoonBit で唯一」であることと「Wasm / JS でも同じ前処理を使える」こと。

## ライセンス

- 本体は Apache-2.0 にする。neologdn（Apache-2.0）とも jaconv（MIT）とも両立する。
- 変換表と挙動を移植するので、NOTICE に両方の著作権表示と jaconv の MIT ライセンス全文を入れる。NOTICE は作成済み。

## 完了条件

- [ ] golden テストの全件が native・wasm-gc・js で通る
- [ ] README に使い方、既知の挙動（上の癖）、jaconv・neologdn との関数の対応表を書く
- [ ] NOTICE を同梱する
- [ ] ベンチマークの結果を README に載せる
- [ ] mooncakes に v0.1.0 を公開する（Mac から行う。クラウド環境からは mooncakes に接続できない）

## 未決事項

- **モジュール名：** `jatext` で仮置きしている。他の候補と難点は次のとおり。
  - `jaconv`：Python 利用者には伝わるが、`normalize` の中身が jaconv の同名関数と違う。
  - `kana`：扱う範囲に対して名前が狭い。
- **癖を直すオプション：** normalize の癖を直すオプション（例：`strict_neologdn? : Bool = true`）を v0.2 で入れるか。

## v0.2 以降

- ローマ字変換（`kana2alphabet` / `alphabet2kana` / `kata2alphabet` / `alphabet2kata`）
- 漢数字、和暦
- strsim と組み合わせた、日本語のあいまい一致の例
- 形態素解析器（別モジュールにし、jatext を前処理に使う）
