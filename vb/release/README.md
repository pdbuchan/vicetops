# VICEtoPS pre-built release

This directory contains the pre-built Visual Basic .NET version of VICEtoPS.

Keep these files together:

```text
ViceToPS.exe
ViceToPS.exe.config
characters.390059-01.bin
```

`ViceToPS.exe.config` identifies the .NET Framework runtime targeted by the application. The character ROM file is required by VICEtoPS at run time.

To rebuild the executable from source, open `../ViceToPS.sln` in Visual Studio and build the Release configuration. The normal Visual Studio `bin/` and `obj/` directories are generated build output and are not stored in the repository.
