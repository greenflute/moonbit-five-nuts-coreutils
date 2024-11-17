# echo

## specification

The Open Group Base Specifications Issue 8
IEEE Std 1003.1-2024
Copyright © 2001-2024 The IEEE and The Open Group

<https://pubs.opengroup.org/onlinepubs/9799919799/utilities/echo.html>

```txt
echo [string...]

The following operands shall be supported:

string
    A string to be written to standard output. If the first operand consists of a '-' followed by one or more characters from the set {'e', 'E', 'n'}, or if any of the operands contain a <backslash> character, the results are implementation-defined.
    [XSI] [Option Start] On XSI-conformant systems, if the first operand consists of a '-' followed by one or more characters from the set {'e', 'E', 'n'}, it shall be treated as a string to be written. The following character sequences shall be recognized on XSI-conformant systems within any of the arguments:

\a
    Write an <alert>.
\b
    Write a <backspace>.
\c
    Suppress the <newline> that otherwise follows the final argument in the output. All characters following the '\c' in the arguments shall be ignored.
\f
    Write a <form-feed>.
\n
    Write a <newline>.
\r
    Write a <carriage-return>.
\t
    Write a <tab>.
\v
    Write a <vertical-tab>.
\\
    Write a <backslash> character.
\0num
    Write an 8-bit value that is the zero, one, two, or three-digit octal number num.
```
