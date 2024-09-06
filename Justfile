test:
	bats -T -j $(nproc) src/*.test.bats

[private]
ci: test

[private]
pre-commit: test
