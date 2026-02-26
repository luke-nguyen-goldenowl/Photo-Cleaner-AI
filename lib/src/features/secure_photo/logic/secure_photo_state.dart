import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:myapp/src/features/authentication/model/confirm_password_formz.dart';
import 'package:myapp/src/features/authentication/model/password_formz.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/network/model/common/pagination/pagination.dart';

enum SecurePhotoStatus {
  initial,
  loading,
  success,
  error,
}

class SecurePhotoState extends Equatable {
  const SecurePhotoState({
    this.status = SecurePhotoStatus.initial,
    this.hasVault = false,
    this.isVaultVerified = false,
    this.isCreateMode = false,
    this.isBiometricSupported = false,
    required this.securePhotosPagination,
    this.password = const PasswordFormzInput.pure(''),
    this.confirmPassword = const ConfirmPasswordFormzInput.pure(),
    this.oldPassword = const PasswordFormzInput.pure(''),
    this.newPassword = const PasswordFormzInput.pure(''),
    this.confirmNewPassword = const ConfirmPasswordFormzInput.pure(),
  });

  final SecurePhotoStatus status;
  final bool hasVault;
  final bool isVaultVerified;
  final bool isBiometricSupported;
  final MPagination<MPhotoItem> securePhotosPagination;
  final PasswordFormzInput password;
  final ConfirmPasswordFormzInput confirmPassword;
  final bool isCreateMode;
  final PasswordFormzInput oldPassword;
  final PasswordFormzInput newPassword;
  final ConfirmPasswordFormzInput confirmNewPassword;

  bool get isLoading => status == SecurePhotoStatus.loading;
  bool get isSuccess => status == SecurePhotoStatus.success;
  bool get hasError => status == SecurePhotoStatus.error;
  List<MPhotoItem> get securePhotos => securePhotosPagination.data;

  bool get isValidated {
    if (isCreateMode) {
      return Formz.validate([password, confirmPassword]);
    }
    return password.isValid;
  }

  bool get isChangePasswordValidated {
    return Formz.validate([oldPassword, newPassword, confirmNewPassword]) &&
        !isDuplicatePassword;
  }

  bool get isDuplicatePassword {
    if (oldPassword.value.isEmpty || newPassword.value.isEmpty) {
      return false;
    }
    return newPassword.value == oldPassword.value;
  }

  SecurePhotoState copyWith({
    SecurePhotoStatus? status,
    bool? hasVault,
    bool? isVaultVerified,
    bool? isCreateMode,
    bool? isBiometricSupported,
    MPagination<MPhotoItem>? securePhotosPagination,
    PasswordFormzInput? password,
    ConfirmPasswordFormzInput? confirmPassword,
    PasswordFormzInput? oldPassword,
    PasswordFormzInput? newPassword,
    ConfirmPasswordFormzInput? confirmNewPassword,
  }) {
    return SecurePhotoState(
      status: status ?? this.status,
      hasVault: hasVault ?? this.hasVault,
      isVaultVerified: isVaultVerified ?? this.isVaultVerified,
      isCreateMode: isCreateMode ?? this.isCreateMode,
      isBiometricSupported: isBiometricSupported ?? this.isBiometricSupported,
      securePhotosPagination:
          securePhotosPagination ?? this.securePhotosPagination,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      oldPassword: oldPassword ?? this.oldPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmNewPassword: confirmNewPassword ?? this.confirmNewPassword,
    );
  }

  @override
  List<Object?> get props => [
        status,
        hasVault,
        isVaultVerified,
        isCreateMode,
        isBiometricSupported,
        securePhotosPagination.status,
        securePhotosPagination.page,
        securePhotosPagination.data.length,
        password,
        confirmPassword,
        oldPassword,
        newPassword,
        confirmNewPassword,
      ];
}
