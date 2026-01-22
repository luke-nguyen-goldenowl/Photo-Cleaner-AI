import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/features/authentication/model/confirm_password_formz.dart';
import 'package:myapp/src/features/authentication/model/password_formz.dart';
import 'package:myapp/src/features/dashboard/photo/model/photo_item.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/network/data/secure_photo/secure_photo_service.dart';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/network/model/common/pagination/pagination.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'secure_photo_state.dart';

class SecurePhotoBloc extends Cubit<SecurePhotoState> {
  SecurePhotoBloc()
      : super(SecurePhotoState(
            securePhotosPagination: MPagination<MPhotoItem>(pageLimit: 20))) {
    _initialize();
  }

  DomainManager get domain => DomainManager();
  final SecurePhotoService _securePhotoService = SecurePhotoService();
  String? _currentUserId;
  List<MPhotoItem> _allSecurePhotos = [];

  Future<void> _initialize() async {
    await syncCurrentUser();
    loadSecurePhotos();
  }

  Future<void> syncCurrentUser() async {
    final result = await domain.user.syncCurrentUser();
    if (result.isSuccess && result.data != null) {
      final user = result.data;
      if (user != null) {
        _currentUserId = user.id;
      }
    }
  }

  Future<void> checkVaultStatus() async {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      emit(state.copyWith(
        status: SecurePhotoStatus.error,
      ));
      return;
    }

