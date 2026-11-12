.PHONY: dev test lint build

dev: test

test:
	./tests/test.sh

lint:
	shellcheck navigate.sh tests/test.sh tests/mock-herdr.sh
	luac -p editor/nvim.lua tests/nvim.lua
	HERDR_PANE_ID=w-test:p1 nvim --clean --headless -u NONE -es \
		+'source editor/vim.vim' +qa

build: lint
	python3 -c 'import pathlib, tomllib; tomllib.loads(pathlib.Path("herdr-plugin.toml").read_text())'
