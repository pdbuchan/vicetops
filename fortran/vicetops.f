C     VICEtoPS Copyright 2004-2026 Paul David Buchan
C     (pdbuchan@gmail.com)
C
C     This program is free software; you can redistribute it and/or
C     modify it under the terms of the GNU General Public License as
C     published by the Free Software Foundation; either version 2 of
C     the License, or (at your option) any later version.
C
C     This program is distributed in the hope that it will be useful,
C     but WITHOUT ANY WARRANTY; without even the implied warranty of
C     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
C     GNU General Public License for more details.
C
C     You should have received a copy of the GNU General Public License
C     along with this program; if not, write to the Free Software
C     Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
C     02110-1301  USA

      program vicetops

      use, intrinsic :: iso_fortran_env, only: error_unit, output_unit,
     & int8, int32, int64, real64

      implicit none

      character(len=*), parameter :: CHARACTER_FILE =
     & 'characters.390059-01.bin'
C     ROM image of CBM character set definitions
      integer, parameter :: CHARACTER_ROM_SIZE = 8192
C     Size in bytes of upper + lowercase character set definition data
      integer, parameter :: CHARACTER_COUNT = 256
C     Number of CBM characters
      integer, parameter :: CHARACTER_ROWS = 8
C     Number of rows in one character (px)
      integer, parameter :: CHARACTER_COLUMNS = 8
C     Number of columns in one character (px)
      integer, parameter :: CHARACTER_SET_SIZE =
     &  CHARACTER_COUNT * CHARACTER_ROWS
C     Size in bytes of upper or lowercase character set definition data

      integer, parameter :: LEFT_MARGIN = 72
C     Set left margin as one inch (72 dpi).
      integer, parameter :: MAXIMUM_CHARACTERS_PER_LINE = 70
C     Set maximum number of characters per line.
      integer, parameter :: TOP_MARGIN = 756
C     Set top page margins as one inch.
      integer, parameter :: BOTTOM_MARGIN = 36
C     Set bottom page margins as one inch.
      integer, parameter :: LINE_SPACING = 12
C     Set spacing between lines.
      integer, parameter :: CBM_LINE_FEED = 141
C     CBM character for line-feed.

      integer :: row, col, y, line_open, ios, alloc_status
      integer :: fi, fo
      integer :: row_bits(CHARACTER_COLUMNS)
      integer(int32) :: chr(CHARACTER_ROM_SIZE)
      integer(int8) :: rom_bytes(CHARACTER_ROM_SIZE)
      integer(int8), allocatable :: raw_data(:)
      integer(int32), allocatable :: dat(:), tmp(:)
      integer(int64) :: c, glyph, i, chars_on_line, rom_index
      integer(int64) :: nchar, offset, pg, input_length
      character(len=1) :: case_flag
      character(len=1024) :: filein, fileout
      character(len=512) :: error_message

      if (command_argument_count().ne.3) then
        write (output_unit,'(A)')
        write (output_unit,'(A)')
     &  'VICEtoPS Copyright 2004-2026 Paul David Buchan'
        write (output_unit,'(A)')
        write (output_unit,'(A)')
     &  'Usage: ./vicetops case_flag VICE_output_filename ' //
     &  'PostScript_filename'
        write (output_unit,'(A)')
        write (output_unit,'(A)') 'case_flag:'
        write (output_unit,'(A)') '  u    Upper case character set'
        write (output_unit,'(A)') '  l    Lower case character set'
        write (output_unit,'(A)')
        write (output_unit,'(A)')
     &  'e.g., ./vicetops u viceprnt.out viceprnt.ps'
        write (output_unit,'(A)')
        stop
      end if

      call get_command_argument (1, case_flag)
      if ((case_flag.eq.'u').or.(case_flag.eq.'U')) then
        offset = 0_int64
      else if ((case_flag.eq.'l').or.(case_flag.eq.'L')) then
        offset = int (CHARACTER_SET_SIZE, int64)
      else
        write (error_unit,'(A)')
        write (error_unit,'(A)')
     &  'Invalid case flag. Type ./vicetops for usage.'
        write (error_unit,'(A)')
        error stop 1
      end if

      call get_command_argument (2, filein)
      call get_command_argument (3, fileout)

