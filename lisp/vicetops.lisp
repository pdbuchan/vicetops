;; VICEtoPS Copyright 2004-2026 Paul David Buchan (pdbuchan@gmail.com)
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

(defconstant +character-file+ "characters.390059-01.bin")
;; ROM image of CBM character set definitions.

(defconstant +character-rom-size+ 8192)
;; Size in bytes of upper + lowercase character set definition data.

(defconstant +character-count+ 256)
;; Number of CBM characters.

(defconstant +character-rows+ 8)
;; Number of rows in one character (px).

(defconstant +character-columns+ 8)
;; Number of columns in one character (px).

(defconstant +character-set-size+
  (* +character-count+ +character-rows+))
;; Size in bytes of upper or lowercase character set definition data.

(defconstant +left-margin+ 72)
;; Set left margin as one inch (72 dpi).

(defconstant +maximum-characters-per-line+ 70)
;; Set maximum number of characters per line.

(defconstant +top-margin+ 756)
;; Set top page margins as one inch.

(defconstant +bottom-margin+ 36)
;; Set bottom page margins as one inch.

(defconstant +line-spacing+ 12)
;; Set spacing between lines.

(defconstant +cbm-line-feed+ 141)
;; CBM character for line-feed.

;; Ask a question of standard input and return the entered line.
(defun ask (question)
  (format t "~A" question)
  (finish-output)
  (read-line))

