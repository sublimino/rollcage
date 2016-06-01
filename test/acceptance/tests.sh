#!/usr/bin/env bats

load test_helper

@test "tests: runs passing command in container" {
    run_assert env -i \
      ${APP} build --config-file=test/fixture/simple/.rollcage \
      --pull=false --tag=123 \
      --build-path=test/fixture/simple/ \
      --image=toast --tag=1234 \
      --test='[ -f /.dockerenv ]'
}

@test "tests: runs failing command in container" {
    run_refute env -i \
      ${APP} build --config-file=test/fixture/simple/.rollcage \
      --pull=false --tag=123 \
      --build-path=test/fixture/simple/ \
      --image=toast --tag=1234 \
      --test='[ ! -f /.dockerenv ]'
}

