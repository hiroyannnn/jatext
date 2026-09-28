///|
/// How `normalize` treats tilde-like characters
/// (`~` `∼` `∾` `〜` `〰` `～`).
pub(all) enum Tilde {
  /// Remove them (default, same as neologdn `tilde='remove'`).
  Remove
  /// Keep them as they are (`tilde='ignore'`).
  Ignore
  /// Replace them with `~` (`tilde='normalize'`).
  Normalize
  /// Replace them with `〜` (`tilde='normalize_zenkaku'`).
  NormalizeZenkaku
} derive(Eq, Debug)

///|
/// CJK unified ideographs, hiragana, katakana, CJK symbols and punctuation
/// (except U+3000) and halfwidth / fullwidth forms: the `blocks` set of
/// neologdn.
fn is_block_char(c : Char) -> Bool {
  let code = c.to_int()
  (code >= 0x4E00 && code < 0xA000) ||
  (code >= 0x3040 && code < 0x3100) ||
  (code >= 0x3001 && code < 0x3040) ||
  (code >= 0xFF00 && code < 0xFFF0)
}

///|
fn is_basic_latin(c : Char) -> Bool {
  c.to_int() < 0x80
}

///|
/// Normalizes Japanese text the same way as neologdn 0.5.6
/// (the preprocessing recommended for mecab-ipadic-NEologd).
///
/// - Full-width ASCII letters, digits and symbols become half-width.
/// - Half-width katakana become full-width, and `ﾞ` / `ﾟ` are joined to the
///   preceding katakana.
/// - Hyphen-like characters become `-`, long-vowel-like characters become
///   `ー`, and runs of them are collapsed to one.
/// - Tilde-like characters are handled according to `tilde`.
/// - Spaces are removed unless they separate two ASCII words
///   (`remove_space=false` keeps them).
/// - If `repeat` is not 0, repeated substrings are shortened with
///   `shorten_repeat(text, repeat, max_repeat_substr_length~)`.
///
/// The known quirks of neologdn are kept on purpose (for example `１－２`
/// becomes `1ー2`); see README.
pub fn normalize(
  text : String,
  repeat? : Int = 0,
  remove_space? : Bool = true,
  max_repeat_substr_length? : Int = 8,
  tilde? : Tilde = Tilde::Remove,
) -> String {
  if text.is_empty() {
    return ""
  }
  // `pos` can move back to overwrite the previous character, so the output
  // is kept in a fixed buffer rather than a StringBuilder.
  let buf : Array[Char] = Array::make(text.length() + 1, '\u{0}')
  let mut prev : Char = '\u{0}'
  let mut pos = 0
  let mut latin_space = false
  for ch in text {
    let mut c = ch
    if neologdn_is_space(c) {
      c = ' '
      if (pos == 0 || prev == ' ' || is_block_char(prev)) && remove_space {
        continue
      } else if prev != '*' && pos > 0 && is_basic_latin(prev) {
        latin_space = true
        buf[pos] = c
      } else if remove_space {
        if pos > 0 {
          pos -= 1
        }
      } else {
        buf[pos] = c
      }
    } else if neologdn_is_hyphen(c) {
      if prev == '-' {
        continue
      }
      c = '-'
      buf[pos] = c
      latin_space = false
    } else if neologdn_is_choonpu(c) {
      if prev == 'ー' {
        continue
      }
      c = 'ー'
      buf[pos] = c
      latin_space = false
    } else if neologdn_is_tilde(c) {
      match tilde {
        Tilde::Remove => continue
        Tilde::Ignore => ()
        Tilde::Normalize => {
          c = '~'
        }
        Tilde::NormalizeZenkaku => {
          c = '〜'
        }
      }
      buf[pos] = c
      latin_space = false
    } else {
      c = neologdn_convert(c)
      if c == 'ﾞ' && pos > 0 {
        match neologdn_kana_ten(prev) {
          Some(voiced) => {
            pos -= 1
            c = voiced
          }
          None => ()
        }
      } else if c == 'ﾟ' && pos > 0 {
        match neologdn_kana_maru(prev) {
          Some(semi_voiced) => {
            pos -= 1
            c = semi_voiced
          }
          None => ()
        }
      }
      if latin_space && pos > 0 && is_block_char(c) && remove_space {
        pos -= 1
      }
      latin_space = false
      buf[pos] = c
    }
    prev = c
    pos += 1
  }
  if pos > 0 && buf[pos - 1] == ' ' {
    pos -= 1
  }
  let sb = StringBuilder()
  for i in 0..<pos {
    sb.write_char(buf[i])
  }
  let result = sb.to_string()
  if repeat != 0 {
    shorten_repeat(
      result,
      repeat,
      max_repeat_substr_length=max_repeat_substr_length,
    )
  } else {
    result
  }
}
