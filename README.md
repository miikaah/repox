# Repox

Make maintaining multiple repositories easier.

## Known issues

If the remote doesn't have a default branch set you may get an error like

```
fatal: ref refs/remotes/origin/HEAD is not a symbolic ref
```

You can set it with (run in the branch you want to be the default)

```sh
git remote set-head origin --auto
```

## Set alias

Setting an alias lets you run repox like a any other program from the command line

```sh
code ~/.bash_profile
```

.bash_profile file

```sh
alias repox='node <Your repository folder>/repox/src/index.mjs'
```

Reload the .bash_profile file

```sh
source ~/.bash_profile
```

Test it

```sh
repox help
```
