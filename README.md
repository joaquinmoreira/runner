# Runner
Small utility written in ruby that wraps a command run inside OS X **notifications**. It supports running as an arbitrary user and to a remote host (via ssh).

## Instalation
Copy-paste this script in some terminal and hit enter.
```
script_url='https://raw.githubusercontent.com/joaquinrulin/runner/master/runner.rb';bin_dest='/usr/local/bin/runner';curl $script_url > $bin_dest;chmod +x $bin_dest
```

## Usage
`runner <long_taking_command>`

## Examples
```runner touch test_file``` 

```runner git pull -v # verbose run``` 

```runner cap deploy -h remote_host -u remote_user # remote execution ```
