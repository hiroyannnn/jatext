.PHONY: test check gen bench release

GENERATED = lib/tables.mbt lib/golden_*_wbtest.mbt

test:
	moon test --target all

# moon fmt also touches the generated files; restore them afterwards.
check:
	moon check
	moon fmt
	git checkout -- $(GENERATED)
	git diff --exit-code

# Needs: pip install -r tools/requirements.txt
gen:
	python3 tools/gen_tables.py
	python3 tools/gen_golden.py

bench:
	moon bench --target native

# Usage: make release v=0.2.0
release:
	@test -n "$(v)" || (echo "Usage: make release v=0.2.0" && exit 1)
	@moon test --target all
	sed -i '' 's/^version = "[^"]*"/version = "$(v)"/' moon.mod
	git add moon.mod
	git commit -m "release: v$(v)"
	git push
	gh release create "v$(v)" --generate-notes
