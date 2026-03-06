.PHONY: pub-get format prepare format-exiting-if-changed analyze test png-to-webp ci

pub-get:
	flutter pub get

format:
	dart format --line-length=120 lib test

prepare: pub-get format

format-exiting-if-changed:
	dart format --line-length=120 --set-exit-if-changed lib test

analyze:
	flutter analyze --no-pub .

test:
	flutter test --no-pub --coverage

png-to-webp:
	find assets/images -name '*.png' | awk -F ".png" '{printf "%s\n", $$1}' | xargs -I% bash -c 'cwebp -q 80 %.png -o %.webp && rm %.png'

version := $(shell grep '^version:' pubspec.yaml | sed 's/version:[[:space:]]*//')

ci: format analyze test

publish-version:
	@read -p "Describe the changes you made to the package: " changes; \
	old="$(version)"; \
	new="$$(echo $$old | awk -F. '{printf "%d.%d.%d", $$1, $$2, $$3 + 1}')"; \
	sed -i '' "s/^version: $$old/version: $$new/" pubspec.yaml; \
	git add pubspec.yaml; \
	git commit -m "Bump to new version $$new"; \
	git push; \
	git tag -a v$$new -m "Version v$$new : $$changes"; \
	git push origin v$$new