#!/usr/bin/env bash

echo $BASH_VERSION
[ "$(which bash)" = '/usr/local/bin/bash' ]; \
bash --version; \
[ "$(bash -c 'echo "${BASH_VERSION%%[^0-9.]*}"')" = "$_BASH_VERSION" ]; \
bash -c 'help' > /dev/null
sleep 1

testUseProgramNameEmpty() {
	use_program
	assertEquals 2 $?
}

testUseProgramVersionEmpty() {
	use_program _BASH_VERSION
	assertEquals 3 $?
}

testUseProgramProgramsDirDoesntExist() {
	FOUNDRY_BIN_DIR='/non/existent'
	local msg=$(
		use_program bash 5.1.0(1)-release 2>&1
		assertEquals 1 $?
	)
	assertEquals "Not installed: bash 5.1.0(1)-release" "$msg"
}

testUseProgramNotInstalled() {
	local msg=$(
		use_program bash 5.1.0(1)-release 2>&1
		assertEquals 1 $?
	)
	assertEquals "Not installed: bash 5.1.0(1)-release" "$msg"
}

testUseProgramNotInstalledInstalledOne() {
	mkdir $pd/bash

	local msg=$(
		use_program bash 5.1.0(1)-release 2>&1
		assertEquals 1 $?
	)
	assertEquals "Not installed: bash 5.1.0(1)-release" "$msg"
}
