To add a new project to GitLab:

Create project in GitLab
Add the Project Variable SUBLIMINO_BITBUCkET_PASS 
Create project in Bitbucket
Add Mr Remote (sublimino-gitlab) to bitbucket project


rollcage - simple Dockerised continuous deployment
==================================================

rollcage build [--file=dockerfile]
    - set tags
    - copy credentials
    - build image from Dockerfile
    - @test
    - @run
    - @push

rollcage push
    - docker push TAG..TAGS

rollcage test
    - run image's acceptance tests from inside contianer
    - docker run -t ${IMAGE} ${TEST_COMMAND}
    
rollcage run
    - docker run -t \
        [many many extra commands?] \
        ${IMAGE} ${COMMAND}

rollcage run 
    - --conditional-build (build image if not exist))
    - --force
    - docker history IMAGE || @build
    - @run

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

rollcage push
    - docker push ${IMAGE}

rollcage run-hook
    - run hook/deploy.sh

rollcage clean
    - remove old docker images
