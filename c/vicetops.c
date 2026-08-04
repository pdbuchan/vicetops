/* VICEtoPS Copyright 2004-2026 Paul David Buchan (pdbuchan@gmail.com)

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <errno.h>

#define CHARACTER_FILE "characters.390059-01.bin"  /* ROM image of CBM character set definitions */
#define CHARACTER_ROM_SIZE 8192  /* Size in bytes of upper + lowercase character set definition data */
#define CHARACTER_COUNT 256  /* Number of CBM characters */
#define CHARACTER_ROWS 8  /* Number of rows in one character (px) */
#define CHARACTER_COLUMNS 8  /* Number of columns in one character (px) */
#define CHARACTER_SET_SIZE (CHARACTER_COUNT * CHARACTER_ROWS)  /* Size in bytes of upper or lowercase character set definition data */

#define LEFT_MARGIN 72  /* Set left margin as one inch (72 dpi). */
#define MAXIMUM_CHARACTERS_PER_LINE 70  /* Set maximum number of characters per line. */
#define TOP_MARGIN 756  /* Set top page margins as one inch. */
#define BOTTOM_MARGIN 36  /* Set bottom page margins as one inch. */
#define LINE_SPACING 12   /* Set spacing between lines. */
#define CBM_LINE_FEED 141  /* CBM character for line-feed. */

