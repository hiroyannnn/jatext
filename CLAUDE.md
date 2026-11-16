# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**jatext** is a MoonBit library for Japanese text conversion and normalization. Its output must match
jaconv 0.5.0 (kana / width conversion) and neologdn 0.5.6 (NEologd normalization) exactly, quirks included.

## Build & Test Commands

```bash
moon check              # Type-check / lint
moon test               # Run all tests (default target)
moon test --target all  # Run tests on all targets (wasm, wasm-gc, js, native)
moon info               # Regenerate .mbti interface files (run after API changes)
moon fmt                # Format code (also touches generated files; see below)
```

Before committing: `moon info && make check && moon test --target all`

Makefile shortcuts:

```bash
make test               # moon test --target all
make check              # moon check + moon fmt (generated files restored) + git diff --exit-code
make gen                # Regenerate lib/tables.mbt and lib/golden_*_wbtest.mbt
make bench              # moon bench --target native
make release v=0.2.0    # Test → bump version → commit → push → gh release create
```

`make gen` needs `pip install -r tools/requirements.txt` (jaconv==0.5.0, neologdn==0.5.6).
Release triggers `release.yml`, which runs `moon publish` to mooncakes.io with the `MOON_TOKEN` secret.

## Architecture

- `lib/` — Core library package
  - `kana.mbt` — `hira2kata` / `kata2hira` / `hira2hkata` / `enlarge_smallkana` and the shared `translate`
  - `width.mbt` — `z2h` / `h2z` (h2z joins `ﾞ` / `ﾟ` before the table lookup, ignoring `ignore`)
  - `normalize.mbt` — neologdn `normalize` ported as the same single-pass state machine, and the `Tilde` enum
  - `repeat.mbt` — neologdn `shorten_repeat` on `Array[Char]` with Python slice semantics
  - `tables.mbt` — **generated** conversion tables (`tools/gen_tables.py`)
  - `golden_*_wbtest.mbt` — **generated** differential tests, ~5,100 cases (`tools/gen_golden.py`)
  - `jatext_test.mbt` — readable examples; `bench_test.mbt` — benchmarks
- `top.mbt` — Re-exports the public API via `pub using @lib { ... }`
- `tools/` — Python generators that run the reference implementations
- `docs/design-v0.1.md` — Scope, compatibility policy and known quirks (Japanese)

## Rules

- Never edit generated files by hand; change the generator and run `make gen`. CI fails if they are stale.
- Keep reference quirks. A behavior change needs an option and an entry in README.mbt.md.
- Process text per `Char` (code point), never by UTF-16 index.

## License

Apache License 2.0. Tables and behavior are ported from jaconv (MIT) and neologdn (Apache-2.0); see NOTICE.
