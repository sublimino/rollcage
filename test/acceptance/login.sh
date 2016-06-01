#!/usr/bin/env bats

load test_helper

@test "login: accepts login action" {
    run_refute env -i \
      ${APP} login
    refute_output_contains "Action required"
}

@test "login: rejects empty --password arg" {
    run_refute env -i \
      ${APP} login --password
    assert_output_contains "Non-empty value required"
}

@test "login: rejects without --registry-user arg" {
    run_refute  env -i \
      ${APP} login
    assert_output_contains "--registry-user required for login"
}

@test "login: rejects without --password arg" {
    run_refute  env -i \
      ${APP} login --registry-user=123
    assert_output_contains "--password required for login"
}