(defun main ()
  (format t "~%VICEtoPS Copyright 2004-2026 Paul David Buchan~%~%")

  (let* ((case-flag (ask "Upper or lower case? "))
         (offset (cond
                   ((string-equal case-flag "u") 0)
                   ((string-equal case-flag "l") +character-set-size+)
                   (t
                    (format *error-output* "~%Invalid case flag. Enter u or l.~%~%")
                    (return-from main nil))))
         (input-file (ask "What is the name of the VICE output file? "))
         (output-file (ask "What would you like the PostScript file to be called? "))
         (character-rom
           (make-array +character-rom-size+
                       :element-type '(unsigned-byte 8)
                       :initial-element 0))
         (row-bits
           (make-array +character-columns+
                       :element-type 'bit
                       :initial-element 0))
         (dat nil)
         (tmp nil)
         (nchar 0))

    ;; Read in Commodore character set ROM.
    (handler-case
        (with-open-file (in +character-file+
                            :direction :input
                            :element-type '(unsigned-byte 8))
          (let ((bytes-read (read-sequence character-rom in)))
            (when (< bytes-read +character-rom-size+)
              (format *error-output* "Character set file ~A is shorter than ~D bytes.~%" +character-file+ +character-rom-size+)
              (return-from main nil))))
      (file-error (condition)
        (format *error-output* "Unable to open or read character set file ~A.~%Error message: ~A~%" +character-file+ condition)
        (return-from main nil)))

    ;; Open VICE output file and count bytes.
    (handler-case
        (with-open-file (in input-file
                            :direction :input
                            :element-type '(unsigned-byte 8))
          (setf nchar (file-length in))

          ;; Allocate memory for arrays dat and tmp for VICE output file data.
          (setf dat (make-array nchar
                                :element-type '(unsigned-byte 8)
                                :initial-element 0))
          (setf tmp (make-array nchar
                                :element-type '(unsigned-byte 8)
                                :initial-element 0))

          ;; Read VICE output file into array dat.
          (let ((bytes-read (read-sequence dat in)))
            (when (/= bytes-read nchar)
              (format *error-output* "VICE output file ~A changed while it was being read.~%" input-file)
              (return-from main nil))))
      (file-error (condition)
        (format *error-output* "Unable to open or read VICE output file ~A.~%Error message: ~A~%" input-file condition)
        (return-from main nil)))

    ;; Remove all line-feeds from file and store in tmp.
    (let ((c 0))
      (loop for i from 0 below nchar do
        (unless (= (aref dat i) 10)
          (setf (aref tmp c) (aref dat i))
          (incf c)))
      (setf nchar c))

    ;; Re-map ASCII to CBM for each character in viceprnt.out.
    (loop for i from 0 below nchar do
      (cond
        ((<= 0 (aref tmp i) 31)
         (setf (aref dat i) (+ (aref tmp i) 128)))
        ((<= 32 (aref tmp i) 63)
         (setf (aref dat i) (aref tmp i)))
        ((<= 64 (aref tmp i) 95)
         (setf (aref dat i) (- (aref tmp i) 64)))
        ((<= 128 (aref tmp i) 159)
         (setf (aref dat i) (+ (aref tmp i) 64)))
        ((<= 160 (aref tmp i) 191)
         (setf (aref dat i) (- (aref tmp i) 64)))
        ((<= 192 (aref tmp i) 223)
         (setf (aref dat i) (- (aref tmp i) 128)))
        (t
         (setf (aref dat i) (aref tmp i)))))

    ;; Write header info for PostScript file.
    (handler-case
        (with-open-file (str output-file
                             :direction :output
                             :if-exists :supersede
                             :if-does-not-exist :create)
          (format str "%!PS-Adobe-3.0~%")
          (format str "%%Title: Commodore Printout~%")
          (format str "%%Creator: vicetops.lisp - Paul David Buchan, 2004-2026~%")
          (format str "%%Pages: (atend)~%")
          (format str "%%Orientation: Portrait~%")
          (format str "0.000 0.000 0.000 setrgbcolor~%")
          (format str "8 dict begin~%")
          (format str "/FontType 3 def~%")
          (format str "/FontMatrix [.001 0 0 .001 0 0] def~%")
          (format str "/FontBBox [0 0 750 750] def~%~%")
          (format str "/Encoding ~D array def~%" +character-count+)
          (format str "0 1 ~D {Encoding exch /.notdef put} for~%"
                  (1- +character-count+))
          (loop for glyph from 0 below +character-count+ do
            (format str "Encoding ~D /cbm~D put~%" glyph glyph))
          ;; .notdef plus one procedure for each character.
          (format str "~%/CharProcs ~D dict def~%"
                  (1+ +character-count+))
          (format str "CharProcs begin~%")
          (format str "/.notdef {} def~%")

          ;; Decode CBM character set and redefine default PostScript Type 3 font set.
          (let ((rom-index 0))
            (loop for glyph from 0 below +character-count+ do
              (format str "/cbm~D~%" glyph)
              (format str "{ 40.0 setlinewidth~%")
              (format str "2 setlinecap~%")
              (format str "[] 0 setdash~%")
              (loop for row from 0 below +character-rows+ do
                (loop for col from 0 below +character-columns+ do
                  (setf (aref row-bits col)
                        (logand
                          (ash (aref character-rom (+ rom-index offset))
                               (- col (- +character-columns+ 1)))
                          1)))
                (incf rom-index)
                (loop for col from 0 below +character-columns+ do
                  (when (= (aref row-bits col) 1)
                    (format str "~,2F ~,2F moveto~%" (* col 93.75d0) (- 750.0d0 (* row 93.75d0)))
                    (format str "~,2F ~,2F lineto~%" (+ (* col 93.75d0) 31.25d0) (- 750.0d0 (* row 93.75d0))))))
              (format str "stroke~%")
              (format str "} bind def~%~%")))
          (format str "end~%")

          ;; Build new character set.
          (format str "/BuildGlyph~%")
          (format str "{1000 0~%")
          (format str "0 0 750 750~%")
          (format str "setcachedevice~%")
          (format str "exch /CharProcs get exch~%")
          (format str "2 copy known not~%")
          (format str "{pop /.notdef}~%")
          (format str "if~%")
          (format str "get exec~%")
          (format str "} bind def~%~%")
          (format str "/BuildChar~%")
          (format str "{ 1 index /Encoding get exch get~%")
          (format str "  1 index /BuildGlyph get exec~%")
          (format str "} bind def~%")
          (format str "currentdict~%")
          (format str "end~%")
          (format str "/ExampleFont exch definefont pop~%")
          (format str "/ExampleFont findfont 10 scalefont setfont~%")

          ;; Print out Commodore file.
          (let ((pg 1)
                (y +top-margin+)       ; Start printing at top of page.
                (chars-on-line 0)
                (line-open 0)
                (i 0))
            (format str "%%Page: Page ~D~%" pg)

            ;; Loop through all characters in VICE output file.
            (loop while (< i nchar) do

              ;; At beginning of a new line.
              (cond
                ((= line-open 0)

                 ;; Found line-feed instead of text.
                 (if (= (aref dat i) +cbm-line-feed+)
                     (progn
                       (decf y +line-spacing+)
                       (incf i))

                     ;; Start new line of text.
                     (progn
                       (format str "~D ~D moveto~%" +left-margin+ y)
                       (format str "-3 0 <")
                       (setf chars-on-line 0)
                       (setf line-open 1))))

                ;; Found line-feed which will terminate line of text.
                ((= (aref dat i) +cbm-line-feed+)
                 (format str "> ashow~%")
                 (setf line-open 0)
                 (setf chars-on-line 0)
                 (incf i)
                 (decf y +line-spacing+))

                ;; Length of line has reached maximum.
                ((= chars-on-line +maximum-characters-per-line+)
                 (format str "> ashow~%")
                 (setf line-open 0)
                 (setf chars-on-line 0)
                 (decf y +line-spacing+))

                ;; Print next character in file.
                (t
                 (format str "~(~2,'0X~)" (aref dat i))
                 (incf i)
                 (incf chars-on-line)

                 ;; Last character in file?
                 (when (= i nchar)
                   (format str "> ashow~%")
                   (setf line-open 0))))

              ;; Reached bottom of page.
              ;; Start another page only when unprinted input remains.
              (when (and (< y +bottom-margin+) (< i nchar))
                (setf y +top-margin+)
                (format str "showpage~%")
                (incf pg)
                (format str "%%Page: Page ~D~%" pg)))

            (format str "showpage~%")
            (format str "%%Trailer~%")
            (format str "%%Pages: ~D~%" pg)
            (format str "%%EOF~%")))
      (file-error (condition)
        (format *error-output* "Unable to open or write PostScript file ~A.~%Error message: ~A~%" output-file condition)
        (return-from main nil))))

  t)

(main)
