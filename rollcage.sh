#!/bin/bash
#
# rollcage - simple Dockerised continuous deployment
# 
# Andrew Martin, 19/05/2016
# sublimino@gmail.com
#
## Usage: %SCRIPT_NAME% [options] [action]
##
## Commands:
##  get-tags            Get auto-generated tags
##    --image-name=a    Image name [optional, default current directory name]
##    --image-tag=b     Image tag [optional, default from CI environment variables]
##    --registry-host=c Registry host [optional]
##    --registry-user=d Registry user [optional]
##  build               Build Dockerfile
##    --pull=true       Pull a newer version of base image  [optional, default true]
##    --build-path=x/y  Set build context [optional, default is current directory]
##
## Options:
##   -h, --help         Display this message
##   -v, --version      Print version
##   -t, --type [bash]  Template type to create
##   -n                 Dry-run; only show what would be done
##

# helper functions
declare -r DIR=$(cd "$(dirname "$0")" && pwd)
source "$DIR"/build.sh_functions

# user defaults
DESCRIPTION="Unknown"
DEBUG=0
DRY_RUN=0

# required defaults
EXPECTED_NUM_ARGUMENTS=0
ARGUMENTS=()
FILENAME=''
ACTION=''

# get-tags
IMAGE_NAME=
IMAGE_TAG=
REGISTRY_HOST=
REGISTRY_USERNAME=

# build
BUILD_PULL=
DOCKERFILE_PATH=

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

function parse_arguments() {
  local CURRENT_ARG
  local NEXT_ARG
  local SPLIT_ARG
  while [ $# -gt 0 ]; do
    CURRENT_ARG="${1}"
    IFS='=' read -ra SPLIT_ARG <<< "${CURRENT_ARG}"
    if [[ ${#SPLIT_ARG[@]} -gt 1 ]]; then
      CURRENT_ARG="${SPLIT_ARG[0]}"
      unset SPLIT_ARG[0]
      NEXT_ARG="$(printf "%s=" "${SPLIT_ARG[@]}")"
      NEXT_ARG="${NEXT_ARG%?}"
    else
      shift
      NEXT_ARG="${1:-}"
    fi

    case ${CURRENT_ARG} in
      (get-tags) ACTION=${CURRENT_ARG};;
      (--image-name) not_empty_or_usage "${NEXT_ARG:-}"; IMAGE_NAME="${NEXT_ARG}"; shift;;
      (--image-tag) not_empty_or_usage "${NEXT_ARG:-}"; IMAGE_TAG="${NEXT_ARG}"; shift;;
      (--registry-host) not_empty_or_usage "${NEXT_ARG:-}"; REGISTRY_HOST="${NEXT_ARG}"; shift;;
      (--registry-user) not_empty_or_usage "${NEXT_ARG:-}"; REGISTRY_USERNAME="${NEXT_ARG}"; shift;;

      (build) ACTION=${CURRENT_ARG};;
      (--pull) not_empty_or_usage "${NEXT_ARG:-}"; [[ "${NEXT_ARG:-}" == 'false' ]] && BUILD_PULL=false || BUILD_PULL=true; shift;;
      (--build-path) not_empty_or_usage "${NEXT_ARG:-}"; BUILD_PATH="${NEXT_ARG}"; shift;;

      (-n) DRY_RUN=1;;
      (-h|--help) usage;;
      (-v|--version) get_version; exit 0;;
      (--debug) DEBUG=1; set -xe;;
      (-t|--type) not_empty_or_usage "${NEXT_ARG:-}"; case ${NEXT_ARG} in
          (bash) FILETYPE=bash; shift;;
          (*) usage "Template type '${NEXT_ARG}' not recognised";;
        esac;;
      (-d|--description) not_empty_or_usage "${NEXT_ARG:-}"; DESCRIPTION="${NEXT_ARG}"; shift;;
      (--) break;;
      (-*) usage "${CURRENT_ARG}: unknown option";;
      (*) ARGUMENTS+=("${CURRENT_ARG}");
    esac
  done
}

validate_arguments() {
  [[ -z "${ACTION}" ]] && usage "Action required"

  check_number_of_expected_arguments

  [[ ${#ARGUMENTS[@]} -gt 0 ]] && FILENAME=${ARGUMENTS[0]} || true
}

main() {
  handle_arguments "$@"

  local HANDLER="perform_${ACTION}"

  if ! type -t "${HANDLER}" &>/dev/null; then error "${HANDLER} not found"; fi

  ${HANDLER}

  return $?
}

perform_get-tags() {
  local REGISTRY_HOST="${REGISTRY_HOST:-}"
  local REGISTRY_USERNAME="${REGISTRY_USERNAME:-}"
  local IMAGE_NAME="${IMAGE_NAME:-$(basename "$(pwd)")}"
  local IMAGE_TAG="${IMAGE_TAG:-${CI_BUILD_ID}}"

  [[ -n "${REGISTRY_HOST}" ]] && REGISTRY_HOST="${REGISTRY_HOST}/"
  [[ -n "${REGISTRY_USERNAME}" ]] && REGISTRY_USERNAME="${REGISTRY_USERNAME}/"

  echo "${REGISTRY_HOST}${REGISTRY_USERNAME}${IMAGE_NAME}:${IMAGE_TAG}"
}

perform_build() {
  local BUILD_PULL=${BUILD_PULL:-true}
  local BUILD_PATH=${BUILD_PATH:-.}
  local DOCKERFILE_NAME=${DOCKERFILE_NAME:-"${BUILD_PATH}/Dockerfile"}

  local COMMAND="docker build --pull=${BUILD_PULL} \
    --tag "$(perform_get-tags)" \
    --file="${DOCKERFILE_NAME}" \
    "${BUILD_PATH}""

  echo ${COMMAND}

  ${COMMAND}
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
