import 'package:flutter/material.dart';
import 'package:myapp/src/services/session_manager.dart';
import 'package:myapp/src/services/user_prefs.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/src/router/route_name.dart';
import 'package:get_it/get_it.dart';
import 'package:myapp/src/features/account/logic/account_bloc.dart';
import 'package:myapp/widgets/logo/app_logo.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    final hasSeenOnboarding = UserPrefs.I.hasSeenOnboarding();
    if (!hasSeenOnboarding) {
      if (mounted) {
        AppCoordinator.goNamed(AppRouteNames.onBoarding.name);
      }
      return;
    }

    final user = await SessionManager.restoreSession();

    if (user != null) {
      GetIt.I<AccountBloc>().onLoginSuccess(user);
      if (mounted) {
        AppCoordinator.showHomeScreen();
      }
    } else {
      if (mounted) {
        AppCoordinator.showSignInScreen();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const XAppLogo(),
            const SizedBox(height: 30),
            const Text(
              'Pixel Perfect',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF091031),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Thư viện ảnh và trình dọn dẹp thông minh',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
            ),
          ],
        ),
      ),
    );
  }
}
