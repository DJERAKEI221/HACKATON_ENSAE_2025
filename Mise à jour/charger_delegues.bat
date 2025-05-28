@echo off
echo Chargement des delegues...
echo.

REM Définir le chemin vers R
set R_PATH="C:\Program Files\R\R-4.3.1\bin\Rscript.exe"

REM Vérifier si R est installé
if not exist %R_PATH% (
    echo Erreur: R n'est pas installe a l'emplacement attendu.
    echo Veuillez installer R ou modifier le chemin dans le script.
    pause
    exit /b 1
)

REM Se déplacer dans le répertoire du script
cd /d "%~dp0"

REM Exécuter le script R
%R_PATH% charger_delegues_csv.R

REM Vérifier si le script s'est bien exécuté
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo Une erreur s'est produite lors du chargement des delegues.
    pause
    exit /b 1
)

echo.
echo Chargement termine avec succes!
pause 