rollcage - simple dev/CI Docker helper
======================================


```
Usage: rollcage [OPTIONS] COMMAND

Options:
  --config=file            Configuration file, parsed after flags. Directives are command options without prefixed `--` [default `.rollcage`]
  -h, --help               Display this message
  -v, --version            Print version

Commands:

  build                    Build Dockerfile
    --pull=true            Pull a newer version of base image  [default true]
    --build-path=path      Set build context [optional, default is current directory]
    --test=command         Run tests in container [optional]

  run                      Run image i.e. `rollcage run echo "test" -- --rm`
    --interactive=true     Add `--interactive` and `--tty` to `docker run`[default true]

  push                     Push an image
    --push-image           Image to push [option, default from env vars]

  login                    Login to a registry
    --password pass        Registry password
    --registry-user user   Registry login user if different from --user [optional]

  get-tags                 Get auto-generated tags
    --image=name           Image name [optional, default current directory name]
    --tag=name             Image tag [optional, default from env vars]]
    --user=name            Registry image owner [optional]
    --registry=host        Registry host [optional]

  git-backup               Backup the git repository to a remote host using password in environment variable GIT_BACKUP_PASS
    --git-owner            Git repository owner i.e. github.com/OWNER/repo [optional, default user/registry-user]
    --git-host             Git repository hostname i.e. HOSTNAME/owner/repo [optional, default github.com]
    --git-user             Git repository user i.e. GIT-USER:pass@github.com/owner/repo [optional]
```

Using `rollcage` for development
--------------------------------
Assuming the current directory name is `my-demo/` running this command:

`$ rollcage build run -- --name demo-app -p 8080:8080 --rm -e VIRTUAL_HOST=my-demo.local -v /tmp`

Will run these commands: 

- `docker build --pull=true --rm=true --tag docker-my-demo:dev`
- `docker run -it --name demo-app -p 8080:8080 --rm -e VIRTUAL_HOST=my-demo -v /tmp docker-my-demo:dev`


Using `git-backup` from GitLab to GitHub
----------------------------------------

This is useful for mirroring a repo to GitHub from a private GitLab instance.

- create project with same name on GitLab and GitHub
- create a bot user on GitHub
- add bot user to GitHub repository
- add the Project Variable GIT_BACKUP_PASS to GitLab with the bot's password
- add a step with the script `rollcage git-backup` to the project's `.gitlab-ci.yaml`

