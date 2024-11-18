# head

## specification

The Open Group Base Specifications Issue 8
IEEE Std 1003.1-2024
Copyright © 2001-2024 The IEEE and The Open Group

<https://pubs.opengroup.org/onlinepubs/9799919799/utilities/head.html>

```txt
head [-c number|-n number] [file...]

The head utility shall conform to XBD 12.2 Utility Syntax Guidelines .

The following options shall be supported:

-c number
    The first number bytes of each input file shall be copied to standard output. The application shall ensure that the number option-argument is a positive decimal integer.

-n number
    This option shall be equivalent to -c number, except that the ending location in the file shall be measured in lines instead of bytes.

When a file contains less than number bytes or lines, it shall be copied to standard output in its entirety. This shall not be an error.

If no options are specified, head shall act as if -n 10 had been specified.
```
