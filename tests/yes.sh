#!/bin/bash

set -e
# Due to https://github.com/moonbitlang/moon/issues/472
# This is test using `yes` instead of `moon run src/yes`

(yes ||:) | head -n 2 | grep -q 'y$'