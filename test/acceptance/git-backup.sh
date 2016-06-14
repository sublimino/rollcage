#!/usr/bin/env bats

load test_helper

@test "git-backup: accepts action" {
    run_assert env -i \
      GIT_BACKUP_PASS=test \
      ${APP} git-backup --dry-run --git-owner=x
    refute_output_contains "Action required"
}

@test "git-backup: accepts --repo-user" {
    run_assert env -i \
      GIT_BACKUP_PASS=test \
      ${APP} git-backup --dry-run --git-owner=horatio
    assert_output_contains "github.com/horatio/rollcage.git"
}

@test "git-backup: accepts --git-host" {
    run_assert env -i \
      GIT_BACKUP_PASS=test \
      ${APP} git-backup --dry-run --git-owner=nelson --git-host=example.com
    assert_output_contains "example.com/nelson/rollcage.git"
}

@test "git-backup: outputs string with git commands" {
    run_assert env -i \
      GIT_BACKUP_PASS=test \
      ${APP} git-backup --dry-run --git-owner=x
    assert_output_contains "git push --verbose --atomic --prune"
}

@test "git-backup: outputs string with user env vars" {
    run_assert env -i \
      GIT_BACKUP_PASS=test \
      ${APP} git-backup --dry-run --git-owner=x
    assert_output_contains "\${GIT_BACKUP_USER}"
}

@test "git-backup: outputs string with pass env vars" {
    run_assert env -i \
      GIT_BACKUP_PASS=this-is-a-backup-pass \
      ${APP} git-backup --dry-run --git-owner=x
    assert_output_contains "this-is-a-backup-pass"
}

@test "git-backup: checks out \$CI_BUILD_REF_NAME when present" {
    run_assert env -i \
      GIT_BACKUP_PASS=test \
      CI_BUILD_REF_NAME=the-ultimate-branch \
      ${APP} git-backup --dry-run --git-owner=x
    assert_output_contains "git checkout the-ultimate-branch"
}

@test "git-backup: does not check out \$CI_BUILD_REF_NAME when missing" {
    run_assert env -i \
      GIT_BACKUP_PASS=test \
      ${APP} git-backup --dry-run --git-owner=x
    refute_output_contains "git checkout"
}
