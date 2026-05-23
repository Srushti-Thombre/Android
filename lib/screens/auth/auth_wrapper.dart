import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart' as app;
import '../../providers/user_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/income_provider.dart';
import '../home/dashboard_screen.dart';
import '../auth/login_screen.dart';
import '../splash/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<app.AuthProvider>(
      builder: (context, authProvider, _) => StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),

        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting || authProvider.isLoading) {
            return const SplashScreen();
          }

          final firebaseUser = snapshot.data;

          // User not logged in - clear all data
          if (firebaseUser == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<ExpenseProvider>().clearData();
              context.read<IncomeProvider>().clearData();
              context.read<UserProvider>().clearData();
            });
            return const LoginScreen();
          }

          // Sync AuthProvider with Firebase user before showing dashboard.
          if (authProvider.currentUser?.uid != firebaseUser.uid) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<app.AuthProvider>().checkAuthState();
            });
            return const SplashScreen();
          }

          // Load user profile after login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<UserProvider>().loadUserProfile();
          });

          // User logged in
          return const DashboardScreen();
        },
      ),
    );
  }
}