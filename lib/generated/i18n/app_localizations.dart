import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i18n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @common_appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pixel Perfect'**
  String get common_appTitle;

  /// Version number of app
  ///
  /// In en, this message translates to:
  /// **'Version {value}'**
  String common_appVersion(String value);

  /// No description provided for @common_appDescription.
  ///
  /// In en, this message translates to:
  /// **'Photo gallery and smart cleaner'**
  String get common_appDescription;

  /// No description provided for @common_buttonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get common_buttonSkip;

  /// No description provided for @common_onBoarding_1_Title.
  ///
  /// In en, this message translates to:
  /// **'Smart photo cleanup'**
  String get common_onBoarding_1_Title;

  /// No description provided for @common_onBoarding_1_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically group and remove your duplicate photos in seconds'**
  String get common_onBoarding_1_subTitle;

  /// No description provided for @common_onBoarding_2_Title.
  ///
  /// In en, this message translates to:
  /// **'AI Quality Upgrade'**
  String get common_onBoarding_2_Title;

  /// No description provided for @common_onBoarding_2_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Transform old, blurry photos into sharp and vibrant images with AI technology'**
  String get common_onBoarding_2_subTitle;

  /// No description provided for @common_onBoarding_3_Title.
  ///
  /// In en, this message translates to:
  /// **'Secure your photos'**
  String get common_onBoarding_3_Title;

  /// No description provided for @common_onBoarding_3_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Store your private moments with absolute safety using high-level encryption and smart management'**
  String get common_onBoarding_3_subTitle;

  /// No description provided for @common_buttonDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover Now'**
  String get common_buttonDiscover;

  /// No description provided for @common_buttonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_buttonContinue;

  /// No description provided for @common_getStarted_Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Pixel Perfect'**
  String get common_getStarted_Title;

  /// No description provided for @common_getStarted_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Optimize your image library with the power of artificial intelligence'**
  String get common_getStarted_subTitle;

  /// No description provided for @common_buttonStarted.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get common_buttonStarted;

  /// No description provided for @common_subTitle_Signin.
  ///
  /// In en, this message translates to:
  /// **'Log in to manage your image library'**
  String get common_subTitle_Signin;

  /// No description provided for @common_emailTitle.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get common_emailTitle;

  /// No description provided for @common_passwordTitle.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get common_passwordTitle;

  /// No description provided for @common_buttonSignin_Title.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get common_buttonSignin_Title;

  /// No description provided for @common_forgotPass_Title.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get common_forgotPass_Title;

  /// No description provided for @common_Or_Title.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get common_Or_Title;

  /// No description provided for @sign_signin_signinWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get sign_signin_signinWithGoogle;

  /// No description provided for @sign_signin_signinWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get sign_signin_signinWithApple;

  /// No description provided for @sign_signin_signinWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Facebook'**
  String get sign_signin_signinWithFacebook;

  /// No description provided for @common_dontHaveAccount_title.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get common_dontHaveAccount_title;

  /// No description provided for @common_SignupNow_title.
  ///
  /// In en, this message translates to:
  /// **'Sign up now'**
  String get common_SignupNow_title;

  /// No description provided for @common_signUp_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to join the Pixel Perfect community to optimize your image library'**
  String get common_signUp_subTitle;

  /// No description provided for @common_userName_signUp.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get common_userName_signUp;

  /// No description provided for @common_confirmPass_signUp.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get common_confirmPass_signUp;

  /// No description provided for @common_buttonSignUp_title.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get common_buttonSignUp_title;

  /// No description provided for @common_haveAccount_title.
  ///
  /// In en, this message translates to:
  /// **'Have an account?'**
  String get common_haveAccount_title;

  /// No description provided for @common_signIn_title.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get common_signIn_title;

  /// No description provided for @common_tab_photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get common_tab_photo;

  /// No description provided for @common_tab_clean.
  ///
  /// In en, this message translates to:
  /// **'Cleaner'**
  String get common_tab_clean;

  /// No description provided for @common_tab_friend.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get common_tab_friend;

  /// No description provided for @common_tab_place.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get common_tab_place;

  /// No description provided for @common_tab_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get common_tab_profile;

  /// No description provided for @common_logout_title.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get common_logout_title;

  /// No description provided for @common_confirmLogout_title.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get common_confirmLogout_title;

  /// No description provided for @common_agreeButton_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_agreeButton_title;

  /// No description provided for @common_cancelButton_title.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancelButton_title;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_list_empty_title.
  ///
  /// In en, this message translates to:
  /// **'List empty!'**
  String get common_list_empty_title;

  /// No description provided for @common_tap_to_refresh.
  ///
  /// In en, this message translates to:
  /// **'Tap to refresh'**
  String get common_tap_to_refresh;

  /// No description provided for @error_somethingWrongTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong, try again...'**
  String get error_somethingWrongTryAgain;

  /// No description provided for @error_login.
  ///
  /// In en, this message translates to:
  /// **'Sign in Failed'**
  String get error_login;

  /// No description provided for @error_signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up Failed'**
  String get error_signUp;

  /// No description provided for @error_fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get error_fieldRequired;

  /// No description provided for @error_invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email '**
  String get error_invalidEmail;

  /// No description provided for @error_invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid password! Requires at least 6 characters'**
  String get error_invalidPassword;

  /// No description provided for @error_confirmPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation does not match'**
  String get error_confirmPasswordMismatch;

  /// No description provided for @success_login.
  ///
  /// In en, this message translates to:
  /// **'Login success'**
  String get success_login;

  /// No description provided for @success_signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up success! Please check email box to confirm your email'**
  String get success_signUp;

  /// No description provided for @common_forgotPass_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry! Enter your email below and we will send an OTP to restore.'**
  String get common_forgotPass_subTitle;

  /// No description provided for @common_hinTextEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter Email address'**
  String get common_hinTextEmail;

  /// No description provided for @common_button_senOTP.
  ///
  /// In en, this message translates to:
  /// **'Send OTP code'**
  String get common_button_senOTP;

  /// No description provided for @common_button_gobackLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get common_button_gobackLogin;

  /// No description provided for @common_sendOTP_Title.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP code'**
  String get common_sendOTP_Title;

  /// No description provided for @common_sendOTP_subTitle.
  ///
  /// In en, this message translates to:
  /// **'We have sent a 6-digit code to your email. Please check your mailbox.'**
  String get common_sendOTP_subTitle;

  /// No description provided for @common_hintTextOTP.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP code (6 digits)'**
  String get common_hintTextOTP;

  /// No description provided for @common_button_verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get common_button_verify;

  /// No description provided for @common_sendOTPAgain_s.
  ///
  /// In en, this message translates to:
  /// **'Resend code after'**
  String get common_sendOTPAgain_s;

  /// No description provided for @common_sendOTPAgain.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP code'**
  String get common_sendOTPAgain;

  /// No description provided for @common_recoverPass_title.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get common_recoverPass_title;

  /// No description provided for @common_recoverPass_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password to complete the recovery process.'**
  String get common_recoverPass_subTitle;

  /// No description provided for @common_newPass_hintText.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get common_newPass_hintText;

  /// No description provided for @common_confirmNewPass_hintText.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get common_confirmNewPass_hintText;

  /// No description provided for @success_sendOTP.
  ///
  /// In en, this message translates to:
  /// **'OTP code has been sent to'**
  String get success_sendOTP;

  /// No description provided for @success_verifyOTP.
  ///
  /// In en, this message translates to:
  /// **'Verified successfully!'**
  String get success_verifyOTP;

  /// No description provided for @success_resetPass_noti_Title.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success_resetPass_noti_Title;

  /// No description provided for @success_resetPass_noti_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Password has been updated successfully! Please log in again.'**
  String get success_resetPass_noti_subTitle;

  /// No description provided for @error_sendOTP.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP'**
  String get error_sendOTP;

  /// No description provided for @error_verifyOTP.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get error_verifyOTP;

  /// No description provided for @error_OTP_invalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code'**
  String get error_OTP_invalid;

  /// No description provided for @error_resetPass.
  ///
  /// In en, this message translates to:
  /// **'Password change failed'**
  String get error_resetPass;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
