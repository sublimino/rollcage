#!/bin/bash
#
# rollcage - simple Dockerised continuous deployment
# 
# Andrew Martin, 19/05/2016
# sublimino@gmail.com
#
## Usage: %SCRIPT_NAME% [options] filename
##
## Options:
##   -h, --help        Display this message
##   -v, --version     Print version
##   -t, --type [bash] Template type to create
##   -n                Dry-run; only show what would be done
##

# helper functions
declare -r DIR=$(cd "$(dirname "$0")" && pwd)
source "$DIR"/build.sh_functions

# user defaults
DESCRIPTION="Unknown"
DEBUG=0
DRY_RUN=0

# required defaults
EXPECTED_NUM_ARGUMENTS=1
ARGUMENTS=()
FILENAME=''

# exit on error or pipe failure
set -eo pipefail
# error on unset variable
set -o nounset
# error on clobber
set -o noclobber

handle_arguments() {
  [[ $# = 0 && $EXPECTED_NUM_ARGUMENTS -gt 0 ]] && usage
  
  parse_arguments "$@"
  validate_arguments "$@"
}

parse_arguments() {
  while [ $# -gt 0 ]; do
    case $1 in
    (-n) DRY_RUN=1;;
    (-h|--help) usage;;
    (-v|--version) get_version; exit 0;;
    (--debug) DEBUG=1; set -xe;;
    (-t|--type) shift; not_empty_or_usage "${1:-}"; case $1 in
        (bash) FILETYPE=bash;;
        (*) usage "Template type '$1' not recognised";;
      esac;;
    (-d|--description) shift; not_empty_or_usage "${1:-}"; DESCRIPTION="$1";;
    (--) shift; break;;
    (-*) usage "$1: unknown option";;
    (*) ARGUMENTS+=("$1");
    esac
    shift
  done
}

validate_arguments() {
  [[ $EXPECTED_NUM_ARGUMENTS -gt 0 && -z ${FILETYPE:-} ]] && usage "Filetype required"

  check_number_of_expected_arguments

  [[ ${#ARGUMENTS[@]} -gt 0 ]] && FILENAME=${ARGUMENTS[0]} || true
}

main() {
  handle_arguments "$@"

  error 'In main(), no further codes.'
}

get_version() {
  VERSION=$(
    (hash node \
      && node -e "console.log(require('./package.json').version)") 2>/dev/null \
    || true
  )
  [[ -z "${VERSION:-}" ]] && {
    VERSION=$(
      grep 'version' package.json \
        | sed -E 's/.*([[:digit:]]\.[[:digit:]]\.[[:digit:]]).*/\1/g'
    )
  }
  [[ -z "${VERSION:-}" ]] && {
    error "Could not parse version"
  }
  echo "${VERSION}"
}


main "$@"
