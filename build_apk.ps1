echo ========================================
echo      QURANICARE APK SIMPLE BUILD
echo ========================================

echo Cleaning project...
flutter clean

echo Getting dependencies...
flutter pub get

echo Building APK (this will take time)...
flutter build apk --debug

echo.
echo Checking if APK was created...
if (Test-Path "build\app\outputs\flutter-apk\app-debug.apk") {
    echo "✅ SUCCESS! APK created successfully!"
    echo "📱 Location: build\app\outputs\flutter-apk\app-debug.apk"
    
    # Copy to Builds folder with new name
    Copy-Item "build\app\outputs\flutter-apk\app-debug.apk" "..\Builds\quranicare_v1.0_debug.apk" -Force
    
    echo "✅ Copied to: ..\Builds\quranicare_v1.0_debug.apk"
    echo "🎉 APK ready! You can share this file via WhatsApp/Google Drive!"
} else {
    echo "❌ Build failed. APK not found."
}

echo.
echo "Press any key to continue..."
Read-Host