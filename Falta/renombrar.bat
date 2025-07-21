@echo off
setlocal enabledelayedexpansion

:: Nombre base del archivo dividido
set "base=vendor"

for %%f in (%base%.zip.*) do (
    set "filename=%%~nxf"
    set "ext=%%~xf"

    :: Extraer el número (últimos 3 dígitos después del punto)
    set "num=%%~xf"
    set "num=!num:~1!"  :: quita el punto al inicio de la extensión

    :: Formato con 3 dígitos (por si 010, 011, 100, etc.)
    ren "%%f" "!base!!num!.zip"
)

echo ✅ Renombrado completo
pause