int
main (int argc, char **argv) {

  int c, row, col, row_bits[CHARACTER_COLUMNS], y, line_open;
  size_t glyph, i, chars_on_line, rom_index, nchar, offset, pg;
  uint8_t chr[CHARACTER_ROM_SIZE], *dat, *tmp;
  long input_length;
  FILE *fi, *fo;

  if (argc != 4) {
    fprintf (stdout, "\nVICEtoPS Copyright 2004-2026 Paul David Buchan\n\n");
    fprintf (stdout, "Usage: ./vicetops case_line_open VICE_output_filename PostScript_filename\n\n");
    fprintf (stdout, "case_line_open:\n");
    fprintf (stdout, "  u    Upper case character set\n");
    fprintf (stdout, "  l    Lower case character set\n\n");
    fprintf (stdout, "e.g., ./vicetops u viceprnt.out viceprnt.ps\n\n");
    return (EXIT_SUCCESS);
  }

  if (strcmp (argv[1], "u") == 0 || strcmp (argv[1], "U") == 0) {
    offset = 0;
  } else if (strcmp (argv[1], "l") == 0 || strcmp (argv[1], "L") == 0) {
    offset = CHARACTER_SET_SIZE;
  } else {
    fprintf (stderr, "\nInvalid case line_open. Type ./vicetops for usage.\n\n");
    exit (EXIT_FAILURE);
  }

  /* Read in Commodore character set ROM. */
  fi = fopen (CHARACTER_FILE, "rb");
  if (fi == NULL) {
    fprintf (stderr, "Unable to open character set file %s.\nError message: %s\n", CHARACTER_FILE, strerror (errno));
    exit (EXIT_FAILURE);
  }

  if (fread (chr, sizeof (*chr), CHARACTER_ROM_SIZE, fi) != CHARACTER_ROM_SIZE) {
    if (ferror (fi)) {
      fprintf (stderr, "Unable to read character set file %s.\nError message: %s\n", CHARACTER_FILE, strerror (errno));
    } else {
      fprintf (stderr, "Character set file %s is shorter than %d bytes.\n", CHARACTER_FILE, CHARACTER_ROM_SIZE);
    }
    fclose (fi);
    exit (EXIT_FAILURE);
  }
  if (ferror (fi)) {
    fprintf (stderr, "Unable to finish reading character set file %s.\nError message: %s\n", CHARACTER_FILE, strerror (errno));
    fclose (fi);
    return (EXIT_FAILURE);
  }
  fclose (fi);

  /* Open VICE output file and count bytes. */
  fi = fopen (argv[2], "rb");
  if (fi == NULL) {
    fprintf (stderr, "Unable to open VICE output file %s.\nError message: %s\n", argv[2], strerror (errno));
    exit (EXIT_FAILURE);
  }
  if (fseek (fi, 0L, SEEK_END) != 0) {
    fprintf (stderr, "Unable to seek in VICE output file %s.\nError message: %s\n", argv[2], strerror (errno));
    fclose (fi);
    exit (EXIT_FAILURE);
  }
  input_length = ftell (fi);
  if (input_length < 0) {
    fprintf (stderr, "Unable to determine the size of VICE output file %s.\nError message: %s\n", argv[2], strerror (errno));
    fclose (fi);
    exit (EXIT_FAILURE);
  }
  if ((uintmax_t) input_length > SIZE_MAX) {
    fprintf (stderr, "VICE output file %s is too large to process.\n", argv[2]);
    fclose (fi);
    exit (EXIT_FAILURE);
  }
  nchar = (size_t) input_length;
  if (fseek (fi, 0L, SEEK_SET) != 0) {
    fprintf (stderr, "Unable to rewind VICE output file %s.\nError message: %s\n", argv[2], strerror (errno));
    fclose (fi);
    exit (EXIT_FAILURE);
  }

  /* Allocate memory for arrays dat and tmp for VICE output file data. */
  dat = calloc (nchar, sizeof (*dat));
  if (dat == NULL) {
    fprintf (stderr, "calloc() failed for dat.\n");
    exit (EXIT_FAILURE);
  }
  tmp = calloc (nchar, sizeof (*tmp));
  if (tmp == NULL) {
    fprintf (stderr, "calloc() failed for tmp.\n");
    exit (EXIT_FAILURE);
  }

  /* Read VICE output file into array dat. */
  if ((nchar > 0) && fread (dat, sizeof (*dat), nchar, fi) != nchar) {
    if (ferror (fi)) {
      fprintf (stderr, "Unable to read VICE output file %s.\nError message: %s\n", argv[2], strerror (errno));
    } else {
      fprintf (stderr, "VICE output file %s changed while it was being read.\n", argv[2]);
    }
    free (dat);
    fclose (fi);
    exit (EXIT_FAILURE);
  }
  fclose (fi);

  /* Remove all line-feeds from file and store in tmp. */
  c = 0;
  for (i = 0; i < nchar; i++) {
    if (dat[i] != '\n') {
      tmp[c] = dat[i];
      c++;
    }
  }
  nchar = c;

  /* Re-map ASCII to CBM for each character in viceprnt.out. */
  for (i = 0; i < nchar; i++) {
    if (tmp[i] >= 0 && tmp[i] <= 31) {
      dat[i] = tmp[i] + 128;
    } else if (tmp[i] >= 32 && tmp[i] <= 63) {
      dat[i] = tmp[i];
    } else if (tmp[i] >= 64 && tmp[i] <= 95) {
      dat[i] = tmp[i] - 64;
    } else if (tmp[i] >= 128 && tmp[i] <= 159) {
      dat[i] = tmp[i] + 64;
    } else if (tmp[i] >= 160 && tmp[i] <= 191) {
      dat[i] = tmp[i] - 64;
    } else if (tmp[i] >= 192 && tmp[i] <= 223) {
      dat[i] = tmp[i] - 128;
    } else {
      dat[i] = tmp[i];
    }
  }

  /* Write header info for PostScript file. */
  fo = fopen (argv[3], "w");
  if (fo == NULL) {
    fprintf (stderr, "Can't open new PostScript file %s.\nError message: %s\n", argv[3], strerror (errno));
    free (dat);
    free (tmp);
    exit (EXIT_FAILURE);
  }

  fprintf (fo, "%%!PS-Adobe-3.0\n");
  fprintf (fo, "%%%%Title: Commodore Printout\n");
  fprintf (fo, "%%%%Creator: vicetops.c - Paul David Buchan, 2004-2026\n");
  fprintf (fo, "%%%%Pages: (atend)\n");
  fprintf (fo, "%%%%Orientation: Portrait\n");
  fprintf (fo, "0.000 0.000 0.000 setrgbcolor\n");
  fprintf (fo, "8 dict begin\n");
  fprintf (fo, "/FontType 3 def\n");
  fprintf (fo, "/FontMatrix [.001 0 0 .001 0 0] def\n");
  fprintf (fo, "/FontBBox [0 0 750 750] def\n\n");
  fprintf (fo, "/Encoding %d array def\n", CHARACTER_COUNT);
  fprintf (fo, "0 1 %d {Encoding exch /.notdef put} for\n", CHARACTER_COUNT - 1);
  for (glyph = 0; glyph < CHARACTER_COUNT; glyph++) {
    fprintf (fo, "Encoding %zu /cbm%zu put\n", glyph, glyph);
  }
  fprintf (fo, "\n/CharProcs %d dict def\n", CHARACTER_COUNT + 1);  /* .notdef plus one procedure for each character. */
  fprintf (fo, "CharProcs begin\n");
  fprintf (fo, "/.notdef {} def\n");

  /* Decode CBM character set and redefine default PostScript Type 3 font set. */
  rom_index = 0;  
  for (glyph = 0; glyph < CHARACTER_COUNT; glyph++) {
    fprintf (fo, "/cbm%zu\n", glyph);
    fprintf (fo, "{ 40.0 setlinewidth\n");
    fprintf (fo, "2 setlinecap\n");
    fprintf (fo, "[] 0 setdash\n");
    for (row = 0; row < CHARACTER_ROWS; row++) {
      for (col = 0; col < CHARACTER_COLUMNS; col++) {
        row_bits[col] = (chr[rom_index + offset] >> (CHARACTER_COLUMNS - 1 - col)) & 1;
      }
      rom_index++;
      for (col = 0; col < CHARACTER_COLUMNS; col++) {
        if (row_bits[col] == 1) {
          fprintf (fo, "%.2f %.2f moveto\n", col * 93.75, (750.0 - (row * 93.75)));
          fprintf (fo, "%.2f %.2f lineto\n", (col * 93.75) + 31.25, 750.0 - (row * 93.75));
        }
      }
    }
    fprintf (fo, "stroke\n");
    fprintf (fo, "} bind def\n\n");
  }
  fprintf (fo, "end\n");
     
  /* Build new character set. */
  fprintf (fo, "/BuildGlyph\n");
  fprintf (fo, "{1000 0\n");
  fprintf (fo, "0 0 750 750\n");
  fprintf (fo, "setcachedevice\n");
  fprintf (fo, "exch /CharProcs get exch\n");
  fprintf (fo, "2 copy known not\n");
  fprintf (fo, "{pop /.notdef}\n");
  fprintf (fo, "if\n");
  fprintf (fo, "get exec\n");
  fprintf (fo, "} bind def\n\n");
  fprintf (fo, "/BuildChar\n");
  fprintf (fo, "{ 1 index /Encoding get exch get\n");
  fprintf (fo, "  1 index /BuildGlyph get exec\n");
  fprintf (fo, "} bind def\n");
  fprintf (fo, "currentdict\n");
  fprintf (fo, "end\n");
  fprintf (fo, "/ExampleFont exch definefont pop\n");
  fprintf (fo, "/ExampleFont findfont 10 scalefont setfont\n");

  /* Print out Commodore file. */
  pg = 1;
  fprintf (fo, "%%%%Page: Page %zu\n", pg);
  y = TOP_MARGIN;  /* Start printing at top of page. */
  chars_on_line = 0;
  line_open = 0;
  i = 0;

  /* Loop through all characters in VICE output file. */
  while (i < nchar) {

    /* At beginning of a new line. */
    if (line_open == 0) {

      /* Found line-feed instead of text */
      if (dat[i] == CBM_LINE_FEED) {
        y -= LINE_SPACING;
        i++;

      /* Start new line of text. */
      } else {
        fprintf (fo, "%d %d moveto\n", LEFT_MARGIN, y);
        fprintf (fo, "-3 0 <");
        chars_on_line = 0;
        line_open = 1;
      }

    /* Found line-feed which will terminate line of text. */
    } else if (dat[i] == CBM_LINE_FEED) {
      fprintf (fo, "> ashow\n");
      line_open = 0;
      chars_on_line = 0;
      i++;
      y -= LINE_SPACING;

    /* Length of line has reached maximum. */
    } else if (chars_on_line == MAXIMUM_CHARACTERS_PER_LINE) {
      fprintf (fo, "> ashow\n");
      line_open = 0;
      chars_on_line = 0;
      y -= LINE_SPACING;

    /* Print next character in file. */
    } else {
      fprintf (fo, "%02x", (unsigned int) dat[i]);
      i++;
      chars_on_line++;

      /* Last character in file? */
      if (i == nchar) {
        fprintf (fo, "> ashow\n");
        line_open = 0;
      }
    }

    /* Reached bottom of page. */
    /* Start another page only when unprinted input remains. */
    if ((y < BOTTOM_MARGIN) && (i < nchar)) {
      y = TOP_MARGIN;
      fprintf (fo, "showpage\n");
      pg++;
      fprintf (fo, "%%%%Page: Page %zu\n", pg);
    }
  }

  fprintf (fo, "showpage\n");
  fprintf (fo, "%%%%Trailer\n");
  fprintf (fo, "%%%%Pages: %zu\n", pg);
  fprintf (fo, "%%%%EOF\n");

  /* Close PostScript output file. */
  fclose (fo);

  /* Free memory allocated for arrays dat and tmp. */
  free (dat);
  free (tmp);

  return (EXIT_SUCCESS);
}
