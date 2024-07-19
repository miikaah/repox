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

Setting an alias lets you run repox like a any other program from the command line / powershell

### Mac OS / Linux

Open your shell's profile file (Instructions for bash)

```sh
nano ~/.bash_profile
```

Set the alias in the .bash_profile file

```sh
alias repox='node <Absolute path to where you keep your repos>/repox/src/index.mjs'
```

Reload the .bash_profile file

```sh
source ~/.bash_profile
```

Test it

```sh
repox help
```

### Windows

Open the Powershell profile file. Notepad will prompt you to create the file if it doesn't exist

```sh
notepad $PROFILE
```

Set the alias in the profile file

```sh
Function repoxNode {
   node "<Absolute path to where you keep your repos>\repox\src\index.mjs" $args
}

Set-Alias -Name repox -Value repoxNode
```

Reload the profile file

```sh
. $PROFILE
```

Test it

```sh
repox help
```
