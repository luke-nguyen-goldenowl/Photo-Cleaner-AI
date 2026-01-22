import 'package:flutter/material.dart';
import 'package:myapp/src/localization/localization_utils.dart';

class AppConstants {
  static List<Map<String, dynamic>> getOnboardingData(BuildContext context) => [
        {
          "title": S.of(context).common_onBoarding_1_Title,
          "subtitle": S.of(context).common_onBoarding_1_subTitle,
          "icon": Icons.cleaning_services_outlined,
        },
        {
          "title": S.of(context).common_onBoarding_2_Title,
          "subtitle": S.of(context).common_onBoarding_2_subTitle,
          "icon": Icons.auto_fix_high,
        },
        {
          "title": S.of(context).common_onBoarding_3_Title,
          "subtitle": S.of(context).common_onBoarding_3_subTitle,
          "icon": Icons.lock_person_outlined,
        },
      ];

  static String avatarLink = 'https://api.dicebear.com/9.x/fun-emoji/png?seed=';
  static const int pageSize = 100;
  static const urlTemplate =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
  static const userAgentPackageName = 'com.yourcompany.photo_map_app';
  static const subdomains = ['a', 'b', 'c', 'd'];
  static const String securePhotoBucket = 'secure_photo';
  static const String favoritePhotoBucket = 'favorite-images';
}
