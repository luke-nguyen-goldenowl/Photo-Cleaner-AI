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
  String get common_delete_title_alert => 'Confirm Deletion';

  @override
  String get common_delete_confirm_title =>
      'Are you sure you want to delete this photo?';

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
  String get error_login => 'Sign in failed';

  @override
  String get error_signUp => 'Sign up failed';

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
  String get error_email_have_been_used => 'Email is already in use';

  @override
  String get error_email_not_confirm =>
      'Email has not been verified. Please check your mailbox';

  @override
  String get error_email_or_password_invalid =>
      'Email or password is incorrect';

  @override
  String get error_otp_expired =>
      'OTP code has expired. Please request a new code';

  @override
  String get error_same_password =>
      'The new password must be different from the current password';

  @override
  String get success_login => 'Login success';

  @override
  String get success_signUp =>
      'Sign up success! Please check email box to confirm your email';

  @override
  String get common_forgotPass_subTitle =>
      'Don\'t worry! Enter your email below and we will send an OTP to restore.';

  @override
  String get common_hinTextEmail => 'Enter Email address';

  @override
  String get common_button_senOTP => 'Send OTP code';

  @override
  String get common_button_gobackLogin => 'Back to Login';

  @override
  String get common_sendOTP_Title => 'Enter OTP code';

  @override
  String get common_sendOTP_subTitle =>
      'We have sent a 6-digit code to your email. Please check your mailbox.';

  @override
  String get common_hintTextOTP => 'Enter OTP code (6 digits)';

  @override
  String get common_button_verify => 'Verify';

  @override
  String get common_sendOTPAgain_s => 'Resend code after';

  @override
  String get common_sendOTPAgain => 'Resend OTP code';

  @override
  String get common_recoverPass_title => 'Reset password';

  @override
  String get common_recoverPass_subTitle =>
      'Enter your new password to complete the recovery process.';

  @override
  String get common_newPass_hintText => 'New password';

  @override
  String get common_confirmNewPass_hintText => 'Confirm new password';

  @override
  String get common_photo_tab_title => 'My Gallery';

  @override
  String get common_offline_mode => 'You are in offline mode';

  @override
  String get common_online_mode => 'Connected to the network';

  @override
  String get common_all_chip_title => 'All';

  @override
  String get common_favourite_chip_title => 'Favourite';

  @override
  String get common_image_count_title => 'image';

  @override
  String get common_floating_button_text => 'Memory';

  @override
  String get common_like_button_text => 'Like';

  @override
  String get common_secure_button_text => 'Secure';

  @override
  String get common_enhance_button_text => 'Enhance';

  @override
  String get common_share_button_text => 'Share';

  @override
  String get common_save_button_text => 'Save';

  @override
  String get common_delete_button_text => 'Delete';

  @override
  String get common_text_share => 'Share from Pixel Perfect';

  @override
  String get common_image_not_found_title => 'There are no photos available';

  @override
  String get common_image_not_found_subTitle => 'Your library is empty';

  @override
  String get common_image_liked_not_found_subTitle =>
      'Your list of favorite photos is empty';

  @override
  String get common_try_again => 'Try Again';

  @override
  String get common_add_to_favorite => 'Liked';

  @override
  String get common_remove_favorite => 'Unlike';

  @override
  String get common_delete_success => 'Delete successfully';

  @override
  String get common_detail_option_text => 'Detail';

  @override
  String get common_infor_image_title => 'Information';

  @override
  String get common_name_image_text => 'Name';

  @override
  String get common_height_text => 'Height';

  @override
  String get common_width_text => 'Width';

  @override
  String get common_path_image_text => 'Path';

  @override
  String get common_created_text => 'Time';

  @override
  String get common_image_text_profile => 'IMAGE';

  @override
  String get common_friend_text_profile => 'FRIEND';

  @override
  String get common_helper_text_profile => 'MENU';

  @override
  String get common_favourite_text_profile => 'Favourite';

  @override
  String get common_share_folder_text_profile => 'Share Album';

  @override
  String get common_secure_folder_text_profile => 'Secure Folder';

  @override
  String get common_log_out_text => 'Log out';

  @override
  String get common_member_since_text => 'Member since';

  @override
  String get common_edit_profile_text => 'Edit Profile';

  @override
  String get common_save_button_profile_text => 'Save';

  @override
  String get common_name_label_input_text => 'Name';

  @override
  String get common_bio_label_input_text => 'Bio';

  @override
  String get common_subTitle_edit_profile =>
      'Your information will be displayed on your personal page';

  @override
  String get common_select_from_gallery => 'Select from the gallery';

  @override
  String get common_take_new_image => 'Take a new photo';

  @override
  String get common_uploading_image_text => 'Uploading photos...';

  @override
  String get common_handling_text => 'Processing...';

  @override
  String get common_no_image_selected => 'No image selected';

  @override
  String get common_no_image_captured => 'No image captured';

  @override
  String get success_update_profile => 'Profile updated successfully';

  @override
  String get success_sendOTP => 'OTP code has been sent to';

  @override
  String get success_verifyOTP => 'Verified successfully!';

  @override
  String get success_resetPass_noti_Title => 'Success';

  @override
  String get success_resetPass_noti_subTitle =>
      'Password has been updated successfully! Please log in again.';

  @override
  String get error_sendOTP => 'Failed to send OTP';

  @override
  String get error_verifyOTP => 'Verification failed';

  @override
  String get error_OTP_invalid => 'Invalid OTP code';

  @override
  String get error_resetPass => 'Password change failed';

  @override
  String get error_permission =>
      'No photo gallery access. Please grant permissions in settings';

  @override
  String get error_noInternetConnection =>
      'Unable to connect to the server. Please check your internet connection';

  @override
  String get common_tab_place_title => 'Check In';

  @override
  String get common_touch_for_detail => 'Touch the photo to see details';

  @override
  String get common_timeline_place => 'Route according to shooting time';

  @override
  String get common_latitude => 'Latitude';

  @override
  String get common_longtitude => 'Longitude';

  @override
  String get common_time => 'Time';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_filter_by_time => 'Filter by time';

  @override
  String get common_filter_all => 'All';

  @override
  String get common_filter_today => 'Today';

  @override
  String get common_filter_week => 'This week';

  @override
  String get common_filter_month => 'This month';

  @override
  String get common_filter_year => 'This year';

  @override
  String get common_filter_custom => 'Custom';

  @override
  String get common_not_found_gps_image => 'No photos with GPS found';

  @override
  String get common_please_take_gps_image =>
      'Please take photos with GPS enabled';

  @override
  String get common_view_mode_maker => 'Markers';

  @override
  String get common_view_mode_route => 'Route';

  @override
  String get common_cleaner_tab_title => 'Tools';

  @override
  String get common_result_view_title => 'Result';

  @override
  String get common_cleaner_tab_subTitle => 'Explore photo editing tools';

  @override
  String get common_duplicate_image_grid_title => 'Duplicate Photos';

  @override
  String get common_duplicate_image_grid_subTitle =>
      'Automatically detect and group similar photos';

  @override
  String get common_remove_bg_grid_title => 'Remove Background';

  @override
  String get common_remove_bg_grid_subTitle =>
      'Remove the background from your photos';

  @override
  String get common_enhance_image_grid_title => 'Enhance Photo';

  @override
  String get common_enhance_image_grid_subTitle =>
      'Sharpen images and enhance photo details';

  @override
  String get common_make_video_grid_title => 'Create Moment Video';

  @override
  String get common_make_video_grid_subTitle =>
      'Turn your favorite moments into a video';

  @override
  String get common_remove_bg_title => 'Remove Background';

  @override
  String get common_select_image_title => 'Select an image from your device';

  @override
  String get common_button_handle_remove_bg => 'Continue';

  @override
  String get common_button_save => 'Save';

  @override
  String get common_image_saved_successfully => 'Image saved successfully';

  @override
  String get common_select_moments_title => 'Select Moments';

  @override
  String get common_selected_count_title => 'selected';

  @override
  String get common_select_audio_title => 'Choose Music';

  @override
  String get common_browse_from_device_title => 'Browse from device';

  @override
  String get common_browse_from_device_subTitle =>
      'Select audio files from your device';

  @override
  String get common_no_audio_file_selected => 'No audio files selected';

  @override
  String get common_tap_to_select_audio =>
      'Tap the button above to browse audio files';

  @override
  String get common_button_create_video => 'Create Video';

  @override
  String get common_video_created_successfully =>
      'Your memory video has been successfully created';

  @override
  String get common_video_ready_title => 'Video Ready';

  @override
  String get common_save_video_success => 'Video saved successfully';

  @override
  String get common_discard_video_title => 'Discard Video?';

  @override
  String get common_confirm_discard_video =>
      'Are you sure you want to discard this video? This action cannot be undone.';

  @override
  String get common_enhance_image_title => 'Enhance Photo';

  @override
  String get common_tap_to_upload_photo => 'Tap to Upload Photo';

  @override
  String get common_supported_image_formats => 'JPG, PNG supported';

  @override
  String get common_ready_to_enhance => 'Ready to Enhance';

  @override
  String get common_ai_enhance_description =>
      'AI will improve sharpness, lighting, and remove noise';

  @override
  String get common_start_enhancing => 'Start Enhancing';

  @override
  String get common_before => 'BEFORE';

  @override
  String get common_after => 'AFTER';

  @override
  String get common_btn_discard => 'Discard';

  @override
  String get common_discard_message =>
      'Are you sure you want to discard this changes? This action cannot be undone.';
}
