# ParkInToday — Flutter App

A complete smart parking app converted from React Native to Flutter, built with a **Rapido-inspired** professional design system.

---

## ✨ Features

### Auth
- **Existing users** → phone number only, **no OTP** (instant login)
- **New users** → OTP verification (demo code: `123456`)
- Smooth tab switcher between Login / Register

### Splash Screen
- Extended logo animation: **2.0 seconds** (original 1.5s + 0.5s extra)
- Total splash duration: **3.5 seconds**
- Dark gradient background with animated loading dots

### Dashboard
- Professional Rapido-style layout with DM Sans typography
- Greeting with time-of-day detection
- Service cards: Find Parking, EV Charging, Valet, Offers & Deals
- Quick actions row: Challan Check, Parking History, Wallet, Refer & Earn, Rewards
- Active vehicle display with default vehicle
- Promo banner
- Recent activity list

### Find Parking
- Map view (requires Google Maps API key)
- Filter by: All / Available / Covered / Open
- Spot cards with availability badges
- **Booking sheet** → auto-fills vehicle details
- **Booking confirmation page** with slot number, duration, total, booking ID

### EV Charging
- Station list with charger type, power, connector
- Filter by: All / DC Fast / AC / Available
- **Reservation sheet** → auto-fills vehicle
- **Booking confirmation page** with session details

### Valet Service
- Zone selection with ETA and pricing
- Booking confirmation step
- **Success page** with Track Driver option

### Offers & Deals
- Coupons tab: copy promo codes with animation
- Deals tab: bundle packages with discounts
- Rewards tab: tier progress (Bronze → Platinum)

### Challan Check
- Vehicle number lookup
- Demo data for: `MH12AB1234`, `KA01MN5678`, `TN09CD9999`
- Pay Now / Receipt actions

### Parking History
- Stats: trips, total spent, hours parked
- Expandable session cards with receipt download
- Filter chips

### Notifications
- Swipe to dismiss
- Mark all as read
- Unread dot indicators

### Profile
- **Vehicles section: Cars and SUVs only**
- + button to add new vehicles via bottom sheet
- Set default vehicle (auto-used in booking)
- Menu with all feature links
- Partner earning banner

---

## 🏗 Project Structure

```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart          # DM Sans, color palette, Rapido-style design
├── models/
│   ├── app_state.dart          # AppState provider, Vehicle, UserProfile
│   └── parking_models.dart     # ParkingSpot, EVStation, mock data
└── screens/
    ├── splash_screen.dart
    ├── auth_screen.dart         # Login (no OTP) / Register (OTP)
    ├── profile_setup_screen.dart # New user onboarding + AddVehicleSheet
    ├── main_shell.dart          # Bottom nav shell
    ├── dashboard_screen.dart
    ├── find_parking_screen.dart  # With booking confirmation
    ├── ev_charging_screen.dart   # With reservation confirmation
    ├── valet_screen.dart
    ├── offers_screen.dart
    ├── challan_screen.dart
    ├── parking_history_screen.dart
    ├── notifications_screen.dart
    └── profile_screen.dart
```

---

## 🚀 Setup

### Prerequisites
- Flutter SDK ≥ 3.1.0
- Dart ≥ 3.1.0
- Android Studio or VS Code with Flutter plugin

### Steps

```bash
# 1. Navigate to project
cd parkintoday_flutter

# 2. Install dependencies
flutter pub get

# 3. Run on device/emulator
flutter run
```

### For Google Maps (optional)
1. Get an API key from [Google Cloud Console](https://console.cloud.google.com)
2. Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_KEY"/>
   ```
3. Add `google_maps_flutter` to `pubspec.yaml` and integrate in `find_parking_screen.dart`

---

## 🎨 Design System

| Token | Value |
|-------|-------|
| Font | DM Sans (Google Fonts) |
| Accent | `#00B4D8` (cyan) |
| Dark BG | `#0A1628` (navy) |
| Card | `#FFFFFF` |
| App BG | `#EEF2F5` |
| Text 1 | `#111827` |
| Text 2 | `#6B7280` |
| Green | `#16A34A` |
| Red | `#DC2626` |

---

## 🔑 Demo Credentials

| Phone | Type | Login |
|-------|------|-------|
| `9876543210` | Existing user | Direct (no OTP) |
| `9123456789` | Existing user | Direct (no OTP) |
| `6379474664` | Existing user | Direct (no OTP) |
| Any other number | New user | OTP: `123456` |

---

## 📦 Dependencies

```yaml
google_fonts: ^6.1.0        # DM Sans typography
provider: ^6.1.1            # State management
pinput: ^5.0.0              # OTP input boxes
uuid: ^4.2.2                # Vehicle IDs
shimmer: ^3.0.0             # Loading skeletons
animations: ^2.0.11         # Page transitions
intl: ^0.19.0               # Date formatting
```
