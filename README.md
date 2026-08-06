# VICE Output to PostScript (VICEtoPS)

**VICEtoPS** is a utility which will produce a simulated Commodore dot-matrix printout from the "print.dump" or "viceprnt.out" file obtained from the [VICE](https://vice-emu.sourceforge.io) emulator.

The utility creates an [Adobe](https://www.adobe.com) PostScript file which, when printed on a PostScript-enabled printer, displays the full set of Commodore characters. Because I redefine an existing font (in order to have the special Commodore characters and to have the dot-matrix look), there is a large overhead (about 300 kB) that always comes with the PostScript file. Nevertheless, I decided it was a tolerable burden.

All versions of this utility require the character set ROM image file in the same directory as the executable. This [Commodore character set](characters.390059-01.bin) (8 KB) was obtained from [http://www.zimmers.net/anonftp/pub/cbm/firmware/computers/c128/](http://www.zimmers.net/anonftp/pub/cbm/firmware/computers/c128). It is a binary ROM image file.

Here is an example of what the utility does:

Taking my VICE emulator printer dump file [print.dump](print.dump) (23 KB) or WinVICE emulator printer output file [viceprnt.out](viceprnt.out) (24 KB), a PostScript printout file [viceprnt.ps](viceprnt.ps) (427 KB) was generated.  A [pdf version](viceprnt.pdf) version (47 KB) was later created from the PostScript using Adobe Distiller. Note the significant decrease in file size as the PostScript (.ps) is converted to Portable Document Format (.pdf).

VICEtoPS should work with both viceprnt.out and print.dump files.

## Available Versions:

| Language | File |
|---|---|
| Visual Basic (.NET) | [`vicetops.vb`](vb/) |
| Perl | [`vicetops.pl`](perl/) |
| C | [`vicetops.c`](c/) |
| Fortran | [`vicetops.f`](fortran/) |
| Common Lisp | [`vicetops.lisp`](lisp/) |
| Python | [`vicetops.py`](python/) |

Project links:

- GitHub: <https://github.com/pdbuchan/vicetops>
- Email: <pdbuchan@gmail.com>


## License

The VICEtoPS source code is free software licensed under the **GNU General Public License, version 3 or any later version**.

<p class="signature">P. David Buchan <a href="mailto:pdbuchan@gmail.com">pdbuchan@gmail.com</a></p>
