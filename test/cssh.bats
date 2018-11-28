#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

@test "If multiple instances are returned, spoon should check the availability of a cssh utility (csshx on Terminal)." {
	# setup
	export mock_command_path="$(mock_create)"
	function command() {
		bash "${mock_command_path}" "${@}"
	}
	export -f command

	# GIVEN
	mock_set_status $mock_command_path 1
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

	# WHEN
	TERM_PROGRAM=Apple_Terminal run $spoon foo

	#THEN
	assert_failure
	assert_output "Please install csshX to SSH to multiple instances."
	assert_equal $(mock_get_call_num $mock_csshx_path) 0

	# teardown
	unset mock_command_path command
}

@test "If multiple instances are returned, spoon should check the availability of a cssh utility (i2cssh on iTerm2)." {
	# setup
	export mock_command_path="$(mock_create)"
	function command() {
		bash "${mock_command_path}" "${@}"
	}
	export -f command

	# GIVEN
	mock_set_status $mock_command_path 1
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

	# WHEN
	TERM_PROGRAM=iTerm.app run $spoon foo

	#THEN
	assert_failure
	assert_output "Please install i2cssh to SSH to multiple instances."
	assert_equal $(mock_get_call_num $mock_i2cssh_path) 0

	# teardown
	unset mock_command_path command
}

@test "If multiple instances are returned, and a cssh utility is available (csshx on Terminal), spoon should pass all the IPs to it." {
	# setup
	export mock_command_path="$(mock_create)"
	function command() {
		bash "${mock_command_path}" "${@}"
	}
	export -f command

	# GIVEN
	mock_set_status $mock_command_path 0
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

	# WHEN
	TERM_PROGRAM=Apple_Terminal run $spoon foo

	#THEN
	assert_success
	assert_equal $(mock_get_call_num $mock_csshx_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" '1.1.1.1 2.2.2.2 3.3.3.3'

	# teardown
	unset mock_command_path command
}

@test "If multiple instances are returned, and a cssh utility is available (i2cssh on iTerm2), spoon should pass all the IPs to it." {
	# setup
	export mock_command_path="$(mock_create)"
	function command() {
		bash "${mock_command_path}" "${@}"
	}
	export -f command

	# GIVEN
	mock_set_status $mock_command_path 0
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple.json)"

	# WHEN
	TERM_PROGRAM=iTerm.app run $spoon foo

	#THEN
	assert_success
	assert_equal $(mock_get_call_num $mock_i2cssh_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_i2cssh_path)" '1.1.1.1 2.2.2.2 3.3.3.3'

	# teardown
	unset mock_command_path command
}