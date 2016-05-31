#!/usr/bin/env bats

load test_helper

@test "get-tags: get-tags: gets tags from environment" {
    TMP_TEST_DIR="${BATS_TMPDIR}"/this-is-some-test
    TEST_DIRECTORY=$(pwd)
    mkdir -p "${TMP_TEST_DIR}"
    \cd "${TMP_TEST_DIR}"

    CI_BUILD_ID=1337 run "${TEST_DIRECTORY}"/${APP} get-tags

    assert_output_contains "this-is-some-test:1337"
    rmdir "${TMP_TEST_DIR}"
}

@test "get-tags: gets image name from arguments" {
    run ${APP} get-tags --image-name=toast --image-tag=1234

    assert_output_contains "toast:1234"
}

@test "get-tags: gets image tag from arguments" {
    CI_BUILD_ID=7113 run ${APP} get-tags --image-name toast

    assert_output_contains "toast:7113"
}

@test "get-tags: overriders image tag from env with that from arguments" {
    CI_BUILD_ID=7113 run ${APP} get-tags --image-name toast --image-tag=1234

    assert_output_contains "toast:1234"
}

@test "get-tags: gets full image name from arguments" {
    run ${APP} get-tags \
      --registry-host=quay.io \
      --registry-user=sublimino \
      --image-name=toast \
      --image-tag=1234

    assert_output_contains "quay.io/sublimino/toast:1234"
}

