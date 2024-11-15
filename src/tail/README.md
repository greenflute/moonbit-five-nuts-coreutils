# tail

## specification

The Open Group Base Specifications Issue 8
IEEE Std 1003.1-2024
Copyright © 2001-2024 The IEEE and The Open Group

<https://pubs.opengroup.org/onlinepubs/9799919799/utilities/tail.html>

```txt
tail [-f] [-c number|-n number] [file] 

tail -r [-n number] [file] 

The following options shall be supported:

-c 
    number The application shall ensure that the number option-argument is a decimal integer, optionally including a sign. The sign shall affect the location in the file, measured in bytes, to begin the copying:
        + Relative to the beginning of the file.
        - Relative to the end of the file.
        none Relative to the end of the file.

        The application shall ensure that if the sign of the number option-argument is '+', the number option-argument is a non-zero decimal integer.

        The origin for counting shall be 1; that is, -c +1 represents the first byte of the file, -c -1 the last.

-f 
    If the input file is a regular file or if the file operand specifies a FIFO, do not terminate after the last line of the input file has been copied, but read and copy further bytes from the input file when they become available. If no file operand is specified and standard input is a pipe or FIFO, the -f option shall be ignored. If the input file is not a FIFO, pipe, or regular file, it is unspecified whether or not the -f option shall be ignored.

-n number 
    If -r is not specified, this option shall be equivalent to -c number, except the starting location in the file shall be measured in lines instead of bytes. The origin for counting shall be 1; that is, -n +1 represents the first line of the file, -n -1 the last.
    
    If -r is specified, number shall specify the number of lines to read (in reverse) from the end of the input file. The application shall ensure that number does not have a sign.

-r 
    Copy the lines in reverse order (last line first). If -n is specified, that many lines of the file, starting with the last line, shall be copied. If -n is not specified, every line of the input file shall be copied.

If none of the -c, -n or -r options is specified, -n 10 shall be assumed.
```
