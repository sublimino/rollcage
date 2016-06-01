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
##   get-tags                 Get auto-generated tags
##     --image=name           Image name [optional, default current directory name]
##     --tag=name             Image tag [optional, default from env vars]]
##     --user=name            Registry image owner [optional]
##     --registry=host        Registry host [optional]
##   login                    Login to a registry
##     --password pass        Registry password
##     --registry-user user   Registry login user if different from --user [optional]
##   build                    Build Dockerfile
##     --pull=true            Pull a newer version of base image  [optional, default true]
##     --build-path=path      Set build context [optional, default is current directory]
##   push                     Push an image}
##    --push-image            Image to push [option, default from env vars]
##
## Options:
##   --config=file            Configuration file
##   -h, --help               Display this message
##   -v, --version            Print version
##   -t, --type [bash]        Template type to create
##   -n                       Dry-run; only show what would be done
##

# helper functions
declare -r DIR=$(cd "$(dirname "$0")" && pwd)
source "$DIR"/build.sh_functions

# user defaults
CONFIG_FILE=${CONFIG_FILE:-.rollcage}
DEBUG=0
DRY_RUN=0

# required defaults
EXPECTED_NUM_ARGUMENTS=0
ARGUMENTS=()
ACTION=''

# get-tags
IMAGE_USER="${IMAGE_USER:-}"
IMAGE_NAME="${IMAGE_NAME:-}"
IMAGE_TAG="${IMAGE_TAG:-}"
REGISTRY_HOST="${REGISTRY_HOST:=}"
REGISTRY_USER="${REGISTRY_USER:-}"

# build
BUILD_PULL=
DOCKERFILE_PATH=

# login
REGISTRY_PASS="${REGISTRY_PASS:-}"

# push
FULL_IMAGE_NAME=

# exit on error or pipe failure
set -eo pipefail
# error on unset variable
set -o nounset
# error on clobber
set -o noclobber

