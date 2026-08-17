# Punch In Punch Out App

Flutter mobile frontend for the existing Punch In Punch Out backend.

## Backend

The app uses the same Express API:

```text
POST /api/auth/signup
POST /api/auth/login
GET /api/weeks
GET /api/weeks/:weekStart
PUT /api/weeks/:weekStart
DELETE /api/weeks/:weekStart
GET /api/settings
PUT /api/settings
PUT /api/settings/timer
DELETE /api/settings/timer
```

## Run

When Flutter CLI is working:

```powershell
flutter create .
flutter pub get
flutter run --dart-define=API_BASE=http://10.0.2.2:5000
```

For a real deployed backend:

```powershell
flutter run --dart-define=API_BASE=https://YOUR-BACKEND.onrender.com
```

For Android emulator, use `10.0.2.2` instead of `localhost`.

For iOS simulator, `localhost` usually works if the backend runs on the Mac.
# Punch_in_punch_out_app_ios
