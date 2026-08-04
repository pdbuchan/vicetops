#!/usr/bin/perl

# VICEtoPS Copyright 2004-2026 Paul David Buchan (pdbuchan@gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

use strict;
use warnings;

use constant {
  CHARACTER_FILE => "characters.390059-01.bin",  # ROM image of CBM character set definitions
  CHARACTER_ROM_SIZE => 8192,  # Size in bytes of upper + lowercase character set definition data
  CHARACTER_COUNT => 256,  # Number of CBM characters
  CHARACTER_ROWS => 8,  # Number of rows in one character (px)
  CHARACTER_COLUMNS => 8,  # Number of columns in one character (px)

  LEFT_MARGIN => 72,  # Set left margin as one inch (72 dpi).
  MAXIMUM_CHARACTERS_PER_LINE => 70,  # Set maximum number of characters per line.
  TOP_MARGIN => 756,  # Set top page margins as one inch.
  BOTTOM_MARGIN => 36,  # Set bottom page margins as one inch.
  LINE_SPACING => 12,  # Set spacing between lines.
  CBM_LINE_FEED => 141,  # CBM character for line-feed.
};

use constant CHARACTER_SET_SIZE => CHARACTER_COUNT * CHARACTER_ROWS;  # Size in bytes of upper or lowercase character set definition data

if (@ARGV != 3) {
  print STDOUT "\nVICEtoPS Copyright 2004-2026 Paul David Buchan\n\n";
  print STDOUT "Usage: ./vicetops.pl case_flag VICE_output_filename PostScript_filename\n\n";
  print STDOUT "case_flag:\n";
  print STDOUT "  u    Upper case character set\n";
  print STDOUT "  l    Lower case character set\n\n";
  print STDOUT "e.g., ./vicetops.pl u viceprnt.out viceprnt.ps\n\n";
  exit 0;
}

my ($case_flag, $input_filename, $output_filename) = @ARGV;
my $offset;

if (($case_flag eq "u") || ($case_flag eq "U")) {
  $offset = 0;
} elsif (($case_flag eq "l") || ($case_flag eq "L")) {
  $offset = CHARACTER_SET_SIZE;
} else {
  print STDERR "\nInvalid case flag. Type ./vicetops.pl for usage.\n\n";
  exit 1;
}

# Read in Commodore character set ROM.
open (my $fi, '<:raw', CHARACTER_FILE) or do {
  print STDERR "Unable to open character set file " . CHARACTER_FILE . ".\nError message: $!\n";
  exit 1;
};

my $rom_data = '';
my $bytes_read = read ($fi, $rom_data, CHARACTER_ROM_SIZE);
if (!defined ($bytes_read)) {
  print STDERR "Unable to read character set file " . CHARACTER_FILE . ".\nError message: $!\n";
  close ($fi);
  exit 1;
}
if ($bytes_read != CHARACTER_ROM_SIZE) {
  print STDERR "Character set file " . CHARACTER_FILE . " is shorter than " . CHARACTER_ROM_SIZE . " bytes.\n";
  close ($fi);
  exit 1;
}
close ($fi);

my @chr = unpack ("C*", $rom_data);

# Open VICE output file and count bytes.
open ($fi, '<:raw', $input_filename) or do {
  print STDERR "Unable to open VICE output file $input_filename.\nError message: $!\n";
  exit 1;
};

my $input_length = -s $fi;
if (!defined ($input_length)) {
  print STDERR "Unable to determine the size of VICE output file $input_filename.\nError message: $!\n";
  close ($fi);
  exit 1;
}
my $nchar = $input_length;

# Allocate memory for arrays dat and tmp for VICE output file data.
my @dat;
my @tmp;

# Read VICE output file into array dat.
my $input_data = '';
$bytes_read = read ($fi, $input_data, $nchar);
if (!defined ($bytes_read)) {
  print STDERR "Unable to read VICE output file $input_filename.\nError message: $!\n";
  close ($fi);
  exit 1;
}
if ($bytes_read != $nchar) {
  print STDERR "VICE output file $input_filename changed while it was being read.\n";
  close ($fi);
  exit 1;
}
close ($fi);
@dat = unpack ("C*", $input_data);

# Remove all line-feeds from file and store in tmp.
my $c = 0;
for (my $i = 0; $i < $nchar; $i++) {
  if ($dat[$i] != ord ("\n")) {
    $tmp[$c] = $dat[$i];
    $c++;
  }
}
$nchar = $c;

# Re-map ASCII to CBM for each character in viceprnt.out.
for (my $i = 0; $i < $nchar; $i++) {
  if (($tmp[$i] >= 0) && ($tmp[$i] <= 31)) {
    $dat[$i] = $tmp[$i] + 128;
  } elsif (($tmp[$i] >= 32) && ($tmp[$i] <= 63)) {
    $dat[$i] = $tmp[$i];
  } elsif (($tmp[$i] >= 64) && ($tmp[$i] <= 95)) {
    $dat[$i] = $tmp[$i] - 64;
  } elsif (($tmp[$i] >= 128) && ($tmp[$i] <= 159)) {
    $dat[$i] = $tmp[$i] + 64;
  } elsif (($tmp[$i] >= 160) && ($tmp[$i] <= 191)) {
    $dat[$i] = $tmp[$i] - 64;
  } elsif (($tmp[$i] >= 192) && ($tmp[$i] <= 223)) {
    $dat[$i] = $tmp[$i] - 128;
  } else {
    $dat[$i] = $tmp[$i];
  }
}

# Write header info for PostScript file.
open (my $fo, '>', $output_filename) or do {
  print STDERR "Can't open new PostScript file $output_filename.\nError message: $!\n";
  exit 1;
};

