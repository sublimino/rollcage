#!/usr/bin/env bats

load test_helper

@test "file: reads config file" {
    run env -i \
      ${APP} --config-file=test/fixture/simple/.rollcage \
      get-tags \
      --image=toast --tag=1234

    assert_output_contains "somewhere.internet.like/herbert/toast:1234"
}

@test "file: ignores missing config file" {
    run env -i \
      ${APP} --config-file=non-extant-file \
      get-tags --image=cereal --tag=9090

    assert_output_contains "cereal:9090"
}
