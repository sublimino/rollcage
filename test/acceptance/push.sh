#!/usr/bin/env bats

load test_helper

@test "push: accepts --pull arg" {
    run ${APP} build --pull=true --image-tag=123
    assert_output_contains "latest: Pulling from"
}
