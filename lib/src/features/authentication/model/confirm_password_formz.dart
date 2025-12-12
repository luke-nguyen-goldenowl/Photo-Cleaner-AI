import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:myapp/src/features/authentication/model/form_error.dart';
import 'package:myapp/src/localization/localization_utils.dart';

class ConfirmPasswordFormzInput extends FormzInput<String, FormError> {
  final String password;
  const ConfirmPasswordFormzInput.pure({this.password = '', String value = ''})
      : super.pure(value);
  const ConfirmPasswordFormzInput.dirty(
      {required this.password, required String value})
      : super.dirty(value);

  @override
  FormError? validator(String? value) {
    if ((value ?? '').isEmpty) {
      return FormError.empty;
    }
    return value == password ? null : FormError.invalid;
  }

  String? errorOf(BuildContext context) {
    if (isPure) {
      return null;
    }

    switch (error) {
      case FormError.empty:
        return S.of(context).error_fieldRequired;
      case FormError.invalid:
        return S.of(context).error_confirmPasswordMismatch;
      default:
        return null;
    }
  }
}
