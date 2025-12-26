import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/features/account/profile/view/profile_edit_view.dart';
import 'package:myapp/src/features/account/profile/view/profile_view.dart';
import 'package:myapp/src/features/common/view/not_found_view.dart';
import 'package:myapp/src/features/authentication/view/forgot_view.dart';
import 'package:myapp/src/features/authentication/view/signin_view.dart';
import 'package:myapp/src/features/authentication/view/signup_view.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/cleaner_view.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/enhance_image/logic/enhance_image_bloc.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/enhance_image/view/pick_image_view.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/enhance_image/view/result_view.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/make_video/view/result_view.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/make_video/view/select_audio_view.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/make_video/view/select_mutilple_image_view.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/remove_bg/view/result_view.dart';
import 'package:myapp/src/features/dashboard/cleaner/view/remove_bg/view/select_image_view.dart';
import 'package:myapp/src/features/dashboard/friend/view/friend_view.dart';
import 'package:myapp/src/features/dashboard/logic/navigation_bar_item.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/features/dashboard/photo/view/photo_detail_view.dart';
import 'package:myapp/src/features/dashboard/photo/view/photo_view.dart';
import 'package:myapp/src/features/dashboard/place/view/place_view.dart';
import 'package:myapp/src/features/dashboard/view/dashboard_view.dart';
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
      ShellRoute(
        navigatorKey: AppCoordinator.shellKey,
        builder: (context, state, child) => DashBoardScreen(
          currentItem: XNavigationBarItems.fromLocation(state.uri.toString()),
          body: child,
        ),
        routes: <RouteBase>[
          GoRoute(
            path: AppRouteNames.photo.path,
            name: AppRouteNames.photo.name,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PhotoView(),
            ),
            routes: <RouteBase>[
              GoRoute(
                  parentNavigatorKey: AppCoordinator.navigatorKey,
                  path: AppRouteNames.photoDetail.subPath,
                  name: AppRouteNames.photoDetail.name,
                  builder: (context, state) {
                    final extra = state.extra as Map<String, dynamic>;
                    final photos = extra['photos'] as List<MPhotoItem>;
                    final initialIndex = extra['initialIndex'];
                    return PhotoDetailView(
                      photos: photos,
                      initialIndex: initialIndex,
                    );
                  }
                  //builder: (_, __) => const PhotoDetailView(),
                  ),
            ],
          ),
          GoRoute(
            path: AppRouteNames.cleaner.path,
            name: AppRouteNames.cleaner.name,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CleanerView(),
            ),
            routes: <RouteBase>[
              GoRoute(
                parentNavigatorKey: AppCoordinator.navigatorKey,
                path: AppRouteNames.selectImage.subPath,
                name: AppRouteNames.selectImage.name,
                builder: (_, __) => const SelectImageView(),
              ),
              GoRoute(
                parentNavigatorKey: AppCoordinator.navigatorKey,
                path: AppRouteNames.resultRemoveBg.subPath,
                name: AppRouteNames.resultRemoveBg.name,
                builder: (context, state) {
                  final imageData = state.extra as Uint8List?;
                  if (imageData == null) {
                    return const NotFoundView();
                  }
                  return ResultView(imageData: imageData);
                },
              ),
              GoRoute(
                parentNavigatorKey: AppCoordinator.navigatorKey,
                path: AppRouteNames.selectMutipleImage.subPath,
                name: AppRouteNames.selectMutipleImage.name,
                builder: (_, __) => const SelectMutilpleImageView(),
              ),
              GoRoute(
                parentNavigatorKey: AppCoordinator.navigatorKey,
                path: AppRouteNames.selectAudio.subPath,
                name: AppRouteNames.selectAudio.name,
                builder: (_, __) {
                  return const SelectAudioView();
                },
              ),
              GoRoute(
                parentNavigatorKey: AppCoordinator.navigatorKey,
                path: AppRouteNames.resultVideo.subPath,
                name: AppRouteNames.resultVideo.name,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  if (extra == null) {
                    return const NotFoundView();
                  }
                  final videoPath = extra['videoPath'] as String?;

                  if (videoPath == null) {
                    return const NotFoundView();
                  }
                  return ResultVideoView(videoPath: videoPath);
                },
              ),
              GoRoute(
                parentNavigatorKey: AppCoordinator.navigatorKey,
                path: AppRouteNames.pickImageEnhance.subPath,
                name: AppRouteNames.pickImageEnhance.name,
                builder: (_, __) => const PickImageView(),
              ),
              GoRoute(
                parentNavigatorKey: AppCoordinator.navigatorKey,
                path: AppRouteNames.resultEnhanceImage.subPath,
                name: AppRouteNames.resultEnhanceImage.name,
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  if (extra == null) {
                    return const NotFoundView();
                  }
                  final originalImage = extra['original'] as Uint8List?;
                  final enhancedImage = extra['enhanced'] as Uint8List?;
                  if (originalImage == null || enhancedImage == null) {
                    return const NotFoundView();
                  }
                  return EnhanceResultView(
                    originalImage: originalImage,
                    enhancedImage: enhancedImage,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRouteNames.friend.path,
            name: AppRouteNames.friend.name,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FriendView(),
            ),
          ),
          GoRoute(
            path: AppRouteNames.places.path,
            name: AppRouteNames.places.name,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PlacesView(),
            ),
          ),
          GoRoute(
            path: AppRouteNames.profile.path,
            name: AppRouteNames.profile.name,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileView(),
            ),
            routes: <RouteBase>[
              GoRoute(
                parentNavigatorKey: AppCoordinator.navigatorKey,
                path: AppRouteNames.profileEdit.subPath,
                name: AppRouteNames.profileEdit.name,
                builder: (_, __) => const ProfileEditView(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (_, __) => const NotFoundView(),
  );
}
