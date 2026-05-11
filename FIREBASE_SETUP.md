# Finance Analyzer - Firebase Setup Guide

## Overview
This is a production-grade personal finance management application built with Flutter and Firebase. This guide explains how to set up Firebase and configure the application.

---

## Prerequisites

### Development Environment
- Flutter SDK (v3.11.4 or higher)
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for platform-specific setup)
- Firebase CLI (optional but recommended)
- A Google account for Firebase

### System Requirements
- macOS 10.11+, Windows 7+, or Linux
- Android 6.0+ or iOS 11.0+
- Minimum 2GB RAM for development

---

## Step 1: Create Firebase Project

### Using Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click **"Create a project"**
3. Enter project name: `Finance Analyzer App`
4. Select your country
5. Click **"Create project"** and wait for setup to complete

### Using Firebase CLI (Optional)

```bash
npm install -g firebase-tools
firebase login
firebase projects:create --display-name "Finance Analyzer App"
```

---

## Step 2: Enable Firebase Services

### 2.1 Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**:
   - Click on "Email/Password"
   - Enable "Email/Password" option
   - Click **Save**

### 2.2 Cloud Firestore

1. Go to **Firestore Database** section
2. Click **"Create database"**
3. Select location (closest to your users)
4. Start in **Test mode** (for development)
5. Click **"Create"**

### 2.3 Set Firestore Security Rules

1. Go to **Firestore Database** → **Rules** tab
2. Replace the content with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      match /expenses/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
      
      match /monthly_summaries/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
      
      match /budget_goals/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

3. Click **Publish**

---

## Step 3: Android Configuration

### 3.1 Add Google Services Plugin

Edit `android/build.gradle`:

```gradle
buildscript {
  repositories {
    google()
    mavenCentral()
  }
  
  dependencies {
    classpath 'com.android.tools.build:gradle:8.1.0'
    classpath 'com.google.gms:google-services:4.4.0'  // Add this line
  }
}
```

Edit `android/app/build.gradle`:

```gradle
plugins {
  id "com.android.application"
  id "com.google.gms.google-services"  // Add this line
}

dependencies {
  // Your existing dependencies
}
```

### 3.2 Download google-services.json

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Select **"Your apps"** section
3. Click **Android** icon
4. Register app with package name: `com.example.finance_app`
5. Click **"Download google-services.json"**
6. Move the file to `android/app/google-services.json`

### 3.3 Update AndroidManifest.xml

Edit `android/app/src/main/AndroidManifest.xml` to ensure internet permission is present:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
  <uses-permission android:name="android.permission.INTERNET" />
  
  <application>
    <!-- Your app configuration -->
  </application>
</manifest>
```

---

## Step 4: iOS Configuration

### 4.1 Download GoogleService-Info.plist

1. In Firebase Console, go to **Project Settings** → **Your apps**
2. Click **iOS** icon
3. Register app with bundle ID: `com.example.financeApp`
4. Click **"Download GoogleService-Info.plist"**
5. Open `ios/Runner.xcworkspace` in Xcode
6. Right-click project → "Add Files to Runner"
7. Select the downloaded **GoogleService-Info.plist**
8. Ensure "Copy items if needed" is checked

### 4.2 Update iOS Podfile

Edit `ios/Podfile`:

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
      ]
    end
  end
end
```

### 4.3 Install iOS Dependencies

```bash
cd ios
pod install
cd ..
```

---

## Step 5: Web Configuration (Optional)

### 5.1 Get Web Configuration

1. In Firebase Console, go to **Project Settings** → **Your apps**
2. Click **Web** icon
3. Register app with name: `Finance Analyzer Web`
4. Copy the Firebase config object

### 5.2 Update web/index.html

Edit `web/index.html` and add Firebase scripts before `</body>`:

```html
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore-compat.js"></script>

<script>
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "finance-analyzer-app.firebaseapp.com",
    projectId: "finance-analyzer-app",
    storageBucket: "finance-analyzer-app.appspot.com",
    messagingSenderId: "YOUR_SENDER_ID",
    appId: "YOUR_APP_ID"
  };
  
  firebase.initializeApp(firebaseConfig);
</script>
```

---

## Step 6: Update firebase_options.dart

Update `lib/firebase_options.dart` with your Firebase credentials from the Firebase Console:

```dart
class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:android:YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'finance-analyzer-app',
    storageBucket: 'finance-analyzer-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: '1:YOUR_PROJECT_NUMBER:ios:YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'finance-analyzer-app',
    storageBucket: 'finance-analyzer-app.appspot.com',
    iosBundleId: 'com.example.financeApp',
  );
  
  // Similar for web and macOS...
}
```

