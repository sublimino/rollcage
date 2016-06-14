#!/usr/bin/env bats

load test_helper

setup() {
    env -i \
      ${APP} build --pull='false' \
      --user='sublimino' \
      --image='rollcage-test-other-user' \
      --tag="foreign-test" \
      --registry='registry.binarysludge.com' \
      --build-path='test/fixture/simple/'

    docker logout "${TEST_REGISTRY_HOST}"
}

teardown() {
    unset CI_BUILD_ID
}

@test "push: logs in automatically and pushes to another user's repo" {
    run_assert ${APP} push \
      --user='sublimino' \
      --image='rollcage-test-other-user' \
      --tag=foreign-test \
      --registry='registry.binarysludge.com' \
      --registry-user='test-rollcage-user' \
      --password='&B518isz0yaX!GYa$c2fnF'

    assert_output_contains "foreign-test: digest: sha256:"
}

@test "push: logs in automatically and pushes to another user's repo using name" {
    run_assert env -i \
      ${APP} push \
      'registry.binarysludge.com/sublimino/rollcage-test-other-user' \
      --registry='registry.binarysludge.com' \
      --registry-user='test-rollcage-user' \
      --password='&B518isz0yaX!GYa$c2fnF'

    assert_output_contains "foreign-test: digest: sha256:"
}
