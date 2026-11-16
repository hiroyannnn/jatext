///|
/// About 10,000 characters of mixed Japanese / full-width / half-width text.
fn bench_text() -> String {
  let sb = StringBuilder()
  for i in 0..<200 {
    sb.write_string(
      "南アルプスの　天然水　Ｓｐａｒｋｉｎｇ　Ｌｅｍｏｎ　ﾚﾓﾝ一絞り。ﾃｨﾛ･ﾌｨﾅｰﾚ〜！！",
    )
    sb.write_string(i.to_string())
  }
  sb.to_string()
}

///|
test "bench normalize" (it : @bench.T) {
  let text = bench_text()
  it.bench(fn() { ignore(@lib.normalize(text)) })
}

///|
test "bench z2h (kana, ascii, digit)" (it : @bench.T) {
  let text = bench_text()
  it.bench(fn() { ignore(@lib.z2h(text, ascii=true, digit=true)) })
}

///|
test "bench h2z (kana, ascii, digit)" (it : @bench.T) {
  let text = bench_text()
  it.bench(fn() { ignore(@lib.h2z(text, ascii=true, digit=true)) })
}

///|
test "bench hira2kata" (it : @bench.T) {
  let text = bench_text()
  it.bench(fn() { ignore(@lib.hira2kata(text)) })
}
