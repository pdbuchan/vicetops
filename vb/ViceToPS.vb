'  VICEtoPS Copyright 2004-2026 Paul David Buchan (pdbuchan@gmail.com)
' 
'  This program is free software; you can redistribute it and/or modify
'  it under the terms of the GNU General Public License as published by
'  the Free Software Foundation; either version 2 of the License, or
'  (at your option) any later version.
'   
'  This program is distributed in the hope that it will be useful,
'  but WITHOUT ANY WARRANTY; without even the implied warranty of
'  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
'  GNU General Public License for more details.
' 
'  You should have received a copy of the GNU General Public License
'  along with this program; if not, write to the Free Software
'  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

Imports System.IO
Imports System.Globalization
Imports System.Text
Imports System.Windows.Forms

Public Class vicetops

    Private Const CHARACTER_FILE As String = "characters.390059-01.bin"  ' ROM image of CBM character set definitions.
    Private Const CHARACTER_ROM_SIZE As Integer = 8192  ' Size in bytes of upper + lowercase character set definition data.
    Private Const CHARACTER_COUNT As Integer = 256  ' Number of CBM characters.
    Private Const CHARACTER_ROWS As Integer = 8  ' Number of rows in one character (px).
    Private Const CHARACTER_COLUMNS As Integer = 8  ' Number of columns in one character (px).
    Private Const CHARACTER_SET_SIZE As Integer = CHARACTER_COUNT * CHARACTER_ROWS  ' Size in bytes of upper or lowercase character set definition data.

    Private Const LEFT_MARGIN As Integer = 72  ' Set left margin as one inch (72 dpi).
    Private Const MAXIMUM_CHARACTERS_PER_LINE As Integer = 70  ' Set maximum number of characters per line.
    Private Const TOP_MARGIN As Integer = 756  ' Set top page margins as one inch.
    Private Const BOTTOM_MARGIN As Integer = 36  ' Set bottom page margins as one inch.
    Private Const LINE_SPACING As Integer = 12  ' Set spacing between lines.
    Private Const CBM_LINE_FEED As Integer = 141  ' CBM character for line-feed.


    Public Sub New()
        MyBase.New()

        'This call is required by the Windows Form Designer.
        InitializeComponent()

        'Add any initialization after the InitializeComponent() call

    End Sub


    Private Sub Form1_Load(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles MyBase.Load

    End Sub

    Private Sub upperCaseRadioButton_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles upperCaseRadioButton.CheckedChanged

    End Sub

    Private Sub lowerCaseRadioButton_CheckedChanged(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles lowerCaseRadioButton.CheckedChanged

    End Sub

    Private Sub GroupBox1_Enter(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles GroupBox1.Enter

    End Sub

    Private Sub Label4_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles Label4.Click

    End Sub

    'Let user browse for VICE output file
    Private InputFileName As String = "viceprnt.out"
    Private Sub inputButton_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles inputButton.Click
        With OpenFileDialog1
            .Filter = "VICE Output Files (*.out)|*.out|All files (*.*)|*.*"
            .FilterIndex = 1
            .CheckPathExists = True
            .Title = "Browsing for VICE output file..."
        End With
        If OpenFileDialog1.ShowDialog() = DialogResult.OK Then
            InputFileName = OpenFileDialog1.FileName
            inputFile.Text = InputFileName
        End If
    End Sub

    'Let user browse for directory to save PostScript file
    Private OutputFileName As String = "viceprnt.ps"
    Private Sub outputButton_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles outputButton.Click
        With SaveFileDialog1
            .Filter = "Adobe PostScript Files (*.ps)|*.ps|All files (*.*)|*.*"
            .FilterIndex = 1
            .CheckPathExists = True
            .OverwritePrompt = False
            .AddExtension = True
            .Title = "Browsing for PostScript output directory..."
        End With
        If SaveFileDialog1.ShowDialog() = DialogResult.OK Then
            OutputFileName = SaveFileDialog1.FileName
            outputFile.Text = OutputFileName
        End If
    End Sub

    ' Generate the Adobe PostScript file.
    Private Sub generatePostScriptButton_Click(ByVal sender As System.Object, ByVal e As System.EventArgs) Handles generatePostScriptButton.Click
        Dim c As Integer
        Dim row As Integer
        Dim col As Integer
        Dim rowBits(CHARACTER_COLUMNS - 1) As Integer
        Dim y As Integer
        Dim lineOpen As Integer
        Dim glyph As Integer
        Dim i As Integer
        Dim charsOnLine As Integer
        Dim romIndex As Integer
        Dim nchar As Integer
        Dim offset As Integer
        Dim pg As Integer
        Dim characterRom(CHARACTER_ROM_SIZE - 1) As Byte
        Dim dat() As Byte
        Dim tmp() As Byte
        Dim inputLength As Long
        Dim bytesRead As Integer
        Dim totalBytesRead As Integer

        ' Upper or lower case selected?
        If upperCaseRadioButton.Checked Then
            offset = 0
        Else
            offset = CHARACTER_SET_SIZE
        End If

        ' Pick up filenames from text boxes.
        InputFileName = inputFile.Text
        OutputFileName = outputFile.Text

        ' Read in Commodore character set ROM from beside the application.
        Dim characterFilePath As String = Path.Combine(AppContext.BaseDirectory, CHARACTER_FILE)
        Try
            Using fi As New FileStream(characterFilePath, FileMode.Open, FileAccess.Read, FileShare.Read)
                If fi.Length < CHARACTER_ROM_SIZE Then
                    MessageBox.Show("Character set file " & CHARACTER_FILE & " is shorter than " & CHARACTER_ROM_SIZE & " bytes.", "Invalid character ROM.", MessageBoxButtons.OK, MessageBoxIcon.Error)
                    Return
                End If

                totalBytesRead = 0
                While totalBytesRead < CHARACTER_ROM_SIZE
                    bytesRead = fi.Read(characterRom, totalBytesRead, CHARACTER_ROM_SIZE - totalBytesRead)
                    If bytesRead = 0 Then
                        Exit While
                    End If
                    totalBytesRead += bytesRead
                End While

                If totalBytesRead <> CHARACTER_ROM_SIZE Then
                    MessageBox.Show("Unable to read character set file " & CHARACTER_FILE & ".", "Read error.", MessageBoxButtons.OK, MessageBoxIcon.Error)
                    Return
                End If
            End Using
        Catch exc As FileNotFoundException
            MessageBox.Show("Unable to open character set file " & CHARACTER_FILE & "." & vbCrLf & "Error message: " & exc.Message, "File not found.", MessageBoxButtons.OK, MessageBoxIcon.Error)
            Return
        Catch exc As Exception
            MessageBox.Show("Unable to read character set file " & CHARACTER_FILE & "." & vbCrLf & "Error message: " & exc.Message, "Read error.", MessageBoxButtons.OK, MessageBoxIcon.Error)
            Return
        End Try

        ' Open VICE output file and count bytes.
        Try
            Using fi As New FileStream(InputFileName, FileMode.Open, FileAccess.Read, FileShare.ReadWrite)
                inputLength = fi.Length
                If inputLength > Integer.MaxValue Then
                    MessageBox.Show("VICE output file " & InputFileName & " is too large to process.", "File too large.", MessageBoxButtons.OK, MessageBoxIcon.Error)
                    Return
                End If
                nchar = CInt(inputLength)

                ' Allocate memory for arrays dat and tmp for VICE output file data.
                If nchar > 0 Then
                    ReDim dat(nchar - 1)
                    ReDim tmp(nchar - 1)
                Else
                    dat = New Byte() {}
                    tmp = New Byte() {}
                End If

                ' Read VICE output file into array dat.
                totalBytesRead = 0
                While totalBytesRead < nchar
                    bytesRead = fi.Read(dat, totalBytesRead, nchar - totalBytesRead)
                    If bytesRead = 0 Then
                        Exit While
                    End If
                    totalBytesRead += bytesRead
                End While

                If totalBytesRead <> nchar Then
                    MessageBox.Show("VICE output file " & InputFileName & " changed while it was being read.", "Read error.", MessageBoxButtons.OK, MessageBoxIcon.Error)
                    Return
                End If
            End Using
        Catch exc As FileNotFoundException
            MessageBox.Show("Unable to open VICE output file " & InputFileName & "." & vbCrLf & "Error message: " & exc.Message, "File not found.", MessageBoxButtons.OK, MessageBoxIcon.Error)
            Return
        Catch exc As Exception
            MessageBox.Show("Unable to read VICE output file " & InputFileName & "." & vbCrLf & "Error message: " & exc.Message, "Read error.", MessageBoxButtons.OK, MessageBoxIcon.Error)
            Return
        End Try

        ' Remove all line-feeds from file and store in tmp.
        c = 0
        For i = 0 To nchar - 1
            If dat(i) <> 10 Then
                tmp(c) = dat(i)
                c += 1
            End If
        Next i
        nchar = c

        ' Re-map ASCII to CBM for each character in viceprnt.out.
        For i = 0 To nchar - 1
            If tmp(i) >= 0 AndAlso tmp(i) <= 31 Then
                dat(i) = CByte(tmp(i) + 128)
            ElseIf tmp(i) >= 32 AndAlso tmp(i) <= 63 Then
                dat(i) = tmp(i)
            ElseIf tmp(i) >= 64 AndAlso tmp(i) <= 95 Then
                dat(i) = CByte(tmp(i) - 64)
            ElseIf tmp(i) >= 128 AndAlso tmp(i) <= 159 Then
                dat(i) = CByte(tmp(i) + 64)
            ElseIf tmp(i) >= 160 AndAlso tmp(i) <= 191 Then
                dat(i) = CByte(tmp(i) - 64)
            ElseIf tmp(i) >= 192 AndAlso tmp(i) <= 223 Then
                dat(i) = CByte(tmp(i) - 128)
            Else
                dat(i) = tmp(i)
            End If
        Next i

        ' Write header info for PostScript file.
        Try
            Using objWriter As New StreamWriter(OutputFileName, False, New UTF8Encoding(False))
                objWriter.NewLine = vbLf

                objWriter.WriteLine("%!PS-Adobe-3.0")
                objWriter.WriteLine("%%Title: Commodore Printout")
                objWriter.WriteLine("%%Creator: vicetops.vb - Paul David Buchan, 2004-2026")
                objWriter.WriteLine("%%Pages: (atend)")
                objWriter.WriteLine("%%Orientation: Portrait")
                objWriter.WriteLine("0.000 0.000 0.000 setrgbcolor")
                objWriter.WriteLine("8 dict begin")
                objWriter.WriteLine("/FontType 3 def")
                objWriter.WriteLine("/FontMatrix [.001 0 0 .001 0 0] def")
                objWriter.WriteLine("/FontBBox [0 0 750 750] def")
                objWriter.WriteLine()
                objWriter.WriteLine("/Encoding " & CHARACTER_COUNT & " array def")
                objWriter.WriteLine("0 1 " & (CHARACTER_COUNT - 1) & " {Encoding exch /.notdef put} for")
                For glyph = 0 To CHARACTER_COUNT - 1
                    objWriter.WriteLine("Encoding " & glyph & " /cbm" & glyph & " put")
                Next glyph
                objWriter.WriteLine()
                objWriter.WriteLine("/CharProcs " & (CHARACTER_COUNT + 1) & " dict def")  ' .notdef plus one procedure for each character.
                objWriter.WriteLine("CharProcs begin")
                objWriter.WriteLine("/.notdef {} def")

                ' Decode CBM character set and redefine default PostScript Type 3 font set.
                romIndex = 0
                For glyph = 0 To CHARACTER_COUNT - 1
                    objWriter.WriteLine("/cbm" & glyph)
                    objWriter.WriteLine("{ 40.0 setlinewidth")
                    objWriter.WriteLine("2 setlinecap")
                    objWriter.WriteLine("[] 0 setdash")
                    For row = 0 To CHARACTER_ROWS - 1
                        For col = 0 To CHARACTER_COLUMNS - 1
                            rowBits(col) = (CInt(characterRom(romIndex + offset)) >> (CHARACTER_COLUMNS - 1 - col)) And 1
                        Next col
                        romIndex += 1
                        For col = 0 To CHARACTER_COLUMNS - 1
                            If rowBits(col) = 1 Then
                                objWriter.WriteLine(String.Format(CultureInfo.InvariantCulture, "{0:F2} {1:F2} moveto", col * 93.75, 750.0 - (row * 93.75)))
                                objWriter.WriteLine(String.Format(CultureInfo.InvariantCulture, "{0:F2} {1:F2} lineto", (col * 93.75) + 31.25, 750.0 - (row * 93.75)))
                            End If
                        Next col
                    Next row
                    objWriter.WriteLine("stroke")
                    objWriter.WriteLine("} bind def")
                    objWriter.WriteLine()
                Next glyph
                objWriter.WriteLine("end")

                ' Build new character set.
                objWriter.WriteLine("/BuildGlyph")
                objWriter.WriteLine("{1000 0")
                objWriter.WriteLine("0 0 750 750")
                objWriter.WriteLine("setcachedevice")
                objWriter.WriteLine("exch /CharProcs get exch")
                objWriter.WriteLine("2 copy known not")
                objWriter.WriteLine("{pop /.notdef}")
                objWriter.WriteLine("if")
                objWriter.WriteLine("get exec")
                objWriter.WriteLine("} bind def")
                objWriter.WriteLine()
                objWriter.WriteLine("/BuildChar")
                objWriter.WriteLine("{ 1 index /Encoding get exch get")
                objWriter.WriteLine("  1 index /BuildGlyph get exec")
                objWriter.WriteLine("} bind def")
                objWriter.WriteLine("currentdict")
                objWriter.WriteLine("end")
                objWriter.WriteLine("/ExampleFont exch definefont pop")
                objWriter.WriteLine("/ExampleFont findfont 10 scalefont setfont")

                ' Print out Commodore file.
                pg = 1
                objWriter.WriteLine("%%Page: Page " & pg)
                y = TOP_MARGIN  ' Start printing at top of page.
                charsOnLine = 0
                lineOpen = 0
                i = 0

                ' Loop through all characters in VICE output file.
                While i < nchar

                    ' At beginning of a new line.
                    If lineOpen = 0 Then

                        ' Found line-feed instead of text
                        If dat(i) = CBM_LINE_FEED Then
                            y -= LINE_SPACING
                            i += 1

                        ' Start new line of text.
                        Else
                            objWriter.WriteLine(LEFT_MARGIN & " " & y & " moveto")
                            objWriter.Write("-3 0 <")
                            charsOnLine = 0
                            lineOpen = 1
                        End If

                    ' Found line-feed which will terminate line of text.
                    ElseIf dat(i) = CBM_LINE_FEED Then
                        objWriter.WriteLine("> ashow")
                        lineOpen = 0
                        charsOnLine = 0
                        i += 1
                        y -= LINE_SPACING

                    ' Length of line has reached maximum.
                    ElseIf charsOnLine = MAXIMUM_CHARACTERS_PER_LINE Then
                        objWriter.WriteLine("> ashow")
                        lineOpen = 0
                        charsOnLine = 0
                        y -= LINE_SPACING

                    ' Print next character in file.
                    Else
                        objWriter.Write(dat(i).ToString("x2", CultureInfo.InvariantCulture))
                        i += 1
                        charsOnLine += 1

                        ' Last character in file?
                        If i = nchar Then
                            objWriter.WriteLine("> ashow")
                            lineOpen = 0
                        End If
                    End If

                    ' Reached bottom of page.
                    ' Start another page only when unprinted input remains.
                    If (y < BOTTOM_MARGIN) AndAlso (i < nchar) Then
                        y = TOP_MARGIN
                        objWriter.WriteLine("showpage")
                        pg += 1
                        objWriter.WriteLine("%%Page: Page " & pg)
                    End If
                End While

                objWriter.WriteLine("showpage")
                objWriter.WriteLine("%%Trailer")
                objWriter.WriteLine("%%Pages: " & pg)
                objWriter.WriteLine("%%EOF")
            End Using
        Catch exc As Exception
            MessageBox.Show("Unable to write PostScript file " & OutputFileName & "." & vbCrLf & "Error message: " & exc.Message, "Write error.", MessageBoxButtons.OK, MessageBoxIcon.Error)
            Return
        End Try

        MessageBox.Show("       Done!", "VICEtoPS")
    End Sub
End Class
