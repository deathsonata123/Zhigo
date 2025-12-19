@echo off
REM Zhigo Build Script for Windows
REM This builds all web applications for production

echo ========================================
echo  Building Zhigo Web Applications
echo ========================================

cd /d "%~dp0"

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Node.js is not installed or not in PATH
    pause
    exit /b 1
)

echo.
echo [1/3] Building Admin Dashboard...
echo ----------------------------------------
cd web\admin-dashboard
if exist node_modules (
    echo Dependencies already installed
) else (
    echo Installing dependencies...
    call npm install
)
echo Building...
call npm run build
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Admin dashboard build failed
    cd ..\..
    pause
    exit /b 1
)
echo Admin Dashboard built successfully!
cd ..\..

echo.
echo [2/3] Building Restaurant Dashboard...
echo ----------------------------------------
cd web\restaurant-dashboard
if exist node_modules (
    echo Dependencies already installed
) else (
    echo Installing dependencies...
    call npm install
)
echo Building...
call npm run build
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Restaurant dashboard build failed
    cd ..\..
    pause
    exit /b 1
)
echo Restaurant Dashboard built successfully!
cd ..\..

echo.
echo [3/3] Building Backend...
echo ----------------------------------------
cd backend-express
if exist node_modules (
    echo Dependencies already installed
) else (
    echo Installing dependencies...
    call npm install
)
if exist tsconfig.json (
    echo Building TypeScript...
    call npm run build
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Backend build failed
        cd ..
        pause
        exit /b 1
    )
    echo Backend built successfully!
) else (
    echo Backend is JavaScript only, no build needed
)
cd ..

echo.
echo ========================================
echo  All builds completed successfully!
echo ========================================
echo.
echo Next step: Transfer files to EC2
echo Run: transfer-to-ec2.bat
echo.
pause
