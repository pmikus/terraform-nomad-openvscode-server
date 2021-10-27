# Code Server example

The current directory contains terraform related files that use the module
in `../`. The [example code-server module](main.tf) runs with
[host volume](https://www.nomadproject.io/docs/job-specification/volume) enabled
and the workspace data is saved in the `/home/coder/woorkspace` folder.

