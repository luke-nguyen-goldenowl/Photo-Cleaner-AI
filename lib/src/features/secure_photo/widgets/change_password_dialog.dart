import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/features/secure_photo/logic/secure_photo_bloc.dart';
import 'package:myapp/src/features/secure_photo/logic/secure_photo_state.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/widgets/forms/input.dart';

class ChangePasswordDialog extends StatelessWidget {
  const ChangePasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SecurePhotoBloc, SecurePhotoState>(
      buildWhen: (previous, current) =>
          previous.oldPassword != current.oldPassword ||
          previous.newPassword != current.newPassword ||
          previous.confirmNewPassword != current.confirmNewPassword,
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Color(0xFF6C63FF),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).common_change_password_title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF091031),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            S.of(context).common_change_password_description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                XInput(
                  value: state.oldPassword.value,
                  hintText: S.of(context).common_old_password,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  onChanged: (value) {
                    context.read<SecurePhotoBloc>().onOldPasswordChanged(value);
                  },
                  errorText: state.oldPassword.errorOf(context),
                ),
                const SizedBox(height: 16),
                XInput(
                  value: state.newPassword.value,
                  hintText: S.of(context).common_new_password,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  onChanged: (value) {
                    context.read<SecurePhotoBloc>().onNewPasswordChanged(value);
                  },
                  errorText: state.isDuplicatePassword
                      ? S.of(context).error_same_password
                      : state.newPassword.errorOf(context),
                ),
                const SizedBox(height: 16),
                XInput(
                  value: state.confirmNewPassword.value,
                  hintText: S.of(context).common_confirm_new_password,
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  onChanged: (value) {
                    context
                        .read<SecurePhotoBloc>()
                        .onConfirmNewPasswordChanged(value);
                  },
                  errorText: state.confirmNewPassword.errorOf(context),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context
                              .read<SecurePhotoBloc>()
                              .resetChangePasswordFields();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFF6C63FF)),
                        ),
                        child: Text(
                          S.of(context).common_cancelButton_title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BlocBuilder<SecurePhotoBloc, SecurePhotoState>(
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state.isChangePasswordValidated
                                ? () {
                                    Navigator.of(context).pop(true);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFF6C63FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              S.of(context).common_agreeButton_title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
