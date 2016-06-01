#!/usr/bin/env bats

load test_helper

@test "login: accepts --registry-pass arg" {
    run_refute env -i \
      ${APP} login --registry-user=123 --registry-pass=123
    assert_output_contains "unauthorized: incorrect username or password"
}

@test "login: succeeds with valid credentials" {
    run_assert env -i \
      ${APP} login \
      --registry-host=registry.binarysludge.com \
      --registry-user=test-rollcage-user \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'
    assert_output_contains "Login Succeeded"
}

@test "login: accepts environment variable for user" {
    run_assert env -i \
      REGISTRY_USER='test-rollcage-user' \
      ${APP} login \
      --registry-host=registry.binarysludge.com \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'
    assert_output_contains "Login Succeeded"
}

@test "login: accepts environment variable for password" {
    run_assert env -i \
      REGISTRY_PASS='&B518isz0yaX!GYa$c2fnF' \
      ${APP} login \
      --registry-host=registry.binarysludge.com \
      --registry-user=test-rollcage-user
    assert_output_contains "Login Succeeded"
}

@test "login: accepts environment variable for host" {
    run_assert env -i \
      REGISTRY_HOST='registry.binarysludge.com' \
      ${APP} login \
      --registry-user=test-rollcage-user \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'
    assert_output_contains "Login Succeeded"
}

@test "login: prioritises arguments over environment variables" {
    run_assert env -i \
      REGISTRY_USER='wrong-user' \
      REGISTRY_PASS='wrong-pass' \
      REGISTRY_HOST='wrong-registry.binarysludge.com' \
      ${APP} login \
      --registry-host=registry.binarysludge.com \
      --registry-user=test-rollcage-user \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'
    assert_output_contains "Login Succeeded"
}
