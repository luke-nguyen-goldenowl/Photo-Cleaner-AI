import 'package:flutter/material.dart';
import 'package:myapp/generated/i18n/app_localizations.dart';

class AppConstants {
  static List<Map<String, dynamic>> getOnboardingData(BuildContext context) => [
        {
          "title": AppLocalizations.of(context)!.common_onBoarding_1_Title,
          "subtitle":
              AppLocalizations.of(context)!.common_onBoarding_1_subTitle,
          "icon": Icons.cleaning_services_outlined,
        },
        {
          "title": AppLocalizations.of(context)!.common_onBoarding_2_Title,
          "subtitle":
              AppLocalizations.of(context)!.common_onBoarding_2_subTitle,
          "icon": Icons.auto_fix_high,
        },
        {
          "title": AppLocalizations.of(context)!.common_onBoarding_3_Title,
          "subtitle":
              AppLocalizations.of(context)!.common_onBoarding_3_subTitle,
          "icon": Icons.lock_person_outlined,
        },
      ];
}
