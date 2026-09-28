///|
/// `a[start:end]` with Python slice semantics for non-negative indices.
fn slice_chars(a : Array[Char], start : Int, end : Int) -> Array[Char] {
  let len = a.length()
  let s = if start > len { len } else { start }
  let e = if end > len { len } else { end }
  let out : Array[Char] = []
  for i in s..<e {
    out.push(a[i])
  }
  out
}

///|
/// Shortens a substring repeated more than `threshold` times in a row to
/// exactly `threshold` repetitions (neologdn `shorten_repeat`).
///
/// Only substrings of up to `max_repeat_substr_length` characters are
/// considered; `0` means no limit. Lengths are counted in code points.
///
/// `threshold` must be at least 1. For smaller values the text is returned
/// unchanged (neologdn gives slice-dependent results there).
pub fn shorten_repeat(
  text : String,
  threshold : Int,
  max_repeat_substr_length? : Int = 8,
) -> String {
  if threshold < 1 {
    return text
  }
  let mut chars = text.to_array()
  let mut i = 0
  while i < chars.length() {
    // As in neologdn, `text_length` and the range of lengths are fixed at the
    // start of each position even if the text is shortened below.
    let text_length = chars.length()
    let mut upper = (text_length - i) / 2
    if max_repeat_substr_length != 0 && max_repeat_substr_length < upper {
      upper = max_repeat_substr_length + 1
    }
    for repeat_length in 1..<upper {
      let substr = slice_chars(chars, i, i + repeat_length)
      let mut right_start = i + repeat_length
      let mut right_end = right_start + repeat_length
      let mut right = slice_chars(chars, right_start, right_end)
      let mut count = 1
      while substr == right && right_end <= text_length {
        count += 1
        right_start += repeat_length
        right_end += repeat_length
        right = slice_chars(chars, right_start, right_end)
      }
      if count > threshold {
        let head = slice_chars(chars, 0, i + repeat_length * threshold)
        let tail = slice_chars(
          chars,
          i + repeat_length * count,
          chars.length(),
        )
        head.push_iter(tail.iter())
        chars = head
      }
    }
    i += 1
  }
  String::from_array(chars)
}
