<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class vicetops
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    Friend WithEvents Label1 As System.Windows.Forms.Label
    Friend WithEvents Label2 As System.Windows.Forms.Label
    Friend WithEvents Label3 As System.Windows.Forms.Label
    Friend WithEvents Label4 As System.Windows.Forms.Label
    Friend WithEvents GroupBox1 As System.Windows.Forms.GroupBox
    Friend WithEvents GroupBox2 As System.Windows.Forms.GroupBox
    Friend WithEvents GroupBox3 As System.Windows.Forms.GroupBox
    Friend WithEvents inputFile As System.Windows.Forms.TextBox
    Friend WithEvents outputFile As System.Windows.Forms.TextBox
    Friend WithEvents upperCaseRadioButton As System.Windows.Forms.RadioButton
    Friend WithEvents lowerCaseRadioButton As System.Windows.Forms.RadioButton
    Friend WithEvents generatePostScriptButton As System.Windows.Forms.Button
    Friend WithEvents inputButton As System.Windows.Forms.Button
    Friend WithEvents outputButton As System.Windows.Forms.Button
    Friend WithEvents OpenFileDialog1 As System.Windows.Forms.OpenFileDialog
    Friend WithEvents SaveFileDialog1 As System.Windows.Forms.SaveFileDialog
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Me.inputFile = New System.Windows.Forms.TextBox()
        Me.outputFile = New System.Windows.Forms.TextBox()
        Me.inputButton = New System.Windows.Forms.Button()
        Me.outputButton = New System.Windows.Forms.Button()
        Me.upperCaseRadioButton = New System.Windows.Forms.RadioButton()
        Me.lowerCaseRadioButton = New System.Windows.Forms.RadioButton()
        Me.Label1 = New System.Windows.Forms.Label()
        Me.Label2 = New System.Windows.Forms.Label()
        Me.Label3 = New System.Windows.Forms.Label()
        Me.Label4 = New System.Windows.Forms.Label()
        Me.generatePostScriptButton = New System.Windows.Forms.Button()
        Me.GroupBox1 = New System.Windows.Forms.GroupBox()
        Me.GroupBox2 = New System.Windows.Forms.GroupBox()
        Me.GroupBox3 = New System.Windows.Forms.GroupBox()
        Me.OpenFileDialog1 = New System.Windows.Forms.OpenFileDialog()
        Me.SaveFileDialog1 = New System.Windows.Forms.SaveFileDialog()
        Me.GroupBox1.SuspendLayout()
        Me.GroupBox2.SuspendLayout()
        Me.GroupBox3.SuspendLayout()
        Me.SuspendLayout()
        '
        'inputFile
        '
        Me.inputFile.Location = New System.Drawing.Point(8, 40)
        Me.inputFile.Name = "inputFile"
        Me.inputFile.Size = New System.Drawing.Size(280, 20)
        Me.inputFile.TabIndex = 0
        Me.inputFile.Text = "viceprnt.out"
        '
        'outputFile
        '
        Me.outputFile.Location = New System.Drawing.Point(8, 40)
        Me.outputFile.Name = "outputFile"
        Me.outputFile.Size = New System.Drawing.Size(280, 20)
        Me.outputFile.TabIndex = 1
        Me.outputFile.Text = "viceprnt.ps"
        '
        'inputButton
        '
        Me.inputButton.Location = New System.Drawing.Point(296, 40)
        Me.inputButton.Name = "inputButton"
        Me.inputButton.Size = New System.Drawing.Size(75, 23)
        Me.inputButton.TabIndex = 2
        Me.inputButton.Text = "Browse..."
        '
        'outputButton
        '
        Me.outputButton.Location = New System.Drawing.Point(296, 40)
        Me.outputButton.Name = "outputButton"
        Me.outputButton.Size = New System.Drawing.Size(75, 23)
        Me.outputButton.TabIndex = 3
        Me.outputButton.Text = "Browse..."
        '
        'upperCaseRadioButton
        '
        Me.upperCaseRadioButton.Checked = True
        Me.upperCaseRadioButton.Location = New System.Drawing.Point(16, 16)
        Me.upperCaseRadioButton.Name = "upperCaseRadioButton"
        Me.upperCaseRadioButton.Size = New System.Drawing.Size(88, 24)
        Me.upperCaseRadioButton.TabIndex = 4
        Me.upperCaseRadioButton.TabStop = True
        Me.upperCaseRadioButton.Text = "Upper Case"
        '
        'lowerCaseRadioButton
        '
        Me.lowerCaseRadioButton.Location = New System.Drawing.Point(16, 40)
        Me.lowerCaseRadioButton.Name = "lowerCaseRadioButton"
        Me.lowerCaseRadioButton.Size = New System.Drawing.Size(88, 24)
        Me.lowerCaseRadioButton.TabIndex = 5
        Me.lowerCaseRadioButton.Text = "Lower Case"
        '
        'Label1
        '
        Me.Label1.Location = New System.Drawing.Point(16, 8)
        Me.Label1.Name = "Label1"
        Me.Label1.Size = New System.Drawing.Size(216, 16)
        Me.Label1.TabIndex = 6
        Me.Label1.Text = "VICE Output to Adobe PostScript Utility"
        '
        'Label2
        '
        Me.Label2.Location = New System.Drawing.Point(16, 24)
        Me.Label2.Name = "Label2"
        Me.Label2.Size = New System.Drawing.Size(240, 16)
        Me.Label2.TabIndex = 7
        Me.Label2.Text = "Copyright 2004-2026 Paul David Buchan"
        '
        'Label3
        '
        Me.Label3.Location = New System.Drawing.Point(8, 16)
        Me.Label3.Name = "Label3"
        Me.Label3.Size = New System.Drawing.Size(289, 21)
        Me.Label3.TabIndex = 8
        Me.Label3.Text = "VICE emulator output file (e.g., viceprnt.out, print.dump)"
        '
        'Label4
        '
        Me.Label4.Location = New System.Drawing.Point(8, 16)
        Me.Label4.Name = "Label4"
        Me.Label4.Size = New System.Drawing.Size(256, 16)
        Me.Label4.TabIndex = 9
        Me.Label4.Text = "PostScript file (e.g., viceprnt.ps)"
        '
        'generatePostScriptButton
        '
        Me.generatePostScriptButton.Location = New System.Drawing.Point(72, 352)
        Me.generatePostScriptButton.Name = "generatePostScriptButton"
        Me.generatePostScriptButton.Size = New System.Drawing.Size(264, 32)
        Me.generatePostScriptButton.TabIndex = 10
        Me.generatePostScriptButton.Text = "Generate Adobe PostScript File"
        '
        'GroupBox1
        '
        Me.GroupBox1.Controls.Add(Me.upperCaseRadioButton)
        Me.GroupBox1.Controls.Add(Me.lowerCaseRadioButton)
        Me.GroupBox1.Location = New System.Drawing.Point(16, 256)
        Me.GroupBox1.Name = "GroupBox1"
        Me.GroupBox1.Size = New System.Drawing.Size(120, 80)
        Me.GroupBox1.TabIndex = 11
        Me.GroupBox1.TabStop = False
        Me.GroupBox1.Text = "Character Set"
        '
        'GroupBox2
        '
        Me.GroupBox2.Controls.Add(Me.Label3)
        Me.GroupBox2.Controls.Add(Me.inputButton)
        Me.GroupBox2.Controls.Add(Me.inputFile)
        Me.GroupBox2.Location = New System.Drawing.Point(16, 56)
        Me.GroupBox2.Name = "GroupBox2"
        Me.GroupBox2.Size = New System.Drawing.Size(376, 80)
        Me.GroupBox2.TabIndex = 12
        Me.GroupBox2.TabStop = False
        Me.GroupBox2.Text = "Input File"
        '
        'GroupBox3
        '
        Me.GroupBox3.Controls.Add(Me.Label4)
        Me.GroupBox3.Controls.Add(Me.outputFile)
        Me.GroupBox3.Controls.Add(Me.outputButton)
        Me.GroupBox3.Location = New System.Drawing.Point(16, 152)
        Me.GroupBox3.Name = "GroupBox3"
        Me.GroupBox3.Size = New System.Drawing.Size(376, 80)
        Me.GroupBox3.TabIndex = 13
        Me.GroupBox3.TabStop = False
        Me.GroupBox3.Text = "Output File"
        '
        'OpenFileDialog1
        '
        Me.OpenFileDialog1.FileName = "viceprnt.out"
        '
        'SaveFileDialog1
        '
        Me.SaveFileDialog1.FileName = "viceprnt.ps"
        '
        'Form1
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(400, 394)
        Me.Controls.Add(Me.GroupBox3)
        Me.Controls.Add(Me.GroupBox2)
        Me.Controls.Add(Me.GroupBox1)
        Me.Controls.Add(Me.generatePostScriptButton)
        Me.Controls.Add(Me.Label2)
        Me.Controls.Add(Me.Label1)
        Me.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle
        Me.MaximumSize = New System.Drawing.Size(416, 432)
        Me.MinimumSize = New System.Drawing.Size(416, 432)
        Me.Name = "Form1"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
        Me.Text = "VICEtoPS"
        Me.GroupBox1.ResumeLayout(False)
        Me.GroupBox2.ResumeLayout(False)
        Me.GroupBox2.PerformLayout()
        Me.GroupBox3.ResumeLayout(False)
        Me.GroupBox3.PerformLayout()
        Me.ResumeLayout(False)

    End Sub
End Class
