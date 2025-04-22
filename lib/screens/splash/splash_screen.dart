import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 2000,
      splash: Hero(
        tag: 'app_logo',
        child: Image.asset('assets/logo/logo.png', width: 200, height: 200),
      ),
      nextScreen:
          context.watch<AuthService>().isAuthenticated
              ? const HomeScreen()
              : const LoginScreen(),
      splashTransition: SplashTransition.scaleTransition,
      backgroundColor: Theme.of(context).colorScheme.background,
      centered: true,
    );
  }
}
