#!/usr/bin/env bats

load test_helper

@test "run: accepts run action" {
    run_assert ${APP} \
      run --dry-run
}

@test "run: runs command" {
    run_assert ${APP} \
      run --dry-run \
      --push-image=rollcage:dev \
      echo 'testerino'
    assert_output_contains "testerino"
}

@test "run: supresses '-it' with --interactive arg" {
    run_assert ${APP} \
      run  --dry-run \
      --push-image=rollcage:dev \
      --interactive=false echo 'testerino'
    assert_output_contains "docker run rollcage:dev echo testerino"
}

@test "run: passes arguments to docker" {
    run_assert ${APP} \
      --dry-run \
      --push-image=rollcage:dev \
      run -- -v /home:/home -v=/home:/home
    assert_output_contains "docker run -it -v /home:/home -v=/home:/home rollcage:dev"
}

@test "run: passes arguments to docker with command" {
    run_assert ${APP} \
      --dry-run \
      --push-image=rollcage:dev \
      run echo 'toast' -- -v /home:/home -v=/home:/home
    assert_output_contains "docker run -it -v /home:/home -v=/home:/home rollcage:dev echo toast"
}

@test "run: parses tag from image" {
    run_assert ${APP} \
      --dry-run \
      --image errordeveloper/kube-installer:latest \
      --debug \
      run 
    refute_output_contains "docker run -it errordeveloper/kube-installer:latest:dev"
    assert_output_contains "docker run -it errordeveloper/kube-installer:latest"
}

@test "run: overrides parsed tag from image with --tag" {
    run_assert ${APP} \
      --dry-run \
      --image errordeveloper/kube-installer:latest \
      --tag toast-assault \
      run 
    refute_output_contains "docker run -it errordeveloper/kube-installer:toast-assault:dev"
    assert_output_contains "docker run -it errordeveloper/kube-installer:toast-assault"
}

@test "run: errors when --image and --tag passed when --tag contains colon" {
    run_refute ${APP} \
      --dry-run \
      --image some-image \
      --tag another-image:latest \
      run 
    refute_output_contains "docker run -it"
}

@test "run: sets image with --tag when --tag contains colon" {
    run_assert ${APP} \
      --dry-run \
      --tag ansible-dp-test:latest \
      run 
    refute_output_contains "docker run -it ansible-dp-test:latest:dev"
    assert_output_contains "docker run -it ansible-dp-test:latest"
}

@test "run: sets image with --tag when --tag contains colon and slash" {
    run_assert ${APP} \
      --dry-run \
      --tag errordeveloper/ansible-dp-test:latest \
      run 
    refute_output_contains "docker run -it errordeveloper/ansible-dp-test:latest:dev"
    assert_output_contains "docker run -it errordeveloper/ansible-dp-test:latest"
}

@test "run: runs images from the hub" {
    skip
    # rollcage run --image _/alpine:latest
    run_assert ${APP} \
      --dry-run \
      --push-image=rollcage:dev \
      run echo 'toast' -- -v /home:/home -v=/home:/home
    assert_output_contains "docker run -it -v /home:/home -v=/home:/home rollcage:dev echo toast"
}

# --image kube-baremetal-tests:latest
