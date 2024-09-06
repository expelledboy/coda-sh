test:
	bats -T -j $(nproc) src/*.test.bats
