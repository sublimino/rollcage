#!/usr/bin/env bats

load test_helper

@test "login: accepts --registry-pass arg" {
    refute ${APP} --debug login --registry-user=123 --registry-pass=123
    assert_output_contains "unauthorized: incorrect username or password"
}

@test "login: succeeds with valid credentials" {
    assert ${APP} login \
      --registry-host=registry.binarysludge.com \
      --registry-user=test-rollcage-user \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'
    assert_output_contains "Login Succeeded"
}

@test "login: accepts environment variable for user" {
    REGISTRY_USER='test-rollcage-user' \
      assert ${APP} login \
      --registry-host=registry.binarysludge.com \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'
    assert_output_contains "Login Succeeded"
}

@test "login: accepts environment variable for password" {
    REGISTRY_PASS='&B518isz0yaX!GYa$c2fnF' \
      assert ${APP} login \
      --registry-host=registry.binarysludge.com \
      --registry-user=test-rollcage-user
    assert_output_contains "Login Succeeded"
}

@test "login: accepts environment variable for host" {
    REGISTRY_HOST='registry.binarysludge.com' \
      assert ${APP} login \
      --registry-user=test-rollcage-user \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'
    assert_output_contains "Login Succeeded"
}

@test "login: prioritises arguments over environment variables" {
    REGISTRY_USER='wrong-user' \
    REGISTRY_PASS='wrong-pass' \
    REGISTRY_HOST='wrong-registry.binarysludge.com' \
      assert ${APP} login \
      --registry-host=registry.binarysludge.com \
      --registry-user=test-rollcage-user \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'
    assert_output_contains "Login Succeeded"
}
