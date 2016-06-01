#!/usr/bin/env bats

load test_helper

@test "push: rejects push without tag and image" {
    run_refute env -i \
      ${APP} push \
      --registry-host=registry.binarysludge.com \
      --registry-user=test-rollcage-user \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'

    assert_output_contains '--image-tag or $CI_BUILD_ID env var required'
}

@test "push: rejects push without tag" {
    run_refute env -i \
      ${APP} push \
      --registry-host=registry.binarysludge.com \
      --registry-user=test-rollcage-user \
      --image-name='test-rollcage' \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'

    assert_output_contains '--image-tag or $CI_BUILD_ID env var required'
}

@test "push: accepts push with tag and image" {
    run_refute env -i \
      ${APP} push \
      --registry-host=registry.binarysludge.com \
      --registry-user=test-rollcage-user \
      --image-name='test-rollcage' \
      --image-tag='fruity-test' \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'

    assert_output_contains 'tag does not exist: registry.binarysludge.com/test-rollcage-user/test-rollcage:fruity-test'
}
