@rem Gradle wrapper bootstrap script for Windows.
@rem Downloads the Gradle distribution recorded in gradle\wrapper\gradle-wrapper.properties
@rem and runs it. Requires java on PATH.

@echo off
setlocal EnableExtensions

set "APP_HOME=%~dp0"
set "PROPS=%APP_HOME%gradle\wrapper\gradle-wrapper.properties"
set "DIST_DIR=%APP_HOME%gradle\wrapper\dists"

if not exist "%PROPS%" (
  echo ERROR: %PROPS% not found. 1>&2
  exit /b 1
)

set "DIST_URL="
for /f "usebackq tokens=1,* delims==" %%A in ("%PROPS%") do (
  if "%%A"=="distributionUrl" set "DIST_URL=%%B"
)

if "%DIST_URL%"=="" (
  echo ERROR: no distributionUrl found in %PROPS%. 1>&2
  exit /b 1
)

set "DIST_URL=%DIST_URL:\:=:%"

for %%I in ("%DIST_URL%") do set "DIST_NAME=%%~nxI"
set "DIST_HOME=%DIST_DIR%\%DIST_NAME%"
set "GRADLE_HOME=%DIST_HOME%\%DIST_NAME:-bin.zip=%"

where java >nul 2>&1
if errorlevel 1 (
  echo ERROR: java was not found on PATH. Install JDK 21 and try again. 1>&2
  exit /b 1
)

if exist "%GRADLE_HOME%\bin\gradle.bat" goto run

if not exist "%DIST_HOME%" mkdir "%DIST_HOME%" >nul 2>&1

set "ZIP=%DIST_HOME%\%DIST_NAME%"
if not exist "%ZIP%" (
  echo Downloading %DIST_URL%
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri '%DIST_URL%' -OutFile '%ZIP%'"
  if errorlevel 1 (
    echo ERROR: failed to download Gradle. 1>&2
    exit /b 1
  )
)

echo Unpacking Gradle
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Force -LiteralPath '%ZIP%' -DestinationPath '%DIST_HOME%'"
if errorlevel 1 (
  echo ERROR: failed to unpack Gradle. 1>&2
  exit /b 1
)

if not exist "%GRADLE_HOME%\bin\gradle.bat" (
  echo ERROR: Gradle did not unpack as expected under %DIST_HOME%. 1>&2
  exit /b 1
)

:run
"%GRADLE_HOME%\bin\gradle.bat" %*
endlocal