    emit(state.copyWith(status: SecurePhotoStatus.loading));
    final result = await domain.securePhoto.hasVault(_currentUserId!);
    if (result.isSuccess) {
      emit(state.copyWith(
        status: SecurePhotoStatus.success,
        hasVault: result.data,
      ));
    } else {
      emit(state.copyWith(
        status: SecurePhotoStatus.error,
      ));
    }
  }

  Future<bool> createVault(String password) async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return false;

    emit(state.copyWith(status: SecurePhotoStatus.loading));

    final result = await domain.securePhoto.createVault(
      userId: _currentUserId!,
      password: password,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        status: SecurePhotoStatus.success,
        hasVault: true,
      ));
      return true;
    } else {
      emit(state.copyWith(
        status: SecurePhotoStatus.error,
      ));
      return false;
    }
  }

  Future<bool> verifyPassword(String password) async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return false;

    emit(state.copyWith(status: SecurePhotoStatus.loading));

    final result = await domain.securePhoto.verifyPassword(
      userId: _currentUserId!,
      password: password,
    );

    if (result.isSuccess) {
      final isValid = result.data ?? false;
      emit(state.copyWith(
        status: SecurePhotoStatus.success,
        isVaultVerified: isValid,
      ));
      AppCoordinator.showSecurePhotoScreen();
      return isValid;
    } else {
      emit(state.copyWith(
        status: SecurePhotoStatus.error,
      ));
      XToast.error(result.error);
      return false;
    }
  }

  Future<void> addSecurePhoto(
    MPhotoItem photo, {
    required Future<String?> Function() onNeedPassword,
    required Future<void> Function() onSuccess,
  }) async {
    if (photo.asset == null && photo.storageUrl == null) {
      XToast.error(S.text.error_somethingWrongTryAgain);
      return;
    }

    emit(state.copyWith(status: SecurePhotoStatus.loading));

    await syncCurrentUser();
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      emit(state.copyWith(status: SecurePhotoStatus.error));
      return;
    }

    final vaultResult = await domain.securePhoto.hasVault(_currentUserId!);
    if (!vaultResult.isSuccess) {
      emit(state.copyWith(status: SecurePhotoStatus.error));
      return;
    }

    final hasVault = vaultResult.data ?? false;

    if (!hasVault) {
      final password = await onNeedPassword();
      if (password == null || password.isEmpty) {
        emit(state.copyWith(status: SecurePhotoStatus.success));
        return;
      }

      emit(state.copyWith(status: SecurePhotoStatus.loading));
      final createResult = await domain.securePhoto.createVault(
        userId: _currentUserId!,
        password: password,
      );

      if (!createResult.isSuccess) {
        XToast.error(S.text.error_somethingWrongTryAgain);
        emit(state.copyWith(status: SecurePhotoStatus.error));
        return;
      }

      emit(state.copyWith(hasVault: true));
    }

    if (photo.asset == null && photo.storageUrl != null) {
      final result = await domain.securePhoto.addSecurePhotoFromUrl(
        userId: _currentUserId!,
        imageUrl: photo.storageUrl!,
        photoId: photo.id,
      );

      if (result.isSuccess) {
        XToast.success(S.text.common_add_to_secure_photo_vault);
        emit(state.copyWith(status: SecurePhotoStatus.success));
        await onSuccess();
      } else {
        XToast.error(S.text.error_somethingWrongTryAgain);
        emit(state.copyWith(status: SecurePhotoStatus.error));
      }
      return;
    }

    final imageFile = await photo.asset!.file;
    if (imageFile == null) {
      XToast.error(S.text.error_somethingWrongTryAgain);
      emit(state.copyWith(status: SecurePhotoStatus.error));
      return;
    }

    final result = await domain.securePhoto.addSecurePhoto(
      userId: _currentUserId!,
      imageFile: imageFile,
    );

    if (result.isSuccess) {
      emit(state.copyWith(status: SecurePhotoStatus.success));
      await onSuccess();
    } else {
      XToast.error(S.text.error_somethingWrongTryAgain);
      emit(state.copyWith(status: SecurePhotoStatus.error));
    }
  }

  Future<void> loadSecurePhotos() async {
    if (isClosed) return;

    if (_currentUserId == null || _currentUserId!.isEmpty) {
      emit(state.copyWith(
        status: SecurePhotoStatus.error,
      ));
      return;
    }

    if (!state.securePhotosPagination.canLoad) {
      return;
    }

    final currentPage = state.securePhotosPagination.page;
    final isFirstPage = currentPage == 0;

    emit(state.copyWith(
      securePhotosPagination: state.securePhotosPagination.toLoading(),
      status: isFirstPage ? SecurePhotoStatus.loading : state.status,
    ));

    if (isFirstPage) {
      final result = await domain.securePhoto.getSecurePhotos(_currentUserId!);

      if (!result.isSuccess) {
        emit(state.copyWith(
          status: SecurePhotoStatus.error,
        ));
        return;
      }

      _allSecurePhotos = result.data ?? [];
    }

    if (_allSecurePhotos.isEmpty && isFirstPage) {
      emit(state.copyWith(
        status: SecurePhotoStatus.success,
        securePhotosPagination: state.securePhotosPagination.addAll(
          [],
          totalPage: 1,
          countData: 0,
        ),
      ));
      return;
    }

    final pageSize = state.securePhotosPagination.pageLimit;
    final start = currentPage * pageSize;
    final paginatedPhotos =
        _allSecurePhotos.skip(start).take(pageSize).toList();

    final isLastPage = (start + pageSize) >= _allSecurePhotos.length;
    final totalPage = isLastPage ? (currentPage + 1) : -1;
    final countData = isLastPage ? _allSecurePhotos.length : -1;

    if (isClosed) return;

    emit(state.copyWith(
      status: SecurePhotoStatus.success,
      securePhotosPagination: state.securePhotosPagination.addAll(
        paginatedPhotos,
        totalPage: totalPage,
        countData: countData,
      ),
    ));
  }

  Future<bool> unsecurePhoto(String photoId) async {
    emit(state.copyWith(status: SecurePhotoStatus.loading));

    final result = await domain.securePhoto.unsecurePhoto(photoId);

    if (result.isSuccess) {
      _allSecurePhotos.removeWhere((photo) => photo.id == photoId);

      final updatedPhotos =
          state.securePhotos.where((photo) => photo.id != photoId).toList();

      final updatedPagination = state.securePhotosPagination.copyWith(
        data: updatedPhotos,
      );

      emit(state.copyWith(
        status: SecurePhotoStatus.success,
        securePhotosPagination: updatedPagination,
      ));
      XToast.success(S.text.common_secure_photo_vault_remove_security_success);
      return true;
    } else {
      emit(state.copyWith(
        status: SecurePhotoStatus.error,
      ));
      XToast.error(S.text.error_somethingWrongTryAgain);
      return false;
    }
  }

  Future<bool> downloadSecurePhoto(String photoUrl) async {
    emit(state.copyWith(status: SecurePhotoStatus.loading));
    final result = await domain.securePhoto.downloadSecurePhoto(photoUrl);
    if (!result.isSuccess) {
      emit(state.copyWith(
        status: SecurePhotoStatus.error,
      ));
      XToast.error(S.text.error_somethingWrongTryAgain);
      return false;
    }
    emit(state.copyWith(
      status: SecurePhotoStatus.success,
    ));
    return true;
  }

  Future<void> refresh() async {
    await syncCurrentUser();
    _allSecurePhotos = [];
    emit(state.copyWith(
      securePhotosPagination: MPagination<MPhotoItem>(pageLimit: 20),
    ));
    await loadSecurePhotos();
  }

  Future<void> checkBiometricSupport() async {
    final auth = LocalAuthentication();
    final isSupported = await auth.isDeviceSupported();
    emit(state.copyWith(isBiometricSupported: isSupported));
  }

  void resetVerification() {
    emit(state.copyWith(isVaultVerified: false));
  }

  void setCreateMode(bool value) {
    emit(state.copyWith(isCreateMode: value));
  }

  Future<bool> changePassword() async {
    if (_currentUserId == null || _currentUserId!.isEmpty) return false;

    emit(state.copyWith(status: SecurePhotoStatus.loading));

    final result = await _securePhotoService.changePassword(
      userId: _currentUserId!,
      oldPassword: state.oldPassword.value,
      newPassword: state.newPassword.value,
    );

    if (result.isSuccess && result.data == true) {
      emit(state.copyWith(status: SecurePhotoStatus.success));
      resetChangePasswordFields();
      XToast.success(S.text.common_change_password_success);
      return true;
    } else {
      emit(state.copyWith(status: SecurePhotoStatus.error));
      XToast.error(result.error ?? S.text.error_somethingWrongTryAgain);
      return false;
    }
  }

  Future<void> authenticateWithBiometrics() async {
    emit(state.copyWith(status: SecurePhotoStatus.loading));

    final result = await _securePhotoService.authenticateWithBiometrics();

    if (result.isSuccess) {
      final didAuthenticate = result.data ?? false;
      if (didAuthenticate) {
        emit(state.copyWith(
          status: SecurePhotoStatus.success,
          isVaultVerified: true,
        ));
        AppCoordinator.showSecurePhotoScreen();
      } else {
        emit(state.copyWith(
          status: SecurePhotoStatus.success,
        ));
      }
    } else {
      emit(state.copyWith(
        status: SecurePhotoStatus.error,
      ));
      XToast.error(S.text.error_somethingWrongTryAgain);
    }
  }

  void onPasswordChanged(String value) {
    emit(state.copyWith(
      password: PasswordFormzInput.dirty(value),
    ));
  }

  void onConfirmPasswordChanged(String value) {
    emit(state.copyWith(
      confirmPassword: ConfirmPasswordFormzInput.dirty(
        password: state.password.value,
        value: value,
      ),
    ));
  }

  void onOldPasswordChanged(String value) {
    emit(state.copyWith(
      oldPassword: PasswordFormzInput.dirty(value),
    ));
  }

  void onNewPasswordChanged(String value) {
    emit(state.copyWith(
      newPassword: PasswordFormzInput.dirty(value),
      confirmNewPassword: ConfirmPasswordFormzInput.dirty(
        password: value,
        value: state.confirmNewPassword.value,
      ),
    ));
  }

  void onConfirmNewPasswordChanged(String value) {
    emit(state.copyWith(
      confirmNewPassword: ConfirmPasswordFormzInput.dirty(
        password: state.newPassword.value,
        value: value,
      ),
    ));
  }

  void resetChangePasswordFields() {
    emit(state.copyWith(
      oldPassword: const PasswordFormzInput.pure(''),
      newPassword: const PasswordFormzInput.pure(''),
      confirmNewPassword: const ConfirmPasswordFormzInput.pure(),
    ));
  }
}
