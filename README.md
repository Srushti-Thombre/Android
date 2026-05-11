# Finance Analyzer - Production Finance App

A professional personal finance management application built with Flutter and Firebase. Track expenses, analyze spending patterns, manage your budget, and gain smart financial insights.

## 🎯 Features

### Authentication & Security
- ✅ Email/Password authentication with Firebase
- ✅ Secure session management with persistent login
- ✅ User profile management
- ✅ Password reset functionality
- ✅ Form validation & error handling

### Expense Management
- ✅ Add, edit, delete expenses with real-time sync
- ✅ 7 expense categories (Rent, Groceries, Transport, Entertainment, Bills, Shopping, Other)
- ✅ Date picker for precise expense tracking
- ✅ Notes/descriptions for each expense
- ✅ Firestore cloud storage for data persistence

### Financial Analytics
- ✅ Monthly income tracking
- ✅ Total expense calculation with category breakdown
- ✅ Savings amount and percentage analysis
- ✅ Expense ratio insights
- ✅ Interactive pie charts for visualization
- ✅ Category-wise spending analysis with trends
- ✅ Smart financial insights with spending alerts

### Dashboard & Reporting
- ✅ Monthly summary cards (Income, Expenses, Savings)
- ✅ Expense history with date grouping
- ✅ Quick action buttons for common tasks
- ✅ Budget status indicator with alerts
- ✅ Analytics screen with detailed breakdowns
- ✅ Three-tab navigation: Overview, History, Insights

### User Experience
- ✅ Material 3 modern design system
- ✅ Dark mode support with persistence
- ✅ Responsive layouts for all screen sizes
- ✅ Smooth animations and transitions
- ✅ Loading indicators for async operations
- ✅ Comprehensive error handling
- ✅ Empty states for better UX
- ✅ Toast notifications with Snackbars

## 📱 Supported Platforms

- ✅ Android 6.0+
- ✅ iOS 11.0+
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🏗️ Project Architecture

**Clean Architecture Pattern** with:
- **Models**: Type-safe data models with serialization
- **Services**: Business logic layer (Auth, Firestore, Expenses)
- **Providers**: State management using Provider pattern
- **Screens**: UI layer with proper separation
- **Widgets**: Reusable component library
- **Utils**: Helper functions, validators, formatters

## 📲 Quick Start

### Prerequisites
- Flutter SDK v3.11.4+
- Dart SDK (included)
- Firebase Project
- Android Studio / Xcode (for mobile)

### Installation

1. Clone repository:
```bash
git clone https://github.com/yourusername/finance_analyzer.git
cd finance_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase (detailed guide in FIREBASE_SETUP.md):
```bash
# Download google-services.json (Android)
# Download GoogleService-Info.plist (iOS)
# Update lib/firebase_options.dart
```

4. Run the app:
```bash
flutter run -d android  # Android
flutter run -d ios      # iOS
flutter run -d chrome   # Web
```

## 🗄️ Database Schema

### Firestore Collections

- `users/{userId}` - User profiles
- `users/{userId}/expenses/{expenseId}` - Individual expenses
- `users/{userId}/monthly_summaries/{year_month}` - Monthly aggregates
- `users/{userId}/budget_goals/{goalId}` - Budget goals

See **FIREBASE_SETUP.md** for detailed schema documentation.

## 🎨 Screens

| Screen | Purpose |
|--------|---------|
| Splash | Animated app initialization |
| Login | Email/password authentication |
| Sign Up | New account creation with validation |
| Dashboard | Main hub with overview, history, and insights |
| Add Expense | Form to add new expenses |
| Analytics | Detailed breakdown with charts |
| Profile | User information and settings |

## 🔒 Security

- Firebase Authentication & Firestore security rules
- User-scoped data access only
- Input validation on client and server
- No sensitive data in logs
- Secure password requirements

## 📦 Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.11.4, Material 3 |
| State | Provider 6.2.0 |
| Backend | Firebase (Auth, Firestore) |
| Charts | fl_chart 1.2.0 |
| Storage | SharedPreferences |
| Utilities | intl, uuid, connectivity_plus |

## 🧪 Testing

Manual testing checklist included in code. Test:
- Authentication flows
- Expense CRUD operations
- Chart visualizations
- Dashboard calculations
- Dark mode toggle
- Form validation
- Error handling

## 🚀 Performance

- Real-time Firestore listeners
- Local caching with SharedPreferences
- Efficient Provider state management
- Lazy loading of expenses
- Optimized widget rebuilds

## 📄 Documentation

- **FIREBASE_SETUP.md** - Complete Firebase configuration guide
- **Code comments** - Inline documentation for complex logic
- **README.md** - This file

## 🎓 Learning Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Material 3 Design](https://m3.material.io/)
- [Provider Pattern](https://pub.dev/packages/provider)

## 🐛 Troubleshooting

**Firebase not working?**
→ See FIREBASE_SETUP.md section "Troubleshooting"

**Hot reload issues?**
```bash
flutter clean
flutter pub get
flutter run --no-fast-start
```

**Build errors?**
```bash
flutter doctor -v
flutter clean
```

## 📊 Project Stats

```
Total Files: 40+
Lines of Code: 3000+
Test Coverage: Manual
Platforms: 6
Features: 20+
```

## ✨ Highlights

🎨 Beautiful Material 3 UI  
🔐 Secure Firebase backend  
📊 Real-time analytics  
🌙 Dark mode support  
⚡ High performance  
📱 Cross-platform  
💾 Cloud persistence  
🛡️ Type-safe Dart  
🎯 Clean architecture  
📚 Well documented  

## 🚢 Deployment

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
firebase deploy  # If hosting on Firebase
```

## 🤝 Contributing

Contributions welcome! Ensure:
- Code follows Dart style guide
- All tests pass
- Documentation updated
- Clear PR description

## 📞 Support & Feedback

- Check FIREBASE_SETUP.md first
- Review inline code comments
- Consult Flutter/Firebase documentation
- Create GitHub issue with details

## 📄 License

Provided as-is for educational and personal use.

---

**Happy Tracking! 💸**

For complete Firebase setup instructions, see **FIREBASE_SETUP.md**