---

## Step 7: Install Flutter Dependencies

```bash
cd finance_app
flutter pub get
```

---

## Step 8: Run the Application

### Android

```bash
flutter run -d android
```

### iOS

```bash
flutter run -d ios
```

### Web

```bash
flutter run -d chrome
```

---

## Database Schema

### Collections Structure

#### `/users/{userId}`
Stores user profile information.

```
{
  email: string,
  displayName: string,
  photoUrl: string (optional),
  monthlyIncome: number,
  currency: string (default: "₹"),
  budgetLimit: number,
  createdAt: timestamp,
  updatedAt: timestamp,
  lastLoginAt: timestamp
}
```

#### `/users/{userId}/expenses/{expenseId}`
Stores individual expenses.

```
{
  category: string,
  amount: number,
  date: timestamp,
  note: string,
  createdAt: timestamp,
  updatedAt: timestamp,
  receipt_url: string (optional)
}
```

#### `/users/{userId}/monthly_summaries/{year_month}`
Stores aggregated monthly data.

```
{
  month: string (YYYY-MM format),
  totalIncome: number,
  totalExpenses: number,
  categoryBreakdown: map,
  savings: number,
  expenseRatio: number,
  budgetStatus: string,
  generatedAt: timestamp
}
```

#### `/users/{userId}/budget_goals/{goalId}`
Stores budget goals for categories.

```
{
  categoryName: string,
  monthlyLimit: number,
  currentSpending: number,
  alertThreshold: number,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

---

## Features Implemented

### ✅ Core Features
- User Authentication (Email/Password with Firebase)
- Secure session management
- Expense tracking with 7 categories
- Monthly income tracking
- Real-time expense synchronization
- Financial analytics with charts
- Budget tracking
- Expense history with filtering

### ✅ UI/UX Features
- Material 3 design
- Dark mode support
- Responsive layouts
- Smooth animations
- Loading indicators
- Error handling
- Empty states
- Snackbar notifications

### ✅ Technical Features
- Provider state management
- Cloud Firestore database
- Firebase Authentication
- Real-time data listeners
- Offline support (cached data)
- Form validation
- Null safety
- Clean architecture

---

## Testing

### Manual Testing Checklist

- [ ] App launches with splash screen
- [ ] Can sign up with email
- [ ] Can login after signup
- [ ] User data persists in Firestore
- [ ] Can add expense with all categories
- [ ] Charts display correctly
- [ ] Can delete expenses
- [ ] Dashboard calculations are accurate
- [ ] Profile page shows correct user info
- [ ] Dark mode toggles and persists
- [ ] Logout clears session
- [ ] Navigation works between all screens
- [ ] Error messages display on failures
- [ ] Loading states show during operations

---

## Troubleshooting

### Common Issues

#### Firebase not initializing
- Verify `google-services.json` is in `android/app/`
- Verify `GoogleService-Info.plist` is in `ios/Runner/`
- Check Firebase project ID matches in config files

#### Authentication not working
- Verify Email/Password is enabled in Firebase Authentication
- Check Firestore security rules are correct
- Ensure internet permission in AndroidManifest.xml

#### Firestore operations failing
- Check security rules allow user operations
- Verify collection names match exactly (case-sensitive)
- Ensure user document exists before adding sub-collections

#### Hot reload issues
- Run `flutter clean` and then `flutter pub get`
- Try `flutter run --no-fast-start`
- Restart the Flutter development server

---

## Environment Variables

Create `.env` file in project root (optional):

```
FIREBASE_PROJECT_ID=finance-analyzer-app
FIREBASE_API_KEY=YOUR_API_KEY
```

---

## Production Deployment

### Before Release

1. **Update version in pubspec.yaml**:
   ```yaml
   version: 1.0.0+1
   ```

2. **Update Security Rules** (Test mode → Production):
   - In Firestore Rules tab, change from test mode to production rules

3. **Enable required Firebase services**:
   - Authentication
   - Cloud Firestore
   - Cloud Storage (if using receipts)

4. **Test on real device** before publishing

### Android Release Build

```bash
flutter build apk --release
# or for AAB format
flutter build appbundle --release
```

### iOS Release Build

```bash
flutter build ios --release
```

---

## Support & Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Console](https://console.firebase.google.com)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Material 3 Design](https://m3.material.io/)

---

## License

This project is provided as-is for educational and personal use.

---

## Next Steps

1. ✅ Complete Firebase setup following this guide
2. ✅ Test authentication and database operations
3. ✅ Deploy to Firebase Hosting (optional)
4. ✅ Publish to App Stores

Enjoy using Finance Analyzer! 💸
