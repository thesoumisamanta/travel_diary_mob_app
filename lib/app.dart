import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_diary_mob_app/business_logic/auth_bloc/auth_bloc.dart';
import 'package:travel_diary_mob_app/business_logic/auth_bloc/auth_event.dart';
import 'package:travel_diary_mob_app/business_logic/auth_bloc/auth_state.dart';
import 'package:travel_diary_mob_app/core/theme/app_theme.dart';
import 'package:travel_diary_mob_app/presentation/screens/auth/login_screen.dart';
import 'package:travel_diary_mob_app/presentation/screens/home/home_screen.dart';
import 'package:travel_diary_mob_app/presentation/widgets/loading_widget.dart';
import 'package:travel_diary_mob_app/routes/app_routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger check
    context.read<AuthBloc>().add(AuthCheckRequested());

    return MaterialApp(
      title: 'Travel Diary',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      onGenerateRoute: AppRoutes.generateRoute,
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(body: Center(child: LoadingWidget()));
          } else if (state is AuthAuthenticated) {
            return const HomeScreen();
          } else if (state is AuthUnauthenticated) {
            return const LoginScreen();
          } else {
            return const Scaffold(body: Center(child: LoadingWidget()));
          }
        },
      ),
    );
  }
}

