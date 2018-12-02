#!/usr/bin/env bats

source "$BATS_TEST_DIRNAME/bats-setup.sh"

@test "Selection: no instances selected" {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

	TERM_PROGRAM=Apple_Terminal run $spoon foo <<< ''

	assert_success
	assert_equal $(mock_get_call_num $mock_ssh_path) 0
}

@test "Selection: all instances selected via *" {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

	TERM_PROGRAM=Apple_Terminal run $spoon foo <<< '*'

	assert_success
	assert_equal $(mock_get_call_num $mock_csshx_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" \
		"1.1.1.1 2.2.2.2 3.3.3.3 4.4.4.4 5.5.5.5 6.6.6.6 7.7.7.7 8.8.8.8 9.9.9.9"
}

@test "Selection: invalid selector (letters)" {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

	TERM_PROGRAM=Apple_Terminal run $spoon foo <<< gibberish

	assert_failure
	assert_line "[spoon] jq error: invalid selector"
}

@test "Selection: a single instance selected" {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

	TERM_PROGRAM=Apple_Terminal run $spoon foo <<< 1

	assert_success
	assert_equal $(mock_get_call_num $mock_ssh_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_ssh_path)" '1.1.1.1'
}

@test "Selection: multiple single instances selected" {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

	TERM_PROGRAM=Apple_Terminal run $spoon foo <<< '1, 5'

	assert_success
	assert_equal $(mock_get_call_num $mock_csshx_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" '1.1.1.1 5.5.5.5'
}

@test "Selection: single instance index out of range" {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

	TERM_PROGRAM=Apple_Terminal run $spoon foo <<< 99

	assert_success
	assert_equal $(mock_get_call_num $mock_ssh_path) 0
}

@test "Selection: one range selected" {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

	TERM_PROGRAM=Apple_Terminal run $spoon foo <<< '1-5'

	assert_success
	assert_equal $(mock_get_call_num $mock_csshx_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" \
		'1.1.1.1 2.2.2.2 3.3.3.3 4.4.4.4 5.5.5.5'
}

@test "Selection: multiple ranges selected" {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

	TERM_PROGRAM=Apple_Terminal run $spoon foo <<< '1-3, 7-9'

	assert_success
	assert_equal $(mock_get_call_num $mock_csshx_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" \
		'1.1.1.1 2.2.2.2 3.3.3.3 7.7.7.7 8.8.8.8 9.9.9.9'
}

@test "Selection: range selector out of range" {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

	TERM_PROGRAM=Apple_Terminal run $spoon foo <<< '8-12'

	assert_success
	assert_equal $(mock_get_call_num $mock_csshx_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" "8.8.8.8 9.9.9.9"
}

@test "Selection: single and range selectors mixed" {
	mock_set_output $mock_aws_path "$(cat $BATS_TEST_DIRNAME/data/multiple-many.json)"

	TERM_PROGRAM=Apple_Terminal run $spoon foo <<< '2, 4-6, 8'

	assert_success
	assert_equal $(mock_get_call_num $mock_csshx_path) 1
	assert_equal_regex "$(mock_get_call_args $mock_csshx_path)" "2.2.2.2 4.4.4.4 5.5.5.5 6.6.6.6 8.8.8.8"
}
