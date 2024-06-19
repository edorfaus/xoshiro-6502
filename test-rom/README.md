# Test ROM

This directory contains a NES ROM that runs some simple tests on all of
the xoshiro/xoroshiro implementations in the other directories.

Like the main code, it is written for the [ca65][] assembler. The
Makefile assumes that `ca65` and `ld65` are in your PATH, and makes use
of some standard Linux commands. Simply running `make` should cause the
ROM file `build/tests.nes` to be created. I use [Mesen][] to run it, but
any half-decent NES or Famicom emulator should work.

[ca65]: https://cc65.github.io/doc/ca65.html
[Mesen]: https://www.mesen.ca/

When run, it will output a sequence of symbols to the screen. There are
3 symbols in use, green circles, red Xes, and white lines. Each green
circle and red X represent a test, that either succeeded (green circle)
or failed (red X). The white lines, and blank spaces between symbols,
are just separators to make it easier to see which test is where.

For more details, check the code; in particular, the main body of the
tests are in the [main.asm](/test-rom/main.asm) file (starting at Main).

Note that [one of the files](/test-rom/nes2header.inc) in this directory
was not written by me, and has a different license to the other files,
as described at the top of that file.
