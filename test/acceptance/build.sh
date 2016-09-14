#!/usr/bin/env bats

load test_helper

@test "pre-run: deletes images" {
  run_assert docker images -a  \
    | grep -E 'registry.binarysludge.com/(test-rollcage-user/rollcage-test|sublimino/rollcage-test-other-user)' \
    | awk '{print $3}' \
    | \xargs --no-run-if-empty docker rmi --force
}

@test "build: accepts --pull arg" {
    run ${APP} \
      build --pull=true --tag=123 \
      --build-path=test/fixture/simple/
    assert_output_contains "--pull=true"
}

@test "build: accepts --pull=false arg" {
    run ${APP} build --pull=false --tag=123 \
      --build-path=test/fixture/simple/
    refute_output_contains "latest: Pulling from"
}

@test "build: rejects empty --pull arg" {
    run_refute  ${APP} build --pull
}

@test "build: rejects invalid --pull arg" {
    run_refute  ${APP} build --pull --version
}

@test "build: tags as ':dev' when no tags found" {
    run_assert env -i \
      ${APP} build --pull=false \
      --build-path=test/fixture/simple/
    assert_output_contains '--tag rollcage:dev'
}

@test "build: accepts Dockerfile path" {
    run ${APP} build --pull=false --tag=123 \
      --build-path=test/fixture/simple/
    assert_output_contains "CMD echo \"SIMPLE DOCKERFILE\""
}

@test "build: accepts tag from environment" {
    run_assert env -i \
      IMAGE_TAG=123 \
      ${APP} build --pull=false \
      --build-path=test/fixture/simple/
    assert_output_contains "CMD echo \"SIMPLE DOCKERFILE\""
}

@test "build: adds VCS build arg" {
i   skip
    # https://microbadger.com/#/labels
    run_assert env -i \
      IMAGE_TAG=123 \
      ${APP} build --pull=false \
      --build-path=test/fixture/simple/
    assert_output_contains "CMD echo \"SIMPLE DOCKERFILE\""
}

