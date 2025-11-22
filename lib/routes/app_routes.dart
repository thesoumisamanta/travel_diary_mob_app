import 'package:flutter/material.dart';
import 'package:travel_diary_mob_app/presentation/screens/auth/login_screen.dart';
import 'package:travel_diary_mob_app/presentation/screens/home/home_screen.dart';
import 'package:travel_diary_mob_app/presentation/screens/profile/edit_profile_screen.dart';
import 'package:travel_diary_mob_app/presentation/screens/profile/profile_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String main = '/home';
  static const String forgotPassword = '/forgot-password';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case main:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case forgotPassword:
        // Add your ForgotPasswordScreen here
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Forgot Password - Coming Soon")),
          ),
          settings: settings,
        );

      case profile:
        // Handle profile with arguments
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(
            userId: args?['userId'],
            username: args?['username'],
            isCurrentUser: args?['isCurrentUser'] ?? false,
          ),
          settings: settings,
        );

        case editProfile:
          return MaterialPageRoute(
            builder: (_) => const EditProfileScreen(),
            settings: settings,
          );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "Route '${settings.name}' not found",
                    style: const TextStyle(fontSize: 16),
                  ),
                  
                ],
              ),
            ),
          ),
          settings: settings,
        );
    }
  }
}
