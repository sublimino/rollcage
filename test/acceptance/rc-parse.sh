#!/usr/bin/env bats

load test_helper

@test "file: reads registry-user" {
    run env -i \
      ${APP} --help
}
