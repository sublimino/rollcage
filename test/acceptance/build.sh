#!/usr/bin/env bats

load test_helper

@test "build: accepts --pull arg" {
    run ${APP} build --pull=true --image-tag=123
    assert_output_contains "latest: Pulling from"
}

@test "build: rejects empty --pull arg" {
    refute ${APP} build --pull
}

@test "build: rejects invalid --pull arg" {
    refute ${APP} build --pull --version
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
    IMAGE_TAG= \
    CI_BUILD_ID= \
      refute ${APP} build --pull=false \
      --build-path=test/fixture/simple/
    assert_output_contains '--image-tag or $CI_BUILD_ID env var required'
}

@test "build: accepts tag from environment" {
    IMAGE_TAG=123 \
      assert ${APP} build --pull=false \
      --build-path=test/fixture/simple/
    assert_output_contains "CMD echo \"SIMPLE DOCKERFILE\""
}
