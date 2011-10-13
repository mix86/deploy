About
=====

I like this script idea. But i want little more ;-)

TGI GitHub!

Usage
=====
Simplest: `deploy` within your project folder. Script will try to find `.deploy` file
and mark folder which contains that file as a project root. If no `.deploy` file
is found (script will try to go up 32 times) - an error will be printed and script
exit with code `1`.

`.deploy` file
-------
This is something like `deploy` settings. Full example:

    REMOTE=server.com
    REMOTE_PATH="/home/user/project"
    REMOTE_USER=dev
    EXCLUDES="
     --exclude=Project.sublime-workspace
     --exclude=*.egg-info
    "
    UPDATE_REMOTE=false # default
    DELETE_EXCLUDED=true # default
    SED="gsed -re" # in case you want to use GNU sed... "sed -Ee" is default

Only `REMOTE` and `REMOTE_PATH` are mandatory. If `USER` is ommited -- local user
will be used (i.e. `USER=$USER`).

Usage examples
--------------

* `deploy` - will deploy your project to the `REMOTE` at `REMOTE_PATH`. Using default excludes and settings.
* `deploy --reverse` - will reverse-deploy project. Ie copy it from server back to project root.
* `deploy --with=.git --with=.ropeproject` - will deploy your code to the `REMOTE` and override default excludes (force `.git` and `.ropeproject` to be copied to the server).
* `deploy --dry` - dry run. You will see what will happen. Without risk ;)

Original README
===============

> Put ".deploy" file to the root of your project.
> Examlpe:
> 
> REMOTE="server.examlpe.com"
> REMOTE_PATH="/home/user/dev"
> EXCLUDES="--exclude=trash"
> 
> Enjoy
