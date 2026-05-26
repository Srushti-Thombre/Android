# Hotel Management System - Table Order Management

A professional hotel/restaurant table management application built with Flutter and Firebase. Manage table orders, track costs per table, calculate taxes, and maintain accurate billing for your establishment.

## 🎯 Features

### Table Management

- ✅ Create and manage multiple tables with easy numbering
- ✅ Open/close tables as customers arrive and leave
- ✅ Re-open tables for returning customers
- ✅ Delete tables when no longer needed

### Order Management

- ✅ Add items/orders to each table in real-time
- ✅ Track quantity and price per item
- ✅ Automatic cost calculation per order
- ✅ Add notes/special requests for each order
- ✅ Remove items from orders
- ✅ Update quantities on the fly

### Billing & Financial Tracking

- ✅ Automatic subtotal calculation per table
- ✅ Tax calculation (5% by default, configurable)
- ✅ Total amount per table (Subtotal + Tax)
- ✅ Grand total for all open tables
- ✅ Track open and closed tables separately
- ✅ Complete order history and details

### Dashboard & Reporting

- ✅ Real-time dashboard with grand total
- ✅ Table status overview (Open/Closed)
- ✅ Quick view of costs, taxes, and totals per table
- ✅ Two-tab navigation: Open Tables, Closed Tables
- ✅ Complete order details per table

### User Experience

- ✅ Material 3 modern design system
- ✅ Dark mode support with persistence
- ✅ Responsive layouts for all screen sizes
- ✅ Smooth animations and transitions
- ✅ Loading indicators for async operations
- ✅ Comprehensive error handling
- ✅ Toast notifications with Snackbars
- ✅ Quick action dialogs and modals

## 📱 Supported Platforms

- ✅ Android 6.0+
- ✅ iOS 11.0+
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🏗️ Project Architecture

**Clean Architecture Pattern** with:

- **Models**: Type-safe Table and Order models with serialization
- **Services**: Business logic layer (Auth, SQLite Database)
- **Providers**: State management using Provider pattern for Tables and Orders
- **Screens**: UI layer with proper separation
- **Widgets**: Reusable component library
- **Utils**: Helper functions, validators, formatters

## 📲 Quick Start

### Prerequisites

- Flutter SDK v3.11.4+
- Dart SDK (included)
- Firebase Project (for authentication only)
- Android Studio / Xcode (for mobile)

### Installation

1. Clone repository:

```bash
git clone https://github.com/yourusername/hotel_management.git
cd finance_app
```

2. Install dependencies:

```bash
flutter pub get
```

3. Configure Firebase (for authentication):

- Follow FIREBASE_SETUP.md for setup instructions

4. Run the app:

```bash
flutter run -d android  # Android
flutter run -d ios      # iOS
flutter run -d windows  # Windows
```

## 🗄️ Database Schema

### SQLite Tables

- `users/{userId}` - User profiles (Firebase UID)
- `hotel_tables/{tableId}` - Individual table records
- `table_orders/{orderId}` - Orders for each table

Tables include:

- tableNumber: Unique identifier per table
- isOpen: Status (open/closed)
- totalAmount: Final amount including tax
- taxAmount: Calculated tax (5%)
- subtotal: Total before tax
- orders: List of items ordered
- createdAt: When table was created
- closedAt: When table was closed (if applicable)

Orders include:

- itemName: Name of the item
- itemPrice: Price per unit
- quantity: Number of units
- totalPrice: itemPrice × quantity
- notes: Special instructions (optional)
- addedAt: When order was added

## 🎨 Screens

| Screen        | Purpose                          |
| ------------- | -------------------------------- |
| Splash        | Animated app initialization      |
| Login         | Email/password authentication    |
| Sign Up       | New account creation             |
| Dashboard     | Main hub with open/closed tables |
| Table Details | View all orders for a table      |
| Add Order     | Form to add new items to a table |
| Profile       | User information and settings    |

## 🔒 Security

- Firebase Authentication for user login
- SQLite local database for data persistence
- User-scoped data access only
- Form validation
- No sensitive data in logs

## 📦 Tech Stack

| Layer     | Technology                    |
| --------- | ----------------------------- |
| Frontend  | Flutter 3.11.4, Material 3    |
| State     | Provider 6.2.0                |
| Auth      | Firebase Authentication       |
| Database  | SQLite (Local)                |
| Utilities | intl, uuid, connectivity_plus |

## 🧪 Testing

Manual testing checklist:

- [ ] App launches successfully
- [ ] Can sign up and login
- [ ] Can create new tables
- [ ] Can add orders to tables
- [ ] Calculations (subtotal, tax, total) are correct
- [ ] Can update order quantities
- [ ] Can close and reopen tables
- [ ] Can delete tables
- [ ] Grand total updates correctly
- [ ] Dark mode works
- [ ] All navigation works
- [ ] Error messages display properly

## 🚀 Performance

- Real-time SQLite operations
- Efficient state management with Provider
- Lazy loading of table data
- Optimized widget rebuilds
- No unnecessary database queries

## 📄 Documentation

- **FIREBASE_SETUP.md** - Complete Firebase authentication setup
- **SQLITE_IMPLEMENTATION.md** - Database schema and operations
- **Code comments** - Inline documentation for complex logic
- **README.md** - This file

## 🎓 Learning Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Material 3 Design](https://m3.material.io/)
- [Provider Pattern](https://pub.dev/packages/provider)

## 🐛 Troubleshooting

**App won't start?**
→ Run `flutter clean && flutter pub get && flutter run --no-fast-start`

**Database errors?**
→ Check SQLite initialization in main.dart and ensure permission is granted

**Build errors?**

```bash
flutter doctor -v
flutter clean
flutter pub get
```

## 📊 Project Stats

```
Total Files: 30+
Lines of Code: 2500+
Tables: Unlimited
Orders per table: Unlimited
Platforms: 4
Features: 15+
```

## ✨ Highlights

🎨 Beautiful Material 3 UI  
🔐 Secure Firebase authentication  
💰 Real-time billing calculations  
🌙 Dark mode support  
⚡ High performance  
📱 Cross-platform  
💾 Local data persistence  
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

### Windows

```bash
flutter build windows --release
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

Provided as-is for educational and commercial use.

---

**Happy Managing! 🍽️**

For complete Firebase setup instructions, see **FIREBASE_SETUP.md**

## Change Log

### Version 1.1.0 (Hotel Management)

- Converted from finance tracking to table order management
- Added table management system
- Implemented real-time order tracking per table
- Added automatic tax and cost calculations
- Replaced expense tracking with hotel management features
- Kept Firebase authentication and SQLite persistence
- Maintained clean architecture and Material 3 design

### Version 1.0.0 (Finance Tracker)

- Initial project setup for personal finance management
