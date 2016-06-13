load ../../node_modules/bats-assert/all

APP="${APP:-./rollcage}"

APP="${APP} --config-file=non-extant-file"
