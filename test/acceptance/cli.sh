#!/usr/bin/env bats

load test_helper

@test "cli: has --help" {
    run ${APP} --help
    assert_output_contains '--version'
    assert_output_contains 'Print version'
}

@test "cli: has --version" {
    run ${APP} --version
    assert_output_contains '0.0.1'
}

@test "parser: rejects empty --pull arg" {
    run_refute  ${APP} --pull
}

@test "parser: rejects invalid --pull arg" {
    run_refute  ${APP} --pull --version
}

