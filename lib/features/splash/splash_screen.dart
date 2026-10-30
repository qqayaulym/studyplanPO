import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../auth/data/auth_service.dart';

/// Splash Screen: логотип, атау, ұран және жүктеу жолағы. 2 секундтан кейін Onboarding ашылады.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      // Сессия сақталған болса — тікелей басты бетке (деректер қайта іске қосқанда да сақталады)
      final next = AuthService.instance.isLoggedIn
          ? AppRoutes.home
          : AppRoutes.onboarding;
      Navigator.of(context).pushReplacementNamed(next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.event_available,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                AppStrings.tagline,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 56),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: const LinearProgressIndicator(
                    minHeight: 4,
                    color: AppColors.accent,
                    backgroundColor: Color(0x40FFFFFF),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
