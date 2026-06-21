# ParkinToday — Logo Animation, Login, Dashboard (Frontend Only)

Built for **Expo SDK 54** (React Native 0.81.4, React 19.1, New Architecture enabled by default).

Styling is plain React Native `style={{}}` objects throughout — no NativeWind/Tailwind dependency, which avoids a whole class of Metro/Babel JSX-runtime resolution issues that broke this build during testing.

A trimmed build with exactly three screens:

1. **Splash** — logo boot animation (rings draw outward from the logo, wordmark fades up), auto-advances to Login after ~2.6s.
2. **Login** — single screen, two steps: phone number entry → 6-digit OTP verification (mono-font digit boxes, auto-advance, resend timer).
3. **Dashboard** — requests the device's real location on load, centers a live map there with a 3 km search radius circle, computes real distance to each mock parking slot using the Haversine formula, and lists only the ones within range.

No profile setup, slot detail, or in-app navigation screens are included in this build.

## First-time setup (Windows)

If you have the old global `expo-cli` installed, remove it first — it conflicts with SDK 54:

```bash
npm uninstall -g expo-cli
```

Then, from inside the `PT-mini` folder:

```bash
npm install
npx expo start --clear
```

That's it — two commands. No extra `expo install` step needed since all native dependencies are
already pinned to SDK 54-compatible versions in `package.json`.

## Before running

- **Android only:** add a Google Maps API key in `app.json` → `expo.android.config.googleMaps.apiKey`. iOS uses Apple Maps by default, no key needed.
- The OTP verification in `LoginScreen.tsx` is mocked (a fixed delay, not a real SMS check) — wire `handleSendOtp` / `handleVerify` to your backend when ready.
- Mock parking data lives in `src/data/mockParkingSlots.ts`, centered around Chennai. Replace with a real API call, or move the coordinates near wherever you're testing so they fall within the live 3 km radius.

## Run

```bash
npx expo start --clear
```

Then:
- `a` → Android emulator (needs Google Play Services images to render maps)
- `i` → iOS simulator (Mac only)
- scan the QR with **Expo Go** on your phone — easiest way to test real GPS. Make sure Expo Go is updated to support SDK 54.

On first reaching the Dashboard, the OS will prompt for location permission. Allow it to see your
real coordinates drive the map and the distance-filtered slot list. Deny it and the dashboard
falls back to a default Chennai coordinate with a "Retry" prompt.

## If something still fails to bundle

Nuke and reinstall clean — this fixes the vast majority of leftover cache/lockfile issues:

```bash
rmdir /s /q node_modules
del package-lock.json
npm install
npx expo start --clear
```
