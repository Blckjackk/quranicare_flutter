@echo off
echo ========================================
echo     QURANICARE APK MANUAL BUILD
echo ========================================
echo.

echo Step 1: Checking disk space...
for /f "skip=1 tokens=3" %%a in ('wmic logicaldisk where caption^="C:" get freespace') do (
    set /a freegb=%%a/1073741824
    echo Free space on C: drive: %freegb% GB
    if %freegb% LSS 5 (
        echo WARNING: Low disk space! Need at least 5GB free.
        echo Please free up space and try again.
        pause
        exit /b 1
    )
)

echo.
echo Step 2: Killing all Java/Gradle processes...
taskkill /F /IM java.exe /T >nul 2>&1
taskkill /F /IM gradle.exe /T >nul 2>&1

echo.
echo Step 3: Deleting Gradle cache (this might take a while)...
rd /s /q "%USERPROFILE%\.gradle" >nul 2>&1
rd /s /q "build" >nul 2>&1
rd /s /q ".gradle" >nul 2>&1

echo.
echo Step 4: Recreating Gradle wrapper...
if not exist "gradle\wrapper\gradle-wrapper.jar" (
    echo ERROR: Gradle wrapper not found! Project may be corrupted.
    pause
    exit /b 1
)

echo.
echo Step 5: Building APK...
echo This will take several minutes. Please be patient!
flutter clean
flutter pub get
flutter build apk --debug

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo.
    echo ========================================
    echo           BUILD SUCCESS! 
    echo ========================================
    echo.
    echo APK Location: build\app\outputs\flutter-apk\app-debug.apk
    echo Size: 
    for %%A in ("build\app\outputs\flutter-apk\app-debug.apk") do echo %%~zA bytes
    echo.
    echo Copying to Builds folder...
    copy "build\app\outputs\flutter-apk\app-debug.apk" "..\Builds\quranicare_v1.0_debug.apk"
    echo.
    echo ✅ SUCCESS! APK ready at: ..\Builds\quranicare_v1.0_debug.apk
) else (
    echo.
    echo ❌ BUILD FAILED! Check the errors above.
)

echo.
pause