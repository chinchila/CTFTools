# Reverse engineering challenges
## Binary files
[Ghidra](https://ghidra-sre.org/)
[Radare2](https://github.com/radareorg/radare2)
[UPX](https://upx.github.io/)

## Python
[uncompyle6](https://pypi.org/project/uncompyle6/)

## PHP
[PHP Opcodes](https://www.php.net/manual/pt_BR/internals2.opcodes.php)

## Java
[jd-gui](http://java-decompiler.github.io/)

## C#
[ILSpy](https://github.com/icsharpcode/ILSpy)

# Rust, C++ and C
Good luck, see binary section or llvm

## LLVM cheat sheet

| Command                                           | Description                |
| ------------------------------------------------- |:--------------------------:|
| clang -emit-llvm -S hello.c -o hello.ll           | From C to IR               |
| llvm-as hello.ll -o hello.bc                      | From IR to IR bitcode      |
| llvm-dis hello.bc -o hello.ll                     | From IR bitcode to IR      |
| lli hello.bc                                      | Run IR bitcode             |
| llc -march=x86-64 hello.bc -o hello.s             | From IR bitcode to x64 ASM |
| clang -S hello.bc -o hello.s -fomit-frame-pointer | From IR bitcode to ASM     |

