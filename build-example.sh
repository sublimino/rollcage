#!/bin/sh

set -ex

main() {
  setTags
  copyCredentials

  buildImage
  contractTest

  if [[ "${CI}" != 'true' ]]; then
    buildAcceptanceTestImage
    unitTest
    acceptanceTest
  fi

  if [ "${DOCKER_HUB_ACCOUNT}" != "local" ]; then
    uploadToDockerHub
  fi

  printf "Tags:\n\n%s\n%s\n" "${IMAGE_NAME}" "${TEST_IMAGE_NAME}"
}

setTags() {
  SERVICE_NAME="$(basename "$(pwd)")"
  DEV_TAG="dev-latest"
  TEST_TAG="test-latest"

  if [ -z "${GO_PIPELINE_LABEL}" ] && [ -z "${GO_PIPELINE_NAME}" ]; then
    TAG="latest"
    DOCKER_HUB_ACCOUNT="local"
    echo "${TAG} development environment configuration..."
  else
    TAG="${GO_PIPELINE_NAME}-${GO_PIPELINE_LABEL}"
    DOCKER_HUB_ACCOUNT=${DOCKER_HUB_ACCOUNT}
    echo "${TAG} environment configuration..."
  fi

  IMAGE_NAME="${DOCKER_HUB_ACCOUNT}/${SERVICE_NAME}:${TAG}"
  TEST_IMAGE_NAME="${DOCKER_HUB_ACCOUNT}/${SERVICE_NAME}:${TEST_TAG}"
}

copyCredentials() {
#  if [ -f package.json ] && [ -f ~/.npmrc ]; then
#    cp -a ~/.npmrc .
#  fi
  if [ "${NPM_TOKEN:-}" != "" ] && ! grep --quiet "${NPM_TOKEN}" .npmrc; then
    echo "NPM auth token mismatch in /home/go/.npmrc. Update the file with the new token."
    exit 1
  fi
  mkdir -p node_modules lib
  if [ -z pavlok-token.json ]; then
    echo "{}" > pavlok-token.json
  fi
  # if [ -n ${GO_PIPELINE_LABEL} ] && [ -f package.json ]; then
  #   REV=$(git rev-list -n 1 HEAD 'package.json');
  #   STAMP=$(git show --pretty=format:%ai --abbrev-commit "$REV" | head -n 1);
  #   md5sum package.json && stat package.json
  #   touch -d "$STAMP" package.json;
  #   md5sum package.json && stat package.json
  # fi
}

buildImage() {
  git log -1 --oneline > last_commit.txt || true
  HOST_IP=$(ip route get 1 | awk '{print $NF;exit}')
  NPM_REGISTRY="http://${HOST_IP}:4873"
  OPTIONAL_SINOPIA=""
#  curl --max-time 2 --silent "${NPM_REGISTRY}" >/dev/null 2>&1 && OPTIONAL_SINOPIA="--build-arg npm_registry=${NPM_REGISTRY}"
  docker build ${OPTIONAL_SINOPIA} --pull=true --tag "${IMAGE_NAME}" .
}

contractTest() {
#  docker run -i \
#    -e MT_SERVICES_URL=${MT_SERVICES_URL:-infra-varnish.elb.ci.ecom.s.aws.economist.com} \
#    "${IMAGE_NAME}" \
#    npm run test:contract -- --start-server
  true
}

buildAcceptanceTestImage() {
#  rm -rf .cidfile 2>/dev/null
#  docker run --cidfile=.cidfile "${IMAGE_NAME}" scripts/setupTestImage.sh
#  docker commit $(cat .cidfile) "${TEST_IMAGE_NAME}"
  docker tag -f "${IMAGE_NAME}" "${TEST_IMAGE_NAME}"
  true
}

acceptanceTest() {
  ./run-container.sh \
    node lib/ --test-api

  ./run-container.sh \
    npm run test:acceptance
}

unitTest() {
  docker run -i \
    "${TEST_IMAGE_NAME}" \
    npm run test:unit
}

uploadToDockerHub ()
{
  if [ -z ${DOCKER_HUB_ACCOUNT} ]; then
    echo "Failed to push to docker hub. Docker hub account credentials not provided."
    exit 1
  else
    docker tag -f "${IMAGE_NAME}" "${DOCKER_HUB_ACCOUNT}/${SERVICE_NAME}:${DEV_TAG}"

    local DOCKER_TAGS="${TAG} ${DEV_TAG} ${TEST_TAG}"
    local DOCKER_PUSH_URL
    for DOCKER_TAG in ${DOCKER_TAGS}; do
      DOCKER_PUSH_URL="${DOCKER_HUB_ACCOUNT}/${SERVICE_NAME}:${DOCKER_TAG}"
      docker push "${DOCKER_PUSH_URL}" || docker push "${DOCKER_PUSH_URL}"
    done
  fi
}

main
