import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/features/common/view/not_found_view.dart';
import 'package:myapp/src/features/authentication/view/forgot_view.dart';
import 'package:myapp/src/features/authentication/view/signin_view.dart';
import 'package:myapp/src/features/authentication/view/signup_view.dart';
import 'package:myapp/src/features/onboarding/view/on_boarding_view.dart';
import 'package:myapp/src/features/getting_started/view/getting_started_view.dart';
import 'package:myapp/src/features/splash/view/splash_view.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/src/router/route_name.dart';

class AppRouter {
  late final router = GoRouter(
    navigatorKey: AppCoordinator.navigatorKey,
    initialLocation: AppRouteNames.splash.path,
    debugLogDiagnostics: kDebugMode,
    observers: [BotToastNavigatorObserver()],
    routes: <RouteBase>[
      GoRoute(
        parentNavigatorKey: AppCoordinator.navigatorKey,
        path: AppRouteNames.splash.path,
        name: AppRouteNames.splash.name,
        builder: (_, __) => const SplashView(),
      ),
      GoRoute(
        parentNavigatorKey: AppCoordinator.navigatorKey,
        path: AppRouteNames.onBoarding.path,
        name: AppRouteNames.onBoarding.name,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        parentNavigatorKey: AppCoordinator.navigatorKey,
        path: AppRouteNames.gettingStarted.path,
        name: AppRouteNames.gettingStarted.name,
        builder: (_, __) => const GettingStartedScreen(),
      ),
      GoRoute(
        parentNavigatorKey: AppCoordinator.navigatorKey,
        path: AppRouteNames.signIn.path,
        name: AppRouteNames.signIn.name,
        builder: (_, __) => const SigninView(),
      ),
      GoRoute(
        parentNavigatorKey: AppCoordinator.navigatorKey,
        path: AppRouteNames.signUp.path,
        name: AppRouteNames.signUp.name,
        builder: (_, __) => const SignupView(),
      ),
      GoRoute(
        parentNavigatorKey: AppCoordinator.navigatorKey,
        path: AppRouteNames.forgotPassword.path,
        name: AppRouteNames.forgotPassword.name,
        builder: (_, __) => const ForgotPasswordView(),
      ),
    ],
    errorBuilder: (_, __) => const NotFoundView(),
  );
}
