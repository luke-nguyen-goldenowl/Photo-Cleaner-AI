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
  /// **'SnapLife'**
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
  /// **'Welcome to SnapLife'**
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
  /// **'Create an account to join the SnapLife community to optimize your image library'**
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

  /// No description provided for @common_delete_title_alert.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get common_delete_title_alert;

  /// No description provided for @common_delete_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this photo?'**
  String get common_delete_confirm_title;

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
  /// **'Sign in failed'**
  String get error_login;

  /// No description provided for @error_signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed'**
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

  /// No description provided for @error_email_have_been_used.
  ///
  /// In en, this message translates to:
  /// **'Email is already in use'**
  String get error_email_have_been_used;

  /// No description provided for @error_email_not_confirm.
  ///
  /// In en, this message translates to:
  /// **'Email has not been verified. Please check your mailbox'**
  String get error_email_not_confirm;

  /// No description provided for @error_email_or_password_invalid.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect'**
  String get error_email_or_password_invalid;

  /// No description provided for @error_otp_expired.
  ///
  /// In en, this message translates to:
  /// **'OTP code has expired. Please request a new code'**
  String get error_otp_expired;

  /// No description provided for @error_same_password.
  ///
  /// In en, this message translates to:
  /// **'The new password must be different from the current password'**
  String get error_same_password;

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

  /// No description provided for @common_photo_tab_title.
  ///
  /// In en, this message translates to:
  /// **'My Gallery'**
  String get common_photo_tab_title;

  /// No description provided for @common_offline_mode.
  ///
  /// In en, this message translates to:
  /// **'You are in offline mode'**
  String get common_offline_mode;

  /// No description provided for @common_online_mode.
  ///
  /// In en, this message translates to:
  /// **'Connected to the network'**
  String get common_online_mode;

  /// No description provided for @common_all_chip_title.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get common_all_chip_title;

  /// No description provided for @common_favourite_chip_title.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get common_favourite_chip_title;

  /// No description provided for @common_image_count_title.
  ///
  /// In en, this message translates to:
  /// **'image'**
  String get common_image_count_title;

  /// No description provided for @common_floating_button_text.
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get common_floating_button_text;

  /// No description provided for @common_like_button_text.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get common_like_button_text;

  /// No description provided for @common_secure_button_text.
  ///
  /// In en, this message translates to:
  /// **'Secure'**
  String get common_secure_button_text;

  /// No description provided for @common_enhance_button_text.
  ///
  /// In en, this message translates to:
  /// **'Enhance'**
  String get common_enhance_button_text;

  /// No description provided for @common_share_button_text.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get common_share_button_text;

  /// No description provided for @common_save_button_text.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save_button_text;

  /// No description provided for @common_delete_button_text.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete_button_text;

  /// No description provided for @common_text_share.
  ///
  /// In en, this message translates to:
  /// **'Share from SnapLife'**
  String get common_text_share;

  /// No description provided for @common_image_not_found_title.
  ///
  /// In en, this message translates to:
  /// **'There are no photos available'**
  String get common_image_not_found_title;

  /// No description provided for @common_image_not_found_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Your library is empty'**
  String get common_image_not_found_subTitle;

  /// No description provided for @common_image_liked_not_found_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Your list of favorite photos is empty'**
  String get common_image_liked_not_found_subTitle;

  /// No description provided for @common_try_again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get common_try_again;

  /// No description provided for @common_add_to_favorite.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get common_add_to_favorite;

  /// No description provided for @common_remove_favorite.
  ///
  /// In en, this message translates to:
  /// **'Unlike'**
  String get common_remove_favorite;

  /// No description provided for @common_delete_success.
  ///
  /// In en, this message translates to:
  /// **'Delete successfully'**
  String get common_delete_success;

  /// No description provided for @common_detail_option_text.
  ///
  /// In en, this message translates to:
  /// **'Detail'**
  String get common_detail_option_text;

  /// No description provided for @common_infor_image_title.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get common_infor_image_title;

  /// No description provided for @common_name_image_text.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get common_name_image_text;

  /// No description provided for @common_height_text.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get common_height_text;

  /// No description provided for @common_width_text.
  ///
  /// In en, this message translates to:
  /// **'Width'**
  String get common_width_text;

  /// No description provided for @common_path_image_text.
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get common_path_image_text;

  /// No description provided for @common_created_text.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get common_created_text;

  /// No description provided for @common_image_text_profile.
  ///
  /// In en, this message translates to:
  /// **'IMAGE'**
  String get common_image_text_profile;

  /// No description provided for @common_friend_text_profile.
  ///
  /// In en, this message translates to:
  /// **'FRIEND'**
  String get common_friend_text_profile;

  /// No description provided for @common_helper_text_profile.
  ///
  /// In en, this message translates to:
  /// **'MENU'**
  String get common_helper_text_profile;

  /// No description provided for @common_favourite_text_profile.
  ///
  /// In en, this message translates to:
  /// **'Favourite'**
  String get common_favourite_text_profile;

  /// No description provided for @common_share_folder_text_profile.
  ///
  /// In en, this message translates to:
  /// **'Share Album'**
  String get common_share_folder_text_profile;

  /// No description provided for @common_secure_folder_text_profile.
  ///
  /// In en, this message translates to:
  /// **'Secure Folder'**
  String get common_secure_folder_text_profile;

  /// No description provided for @common_log_out_text.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get common_log_out_text;

  /// No description provided for @common_member_since_text.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get common_member_since_text;

  /// No description provided for @common_edit_profile_text.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get common_edit_profile_text;

  /// No description provided for @common_save_button_profile_text.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save_button_profile_text;

  /// No description provided for @common_name_label_input_text.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get common_name_label_input_text;

  /// No description provided for @common_bio_label_input_text.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get common_bio_label_input_text;

  /// No description provided for @common_subTitle_edit_profile.
  ///
  /// In en, this message translates to:
  /// **'Your information will be displayed on your personal page'**
  String get common_subTitle_edit_profile;

  /// No description provided for @common_select_from_gallery.
  ///
  /// In en, this message translates to:
  /// **'Select from the gallery'**
  String get common_select_from_gallery;

  /// No description provided for @common_take_new_image.
  ///
  /// In en, this message translates to:
  /// **'Take a new photo'**
  String get common_take_new_image;

  /// No description provided for @common_uploading_image_text.
  ///
  /// In en, this message translates to:
  /// **'Uploading photos...'**
  String get common_uploading_image_text;

  /// No description provided for @common_handling_text.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get common_handling_text;

  /// No description provided for @common_no_image_selected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get common_no_image_selected;

  /// No description provided for @common_no_image_captured.
  ///
  /// In en, this message translates to:
  /// **'No image captured'**
  String get common_no_image_captured;

  /// No description provided for @success_update_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get success_update_profile;

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

  /// No description provided for @error_permission.
  ///
  /// In en, this message translates to:
  /// **'No photo gallery access. Please grant permissions in settings'**
  String get error_permission;

  /// No description provided for @error_noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the server. Please check your internet connection'**
  String get error_noInternetConnection;

  /// No description provided for @common_tab_place_title.
  ///
  /// In en, this message translates to:
  /// **'Check In'**
  String get common_tab_place_title;

  /// No description provided for @common_touch_for_detail.
  ///
  /// In en, this message translates to:
  /// **'Touch the photo to see details'**
  String get common_touch_for_detail;

  /// No description provided for @common_timeline_place.
  ///
  /// In en, this message translates to:
  /// **'Route according to shooting time'**
  String get common_timeline_place;

  /// No description provided for @common_latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get common_latitude;

  /// No description provided for @common_longtitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get common_longtitude;

  /// No description provided for @common_time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get common_time;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_filter_by_time.
  ///
  /// In en, this message translates to:
  /// **'Filter by time'**
  String get common_filter_by_time;

  /// No description provided for @common_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get common_filter_all;

  /// No description provided for @common_filter_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get common_filter_today;

  /// No description provided for @common_filter_week.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get common_filter_week;

  /// No description provided for @common_filter_month.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get common_filter_month;

  /// No description provided for @common_filter_year.
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get common_filter_year;

  /// No description provided for @common_filter_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get common_filter_custom;

  /// No description provided for @common_not_found_gps_image.
  ///
  /// In en, this message translates to:
  /// **'No photos with GPS found'**
  String get common_not_found_gps_image;

  /// No description provided for @common_please_take_gps_image.
  ///
  /// In en, this message translates to:
  /// **'Please take photos with GPS enabled'**
  String get common_please_take_gps_image;

  /// No description provided for @common_view_mode_maker.
  ///
  /// In en, this message translates to:
  /// **'Markers'**
  String get common_view_mode_maker;

  /// No description provided for @common_view_mode_route.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get common_view_mode_route;

  /// No description provided for @common_cleaner_tab_title.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get common_cleaner_tab_title;

  /// No description provided for @common_result_view_title.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get common_result_view_title;

  /// No description provided for @common_cleaner_tab_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore photo editing tools'**
  String get common_cleaner_tab_subTitle;

  /// No description provided for @common_duplicate_image_grid_title.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Photos'**
  String get common_duplicate_image_grid_title;

  /// No description provided for @common_duplicate_image_grid_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically detect and group similar photos'**
  String get common_duplicate_image_grid_subTitle;

  /// No description provided for @common_remove_bg_grid_title.
  ///
  /// In en, this message translates to:
  /// **'Remove Background'**
  String get common_remove_bg_grid_title;

  /// No description provided for @common_remove_bg_grid_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove the background from your photos'**
  String get common_remove_bg_grid_subTitle;

  /// No description provided for @common_enhance_image_grid_title.
  ///
  /// In en, this message translates to:
  /// **'Enhance Photo'**
  String get common_enhance_image_grid_title;

  /// No description provided for @common_enhance_image_grid_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Sharpen images and enhance photo details'**
  String get common_enhance_image_grid_subTitle;

  /// No description provided for @common_make_video_grid_title.
  ///
  /// In en, this message translates to:
  /// **'Moment Video'**
  String get common_make_video_grid_title;

  /// No description provided for @common_make_video_grid_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Turn your favorite moments into a video'**
  String get common_make_video_grid_subTitle;

  /// No description provided for @common_remove_bg_title.
  ///
  /// In en, this message translates to:
  /// **'Remove Background'**
  String get common_remove_bg_title;

  /// No description provided for @common_select_image_title.
  ///
  /// In en, this message translates to:
  /// **'Select an image from your device'**
  String get common_select_image_title;

  /// No description provided for @common_button_handle_remove_bg.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_button_handle_remove_bg;

  /// No description provided for @common_button_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_button_save;

  /// No description provided for @common_image_saved_successfully.
  ///
  /// In en, this message translates to:
  /// **'Image saved successfully'**
  String get common_image_saved_successfully;

  /// No description provided for @common_select_moments_title.
  ///
  /// In en, this message translates to:
  /// **'Select Moments'**
  String get common_select_moments_title;

  /// No description provided for @common_selected_count_title.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get common_selected_count_title;

  /// No description provided for @common_select_audio_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Music'**
  String get common_select_audio_title;

  /// No description provided for @common_browse_from_device_title.
  ///
  /// In en, this message translates to:
  /// **'Browse from device'**
  String get common_browse_from_device_title;

  /// No description provided for @common_browse_from_device_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Select audio files from your device'**
  String get common_browse_from_device_subTitle;

  /// No description provided for @common_no_audio_file_selected.
  ///
  /// In en, this message translates to:
  /// **'No audio files selected'**
  String get common_no_audio_file_selected;

  /// No description provided for @common_tap_to_select_audio.
  ///
  /// In en, this message translates to:
  /// **'Tap the button above to browse audio files'**
  String get common_tap_to_select_audio;

  /// No description provided for @common_button_create_video.
  ///
  /// In en, this message translates to:
  /// **'Create Video'**
  String get common_button_create_video;

  /// No description provided for @common_video_created_successfully.
  ///
  /// In en, this message translates to:
  /// **'Your memory video has been successfully created'**
  String get common_video_created_successfully;

  /// No description provided for @common_video_ready_title.
  ///
  /// In en, this message translates to:
  /// **'Video Ready'**
  String get common_video_ready_title;

  /// No description provided for @common_save_video_success.
  ///
  /// In en, this message translates to:
  /// **'Video saved successfully'**
  String get common_save_video_success;

  /// No description provided for @common_discard_video_title.
  ///
  /// In en, this message translates to:
  /// **'Discard Video?'**
  String get common_discard_video_title;

  /// No description provided for @common_confirm_discard_video.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard this video? This action cannot be undone.'**
  String get common_confirm_discard_video;

  /// No description provided for @common_enhance_image_title.
  ///
  /// In en, this message translates to:
  /// **'Enhance Photo'**
  String get common_enhance_image_title;

  /// No description provided for @common_tap_to_upload_photo.
  ///
  /// In en, this message translates to:
  /// **'Tap to Upload Photo'**
  String get common_tap_to_upload_photo;

  /// No description provided for @common_supported_image_formats.
  ///
  /// In en, this message translates to:
  /// **'JPG, PNG supported'**
  String get common_supported_image_formats;

  /// No description provided for @common_ready_to_enhance.
  ///
  /// In en, this message translates to:
  /// **'Ready to Enhance'**
  String get common_ready_to_enhance;

  /// No description provided for @common_ai_enhance_description.
  ///
  /// In en, this message translates to:
  /// **'AI will improve sharpness, lighting, and remove noise'**
  String get common_ai_enhance_description;

  /// No description provided for @common_start_enhancing.
  ///
  /// In en, this message translates to:
  /// **'Start Enhancing'**
  String get common_start_enhancing;

  /// No description provided for @common_before.
  ///
  /// In en, this message translates to:
  /// **'BEFORE'**
  String get common_before;

  /// No description provided for @common_after.
  ///
  /// In en, this message translates to:
  /// **'AFTER'**
  String get common_after;

  /// No description provided for @common_btn_discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get common_btn_discard;

  /// No description provided for @common_discard_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard this changes? This action cannot be undone.'**
  String get common_discard_message;

  /// No description provided for @common_duplicate_image_main_description.
  ///
  /// In en, this message translates to:
  /// **'Clean Up Duplicates'**
  String get common_duplicate_image_main_description;

  /// No description provided for @common_duplicate_image_sub_description.
  ///
  /// In en, this message translates to:
  /// **'Automatically find duplicate photos and bursts'**
  String get common_duplicate_image_sub_description;

  /// No description provided for @common_btn_action_duplicate.
  ///
  /// In en, this message translates to:
  /// **'Scan Device'**
  String get common_btn_action_duplicate;

  /// No description provided for @common_scanning_device.
  ///
  /// In en, this message translates to:
  /// **'Scanning device...'**
  String get common_scanning_device;

  /// No description provided for @common_title_result_scan.
  ///
  /// In en, this message translates to:
  /// **'Scan Results'**
  String get common_title_result_scan;

  /// No description provided for @common_group_found_text.
  ///
  /// In en, this message translates to:
  /// **'group found'**
  String get common_group_found_text;

  /// No description provided for @common_group_title.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get common_group_title;

  /// No description provided for @common_you_can_free_up.
  ///
  /// In en, this message translates to:
  /// **'You can free up'**
  String get common_you_can_free_up;

  /// No description provided for @common_delete_selected_image_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the selected images?'**
  String get common_delete_selected_image_message;

  /// No description provided for @common_no_duplicate_found.
  ///
  /// In en, this message translates to:
  /// **'No duplicate images found'**
  String get common_no_duplicate_found;

  /// No description provided for @common_best_image_tag.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get common_best_image_tag;

  /// No description provided for @common_storage_tag.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get common_storage_tag;

  /// No description provided for @common_storage_almost_full.
  ///
  /// In en, this message translates to:
  /// **'Storage is almost full! Free up space to continue.'**
  String get common_storage_almost_full;

  /// No description provided for @common_storage_free.
  ///
  /// In en, this message translates to:
  /// **'free'**
  String get common_storage_free;

  /// No description provided for @common_similarity.
  ///
  /// In en, this message translates to:
  /// **'Similarity'**
  String get common_similarity;

  /// No description provided for @common_friends_title.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get common_friends_title;

  /// No description provided for @common_friend_count.
  ///
  /// In en, this message translates to:
  /// **'friend(s)'**
  String get common_friend_count;

  /// No description provided for @common_friends_empty.
  ///
  /// In en, this message translates to:
  /// **'No friends found'**
  String get common_friends_empty;

  /// No description provided for @common_friends_connect.
  ///
  /// In en, this message translates to:
  /// **'Connect with friends to share photos together'**
  String get common_friends_connect;

  /// No description provided for @common_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// No description provided for @common_friends_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search by username or email'**
  String get common_friends_search_hint;

  /// No description provided for @common_friends_search_description.
  ///
  /// In en, this message translates to:
  /// **'Search for friends'**
  String get common_friends_search_description;

  /// No description provided for @common_friends_search_sub_description.
  ///
  /// In en, this message translates to:
  /// **'Enter a name or email to search for and connect with friends'**
  String get common_friends_search_sub_description;

  /// No description provided for @common_friends_search_no_result.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get common_friends_search_no_result;

  /// No description provided for @common_friends_try_search_again.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different keyword'**
  String get common_friends_try_search_again;

  /// No description provided for @common_friends_connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get common_friends_connected;

  /// No description provided for @common_friends_unfriend.
  ///
  /// In en, this message translates to:
  /// **'Unfriend'**
  String get common_friends_unfriend;

  /// No description provided for @common_unfriend_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unfriend? You\'ll need to send an invitation again if you want to connect.'**
  String get common_unfriend_message;

  /// No description provided for @common_unfriend_success.
  ///
  /// In en, this message translates to:
  /// **'You have unfriended this user.'**
  String get common_unfriend_success;

  /// No description provided for @common_add_friend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get common_add_friend;

  /// No description provided for @common_cancel_friend_request.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get common_cancel_friend_request;

  /// No description provided for @common_pending_friend_request.
  ///
  /// In en, this message translates to:
  /// **'Pending Request'**
  String get common_pending_friend_request;

  /// No description provided for @common_cancel_friend_request_success.
  ///
  /// In en, this message translates to:
  /// **'Cancel successfully'**
  String get common_cancel_friend_request_success;

  /// No description provided for @common_share_folder.
  ///
  /// In en, this message translates to:
  /// **'Share Folder'**
  String get common_share_folder;

  /// No description provided for @common_friend_invitation.
  ///
  /// In en, this message translates to:
  /// **'Friend Invitation'**
  String get common_friend_invitation;

  /// No description provided for @common_no_friend_invitation.
  ///
  /// In en, this message translates to:
  /// **'No friend invitations'**
  String get common_no_friend_invitation;

  /// No description provided for @common_friend_invitation_message.
  ///
  /// In en, this message translates to:
  /// **'You will be notified when someone sends you a friend request'**
  String get common_friend_invitation_message;

  /// No description provided for @common_btn_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get common_btn_accept;

  /// No description provided for @common_btn_reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get common_btn_reject;

  /// No description provided for @common_accept_success.
  ///
  /// In en, this message translates to:
  /// **'Friend request accepted'**
  String get common_accept_success;

  /// No description provided for @common_reject_invitation_title.
  ///
  /// In en, this message translates to:
  /// **'Reject Invitation'**
  String get common_reject_invitation_title;

  /// No description provided for @common_reject_invitation_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject the friend invitation from '**
  String get common_reject_invitation_message;

  /// No description provided for @common_reject_success.
  ///
  /// In en, this message translates to:
  /// **'Friend invitation rejected'**
  String get common_reject_success;

  /// No description provided for @common_this_user.
  ///
  /// In en, this message translates to:
  /// **'this user'**
  String get common_this_user;

  /// No description provided for @common_secure_storage.
  ///
  /// In en, this message translates to:
  /// **'Secure Storage'**
  String get common_secure_storage;

  /// No description provided for @common_password_incorrect.
  ///
  /// In en, this message translates to:
  /// **'Wrong Password'**
  String get common_password_incorrect;

  /// No description provided for @common_secure_photo_vault_title.
  ///
  /// In en, this message translates to:
  /// **'Secure Photo'**
  String get common_secure_photo_vault_title;

  /// No description provided for @common_secure_photo_vault_description.
  ///
  /// In en, this message translates to:
  /// **'Set a password to protect your photos'**
  String get common_secure_photo_vault_description;

  /// No description provided for @common_secure_photo_vault_authentication_description.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to access the secure photo vault'**
  String get common_secure_photo_vault_authentication_description;

  /// No description provided for @common_secure_photo_vault_change_password_title.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get common_secure_photo_vault_change_password_title;

  /// No description provided for @common_secure_photo_vault_biometric_title.
  ///
  /// In en, this message translates to:
  /// **'Biometrics Settings'**
  String get common_secure_photo_vault_biometric_title;

  /// No description provided for @common_secure_photo_vault_remove_security_title.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get common_secure_photo_vault_remove_security_title;

  /// No description provided for @common_secure_photo_vault_remove_security_success.
  ///
  /// In en, this message translates to:
  /// **'Unlock successfully'**
  String get common_secure_photo_vault_remove_security_success;

  /// No description provided for @common_downloaded.
  ///
  /// In en, this message translates to:
  /// **'Downloaded successfully'**
  String get common_downloaded;

  /// No description provided for @common_storage_secure_empty.
  ///
  /// In en, this message translates to:
  /// **'No Secure Photos'**
  String get common_storage_secure_empty;

  /// No description provided for @common_storage_secure_empty_subTitle.
  ///
  /// In en, this message translates to:
  /// **'Your secure photos will appear here'**
  String get common_storage_secure_empty_subTitle;

  /// No description provided for @common_not_created_secure_photo_vault.
  ///
  /// In en, this message translates to:
  /// **'You have not created a secure photo vault yet.'**
  String get common_not_created_secure_photo_vault;

  /// No description provided for @common_change_password_title.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get common_change_password_title;

  /// No description provided for @common_change_password_description.
  ///
  /// In en, this message translates to:
  /// **'Enter your old password and new password to change'**
  String get common_change_password_description;

  /// No description provided for @common_old_password.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get common_old_password;

  /// No description provided for @common_new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get common_new_password;

  /// No description provided for @common_confirm_new_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get common_confirm_new_password;

  /// No description provided for @common_change_password_success.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get common_change_password_success;

  /// No description provided for @common_old_password_incorrect.
  ///
  /// In en, this message translates to:
  /// **'Old password is incorrect'**
  String get common_old_password_incorrect;

  /// No description provided for @common_fingerprint_authentication.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint authentication to unlock'**
  String get common_fingerprint_authentication;

  /// No description provided for @common_fingerprint_authentication_error.
  ///
  /// In en, this message translates to:
  /// **'Please register fingerprint in device before using this feature'**
  String get common_fingerprint_authentication_error;

  /// No description provided for @common_add_to_secure_photo_vault.
  ///
  /// In en, this message translates to:
  /// **'Added to security vault'**
  String get common_add_to_secure_photo_vault;

  /// No description provided for @common_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get common_user;

  /// No description provided for @common_bio.
  ///
  /// In en, this message translates to:
  /// **'Hi there! I am using SnapLife.'**
  String get common_bio;
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
