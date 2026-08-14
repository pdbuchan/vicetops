# Visual Basic (.NET)

This version of VICEtoPS was written in [Visual Basic .NET](https://en.wikipedia.org/wiki/Visual_Basic_.NET) and provides a Windows Forms interface.

The project targets **.NET Framework 4.8** and was built with Visual Studio Community 2026 on Microsoft Windows 11 Home 25H2 Build 26200.7171.

## Pre-built executable

A pre-built release is retained in [`release/`](release/):

```text
release/
├── ViceToPS.exe
├── ViceToPS.exe.config
└── characters.390059-01.bin
```

Keep all three files together. `ViceToPS.exe.config` specifies the .NET Framework runtime used by the application, and `characters.390059-01.bin` supplies the Commodore character definitions required by VICEtoPS.

## Building from source

Open `ViceToPS.sln` in Visual Studio and build the desired configuration. Visual Studio places generated files under `bin/`, `obj/`, and `.vs/`; these directories are build/workspace artifacts and are intentionally excluded from Git.

The project source retained in this directory is:

```text
vb/
├── My Project/
├── App.config
├── README.md
├── ViceToPS.Designer.vb
├── ViceToPS.resx
├── ViceToPS.sln
├── ViceToPS.vb
├── ViceToPS.vbproj
└── release/
```

`App.config` is the source configuration file used by the build to produce `ViceToPS.exe.config`.

## License

This program is licensed under the GNU General Public License, version 3 or later. See the repository root `LICENSE` file.
