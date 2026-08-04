"""Copyright (C) 2025-2026 Paul David Buchan (pdbuchan@gmail.com)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
"""

import os
import sys


CHARACTER_FILE = "characters.390059-01.bin"  # ROM image of CBM character set definitions
CHARACTER_ROM_SIZE = 8192  # Size in bytes of upper + lowercase character set definition data
CHARACTER_COUNT = 256  # Number of CBM characters
CHARACTER_ROWS = 8  # Number of rows in one character (px)
CHARACTER_COLUMNS = 8  # Number of columns in one character (px)
CHARACTER_SET_SIZE = CHARACTER_COUNT * CHARACTER_ROWS  # Size in bytes of one character set

LEFT_MARGIN = 72  # Set left margin as one inch (72 dpi).
MAXIMUM_CHARACTERS_PER_LINE = 70  # Set maximum number of characters per line.
TOP_MARGIN = 756  # Set top page margins as one inch.
BOTTOM_MARGIN = 36  # Set bottom page margins as one inch.
LINE_SPACING = 12  # Set spacing between lines.
CBM_LINE_FEED = 141  # CBM character for line-feed.


def main():

  if len (sys.argv) != 4:
    print ("\nVICEtoPS Copyright 2025-2026 Paul David Buchan\n")
    print ("Usage: python3 ./vicetops.py case_flag VICE_output_filename PostScript_filename\n")
    print ("case_flag:")
    print ("  u    Upper case character set")
    print ("  l    Lower case character set\n")
    print ("e.g., python3 ./vicetops.py u viceprnt.out viceprnt.ps\n")
    return 0

  case_flag = sys.argv[1]
  input_filename = sys.argv[2]
  output_filename = sys.argv[3]

  if case_flag == "u" or case_flag == "U":
    offset = 0
  elif case_flag == "l" or case_flag == "L":
    offset = CHARACTER_SET_SIZE
  else:
    print ("\nInvalid case flag. Type python3 ./vicetops.py for usage.\n", file = sys.stderr)
    return 1

  # Read in Commodore character set ROM.
  try:
    with open (CHARACTER_FILE, mode = "rb") as fi:
      character_rom = bytearray (fi.read (CHARACTER_ROM_SIZE))
  except OSError as error:
    print (f"Unable to open character set file {CHARACTER_FILE}.\nError message: {error}", file = sys.stderr)
    return 1

  if len (character_rom) != CHARACTER_ROM_SIZE:
    print (f"Character set file {CHARACTER_FILE} is shorter than {CHARACTER_ROM_SIZE} bytes.", file = sys.stderr)
    return 1

  # Open VICE output file and count bytes.
  try:
    with open (input_filename, mode = "rb") as fi:
      fi.seek (0, os.SEEK_END)
      input_length = fi.tell ()
      fi.seek (0, os.SEEK_SET)

      # Allocate memory for arrays dat and tmp for VICE output file data.
      dat = bytearray (input_length)
      tmp = bytearray (input_length)

      # Read VICE output file into array dat.
      input_data = fi.read (input_length)
      if len (input_data) != input_length:
        print (f"VICE output file {input_filename} changed while it was being read.", file = sys.stderr)
        return 1
      dat[:] = input_data
  except OSError as error:
    print (f"Unable to open or read VICE output file {input_filename}.\nError message: {error}", file = sys.stderr)
    return 1

  nchar = input_length

  # Remove all line-feeds from file and store in tmp.
  c = 0
  for i in range (nchar):
    if dat[i] != ord ("\n"):
      tmp[c] = dat[i]
      c += 1
  nchar = c

  # Re-map ASCII to CBM for each character in viceprnt.out.
  for i in range (nchar):
    if 0 <= tmp[i] <= 31:
      dat[i] = tmp[i] + 128
    elif 32 <= tmp[i] <= 63:
      dat[i] = tmp[i]
    elif 64 <= tmp[i] <= 95:
      dat[i] = tmp[i] - 64
    elif 128 <= tmp[i] <= 159:
      dat[i] = tmp[i] + 64
    elif 160 <= tmp[i] <= 191:
      dat[i] = tmp[i] - 64
    elif 192 <= tmp[i] <= 223:
      dat[i] = tmp[i] - 128
    else:
      dat[i] = tmp[i]

  # Write header info for PostScript file.
  try:
    with open (output_filename, mode = "w", encoding = "ascii") as fo:
      fo.write ("%!PS-Adobe-3.0\n")
      fo.write ("%%Title: Commodore Printout\n")
      fo.write ("%%Creator: vicetops.py - Paul David Buchan, 2025-2026\n")
      fo.write ("%%Pages: (atend)\n")
      fo.write ("%%Orientation: Portrait\n")
      fo.write ("0.000 0.000 0.000 setrgbcolor\n")
      fo.write ("8 dict begin\n")
      fo.write ("/FontType 3 def\n")
      fo.write ("/FontMatrix [.001 0 0 .001 0 0] def\n")
      fo.write ("/FontBBox [0 0 750 750] def\n\n")
      fo.write (f"/Encoding {CHARACTER_COUNT} array def\n")
      fo.write (f"0 1 {CHARACTER_COUNT - 1} {{Encoding exch /.notdef put}} for\n")
      for glyph in range (CHARACTER_COUNT):
        fo.write (f"Encoding {glyph} /cbm{glyph} put\n")
      fo.write (f"\n/CharProcs {CHARACTER_COUNT + 1} dict def\n")  # .notdef plus all character procedures.
      fo.write ("CharProcs begin\n")
      fo.write ("/.notdef {} def\n")

      # Decode CBM character set and redefine default PostScript Type 3 font set.
      rom_index = 0
      row_bits = [0] * CHARACTER_COLUMNS
      for glyph in range (CHARACTER_COUNT):
        fo.write (f"/cbm{glyph}\n")
        fo.write ("{ 40.0 setlinewidth\n")
        fo.write ("2 setlinecap\n")
        fo.write ("[] 0 setdash\n")
        for row in range (CHARACTER_ROWS):
          for col in range (CHARACTER_COLUMNS):
            row_bits[col] = (character_rom[rom_index + offset] >> (CHARACTER_COLUMNS - 1 - col)) & 1
          rom_index += 1
          for col in range (CHARACTER_COLUMNS):
            if row_bits[col] == 1:
              fo.write (f"{col * 93.75:.2f} {750.0 - (row * 93.75):.2f} moveto\n")
              fo.write (f"{(col * 93.75) + 31.25:.2f} {750.0 - (row * 93.75):.2f} lineto\n")
        fo.write ("stroke\n")
        fo.write ("} bind def\n\n")
      fo.write ("end\n")

      # Build new character set.
      fo.write ("/BuildGlyph\n")
      fo.write ("{1000 0\n")
      fo.write ("0 0 750 750\n")
      fo.write ("setcachedevice\n")
      fo.write ("exch /CharProcs get exch\n")
      fo.write ("2 copy known not\n")
      fo.write ("{pop /.notdef}\n")
      fo.write ("if\n")
      fo.write ("get exec\n")
      fo.write ("} bind def\n\n")
      fo.write ("/BuildChar\n")
      fo.write ("{ 1 index /Encoding get exch get\n")
      fo.write ("  1 index /BuildGlyph get exec\n")
      fo.write ("} bind def\n")
      fo.write ("currentdict\n")
      fo.write ("end\n")
      fo.write ("/ExampleFont exch definefont pop\n")
      fo.write ("/ExampleFont findfont 10 scalefont setfont\n")

      # Print out Commodore file.
      pg = 1
      fo.write (f"%%Page: Page {pg}\n")
      y = TOP_MARGIN  # Start printing at top of page.
      chars_on_line = 0
      line_open = 0
      i = 0

      # Loop through all characters in VICE output file.
      while i < nchar:

        # At beginning of a new line.
        if line_open == 0:

          # Found line-feed instead of text
          if dat[i] == CBM_LINE_FEED:
            y -= LINE_SPACING
            i += 1

          # Start new line of text.
          else:
            fo.write (f"{LEFT_MARGIN} {y} moveto\n")
            fo.write ("-3 0 <")
            chars_on_line = 0
            line_open = 1

        # Found line-feed which will terminate line of text.
        elif dat[i] == CBM_LINE_FEED:
          fo.write ("> ashow\n")
          line_open = 0
          chars_on_line = 0
          i += 1
          y -= LINE_SPACING

        # Length of line has reached maximum.
        elif chars_on_line == MAXIMUM_CHARACTERS_PER_LINE:
          fo.write ("> ashow\n")
          line_open = 0
          chars_on_line = 0
          y -= LINE_SPACING

        # Print next character in file.
        else:
          fo.write (f"{dat[i]:02x}")
          i += 1
          chars_on_line += 1

          # Last character in file?
          if i == nchar:
            fo.write ("> ashow\n")
            line_open = 0

        # Reached bottom of page.
        # Start another page only when unprinted input remains.
        if (y < BOTTOM_MARGIN) and (i < nchar):
          y = TOP_MARGIN
          fo.write ("showpage\n")
          pg += 1
          fo.write (f"%%Page: Page {pg}\n")

      fo.write ("showpage\n")
      fo.write ("%%Trailer\n")
      fo.write (f"%%Pages: {pg}\n")
      fo.write ("%%EOF\n")

  except OSError as error:
    print (f"Can't open or write new PostScript file {output_filename}.\nError message: {error}", file = sys.stderr)
    return 1

  return 0


if __name__ == "__main__":
  sys.exit (main ())
