# MediConnect — one-time Android setup + APK build (Windows PowerShell)
# Run from the project root (the folder that contains pubspec.yaml):
#   powershell -ExecutionPolicy Bypass -File .\setup_android.ps1
$ErrorActionPreference = "Stop"

if (-not (Test-Path "pubspec.yaml")) { throw "Run this from the project root (where pubspec.yaml is)." }

Write-Host "1/5  Recreating the Android project..." -ForegroundColor Cyan
if (Test-Path "android") { Remove-Item -Recurse -Force "android" }
flutter create . --project-name mediconnect --org com.mediconnect --platforms=android
if (Test-Path "test") { Remove-Item -Recurse -Force "test" }   # default template test refers to a MyApp class we don't have

Write-Host "2/5  Installing packages..." -ForegroundColor Cyan
flutter pub get

Write-Host "3/5  Adding permissions to AndroidManifest.xml..." -ForegroundColor Cyan
$manifest = "android\app\src\main\AndroidManifest.xml"
$text = [System.IO.File]::ReadAllText((Resolve-Path $manifest))
if ($text -notmatch "android.permission.INTERNET") {
$perms = @'
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.READ_CONTACTS"/>
    <queries>
        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="sms"/></intent>
        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
        <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="upi"/></intent>
        <intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>
        <intent><action android:name="android.intent.action.TTS_SERVICE"/></intent>
        <intent><action android:name="android.speech.RecognitionService"/></intent>
    </queries>

'@
    $text = $text.Replace("<application", $perms + "    <application")
    [System.IO.File]::WriteAllText((Resolve-Path $manifest), $text)
}

Write-Host "4/5  Setting minimum Android version to 24..." -ForegroundColor Cyan
foreach ($f in @("android\app\build.gradle.kts", "android\app\build.gradle")) {
    if (Test-Path $f) {
        $g = [System.IO.File]::ReadAllText((Resolve-Path $f))
        $g = $g -replace 'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 24'
        $g = $g -replace 'minSdkVersion\s+flutter\.minSdkVersion', 'minSdkVersion 24'
        [System.IO.File]::WriteAllText((Resolve-Path $f), $g)
    }
}

Write-Host "5/5  Building the release APK (this takes a few minutes)..." -ForegroundColor Cyan
flutter build apk --release

Write-Host ""
Write-Host "Done. Your APK: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
