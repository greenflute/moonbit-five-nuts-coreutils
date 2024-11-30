#!/bin/bash

set -e

moon run src/wc -- -lcmw --max-line-length README.md
moon run src/wc < README.md
