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
}
