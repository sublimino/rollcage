#!/usr/bin/env bats

load test_helper

@test "login: accepts login action" {
    run_refute  ${APP} login
    refute_output_contains "Action required"
}

@test "login: rejects empty --registry-pass arg" {
    run_refute  ${APP} login --registry-pass
    assert_output_contains "Non-empty value required"
}

@test "login: rejects without --registry-user arg" {
    run_refute  ${APP} login
    assert_output_contains "--registry-user required for login"
}

@test "login: rejects without --registry-pass arg" {
    run_refute  ${APP} login --registry-user=123
    assert_output_contains "--registry-pass required for login"
}

