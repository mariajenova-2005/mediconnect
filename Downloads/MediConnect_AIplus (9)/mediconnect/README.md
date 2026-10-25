# MediConnect AI+ 🩺💙💚

Flutter app + Node backend. **No MongoDB, no Razorpay, no accounts needed to run.**

## Easiest way (Windows): one script
From the project folder in PowerShell:
```powershell
powershell -ExecutionPolicy Bypass -File .\setup_android.ps1
```
It recreates the Android project, adds all permissions, sets minSdk 24, and builds `build\app\outputs\flutter-apk\app-release.apk`.
If Flutter says "unsupported Gradle project", this script is the fix.

## Run it — ONE app, no server needed
The backend now runs inside the app (data is saved on the phone). Just:
```bash
flutter create . --project-name mediconnect --org com.mediconnect   # once
flutter pub get
flutter run                          # test on a connected phone / emulator / Chrome
flutter build apk --release          # single APK -> build/app/outputs/flutter-apk/app-release.apk
```
Install the APK on your phone (copy it over or `flutter install`). No PC, Wi-Fi or server is involved.
- Make sure the Android permissions below (especially `INTERNET`) are in `AndroidManifest.xml` — needed for maps and AI.
- For live AI: open the app → ⚙ Settings (top right of the dashboard) → paste your Groq key.
- Logins: `patient@mediconnect.app / Patient@123`, `dr.aisha.menon@mediconnect.app / Doctor@123`, `admin@mediconnect.app / Admin@123`
- Data lives only on that phone (per-device). Uninstalling the app erases it.
- Optional: the original Node server is still in `/backend`. Use it with `--dart-define=USE_SERVER=true --dart-define=API_URL=http://<host>:5000/api`.

## Android permissions (after `flutter create .`)
In `AndroidManifest.xml` inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<queries>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="sms"/></intent>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent>
  <intent><action android:name="android.intent.action.VIEW"/><data android:scheme="upi"/></intent>
  <intent><action android:name="android.intent.action.DIAL"/><data android:scheme="tel"/></intent>
</queries>
```
iOS `Info.plist`: add `NSLocationWhenInUseUsageDescription`.

## Payments (simple, no gateway)
- **Pay at Clinic** — booking confirmed, pay at reception.
- **UPI** — opens the patient's UPI app pre-filled. Set your clinic's UPI ID in `lib/screens/patient/payment_screen.dart` (`clinicUpi`). The clinic confirms receipt manually.

## What's real vs sample
Real (database-backed): login/register, profile, doctors + fees + online status, appointments, doctor queue, admin stats, live GPS hospitals (OpenStreetMap).
Sample/demo: vitals & health score, family members, blood donors, record-upload UI, payment confirmation. AI uses Groq when `GROQ_API_KEY` is set, otherwise built-in answers.

## Features
Auth (patient/doctor/admin) · doctor search & booking · appointments · UPI/clinic payment · doctor & admin dashboards · video-call UI (+ Socket.IO signaling) · AI symptom checker / prescription explainer / report analyzer / MediBot · medical records · family health · Emergency SOS with live location & gesture mode · Family SOS alert · live hospital map · medicine reminders · Medical ID · blood donors · wellness (water + BMI) · CPR guide · stroke FAST check · Show-to-Doctor card · pain map.

## New: Emergency alarm, camera gestures, Dr. Medi (voice AI doctor)
**Extra permissions** (after `flutter create .`) in `AndroidManifest.xml`, inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```
and add to the existing `<queries>` block:
```xml
<intent><action android:name="android.intent.action.TTS_SERVICE"/></intent>
<intent><action android:name="android.speech.RecognitionService"/></intent>
```
Set `minSdkVersion 21` (or higher) in `android/app/build.gradle`. iOS `Info.plist`: `NSCameraUsageDescription`, `NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`.

- **Alarm:** loops a siren at full app volume, raises phone media volume to max (mobile), vibrates. Opens automatically on Severe. A phone can't exceed its max volume; browsers can't change system volume.
- **Gesture camera (Android/iOS only):** both hands up = Severe, one hand up = Moderate, hands together at chest = Mild; hold ~1.5 s. Uses on-device ML Kit pose detection. Chrome shows tap mode instead.
- **Dr. Medi:** speak or type; answers aloud. Uses Groq via the backend when `GROQ_API_KEY` is set, otherwise a small built-in rule set. It is an AI assistant, not a doctor: it gives general guidance, never prescription drugs or child doses, and escalates red-flag symptoms.

## Updates: big Dr. Medi face, live location, live medicine suggestions, phone contacts
- Add to `AndroidManifest.xml`: `<uses-permission android:name="android.permission.READ_CONTACTS"/>`; iOS `Info.plist`: `NSContactsUsageDescription`.
- **Live location:** map follows you and hospitals refresh every ~500 m / 90 s; SOS hospital list updates while you move.
- **Medicine suggestions** update every turn of the conversation: over-the-counter options only, no doses, filtered against your allergies and a block-list of prescription-only drugs.
- **Contacts:** import from your phone's real contact book (updates live when contacts change); saved to your account.