C     Read in Commodore character set ROM.
      open (newunit=fi, file=CHARACTER_FILE, form='unformatted',
     & access='stream', status='old', action='read', iostat=ios,
     & iomsg=error_message)
      if (ios.ne.0) then
        write (error_unit,'(A,A,A)')
     &  'Unable to open character set file ', CHARACTER_FILE, '.'
        write (error_unit,'(A,A)')
     &  'Error message: ', trim (error_message)
        error stop 1
      end if

      inquire (unit=fi, size=input_length, iostat=ios,
     & iomsg=error_message)
      if (ios.ne.0) then
        write (error_unit,'(A,A,A)')
     &  'Unable to determine the size of character set file ',
     &  CHARACTER_FILE, '.'
        write (error_unit,'(A,A)')
     &  'Error message: ', trim (error_message)
        close (fi)
        error stop 1
      end if

      if (input_length.lt.CHARACTER_ROM_SIZE) then
        write (error_unit,'(A,A,A,I0,A)')
     &  'Character set file ', CHARACTER_FILE,
     &  ' is shorter than ', CHARACTER_ROM_SIZE, ' bytes.'
        close (fi)
        error stop 1
      end if

      read (fi, iostat=ios, iomsg=error_message) rom_bytes
      if (ios.ne.0) then
        write (error_unit,'(A,A,A)')
     &  'Unable to read character set file ', CHARACTER_FILE, '.'
        write (error_unit,'(A,A)')
     &  'Error message: ', trim (error_message)
        close (fi)
        error stop 1
      end if
      close (fi)

      do i = 1, CHARACTER_ROM_SIZE
        chr(i) = iand (int (rom_bytes(i), int32),
     &                 int (z'ff', int32))
      end do

C     Open VICE output file and count bytes.
      open (newunit=fi, file=trim (filein), form='unformatted',
     & access='stream', status='old', action='read', iostat=ios,
     & iomsg=error_message)
      if (ios.ne.0) then
        write (error_unit,'(A,A,A)')
     &  'Unable to open VICE output file ', trim (filein), '.'
        write (error_unit,'(A,A)')
     &  'Error message: ', trim (error_message)
        error stop 1
      end if

      inquire (unit=fi, size=input_length, iostat=ios,
     & iomsg=error_message)
      if (ios.ne.0) then
        write (error_unit,'(A,A,A)')
     &  'Unable to determine the size of VICE output file ',
     &  trim (filein), '.'
        write (error_unit,'(A,A)')
     &  'Error message: ', trim (error_message)
        close (fi)
        error stop 1
      end if
      nchar = input_length

C     Allocate memory for arrays dat and tmp for VICE output file data.
      allocate (raw_data(nchar), stat=alloc_status)
      if (alloc_status.ne.0) then
        write (error_unit,'(A)')
     &  'Allocation failed for raw_data.'
        close (fi)
        error stop 1
      end if

      allocate (dat(nchar), stat=alloc_status)
      if (alloc_status.ne.0) then
        write (error_unit,'(A)') 'Allocation failed for dat.'
        deallocate (raw_data)
        close (fi)
        error stop 1
      end if

      allocate (tmp(nchar), stat=alloc_status)
      if (alloc_status.ne.0) then
        write (error_unit,'(A)') 'Allocation failed for tmp.'
        deallocate (raw_data)
        deallocate (dat)
        close (fi)
        error stop 1
      end if

C     Read VICE output file into array dat.
      if (nchar.gt.0) then
        read (fi, iostat=ios, iomsg=error_message) raw_data
        if (ios.ne.0) then
          if (is_iostat_end (ios)) then
            write (error_unit,'(A,A,A)')
     &      'VICE output file ', trim (filein),
     &      ' changed while it was being read.'
          else
            write (error_unit,'(A,A,A)')
     &      'Unable to read VICE output file ', trim (filein), '.'
            write (error_unit,'(A,A)')
     &      'Error message: ', trim (error_message)
          end if
          deallocate (raw_data)
          deallocate (dat)
          deallocate (tmp)
          close (fi)
          error stop 1
        end if

        do i = 1, nchar
          dat(i) = iand (int (raw_data(i), int32),
     &                   int (z'ff', int32))
        end do
      end if
      deallocate (raw_data)
      close (fi)

