///|
/// Applies `table` to each character of `text`, leaving characters in
/// `ignore` (and characters the table does not cover) unchanged.
///
/// Unlike jaconv, characters in `ignore` that the table does not cover are
/// accepted silently instead of raising an error.
fn translate(
  text : String,
  ignore : String,
  table : (Char) -> String?,
) -> String {
  let sb = StringBuilder()
  for c in text {
    if ignore.contains_char(c) {
      sb.write_char(c)
      continue
    }
    match table(c) {
      Some(s) => sb.write_string(s)
      None => sb.write_char(c)
    }
  }
  sb.to_string()
}

///|
/// Converts hiragana to full-width katakana (jaconv `hira2kata`).
///
/// Characters in `ignore` are left as they are.
pub fn hira2kata(text : String, ignore? : String = "") -> String {
  translate(text, ignore, hira2kata_table)
}

///|
/// Converts full-width katakana to hiragana (jaconv `kata2hira`).
///
/// Characters in `ignore` are left as they are.
pub fn kata2hira(text : String, ignore? : String = "") -> String {
  translate(text, ignore, kata2hira_table)
}

///|
/// Converts hiragana to half-width katakana (jaconv `hira2hkata`).
///
/// Voiced kana become two characters (`が` -> `ｶﾞ`). Characters in `ignore`
/// are left as they are.
pub fn hira2hkata(text : String, ignore? : String = "") -> String {
  translate(text, ignore, hira2hkata_table)
}

///|
/// Converts small kana to their normal size (jaconv `enlarge_smallkana`).
///
/// Characters in `ignore` are left as they are.
pub fn enlarge_smallkana(text : String, ignore? : String = "") -> String {
  translate(text, ignore, enlarge_smallkana_table)
}
