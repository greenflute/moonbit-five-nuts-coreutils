# wc

wc - Print newline, word, and byte counts for each FILE, and a total line if
more than one FILE is specified.  A word is a non-zero-length sequence of
characters delimited by white space.
usage: 
     wc [OPTION]... [FILE]...
options:
     -c, --bytes            print the byte counts
     -m, --chars            print the character counts
     -l, --lines            print the newline counts
     -L, --max-line-length  print the maximum display width
     -w, --words            print the word counts
     -h, --help             display this help and exit
     -v, --version          output version information and exit

## TODO
- stdin对于bytes的计算有问题
- 行数计算和gnu的wc略有不同，包含EOF前不存在"\n"的最后一行
