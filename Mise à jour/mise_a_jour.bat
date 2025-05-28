@echo off
echo ========================================
echo    MISE A JOUR ELECTIONS ENSAE 2025
echo ========================================
echo.

echo Changement vers le dossier Mise a jour...
cd /d "%~dp0"

echo Execution du script de mise a jour...
echo.

Rscript mise_a_jour_complete.R

echo.
echo ========================================
echo Appuyez sur une touche pour continuer...
pause > nul 