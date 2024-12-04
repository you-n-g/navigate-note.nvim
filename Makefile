TESTS_INIT=tests/minimal_init.lua
TESTS_DIR=tests/

.PHONY: test test-lazy test-pckr

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${TESTS_INIT} \
		-c "PlenaryBustedDirectory ${TESTS_DIR} { minimal_init = '${TESTS_INIT}' }"

test-lazy:
	./tests/init_conf/venv.sh -u tests/init_conf/lazy.lua -U NONE -N -i NONE
test-pckr:
	./tests/init_conf/venv.sh -u tests/init_conf/pckr.lua -U NONE -N -i NONE
