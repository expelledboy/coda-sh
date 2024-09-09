test:
	bats -T -j $(nproc) src/**/*.test.bats

[private]
ci: test

[private]
pre-commit:
	editorconfig-checker -v

[private]
pre-push: test
