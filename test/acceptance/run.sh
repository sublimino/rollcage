#!/usr/bin/env bats

load test_helper

@test "run: accepts run action" {
    run_assert ${APP} \
      run
}

@test "run: runs command" {
    run_assert ${APP} \
      run --dry-run \
      echo 'testerino'
    assert_output_contains "testerino"
}

@test "run: supresses '-it' with --interactive arg" {
    run_assert ${APP} \
      run  --dry-run \
      --interactive=false echo 'testerino'
    assert_output_contains "docker run rollcage:dev echo testerino"
}

@test "run: passes arguments to docker" {
    run_assert ${APP} \
      --dry-run \
      run -- -v /home:/home -v=/home:/home
    assert_output_contains "docker run -it -v /home:/home -v=/home:/home rollcage:dev"
}

@test "run: passes arguments to docker with command" {
    run_assert ${APP} \
      --dry-run \
      run echo 'toast' -- -v /home:/home -v=/home:/home
    assert_output_contains "docker run -it -v /home:/home -v=/home:/home rollcage:dev echo toast"
}
