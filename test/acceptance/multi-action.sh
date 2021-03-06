#!/usr/bin/env bats

load test_helper

@test "multi-action: accepts more than one action" {
    run env -i \
      timeout -k 1 1 \
      ${APP} \
      get-tags \
      build \
      --pull=false

    assert_line 0 'rollcage:dev'
    assert_output_contains 'docker build'
}