C     Remove all line-feeds from file and store in tmp.
      c = 0
      do i = 1, nchar
        if (dat(i).ne.iachar (new_line ('A'))) then
          c = c + 1
          tmp(c) = dat(i)
        end if
      end do
      nchar = c

C     Re-map ASCII to CBM for each character in viceprnt.out.
      do i = 1, nchar
        if ((tmp(i).ge.0).and.(tmp(i).le.31)) then
          dat(i) = tmp(i) + 128
        else if ((tmp(i).ge.32).and.(tmp(i).le.63)) then
          dat(i) = tmp(i)
        else if ((tmp(i).ge.64).and.(tmp(i).le.95)) then
          dat(i) = tmp(i) - 64
        else if ((tmp(i).ge.128).and.(tmp(i).le.159)) then
          dat(i) = tmp(i) + 64
        else if ((tmp(i).ge.160).and.(tmp(i).le.191)) then
          dat(i) = tmp(i) - 64
        else if ((tmp(i).ge.192).and.(tmp(i).le.223)) then
          dat(i) = tmp(i) - 128
        else
          dat(i) = tmp(i)
        end if
      end do

C     Write header info for PostScript file.
      open (newunit=fo, file=trim (fileout), status='replace',
     & action='write', iostat=ios, iomsg=error_message)
      if (ios.ne.0) then
        write (error_unit,'(A,A,A)')
     &  'Cannot open new PostScript file ', trim (fileout), '.'
        write (error_unit,'(A,A)')
     &  'Error message: ', trim (error_message)
        deallocate (dat)
        deallocate (tmp)
        error stop 1
      end if

      write (fo,'(A)') '%!PS-Adobe-3.0'
      write (fo,'(A)') '%%Title: Commodore Printout'
      write (fo,'(A)')
     & '%%Creator: vicetops.f - Paul David Buchan, 2004-2026'
      write (fo,'(A)') '%%Pages: (atend)'
      write (fo,'(A)') '%%Orientation: Portrait'
      write (fo,'(A)') '0.000 0.000 0.000 setrgbcolor'
      write (fo,'(A)') '8 dict begin'
      write (fo,'(A)') '/FontType 3 def'
      write (fo,'(A)') '/FontMatrix [.001 0 0 .001 0 0] def'
      write (fo,'(A)') '/FontBBox [0 0 750 750] def'
      write (fo,'(A)')
      write (fo,'(A,I0,A)') '/Encoding ', CHARACTER_COUNT,
     &  ' array def'
      write (fo,'(A,I0,A)') '0 1 ', CHARACTER_COUNT - 1,
     &  ' {Encoding exch /.notdef put} for'
      do glyph = 0, CHARACTER_COUNT - 1
        write (fo,'(A,I0,A,I0,A)')
     &  'Encoding ', glyph, ' /cbm', glyph, ' put'
      end do
      write (fo,'(A)')
C     .notdef plus one procedure for each character.
      write (fo,'(A,I0,A)') '/CharProcs ',
     &  CHARACTER_COUNT + 1, ' dict def'
      write (fo,'(A)') 'CharProcs begin'
      write (fo,'(A)') '/.notdef {} def'

C     Decode CBM character set and redefine default PostScript Type 3
C     font set.
      rom_index = 1
      do glyph = 0, CHARACTER_COUNT - 1
        write (fo,'(A,I0)') '/cbm', glyph
        write (fo,'(A)') '{ 40.0 setlinewidth'
        write (fo,'(A)') '2 setlinecap'
        write (fo,'(A)') '[] 0 setdash'
        do row = 0, CHARACTER_ROWS - 1
          do col = 0, CHARACTER_COLUMNS - 1
            row_bits(col + 1) = iand (
     &        ishft (chr(rom_index + offset),
     &        col - (CHARACTER_COLUMNS - 1)), 1)
          end do
          rom_index = rom_index + 1
          do col = 0, CHARACTER_COLUMNS - 1
            if (row_bits(col + 1).eq.1) then
              write (fo,'(F6.2,1X,F6.2,1X,A)')
     &        real (col, real64) * 93.75_real64,
     &        750.0_real64 - real (row, real64) * 93.75_real64,
     &        'moveto'
              write (fo,'(F6.2,1X,F6.2,1X,A)')
     &        real (col, real64) * 93.75_real64 + 31.25_real64,
     &        750.0_real64 - real (row, real64) * 93.75_real64,
     &        'lineto'
            end if
          end do
        end do
        write (fo,'(A)') 'stroke'
        write (fo,'(A)') '} bind def'
        write (fo,'(A)')
      end do
      write (fo,'(A)') 'end'

