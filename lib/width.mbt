///|
fn z2h_lookup(c : Char, kana : Bool, ascii : Bool, digit : Bool) -> String? {
  if ascii {
    match z2h_ascii_table(c) {
      Some(s) => return Some(s)
      None => ()
    }
  }
  if digit {
    match z2h_digit_table(c) {
      Some(s) => return Some(s)
      None => ()
    }
  }
  if kana {
    match z2h_kana_table(c) {
      Some(s) => return Some(s)
      None => ()
    }
  }
  None
}

///|
fn h2z_lookup(c : Char, kana : Bool, ascii : Bool, digit : Bool) -> String? {
  if ascii {
    match h2z_ascii_table(c) {
      Some(s) => return Some(s)
      None => ()
    }
  }
  if digit {
    match h2z_digit_table(c) {
      Some(s) => return Some(s)
      None => ()
    }
  }
  if kana {
    match h2z_kana_table(c) {
      Some(s) => return Some(s)
      None => ()
    }
  }
  None
}

///|
/// Converts full-width characters to half-width (jaconv `z2h`).
///
/// - `kana`: full-width katakana and Japanese punctuation (default: `true`)
/// - `ascii`: full-width ASCII letters, symbols and the ideographic space
///   (default: `false`)
/// - `digit`: full-width digits (default: `false`)
///
/// Characters in `ignore` are left as they are.
pub fn z2h(
  text : String,
  ignore? : String = "",
  kana? : Bool = true,
  ascii? : Bool = false,
  digit? : Bool = false,
) -> String {
  translate(text, ignore, fn(c) { z2h_lookup(c, kana, ascii, digit) })
}

///|
/// Joins a half-width kana and a following half-width (han)dakuten into one
/// full-width kana (`ｶﾞ` -> `ガ`), the same way jaconv `h2z` does before its
/// table lookup.
fn compose_half_kana_marks(text : String) -> String {
  let chars = text.to_array()
  let n = chars.length()
  let sb = StringBuilder()
  let mut i = 0
  while i < n {
    let c = chars[i]
    if i + 1 < n {
      match half_kana_compose(c, chars[i + 1]) {
        Some(composed) => {
          sb.write_char(composed)
          i += 2
          continue
        }
        None => ()
      }
    }
    sb.write_char(c)
    i += 1
  }
  sb.to_string()
}

///|
/// Converts half-width characters to full-width (jaconv `h2z`).
///
/// - `kana`: half-width katakana and Japanese punctuation (default: `true`).
///   A half-width kana followed by `ﾞ` or `ﾟ` is joined into one character
///   (`ｶﾞ` -> `ガ`). This joining ignores `ignore`, as in jaconv.
/// - `ascii`: ASCII letters, symbols and the space (default: `false`)
/// - `digit`: digits (default: `false`)
///
/// Characters in `ignore` are otherwise left as they are.
pub fn h2z(
  text : String,
  ignore? : String = "",
  kana? : Bool = true,
  ascii? : Bool = false,
  digit? : Bool = false,
) -> String {
  let source = if kana { compose_half_kana_marks(text) } else { text }
  translate(source, ignore, fn(c) { h2z_lookup(c, kana, ascii, digit) })
}
