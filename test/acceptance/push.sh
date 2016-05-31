#!/usr/bin/env bats

load test_helper

#@test "push: builds correct tag" {
#    CI_BUILD_ID=not-a-real-tag \
#      run ${APP} push \
#      --registry-host=registry.binarysludge.com \
#      --registry-user=test-rollcage-user \
#      --registry-pass='&B518isz0yaX!GYa$c2fnF'
#    assert_output_contains "Repository does not exist: registry.binarysludge.com/test-rollcage-user/rollcage"
#}

setup() {
    CI_BUILD_ID=1234567890
    TEST_REGISTRY_HOST=registry.binarysludge.com

    ${APP} build --pull=false \
      --image-tag="${CI_BUILD_ID}" \
      --registry-host="${TEST_REGISTRY_HOST}" \
      --registry-user=test-rollcage-user \
      --image-name='test-rollcage' \
      --build-path=test/fixture/simple/

    docker logout "${TEST_REGISTRY_HOST}"
}

teardown() {
    unset CI_BUILD_ID
}

@test "push: logs in automatically and pushes" {

    assert ${APP} push \
      --image-tag="${CI_BUILD_ID}" \
      --registry-host=registry.binarysludge.com \
      --registry-user=test-rollcage-user \
      --image-name='test-rollcage' \
      --registry-pass='&B518isz0yaX!GYa$c2fnF'

    assert_output_contains "${CI_BUILD_ID}: digest: sha256:"
}
