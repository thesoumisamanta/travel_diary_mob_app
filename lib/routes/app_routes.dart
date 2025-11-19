import 'package:flutter/material.dart';
import 'package:travel_diary_mob_app/presentation/screens/auth/login_screen.dart';
import 'package:travel_diary_mob_app/presentation/screens/home/home_screen.dart';


class AppRoutes {
  static const String login = '/login';
  static const String main = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case main:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Route not found")),
          ),
        );
    }
  }
}