C     Build new character set.
      write (fo,'(A)') '/BuildGlyph'
      write (fo,'(A)') '{1000 0'
      write (fo,'(A)') '0 0 750 750'
      write (fo,'(A)') 'setcachedevice'
      write (fo,'(A)') 'exch /CharProcs get exch'
      write (fo,'(A)') '2 copy known not'
      write (fo,'(A)') '{pop /.notdef}'
      write (fo,'(A)') 'if'
      write (fo,'(A)') 'get exec'
      write (fo,'(A)') '} bind def'
      write (fo,'(A)')
      write (fo,'(A)') '/BuildChar'
      write (fo,'(A)') '{ 1 index /Encoding get exch get'
      write (fo,'(A)') '  1 index /BuildGlyph get exec'
      write (fo,'(A)') '} bind def'
      write (fo,'(A)') 'currentdict'
      write (fo,'(A)') 'end'
      write (fo,'(A)') '/ExampleFont exch definefont pop'
      write (fo,'(A)')
     & '/ExampleFont findfont 10 scalefont setfont'

C     Print out Commodore file.
      pg = 1
      write (fo,'(A,I0)') '%%Page: Page ', pg
      y = TOP_MARGIN
C     Start printing at top of page.
      chars_on_line = 0
      line_open = 0
      i = 1

C     Loop through all characters in VICE output file.
      do while (i.le.nchar)

C       At beginning of a new line.
        if (line_open.eq.0) then

C         Found line-feed instead of text
          if (dat(i).eq.CBM_LINE_FEED) then
            y = y - LINE_SPACING
            i = i + 1

C         Start new line of text.
          else
            write (fo,'(I0,1X,I0,A)') LEFT_MARGIN, y, ' moveto'
            write (fo,'(A)',advance='no') '-3 0 <'
            chars_on_line = 0
            line_open = 1
          end if

C       Found line-feed which will terminate line of text.
        else if (dat(i).eq.CBM_LINE_FEED) then
          write (fo,'(A)') '> ashow'
          line_open = 0
          chars_on_line = 0
          i = i + 1
          y = y - LINE_SPACING

C       Length of line has reached maximum.
        else if (chars_on_line.eq.MAXIMUM_CHARACTERS_PER_LINE) then
          write (fo,'(A)') '> ashow'
          line_open = 0
          chars_on_line = 0
          y = y - LINE_SPACING

C       Print next character in file.
        else
          write (fo,'(Z2.2)',advance='no') dat(i)
          i = i + 1
          chars_on_line = chars_on_line + 1

C         Last character in file?
          if (i.gt.nchar) then
            write (fo,'(A)') '> ashow'
            line_open = 0
          end if
        end if

C       Reached bottom of page.
C       Start another page only when unprinted input remains.
        if ((y.lt.BOTTOM_MARGIN).and.(i.le.nchar)) then
          y = TOP_MARGIN
          write (fo,'(A)') 'showpage'
          pg = pg + 1
          write (fo,'(A,I0)') '%%Page: Page ', pg
        end if
      end do

      write (fo,'(A)') 'showpage'
      write (fo,'(A)') '%%Trailer'
      write (fo,'(A,I0)') '%%Pages: ', pg
      write (fo,'(A)') '%%EOF'

C     Close PostScript output file.
      close (fo, iostat=ios, iomsg=error_message)
      if (ios.ne.0) then
        write (error_unit,'(A,A,A)')
     &  'Unable to close PostScript output file ', trim (fileout), '.'
        write (error_unit,'(A,A)')
     &  'Error message: ', trim (error_message)
        deallocate (dat)
        deallocate (tmp)
        error stop 1
      end if

C     Free memory allocated for arrays dat and tmp.
      deallocate (dat)
      deallocate (tmp)

      end program vicetops
