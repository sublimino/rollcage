To add a new project to GitLab:

Create project in GitLab
Add the Project Variable GIT_BACKUP_PASS 
Create project in Github
Add sublimino-bot to Github project

#  examples


rollcage - simple Dockerised continuous deployment
==================================================

    rollcage get-tags
        - get tags from environment
    
    rollcage build [--file=dockerfile] [--tag=xyz]
        - set tags
        - copy credentials?
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
    
### not implemented

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

# acceptance testing rewrite

letsencrypt local cert
nginx-proxy
registry