print {$fo} "%!PS-Adobe-3.0\n";
print {$fo} "%%Title: Commodore Printout\n";
print {$fo} "%%Creator: vicetops.pl - Paul David Buchan, 2004-2026\n";
print {$fo} "%%Pages: (atend)\n";
print {$fo} "%%Orientation: Portrait\n";
print {$fo} "0.000 0.000 0.000 setrgbcolor\n";
print {$fo} "8 dict begin\n";
print {$fo} "/FontType 3 def\n";
print {$fo} "/FontMatrix [.001 0 0 .001 0 0] def\n";
print {$fo} "/FontBBox [0 0 750 750] def\n\n";
printf {$fo} "/Encoding %u array def\n", CHARACTER_COUNT;
printf {$fo} "0 1 %u {Encoding exch /.notdef put} for\n", CHARACTER_COUNT - 1;
for (my $glyph = 0; $glyph < CHARACTER_COUNT; $glyph++) {
  printf {$fo} "Encoding %u /cbm%u put\n", $glyph, $glyph;
}
printf {$fo} "\n/CharProcs %u dict def\n", CHARACTER_COUNT + 1;  # .notdef plus one procedure for each character.
print {$fo} "CharProcs begin\n";
print {$fo} "/.notdef {} def\n";

# Decode CBM character set and redefine default PostScript Type 3 font set.
my $rom_index = 0;
my @row_bits = (0) x CHARACTER_COLUMNS;
for (my $glyph = 0; $glyph < CHARACTER_COUNT; $glyph++) {
  printf {$fo} "/cbm%u\n", $glyph;
  print {$fo} "{ 40.0 setlinewidth\n";
  print {$fo} "2 setlinecap\n";
  print {$fo} "[] 0 setdash\n";
  for (my $row = 0; $row < CHARACTER_ROWS; $row++) {
    for (my $col = 0; $col < CHARACTER_COLUMNS; $col++) {
      $row_bits[$col] = ($chr[$rom_index + $offset] >> (CHARACTER_COLUMNS - 1 - $col)) & 1;
    }
    $rom_index++;
    for (my $col = 0; $col < CHARACTER_COLUMNS; $col++) {
      if ($row_bits[$col] == 1) {
        printf {$fo} "%.2f %.2f moveto\n", $col * 93.75, 750.0 - ($row * 93.75);
        printf {$fo} "%.2f %.2f lineto\n", ($col * 93.75) + 31.25, 750.0 - ($row * 93.75);
      }
    }
  }
  print {$fo} "stroke\n";
  print {$fo} "} bind def\n\n";
}
print {$fo} "end\n";

# Build new character set.
print {$fo} "/BuildGlyph\n";
print {$fo} "{1000 0\n";
print {$fo} "0 0 750 750\n";
print {$fo} "setcachedevice\n";
print {$fo} "exch /CharProcs get exch\n";
print {$fo} "2 copy known not\n";
print {$fo} "{pop /.notdef}\n";
print {$fo} "if\n";
print {$fo} "get exec\n";
print {$fo} "} bind def\n\n";
print {$fo} "/BuildChar\n";
print {$fo} "{ 1 index /Encoding get exch get\n";
print {$fo} "  1 index /BuildGlyph get exec\n";
print {$fo} "} bind def\n";
print {$fo} "currentdict\n";
print {$fo} "end\n";
print {$fo} "/ExampleFont exch definefont pop\n";
print {$fo} "/ExampleFont findfont 10 scalefont setfont\n";

# Print out Commodore file.
my $pg = 1;
printf {$fo} "%%%%Page: Page %u\n", $pg;
my $y = TOP_MARGIN;  # Start printing at top of page.
my $chars_on_line = 0;
my $line_open = 0;
my $i = 0;

# Loop through all characters in VICE output file.
while ($i < $nchar) {

  # At beginning of a new line.
  if ($line_open == 0) {

    # Found line-feed instead of text
    if ($dat[$i] == CBM_LINE_FEED) {
      $y -= LINE_SPACING;
      $i++;

    # Start new line of text.
    } else {
      printf {$fo} "%d %d moveto\n", LEFT_MARGIN, $y;
      print {$fo} "-3 0 <";
      $chars_on_line = 0;
      $line_open = 1;
    }

  # Found line-feed which will terminate line of text.
  } elsif ($dat[$i] == CBM_LINE_FEED) {
    print {$fo} "> ashow\n";
    $line_open = 0;
    $chars_on_line = 0;
    $i++;
    $y -= LINE_SPACING;

  # Length of line has reached maximum.
  } elsif ($chars_on_line == MAXIMUM_CHARACTERS_PER_LINE) {
    print {$fo} "> ashow\n";
    $line_open = 0;
    $chars_on_line = 0;
    $y -= LINE_SPACING;

  # Print next character in file.
  } else {
    printf {$fo} "%02x", $dat[$i];
    $i++;
    $chars_on_line++;

    # Last character in file?
    if ($i == $nchar) {
      print {$fo} "> ashow\n";
      $line_open = 0;
    }
  }

  # Reached bottom of page.
  # Start another page only when unprinted input remains.
  if (($y < BOTTOM_MARGIN) && ($i < $nchar)) {
    $y = TOP_MARGIN;
    print {$fo} "showpage\n";
    $pg++;
    printf {$fo} "%%%%Page: Page %u\n", $pg;
  }
}

print {$fo} "showpage\n";
print {$fo} "%%Trailer\n";
printf {$fo} "%%%%Pages: %u\n", $pg;
print {$fo} "%%EOF\n";

# Close PostScript output file.
close ($fo);

exit 0;
