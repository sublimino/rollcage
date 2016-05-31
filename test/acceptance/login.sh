#!/usr/bin/env bats

load test_helper

@test "login: accepts login action" {
    refute ${APP} login
    refute_output_contains "Action required"
}

@test "login: rejects empty --registry-pass arg" {
    refute ${APP} login --registry-pass
    assert_output_contains "Non-empty value required"
}

@test "login: rejects without --registry-user arg" {
    refute ${APP} login
    assert_output_contains "--registry-user required for login"
}

@test "login: rejects without --registry-pass arg" {
    refute ${APP} login --registry-user=123
    assert_output_contains "--registry-pass required for login"
}

@test "login: accepts --registry-pass arg" {
    refute ${APP} --debug login --registry-user=123 --registry-pass=123
    assert_output_contains "unauthorized: incorrect username or password"
}

@test "login: succeeds with valid credentials" {
    assert ${APP} login --registry-host=registry.binarysludge.com \
      --registry-user=test-rollcage-user \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'
    assert_output_contains "Login Succeeded"
}
