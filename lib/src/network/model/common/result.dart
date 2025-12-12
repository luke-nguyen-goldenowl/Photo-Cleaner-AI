import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MResult<T> {
  MResult.exception(Object? e) {
    data = null;
    if (e is AuthApiException) {
      error = _handleAuthSupabase(e);
    } else if (e is AuthRetryableFetchException) {
      error = 'Lỗi kết nối! Vui lòng kiểm tra lại Internet';
    } else if (e is PostgrestException) {
      error = _handlePostgrestException(e);
    } else if (e is StorageException) {
      error = _handleStorageException(e);
    } else if (e is SocketException) {
      error = _handleSocketException(e);
    } else if (e is HttpException) {
      error = _handleHttpException(e);
    } else if (e is FormatException) {
      error = _handleFormatException(e);
    } else if (e is PlatformException) {
      error = _handlePlatformException(e);
    } else if (e is AssertionError) {
      error = e.message?.toString() ?? 'Lỗi xác thực dữ liệu';
    } else if (e is FlutterError) {
      error = e.message;
    } else if (e is TypeError) {
      error = 'Lỗi kiểu dữ liệu. Vui lòng liên hệ hỗ trợ';
    } else if (e is Exception) {
      final message = e.toString();
      error = message.replaceFirst('Exception: ', '');
    } else if (e is Error) {
      error = 'Đã xảy ra lỗi hệ thống. Vui lòng thử lại';
    } else {
      error = 'Đã xảy ra lỗi không xác định';
    }
  }

  MResult.error(String? error) {
    data = null;
    this.error = error ?? 'Đã xảy ra lỗi không xác định';
  }

  MResult.success(this.data) {
    error = null;
  }

  T? data;
  String? error;
  bool get isError => error != null;
  bool get isSuccess => !isError;

  String _handlePostgrestException(PostgrestException e) {
    final code = e.code;
    final message = e.message;

    switch (code) {
      case '23505':
        return 'Dữ liệu đã tồn tại trong hệ thống';
      case '23503':
        return 'Dữ liệu liên quan không tồn tại';
      case '23502':
        return 'Thiếu thông tin bắt buộc';
      case '42501':
        return 'Bạn không có quyền thực hiện thao tác này';
      case '42P01':
        return 'Bảng dữ liệu không tồn tại';
      case '42703':
        return 'Trường dữ liệu không tồn tại';
      case 'PGRST116':
        return 'Không tìm thấy dữ liệu';
      case 'PGRST301':
        return 'Yêu cầu không hợp lệ';
      default:
        if (message.isNotEmpty) {
          return message;
        }
        return 'Lỗi cơ sở dữ liệu: $code';
    }
  }

  String _handleStorageException(StorageException e) {
    final message = e.message.toLowerCase();

    if (message.contains('not found')) {
      return 'Tệp không tồn tại';
    } else if (message.contains('unauthorized')) {
      return 'Bạn không có quyền truy cập tệp này';
    } else if (message.contains('payload too large')) {
      return 'Kích thước tệp quá lớn';
    } else if (message.contains('invalid mime type')) {
      return 'Định dạng tệp không được hỗ trợ';
    }

    return e.message.isNotEmpty ? e.message : 'Lỗi lưu trữ';
  }

  String _handleAuthSupabase(AuthApiException e) {
    switch (e.code) {
      // Anonymous & Provider
      case 'anonymous_provider_disabled':
        return 'Đăng nhập bằng tài khoản ẩn danh đã bị vô hiệu hóa';
      case 'oauth_provider_not_supported':
        return 'Phương thức đăng nhập này không được hỗ trợ';
      case 'provider_disabled':
        return 'Phương thức đăng nhập này đã bị vô hiệu hóa';
      case 'provider_email_needs_verification':
        return 'Email từ nhà cung cấp cần được xác thực. Vui lòng kiểm tra hộp thư';

      // PKCE Flow
      case 'bad_code_verifier':
        return 'Mã xác thực không hợp lệ. Vui lòng thử đăng nhập lại';
      case 'flow_state_expired':
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại';
      case 'flow_state_not_found':
        return 'Không tìm thấy phiên đăng nhập. Vui lòng thử lại';

      // Request Format
      case 'bad_json':
        return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại';
      case 'validation_failed':
        return 'Thông tin không đúng định dạng. Vui lòng kiểm tra lại';

      // JWT & Token
      case 'bad_jwt':
        return 'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại';
      case 'invalid_user_token':
        return 'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại';
      case 'user_token_expired':
        return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại';
      case 'session_expired':
        return 'Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại';
      case 'session_not_found':
        return 'Không tìm thấy phiên làm việc. Vui lòng đăng nhập lại';
      case 'refresh_token_already_used':
        return 'Token làm mới đã được sử dụng. Vui lòng đăng nhập lại';
      case 'refresh_token_not_found':
        return 'Không tìm thấy token làm mới. Vui lòng đăng nhập lại';

      // OAuth
      case 'bad_oauth_callback':
        return 'Lỗi xác thực OAuth. Vui lòng thử lại';
      case 'bad_oauth_state':
        return 'Trạng thái xác thực không hợp lệ. Vui lòng thử lại';

      // CAPTCHA
      case 'captcha_failed':
        return 'Xác thực CAPTCHA thất bại. Vui lòng thử lại';

      // Conflicts
      case 'conflict':
        return 'Xung đột dữ liệu. Vui lòng thử lại sau';

      // Email
      case 'email_address_invalid':
        return 'Địa chỉ email không hợp lệ';
      case 'email_address_not_authorized':
        return 'Email không được phép sử dụng. Vui lòng thiết lập SMTP tùy chỉnh';
      case 'email_conflict_identity_not_deletable':
        return 'Không thể xóa phương thức đăng nhập chính';
      case 'email_exists':
        return 'Email đã được sử dụng';
      case 'email_not_confirmed':
        return 'Email chưa được xác thực. Vui lòng kiểm tra hộp thư';
      case 'email_provider_disabled':
        return 'Đăng ký bằng email đã bị vô hiệu hóa';

      // Phone
      case 'phone_exists':
        return 'Số điện thoại đã được sử dụng';
      case 'phone_not_confirmed':
        return 'Số điện thoại chưa được xác thực';
      case 'phone_provider_disabled':
        return 'Đăng ký bằng số điện thoại đã bị vô hiệu hóa';
      case 'invalid_phone_number':
        return 'Số điện thoại không hợp lệ';
      case 'missing_phone_number':
        return 'Vui lòng nhập số điện thoại';

      // Credentials
      case 'invalid_credentials':
        return 'Email hoặc mật khẩu không chính xác';
      case 'weak_password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn';
      case 'same_password':
        return 'Mật khẩu mới phải khác mật khẩu hiện tại';

      // Action Codes & OTP
      case 'expired_action_code':
        return 'Mã xác thực đã hết hạn. Vui lòng yêu cầu mã mới';
      case 'invalid_action_code':
        return 'Mã xác thực không hợp lệ hoặc đã được sử dụng';
      case 'otp_disabled':
        return 'Đăng nhập bằng OTP đã bị vô hiệu hóa';
      case 'otp_expired':
        return 'Mã OTP đã hết hạn. Vui lòng yêu cầu mã mới';

      // Network
      case 'network_request_failed':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại';
      case 'timeout':
      case 'request_timeout':
        return 'Yêu cầu quá lâu. Vui lòng thử lại';

      // Account State
      case 'account_exists_with_different_credential':
      case 'user_already_exists':
        return 'Tài khoản đã tồn tại. Vui lòng sử dụng phương thức đăng nhập ban đầu';
      case 'credential_already_in_use':
        return 'Thông tin xác thực này đã được sử dụng cho tài khoản khác';
      case 'user_not_found':
        return 'Không tìm thấy tài khoản';
      case 'user_banned':
        return 'Tài khoản đã bị khóa. Vui lòng liên hệ hỗ trợ';
      case 'user_sso_managed':
        return 'Tài khoản được quản lý bởi SSO. Không thể cập nhật thông tin này';

      // Reauthentication
      case 'reauthentication_needed':
        return 'Cần xác thực lại để thực hiện thao tác này';
      case 'reauthentication_not_valid':
        return 'Xác thực lại không thành công. Vui lòng thử lại';

      // Authorization
      case 'no_authorization':
        return 'Thiếu thông tin xác thực. Vui lòng đăng nhập';
      case 'not_admin':
        return 'Bạn không có quyền quản trị viên';
      case 'insufficient_aal':
        return 'Cần xác thực đa yếu tố để thực hiện thao tác này';

      // Rate Limits
      case 'over_email_send_rate_limit':
        return 'Đã gửi quá nhiều email. Vui lòng thử lại sau';
      case 'over_request_rate_limit':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau vài phút';
      case 'over_sms_send_rate_limit':
        return 'Đã gửi quá nhiều SMS. Vui lòng thử lại sau';
      case 'quota_exceeded':
        return 'Đã vượt quá số lượng cho phép. Vui lòng thử lại sau';

      // Popup/Browser
      case 'popup_closed_by_user':
        return 'Cửa sổ đăng nhập đã bị đóng. Vui lòng thử lại';
      case 'popup_blocked':
        return 'Trình duyệt đã chặn cửa sổ đăng nhập. Vui lòng cho phép popup';
      case 'unauthorized_domain':
        return 'Tên miền không được phép sử dụng';

      // MFA (Multi-Factor Authentication)
      case 'mfa_challenge_expired':
        return 'Mã xác thực đa yếu tố đã hết hạn. Vui lòng yêu cầu mã mới';
      case 'mfa_factor_name_conflict':
        return 'Tên phương thức xác thực đã tồn tại';
      case 'mfa_factor_not_found':
        return 'Không tìm thấy phương thức xác thực';
      case 'mfa_ip_address_mismatch':
        return 'Địa chỉ IP không khớp. Vui lòng thử lại';
      case 'mfa_phone_enroll_not_enabled':
        return 'Đăng ký xác thực qua điện thoại chưa được bật';
      case 'mfa_phone_verify_not_enabled':
        return 'Xác thực qua điện thoại chưa được bật';
      case 'mfa_totp_enroll_not_enabled':
        return 'Đăng ký xác thực TOTP chưa được bật';
      case 'mfa_totp_verify_not_enabled':
        return 'Xác thực TOTP chưa được bật';
      case 'mfa_verification_failed':
        return 'Mã xác thực không chính xác';
      case 'mfa_verification_rejected':
        return 'Xác thực bị từ chối';
      case 'mfa_verified_factor_exists':
        return 'Đã có phương thức xác thực được kích hoạt';
      case 'mfa_web_authn_enroll_not_enabled':
        return 'Đăng ký WebAuthn chưa được bật';
      case 'mfa_web_authn_verify_not_enabled':
        return 'Xác thực WebAuthn chưa được bật';
      case 'too_many_enrolled_mfa_factors':
        return 'Đã đạt giới hạn số lượng phương thức xác thực';

      // Identity Management
      case 'identity_already_exists':
        return 'Phương thức đăng nhập này đã được liên kết';
      case 'identity_not_found':
        return 'Không tìm thấy phương thức đăng nhập';
      case 'single_identity_not_deletable':
        return 'Không thể xóa phương thức đăng nhập duy nhất';
      case 'manual_linking_disabled':
        return 'Liên kết thủ công đã bị vô hiệu hóa';

      // Invites
      case 'invite_not_found':
        return 'Lời mời không tồn tại hoặc đã hết hạn';

      // SAML SSO
      case 'saml_assertion_no_email':
        return 'Không tìm thấy email trong thông tin SAML';
      case 'saml_assertion_no_user_id':
        return 'Không tìm thấy ID người dùng trong thông tin SAML';
      case 'saml_entity_id_mismatch':
        return 'Entity ID không khớp';
      case 'saml_idp_already_exists':
        return 'Nhà cung cấp SAML đã tồn tại';
      case 'saml_idp_not_found':
        return 'Không tìm thấy nhà cung cấp SAML';
      case 'saml_metadata_fetch_failed':
        return 'Không thể tải metadata SAML';
      case 'saml_provider_disabled':
        return 'SAML SSO chưa được bật';
      case 'saml_relay_state_expired':
        return 'Trạng thái SAML đã hết hạn. Vui lòng đăng nhập lại';
      case 'saml_relay_state_not_found':
        return 'Không tìm thấy trạng thái SAML. Vui lòng đăng nhập lại';

      // SSO General
      case 'sso_domain_already_exists':
        return 'Tên miền SSO đã tồn tại';
      case 'sso_provider_not_found':
        return 'Không tìm thấy nhà cung cấp SSO';

      // SMS
      case 'sms_send_failed':
        return 'Gửi SMS thất bại. Vui lòng thử lại';

      // Signup
      case 'signup_disabled':
        return 'Đăng ký tài khoản mới đã bị tắt';

      // Hooks
      case 'hook_payload_invalid_content_type':
        return 'Lỗi xử lý webhook: Content-Type không hợp lệ';
      case 'hook_payload_over_size_limit':
        return 'Lỗi xử lý webhook: Dữ liệu quá lớn';
      case 'hook_timeout':
        return 'Lỗi xử lý webhook: Timeout';
      case 'hook_timeout_after_retry':
        return 'Lỗi xử lý webhook: Timeout sau khi thử lại';

      // Deprecated/Rare
      case 'unexpected_audience':
        return 'Audience không khớp';
      case 'unexpected_failure':
        return 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại';

      // Legacy codes (từ code cũ)
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này chưa được kích hoạt';
      case 'requires-recent-login':
        return 'Thao tác này yêu cầu đăng nhập lại. Vui lòng đăng xuất và đăng nhập lại';
      case 'email-already-verified':
        return 'Email đã được xác thực rồi';

      // Default
      default:
        if (e.message.isNotEmpty) {
          return e.message;
        }
        return 'Đã xảy ra lỗi không xác định. Vui lòng thử lại. (Mã lỗi: ${e.code})';
    }
  }

  // Handle Socket Exceptions (Network errors)
  String _handleSocketException(SocketException e) {
    if (e.osError != null) {
      switch (e.osError!.errorCode) {
        case 7: // No address associated with hostname
          return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet';
        case 8: // nodename nor servname provided, or not known
          return 'Không tìm thấy máy chủ. Vui lòng kiểm tra kết nối internet';
        case 61: // Connection refused
          return 'Máy chủ từ chối kết nối. Vui lòng thử lại sau';
        case 64: // Host is down
          return 'Máy chủ không hoạt động. Vui lòng thử lại sau';
        case 65: // No route to host
          return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet';
        case 101: // Network is unreachable
          return 'Không có kết nối mạng. Vui lòng kiểm tra internet';
        case 110: // Connection timed out
          return 'Kết nối quá lâu. Vui lòng kiểm tra internet và thử lại';
        case 111: // Connection refused
          return 'Máy chủ từ chối kết nối. Vui lòng thử lại sau';
        default:
          return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại';
      }
    }
    return e.message.isNotEmpty
        ? e.message
        : 'Lỗi kết nối mạng. Vui lòng kiểm tra internet';
  }

  // Handle HTTP Exceptions
  String _handleHttpException(HttpException e) {
    final message = e.message.toLowerCase();

    if (message.contains('connection closed')) {
      return 'Kết nối bị đóng. Vui lòng thử lại';
    } else if (message.contains('connection reset')) {
      return 'Kết nối bị ngắt. Vui lòng thử lại';
    } else if (message.contains('failed host lookup')) {
      return 'Không tìm thấy máy chủ. Vui lòng kiểm tra kết nối internet';
    }

    return e.message.isNotEmpty ? e.message : 'Lỗi HTTP. Vui lòng thử lại';
  }

  // Handle Format Exceptions
  String _handleFormatException(FormatException e) {
    if (e.message.toLowerCase().contains('json')) {
      return 'Dữ liệu phản hồi không hợp lệ. Vui lòng thử lại';
    }
    return 'Định dạng dữ liệu không hợp lệ';
  }

  // Handle Platform Exceptions (improved)
  String _handlePlatformException(PlatformException e) {
    switch (e.code) {
      // Network errors
      case 'network_error':
        return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet';
      case 'connection_timeout':
        return 'Kết nối quá lâu. Vui lòng thử lại';

      // Permission errors
      case 'permission_denied':
      case 'PERMISSION_DENIED':
        return 'Ứng dụng không có quyền truy cập. Vui lòng cấp quyền trong cài đặt';

      // Storage errors
      case 'storage_error':
        return 'Lỗi lưu trữ. Vui lòng kiểm tra dung lượng thiết bị';
      case 'file_not_found':
        return 'Không tìm thấy tệp';

      // Camera/Gallery errors
      case 'camera_access_denied':
        return 'Không có quyền truy cập camera. Vui lòng cấp quyền';
      case 'photo_access_denied':
        return 'Không có quyền truy cập thư viện ảnh. Vui lòng cấp quyền';

      // Location errors
      case 'location_disabled':
        return 'Dịch vụ định vị đã tắt. Vui lòng bật trong cài đặt';
      case 'location_permission_denied':
        return 'Không có quyền truy cập vị trí. Vui lòng cấp quyền';

      // Biometric errors
      case 'NotAvailable':
        return 'Xác thực sinh trắc học không khả dụng trên thiết bị này';
      case 'NotEnrolled':
        return 'Chưa thiết lập xác thực sinh trắc học. Vui lòng thiết lập trong cài đặt';
      case 'PasscodeNotSet':
        return 'Chưa thiết lập mã khóa màn hình';
      case 'LockedOut':
        return 'Xác thực sinh trắc học bị khóa do nhập sai quá nhiều lần';

      // Payment errors
      case 'payment_cancelled':
        return 'Thanh toán đã bị hủy';
      case 'payment_failed':
        return 'Thanh toán thất bại. Vui lòng thử lại';
      case 'payment_invalid':
        return 'Thông tin thanh toán không hợp lệ';

      // General errors
      case 'unavailable':
        return 'Dịch vụ tạm thời không khả dụng. Vui lòng thử lại sau';
      case 'cancelled':
        return 'Thao tác đã bị hủy';
      case 'unknown':
        return 'Đã xảy ra lỗi không xác định';

      default:
        return e.message ?? 'Đã xảy ra lỗi hệ thống';
    }
  }
}