handle_arguments() {
  [[ $# = 0 && $EXPECTED_NUM_ARGUMENTS -gt 0 ]] && usage

  parse_arguments "$@"

  [[ -n ${CONFIG_FILE:-} && -f ${CONFIG_FILE} ]] && {
    local ARGS_FROM_FILE=
    local PREVIOUS_ARGUMENTS="$@"
    local SPLIT_ARG
    while read LINE; do
      LINE="--${LINE}"
      IFS='=' read -ra SPLIT_ARG <<< "${LINE}"
      if ! grep -q -- "${SPLIT_ARG[0]}" <<< "${PREVIOUS_ARGUMENTS}" >/dev/null; then
        set -- "${LINE}"
        parse_arguments "$@"
      fi
    done < <(cat ${CONFIG_FILE})
  }

  validate_arguments "$@"
}

function parse_arguments() {
  local CURRENT_ARG
  local NEXT_ARG
  local SPLIT_ARG
  local COUNT=
  while [ $# -gt 0 ]; do
    CURRENT_ARG="${1}"
    COUNT=$((COUNT + 1))
    [[ $COUNT -gt 20 ]] && error "Too many arguments or '"${CURRENT_ARG}"' is unknown"
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
      (--user) not_empty_or_usage "${NEXT_ARG:-}"; IMAGE_USER="${NEXT_ARG}"; shift;;
      (--image) not_empty_or_usage "${NEXT_ARG:-}"; IMAGE_NAME="${NEXT_ARG}"; shift;;
      (--tag) not_empty_or_usage "${NEXT_ARG:-}"; IMAGE_TAG="${NEXT_ARG}"; shift;;
      (--registry) not_empty_or_usage "${NEXT_ARG:-}"; REGISTRY_HOST="${NEXT_ARG}"; shift;;
      (--registry-user) not_empty_or_usage "${NEXT_ARG:-}"; REGISTRY_USER="${NEXT_ARG}"; shift;;

      (build) ACTION=${CURRENT_ARG};;
      (--pull) not_empty_or_usage "${NEXT_ARG:-}"; [[ "${NEXT_ARG:-}" == 'false' ]] && BUILD_PULL=false || BUILD_PULL=true; shift;;
      (--build-path) not_empty_or_usage "${NEXT_ARG:-}"; BUILD_PATH="${NEXT_ARG}"; shift;;

      (login) ACTION=${CURRENT_ARG};;
      (--password) not_empty_or_usage "${NEXT_ARG:-}"; REGISTRY_PASS="${NEXT_ARG}"; shift;;

      (push) ACTION=${CURRENT_ARG};;
      (--push-image) not_empty_or_usage "${NEXT_ARG:-}"; FULL_IMAGE_NAME="${NEXT_ARG}"; shift;;

      (--config-file) not_empty_or_usage "${NEXT_ARG:-}"; CONFIG_FILE="${NEXT_ARG}"; shift;;
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

  [[ "${ACTION}" == "push" && ${#ARGUMENTS[@]} -gt 0 ]] && EXPECTED_NUM_ARGUMENTS=1

  check_number_of_expected_arguments

  [[ ${#ARGUMENTS[@]} -gt 0 ]] && FULL_IMAGE_NAME=${ARGUMENTS[0]} || true
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
  local REGISTRY_USER="${REGISTRY_USER:-}"
  local IMAGE_USER="${IMAGE_USER:-${REGISTRY_USER:-}}"
  local IMAGE_NAME="${IMAGE_NAME:-$(basename "$(pwd)")}"
  local IMAGE_TAG="${IMAGE_TAG:-${CI_BUILD_ID:-}}"

  [[ -z "${IMAGE_TAG}" ]] && error '--tag or $CI_BUILD_ID env var required'

  [[ -n "${REGISTRY_HOST}" ]] && REGISTRY_HOST="${REGISTRY_HOST}/"
  [[ -n "${IMAGE_USER}" ]] && IMAGE_USER="${IMAGE_USER}/"

  echo "${REGISTRY_HOST}${IMAGE_USER}${IMAGE_NAME}:${IMAGE_TAG}"
}

perform_login() {
  local REGISTRY_HOST="${REGISTRY_HOST:-}"
  local REGISTRY_USER="${REGISTRY_USER:-}"
  local REGISTRY_PASS="${REGISTRY_PASS:-}"

  [[ -z "${REGISTRY_USER}" ]] && error "--registry-user required for login"
  [[ -z "${REGISTRY_PASS}" ]] && error "--password required for login"

  local COMMAND="docker login \
    --username=${REGISTRY_USER} \
    --password "${REGISTRY_PASS}" \
    "${REGISTRY_HOST}""

  info ${COMMAND}

  ${COMMAND}
}

perform_build() {
  local BUILD_PULL=${BUILD_PULL:-true}
  local BUILD_PATH=${BUILD_PATH:-.}
  local DOCKERFILE_NAME=${DOCKERFILE_NAME:-"${BUILD_PATH}/Dockerfile"}

  local COMMAND="docker build --pull=${BUILD_PULL} \
    --tag "$(perform_get-tags)" \
    --file="${DOCKERFILE_NAME}" \
    "${BUILD_PATH}""

  info ${COMMAND}

  ${COMMAND}
}

perform_push() {
  local FULL_IMAGE_NAME=${FULL_IMAGE_NAME:-}

  [[ -z "${FULL_IMAGE_NAME}" ]] && FULL_IMAGE_NAME=$(perform_get-tags)

  local COMMAND="docker push ${FULL_IMAGE_NAME}"

  info ${COMMAND}

  ${COMMAND} || { perform_login && ${COMMAND}; }
}

get_version() {
  VERSION=$(
    (hash node \
      && node -e "console.log(require('./package.json').version)") 2>/dev/null \
    || true
  )
  [[ -z "${VERSION}" ]] && {
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
