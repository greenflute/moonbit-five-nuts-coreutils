#!/bin/bash

set -e
rm -rf rmdir_test_dir
mkdir rmdir_test_dir 
mkdir rmdir_test_dir/a
mkdir rmdir_test_dir/a/b
touch rmdir_test_dir/a/b/c.txt
moon run src/rmdir -- -VIp rmdir_test_dir/a/b

