# Repox

Make maintaining multiple repositories easier. Repox works on MacOS, Linux and Windows (Powershell 7).

## Pre-built binaries

See `/bin`

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

Setting an alias lets you run repox like any other program from the command line without setting it in PATH.

### POSIX

```sh
code ~/.bash_profile
```

.bash_profile file

```sh
alias repox='<Absolute path to repox folder>/bin/repox-<os and arch>'
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

Open the profile file via Powershell. The file will be created to C:\Users\username\Documents\Powershell if it doesn't exist.

```sh
code $PROFILE
```

Microsoft.PowerShell_profile.ps1 file

```ps1
function repoxZig {
    & "<Absolute path to repox folder>\bin\repox.exe" @args
}
Set-Alias repox repoxZig
```

Reload the Microsoft.PowerShell_profile.ps1 file

```sh
. $PROFILE
```

Test it

```sh
repox help
```

## Building

Install Zig (0.13.0) from https://ziglang.org/download/ and run

```sh
zig build
```

the binary can be found in `/zig-out/bin`
