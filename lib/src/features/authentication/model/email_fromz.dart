import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'form_error.dart';

class EmailFormzInput extends FormzInput<String, FormError> {
  const EmailFormzInput.pure([super.value = '']) : super.pure();
  const EmailFormzInput.dirty([super.value = '']) : super.dirty();

  static final RegExp emailRegExp = RegExp(
    r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[\w-]{2,}$',
  );

  @override
  FormError? validator(String? value) {
    if ((value ?? '').isEmpty) {
      return FormError.empty;
    }
    return emailRegExp.hasMatch(value ?? '') ? null : FormError.invalid;
  }

  String? errorOf(BuildContext context) {
    if (isPure) {
      return null;
    }

    switch (error) {
      case FormError.empty:
        return S.of(context).error_fieldRequired;
      case FormError.invalid:
        return S.of(context).error_invalidEmail;
      default:
        return null;
    }
  }
}
