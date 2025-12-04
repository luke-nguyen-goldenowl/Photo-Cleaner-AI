// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_appTitle => 'Pixel Perfect';

  @override
  String common_appVersion(String value) {
    return 'Version $value';
  }

  @override
  String get common_appDescription => 'Photo gallery and smart cleaner';

  @override
  String get common_buttonSkip => 'Skip';

  @override
  String get common_onBoarding_1_Title => 'Smart photo cleanup';

  @override
  String get common_onBoarding_1_subTitle =>
      'Automatically group and remove your duplicate photos in seconds';

  @override
  String get common_onBoarding_2_Title => 'AI Quality Upgrade';

  @override
  String get common_onBoarding_2_subTitle =>
      'Transform old, blurry photos into sharp and vibrant images with AI technology';

  @override
  String get common_onBoarding_3_Title => 'Secure your photos';

  @override
  String get common_onBoarding_3_subTitle =>
      'Store your private moments with absolute safety using high-level encryption and smart management';

  @override
  String get common_buttonDiscover => 'Discover Now';

  @override
  String get common_buttonContinue => 'Continue';

  @override
  String get common_getStarted_Title => 'Welcome to Pixel Perfect';

  @override
  String get common_getStarted_subTitle =>
      'Optimize your image library with the power of artificial intelligence';

  @override
  String get common_buttonStarted => 'Start';

  @override
  String get common_subTitle_Signin => 'Log in to manage your image library';

  @override
  String get common_emailTitle => 'Email';

  @override
  String get common_passwordTitle => 'Password';

  @override
  String get common_buttonSignin_Title => 'Sign In';

  @override
  String get common_forgotPass_Title => 'Forgot Password?';

  @override
  String get common_Or_Title => 'or';

  @override
  String get sign_signin_signinWithGoogle => 'Sign in with Google';

  @override
  String get sign_signin_signinWithApple => 'Sign in with Apple';

  @override
  String get sign_signin_signinWithFacebook => 'Sign in with Facebook';

  @override
  String get common_dontHaveAccount_title => 'Don\'t have an account?';

  @override
  String get common_SignupNow_title => 'Sign up now';

  @override
  String get common_signUp_subTitle =>
      'Create an account to join the Pixel Perfect community to optimize your image library';

  @override
  String get common_userName_signUp => 'Username';

  @override
  String get common_confirmPass_signUp => 'Confirm password';

  @override
  String get common_buttonSignUp_title => 'Sign Up';

  @override
  String get common_haveAccount_title => 'Have an account?';

  @override
  String get common_signIn_title => 'Sign in';

  @override
  String get common_tab_photo => 'Photo';

  @override
  String get common_tab_clean => 'Cleaner';

  @override
  String get common_tab_friend => 'Friends';

  @override
  String get common_tab_place => 'Place';

  @override
  String get common_tab_profile => 'Profile';

  @override
  String get common_logout_title => 'Sign out';

  @override
  String get common_confirmLogout_title => 'Are you sure you want to log out?';

  @override
  String get common_agreeButton_title => 'Confirm';

  @override
  String get common_cancelButton_title => 'Cancel';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_close => 'Close';

  @override
  String get common_next => 'Next';

  @override
  String get common_list_empty_title => 'List empty!';

  @override
  String get common_tap_to_refresh => 'Tap to refresh';

  @override
  String get error_somethingWrongTryAgain =>
      'Something went wrong, try again...';

  @override
  String get error_login => 'Sign in Failed';

  @override
  String get error_signUp => 'Sign up Failed';

  @override
  String get error_fieldRequired => 'This field is required';

  @override
  String get error_invalidEmail => 'Invalid email ';

  @override
  String get error_invalidPassword =>
      'Invalid password! Requires at least 6 characters';

  @override
  String get error_confirmPasswordMismatch =>
      'Password confirmation does not match';

  @override
  String get success_login => 'Login success';

  @override
  String get success_signUp =>
      'Sign up success! Please check email box to confirm your email';
}
