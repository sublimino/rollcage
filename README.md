To add a new project to GitLab:

Create project in GitLab
Add the Project Variable SUBLIMINO_BITBUCkET_PASS 
Create project in Bitbucket
Add Mr Remote (sublimino-gitlab) to bitbucket project


#  examples

current-fighter 

    #!/bin/bash
    
    set -exo pipefail
    
    IMAGE=local/current-fighter:latest 
    VIRTUAL_HOST=pavlink.binarysludge.com
    VIRTUAL_PORT=3000
    EXPOSE_PORT=3000
    SYSLOG_ADDRESS="$(docker port rsyslog-logstash 5514/udp)"
    LOGGER="--log-driver=syslog --log-opt syslog-address=udp://${SYSLOG_ADDRESS} --log-opt syslog-tag={{.ImageName}}-{{.ID}}"
    
    if ! docker history "${IMAGE}" >/dev/null 2>&1; then 
      if [[ "${CI}" != 'true' ]]; then
        ./build.sh;
      else
        printf "${IMAGE} not found\n"
        exit 1
      fi
    fi
    
    mkdir -p /tmp/pavlink-cache
    
    docker stop current-fighter
    docker rm current-fighter || true
    docker run \
        -p "${EXPOSE_PORT}" \
        --name=current-fighter \
        -e VIRTUAL_HOST="${VIRTUAL_HOST}" \
        -e VIRTUAL_PORT="${VIRTUAL_PORT}" \
        -v /tmp/pavlink-cache:/tmp/pavlink-cache \
        -v /var/run/docker.sock:/var/run/docker.sock \
        ${LOGGER} \
        "${IMAGE}" $@


pseudobot

    #!/bin/bash -ex
    
    MARKOV_INPUT_LINES=0
    INPUT_FILE=YLD_Social_Club.txt
    
    [[ ! -f input.txt ]] && {
        [[ $MARKOV_INPUT_LINES -gt 0 ]] && {
            sort -R "${INPUT_FILE}" | head -n ${MARKOV_INPUT_LINES} > input.txt
        } || {
            cp "${INPUT_FILE}" input.txt
        }
    }
    
    docker build --tag pseudobot .
    
    docker rm --force pseudobot || true
    docker run -d --name pseudobot pseudobot

eco build

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



rollcage - simple Dockerised continuous deployment
==================================================

rollcage get-tags
    - get tags from environment

rollcage build [--file=dockerfile] [--tag=xyz]
    - set tags
    - copy credentials
    - build image from Dockerfile
    - @test
    - @run
    - @push

rollcage test
    - run image's acceptance tests from inside container
    - docker run -t ${IMAGE} ${TEST_COMMAND}
    
rollcage push
    - docker push TAG..TAGS

rollcage run
    - docker run -t \
        [many many extra commands?] \
        ${IMAGE} ${COMMAND}

rollcage run 
    - --conditional-build (build image if not exist))
    - --force
    - docker history IMAGE || @build
    - @run

rollcage run-hook
    - run hook/deploy.sh

rollcage clean
    - remove old docker images


### out of scope

rollcage deploy N
    - get version N
    - tag N as :canary
    - get current version (also :prod)
    - tag current version as :prev-prod (write version to .rollcage?)
    - stop version :prod
    - @run-hook
    - @run next (also :canary)
    - @test (acceptance!)
    - re-tag version as :prod
    
rollcage revert
    [inverse deploy]

