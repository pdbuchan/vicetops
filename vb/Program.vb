Imports System
Imports System.Drawing
Imports System.Windows.Forms

Friend Module Program
    <STAThread>
    Friend Sub Main()
        ' Preserve the sizing and appearance of the original .NET Framework forms.
        Application.SetHighDpiMode(HighDpiMode.SystemAware)
        Application.SetDefaultFont(New Font("Microsoft Sans Serif", 8.25F, FontStyle.Regular, GraphicsUnit.Point))
        Application.EnableVisualStyles()
        Application.SetCompatibleTextRenderingDefault(False)
        Application.Run(New vicetops())
    End Sub
End Module
