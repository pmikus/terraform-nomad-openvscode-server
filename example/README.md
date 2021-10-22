# OpenVSCode Server example

The current directory contains terraform related files that use the module
in `../..`. The [example minio module](main.tf) runs with
[host volume](https://www.nomadproject.io/docs/job-specification/volume) enabled
and the worspace data is saved in the `/home/workspace` folder.
