#!/usr/bin/env bats

load test_helper

@test "CLI has --help" {
    run ${APP} --help
    assert_output_contains '--version'
    assert_output_contains 'Print version'
}

@test "CLI has --version" {
    run ${APP} --version
    assert_output_contains '0.0.1'
}
