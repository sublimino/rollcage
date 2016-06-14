#!/usr/bin/env bats

load test_helper

@test "push: accepts push with tag and image" {
    run_refute env -i \
      ${APP} push \
      --registry=registry.binarysludge.com \
      --registry-user=test-rollcage-user \
      --image='rollcage-test' \
      --tag='fruity-test' \
      --password='&B518isz0yaX!GYa$c2fnF'

    assert_output_contains 'tag does not exist: registry.binarysludge.com/test-rollcage-user/rollcage-test:fruity-test'
}
