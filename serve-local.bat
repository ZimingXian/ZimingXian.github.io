@echo off
set "PATH=D:\ProgramData\MSYS2\ucrt64\bin;D:\ProgramData\MSYS2\usr\bin;%PATH%"
cd /d "%~dp0"
D:\ProgramData\MSYS2\ucrt64\bin\bundle.bat exec jekyll serve --host 127.0.0.1 --port 4000 --livereload
