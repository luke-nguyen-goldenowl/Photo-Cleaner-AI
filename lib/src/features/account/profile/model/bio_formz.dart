import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

enum BioValidationError { tooLong }

class BioFormzInput extends FormzInput<String, BioValidationError> {
  const BioFormzInput.pure([super.value = '']) : super.pure();
  const BioFormzInput.dirty([super.value = '']) : super.dirty();

  @override
  BioValidationError? validator(String? value) {
    if (value == null) return null;
    if (value.length > 200) return BioValidationError.tooLong;
    return null;
  }

  String? errorOf(BuildContext context) {
    if (isPure) {
      return null;
    }
    switch (error) {
      case BioValidationError.tooLong:
        return 'Bio không được quá 200 ký tự';
      default:
        return null;
    }
  }
}
