import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../providers/expense_provider.dart';
import '../home/dashboard_screen.dart';
import '../auth/login_screen.dart';
import '../splash/splash_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        // User not logged in - clear all data
        if (!snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<ExpenseProvider>().clearData();
            context.read<UserProvider>().clearData();
          });
          return const LoginScreen();
        }

        // Load user profile after login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<UserProvider>().loadUserProfile();
        });

        // User logged in
        return const DashboardScreen();
      },
    );
  }
}