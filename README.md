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

rollcage push

rollcage test
    - run tests inside contianer
    
rollcage run
rollcage deploy
rollcage revert
