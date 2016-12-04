load ../../node_modules/bats-assert/all

echo "We are in $(pwd)"

APP="${APP:-./rollcage}"

APP="${APP} --config-file=non-extant-file"
