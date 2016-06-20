#!/usr/bin/env bats

load test_helper

@test "cli: has --help" {
    run ${APP} --help
    assert_output_contains '--version'
    assert_output_contains 'Print version'
}

@test "cli: has semver --version" {
    run_assert ${APP} --version
    local SEMVER=( ${output//./ } )
    assert [ "${SEMVER[0]}" -ge 0 ]
    assert [ "${SEMVER[1]}" -ge 0 ]
    assert [ "${SEMVER[2]//\-*/}" -ge 0 ]
}

@test "parser: rejects empty --pull arg" {
    run_refute ${APP} --pull
}

@test "parser: rejects invalid --pull arg" {
    run_refute ${APP} --pull --version
}

@test "cli: does not error on empty args" {
    # remove any arguments in the ${APP} variable
    run_refute ${APP/ */}
    refute_output_contains "Action required"
}
