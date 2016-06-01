#!/usr/bin/env bats

load test_helper

setup() {
    CI_BUILD_ID=foreign-test

    ${APP} build --pull=false \
      --image-user='sublimino' \
      --image-name='test-rollcage-other-user' \
      --image-tag="${CI_BUILD_ID}" \
      --registry-host='registry.binarysludge.com' \
      --build-path='test/fixture/simple/'

    docker logout "${TEST_REGISTRY_HOST}"
}

teardown() {
    unset CI_BUILD_ID
}

@test "push: logs in automatically and pushes to another user's repo" {
    CI_BUILD_ID=foreign-test

    run_assert ${APP} push \
      --image-user='sublimino' \
      --image-name='test-rollcage-other-user' \
      --image-tag="${CI_BUILD_ID}" \
      --registry-host='registry.binarysludge.com' \
      --registry-user='test-rollcage-user' \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'

    assert_output_contains "${CI_BUILD_ID}: digest: sha256:"
}

@test "push: logs in automatically and pushes to another user's repo using name" {
    CI_BUILD_ID=foreign-test-2

    run_assert ${APP} push \
      --push-image=registry.binarysludge.com/sublimino/test-rollcage-other-user \
      --registry-host='registry.binarysludge.com' \
      --registry-user='test-rollcage-user' \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'

    assert_output_contains "latest: digest: sha256:"
}
