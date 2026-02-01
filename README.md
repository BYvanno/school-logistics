# School Logistics Mobile App - Flutter

A native Android mobile application for the School Logistics Management System.

## 📱 Features

- ✅ Native Android app (APK)
- ✅ Material Design UI
- ✅ Role-based access (Admin, Storekeeper, Teacher)
- ✅ Inventory management
- ✅ Request workflow
- ✅ Offline-capable (with cached data)

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.10+
- Android Studio / VS Code
- Backend API running on `localhost:5000`

### Installation

1. **Install dependencies:**
   ```bash
   cd mobile
   flutter pub get
   ```

2. **Run on Android emulator:**
   ```bash
   flutter run
   ```

3. **Build APK:**
   ```bash
   # Debug APK
   flutter build apk --debug
   
   # Release APK
   flutter build apk --release
   ```

## 📦 APK Location

After building, find your APK at:
- **Debug**: `build/app/outputs/flutter-apk/app-debug.apk`
- **Release**: `build/app/outputs/flutter-apk/app-release.apk`

## 🔧 Backend Configuration

The app connects to the backend API. For testing:

- **Android Emulator**: Uses `10.0.2.2:5000` (localhost redirect)
- **Physical Device**: Update `lib/services/api_service.dart` with your computer's local IP

```dart
// In api_service.dart, change:
static const String baseUrl = 'http://YOUR_LOCAL_IP:5000';
```

## 🔑 Demo Credentials

- Email: `admin@school.com`
- Password: `admin123`

## 📱 App Structure

```
lib/
├── main.dart              # App entry point
├── models/
│   ├── user.dart          # User data model
│   └── item.dart          # Inventory item model
├── services/
│   ├── api_service.dart   # HTTP client & API calls
│   └── auth_provider.dart # State management
└── screens/
    ├── login_screen.dart      # Login UI
    ├── dashboard_screen.dart  # Home dashboard
    ├── inventory_screen.dart  # Inventory list
    └── requests_screen.dart   # Requests management
```

## 🎨 Screenshots

(Screenshots will appear here after running the app)

## 🚢 Distribution

### Direct Installation
1. Build release APK
2. Transfer APK to device
3. Enable "Install from unknown sources"
4. Install APK

### Progressive Web App Alternative
Use the Next.js web version for instant access without installation.

## 📝 Development

```bash
# Run in debug mode
flutter run

# Hot reload
Press 'r' in terminal

# Hot restart
Press 'R' in terminal

# Check for issues
flutter doctor
```

## ✅ Testing Checklist

- [ ] Login with demo credentials
- [ ] View dashboard stats
- [ ] Navigate to inventory
- [ ] Check low stock indicators
- [ ] Test logout
- [ ] Verify pull-to-refresh
- [ ] Test on different screen sizes

## 🔒 Security Notes

- JWT tokens stored in SharedPreferences
- HTTPS recommended for production
- Update API base URL for production deployment

## 📄 License

MIT License - Same as the backend API
