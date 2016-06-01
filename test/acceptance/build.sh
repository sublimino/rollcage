#!/usr/bin/env bats

load test_helper

@test "pre-run: deletes images" {
  run_assert docker images -a  \
    | grep registry.binarysludge.com/test-rollcage-user/test-rollcage \
    | awk '{print $3}' \
    | \xargs --no-run-if-empty docker rmi --force
}


@test "build: accepts --pull arg" {
    run ${APP} build --pull=true --image-tag=123
    assert_output_contains "latest: Pulling from"
}

@test "build: rejects empty --pull arg" {
    run_refute  ${APP} build --pull
}

@test "build: rejects invalid --pull arg" {
    run_refute  ${APP} build --pull --version
}

@test "build: accepts --pull=false arg" {
    run ${APP} build --pull=false --image-tag=123
    refute_output_contains "latest: Pulling from"
}

@test "build: accepts Dockerfile path" {
    run ${APP} build --pull=false --image-tag=123 \
      --build-path=test/fixture/simple/
    assert_output_contains "CMD echo \"SIMPLE DOCKERFILE\""
}

@test "build: rejects tag-less build" {
    run_refute env -i \
      ${APP} build --pull=false \
      --build-path=test/fixture/simple/
    assert_output_contains '--image-tag or $CI_BUILD_ID env var required'
}

@test "build: accepts tag from environment" {
    run_assert env -i \
      IMAGE_TAG=123 \
      ${APP} build --pull=false \
      --build-path=test/fixture/simple/
    assert_output_contains "CMD echo \"SIMPLE DOCKERFILE\""
}
