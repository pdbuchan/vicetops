# Visual Basic (.NET)

This version of VICEtoPS is written in Visual Basic .NET and provides a Windows Forms interface.

The project has been modernized from the traditional .NET Framework 4.8 Visual Basic project format to an **SDK-style Windows Forms project targeting .NET 10** (`net10.0-windows`).

.NET 10 is a Long Term Support release. See Microsoft's [.NET support policy](https://dotnet.microsoft.com/platform/support/policy) and [Windows Forms migration guidance](https://learn.microsoft.com/dotnet/desktop/winforms/migration/).

## Character ROM

VICEtoPS requires `characters.390059-01.bin`, which is stored at the repository root. The SDK project links that file into the Visual Basic project and automatically copies it beside the application in build and publish output.

At run time, VICEtoPS looks for the ROM beside the application rather than relying on the process's current working directory.

## Building from source

Use Visual Studio 2026 with the .NET desktop development workload and a .NET 10 SDK, or build from a Developer Command Prompt:

```text
dotnet build ViceToPS.sln -c Release
```

The project source is:

```text
vb/
├── Program.vb
├── README.md
├── ViceToPS.Designer.vb
├── ViceToPS.resx
├── ViceToPS.sln
├── ViceToPS.vb
├── ViceToPS.vbproj
└── release/
```

Normal Visual Studio and SDK-generated directories and per-user files such as `.vs/`, `bin/`, `obj/`, `*.suo`, and `*.user` are excluded by the repository [`.gitignore`](../.gitignore).

### Publishing a Windows executable

A framework-dependent, single-file Windows x64 build can be produced with:

```text
dotnet publish ViceToPS.vbproj -c Release -r win-x64 --self-contained false -p:PublishSingleFile=true -p:DebugType=None -p:DebugSymbols=false
```

That build requires the .NET 10 Desktop Runtime on the target computer. To publish a larger self-contained executable that carries its own .NET runtime, use:

```text
dotnet publish ViceToPS.vbproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:DebugType=None -p:DebugSymbols=false
```

The character ROM remains a separate companion file and is copied into the publish directory automatically.

## License

This program is licensed under the GNU General Public License, version 3 or later. See the repository root [`LICENSE`](../LICENSE) file.
