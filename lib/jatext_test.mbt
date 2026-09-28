///|
test "hira2kata" {
  inspect(@lib.hira2kata("ともえまみ"), content="トモエマミ")
  inspect(@lib.hira2kata("まどまぎ", ignore="ど"), content="マどマギ")
}

///|
test "kata2hira" {
  inspect(@lib.kata2hira("巴マミ"), content="巴まみ")
}

///|
test "hira2hkata" {
  inspect(@lib.hira2hkata("ともえまみ"), content="ﾄﾓｴﾏﾐ")
  inspect(@lib.hira2hkata("がっこう"), content="ｶﾞｯｺｳ")
}

///|
test "enlarge_smallkana" {
  inspect(@lib.enlarge_smallkana("キュゥべえ"), content="キユウべえ")
}

///|
test "z2h" {
  inspect(@lib.z2h("ティロフィナーレ"), content="ﾃｨﾛﾌｨﾅｰﾚ")
  inspect(
    @lib.z2h("ＡＢＣ１２３　アイウ", ascii=true, digit=true),
    content="ABC123 ｱｲｳ",
  )
  inspect(@lib.z2h("ＡＢＣ１２３", kana=false, digit=true), content="ＡＢＣ123")
}

///|
test "h2z" {
  inspect(@lib.h2z("ﾃｨﾛﾌｨﾅｰﾚ"), content="ティロフィナーレ")
  inspect(@lib.h2z("ｶﾞｯｺｳ"), content="ガッコウ")
  inspect(@lib.h2z("abc123", ascii=true, digit=true), content="ａｂｃ１２３")
}

///|
test "normalize" {
  inspect(
    @lib.normalize("　　　ＰＲＭＬ　　副　読　本　　　"),
    content="PRML副読本",
  )
  inspect(
    @lib.normalize("南アルプスの　天然水　Ｓｐａｒｋｉｎｇ　Ｌｅｍｏｎ　レモン一絞り"),
    content="南アルプスの天然水Sparking Lemonレモン一絞り",
  )
  inspect(@lib.normalize("ﾊﾝｶｸｶﾀｶﾅ ﾊﾟﾊﾟ"), content="ハンカクカタカナパパ")
  inspect(@lib.normalize("スーパーーーー"), content="スーパー")
}

///|
test "normalize: options" {
  inspect(@lib.normalize("1467〜1487年"), content="14671487年")
  inspect(
    @lib.normalize("1467〜1487年", tilde=@lib.Tilde::Normalize),
    content="1467~1487年",
  )
  inspect(
    @lib.normalize("1467~1487年", tilde=@lib.Tilde::NormalizeZenkaku),
    content="1467〜1487年",
  )
  inspect(@lib.normalize("巴 マミ", remove_space=false), content="巴 マミ")
  inspect(@lib.normalize("うまああああああい", repeat=2), content="うまああい")
}

///|
test "normalize: neologdn quirks are kept" {
  inspect(@lib.normalize("１－２"), content="1ー2")
  inspect(@lib.normalize("か゛"), content="かﾞ")
  inspect(@lib.normalize("¥100"), content="\\100")
}

///|
test "shorten_repeat" {
  inspect(@lib.shorten_repeat("無駄無駄無駄無駄ァ", 1), content="無駄ァ")
  inspect(@lib.shorten_repeat("オラオラオラオラーッ", 2), content="オラオラーッ")
  // threshold < 1 is not supported and returns the input unchanged
  inspect(@lib.shorten_repeat("ああああ", 0), content="ああああ")
}

///|
test "ignore accepts characters outside the table" {
  // jaconv raises KeyError here; jatext just leaves them alone.
  inspect(@lib.hira2kata("あいう", ignore="xい"), content="アいウ")
}
