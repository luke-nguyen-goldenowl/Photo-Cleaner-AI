import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/router/route_name.dart';
import 'package:myapp/src/router/router.dart';

class AppCoordinator {
  static AppRouter get rootRouter => GetIt.I<AppRouter>();
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final shellKey = GlobalKey<NavigatorState>();
  static BuildContext get context => navigatorKey.currentState!.context;

  static void pop<T extends Object?>([T? result]) => context.pop(result);

  static void goNamed(
    String name, {
    Map<String, String> params = const <String, String>{},
    Map<String, dynamic> queryParams = const <String, dynamic>{},
    Object? extra,
  }) =>
      context.goNamed(
        name,
        pathParameters: params,
        queryParameters: queryParams,
        extra: extra,
      );

  static void showHomeScreen() => context.goNamed(AppRouteNames.photo.name);

  static void showPhotoDetailScreen({
    required List<MPhotoItem> photos,
    required int initialIndex,
  }) {
    context.pushNamed(
      AppRouteNames.photoDetail.name,
      extra: {
        'photos': photos,
        'initialIndex': initialIndex,
      },
    );
  }

  static void showOnboardingScreen() =>
      context.goNamed(AppRouteNames.onBoarding.name);

  static void showGettingStartedScreen() =>
      context.goNamed(AppRouteNames.gettingStarted.name);

  static void showAccountScreen() =>
      context.goNamed(AppRouteNames.account.name);

  static Future<T?> showSignInScreen<T extends Object?>() =>
      context.pushNamed<T>(AppRouteNames.signIn.name);

  static Future<T?> showSignUpScreen<T extends Object?>() =>
      context.pushNamed<T>(AppRouteNames.signUp.name);

  static Future<T?> showForgotPasswordScreen<T extends Object?>() =>
      context.pushNamed<T>(AppRouteNames.forgotPassword.name);

  static Future<T?> showSampleScreen<T extends Object?>() =>
      context.pushNamed<T>(AppRouteNames.sample.name);

  static Future<T?> showSampleDetails<T extends Object?>(
          {required String id}) =>
      context.pushNamed<T>(
        AppRouteNames.sampleDetails.name,
        pathParameters: {AppRouteNames.sampleDetails.paramName!: id},
      );

  static Future<T?> showProfile<T extends Object?>() =>
      context.pushNamed<T>(AppRouteNames.profile.name);

  static Future<T?> showSelectImage<T extends Object?>() =>
      context.pushNamed<T>(AppRouteNames.selectImage.name);

  static Future<T?> showSelectMultipleImage<T extends Object?>() =>
      context.pushNamed<T>(AppRouteNames.selectMutipleImage.name);

  static Future<T?> showResultRemoveBg<T extends Object?>(
          {required Uint8List imageData}) =>
      context.pushNamed<T>(
        AppRouteNames.resultRemoveBg.name,
        extra: imageData,
      );

  static Future<T?> showSelectAudioView<T extends Object?>({
    required dynamic bloc,
  }) =>
      context.pushNamed<T>(
        AppRouteNames.selectAudio.name,
        extra: bloc,
      );

  static Future<T?> showResultVideo<T extends Object?>({
    required String videoPath,
    required dynamic bloc,
  }) =>
      context.pushNamed<T>(
        AppRouteNames.resultVideo.name,
        extra: {'videoPath': videoPath, 'bloc': bloc},
      );

  static Future<T?> showPickImageEnhance<T extends Object?>(
          {File? initialImage}) =>
      context.pushNamed<T>(
        AppRouteNames.pickImageEnhance.name,
        extra: initialImage,
      );

  static Future<T?> showResultEnhanceImage<T extends Object?>({
    required Uint8List originalImage,
    required Uint8List enhancedImage,
  }) =>
      context.pushNamed<T>(
        AppRouteNames.resultEnhanceImage.name,
        extra: {'original': originalImage, 'enhanced': enhancedImage},
      );

  static Future<T?> showScanDevice<T extends Object?>() =>
      context.pushNamed<T>(AppRouteNames.scanDevice.name);

  static Future<T?> showDuplicateResults<T extends Object?>() =>
      context.pushNamed<T>(
        AppRouteNames.duplicateImageResults.name,
      );
}
