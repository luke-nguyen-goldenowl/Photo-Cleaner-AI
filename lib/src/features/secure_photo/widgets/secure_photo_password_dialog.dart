import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/features/secure_photo/logic/secure_photo_bloc.dart';
import 'package:myapp/src/features/secure_photo/logic/secure_photo_state.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/widgets/forms/input.dart';

class SecurePhotoPasswordDialog extends StatefulWidget {
  const SecurePhotoPasswordDialog({
    super.key,
  });

  @override
  State<SecurePhotoPasswordDialog> createState() =>
      _SecurePhotoPasswordDialogState();
}

class _SecurePhotoPasswordDialogState extends State<SecurePhotoPasswordDialog> {
  @override
  void initState() {
    super.initState();
    context.read<SecurePhotoBloc>().checkBiometricSupport();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SecurePhotoBloc, SecurePhotoState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.confirmPassword != current.confirmPassword ||
          previous.isBiometricSupported != current.isBiometricSupported,
      builder: (context, state) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
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
                              S.of(context).common_secure_photo_vault_title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF091031),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.isCreateMode
                                  ? S
                                      .of(context)
                                      .common_secure_photo_vault_description
                                  : S
                                      .of(context)
                                      .common_secure_photo_vault_authentication_description,
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
                    value: state.password.value,
                    hintText: S.of(context).common_passwordTitle,
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    onChanged: (value) {
                      context.read<SecurePhotoBloc>().onPasswordChanged(value);
                    },
                    errorText: state.password.errorOf(context),
                  ),
                  if (state.isBiometricSupported && !state.isCreateMode) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        context
                            .read<SecurePhotoBloc>()
                            .authenticateWithBiometrics();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.fingerprint,
                              size: 45, color: Color(0xFF6C63FF)),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ],
                  if (state.isCreateMode) ...[
                    const SizedBox(height: 16),
                    XInput(
                      value: state.confirmPassword.value,
                      hintText: S.of(context).common_confirmPass_signUp,
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      onChanged: (value) {
                        context
                            .read<SecurePhotoBloc>()
                            .onConfirmPasswordChanged(value);
                      },
                      errorText: state.confirmPassword.errorOf(context),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Color(0xFF6C63FF)),
                          ),
                          child: Text(
                            S.of(context).common_cancelButton_title,
                            style: TextStyle(
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
                              onPressed: state.isValidated
                                  ? () {
                                      Navigator.of(context)
                                          .pop(state.password.value.trim());
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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
          ),
        );
      },
    );
  }
}
