import 'package:flutter/material.dart';
import 'package:formz/formz.dart';
import 'package:myapp/src/features/authentication/model/form_error.dart';

class SearchQueryFormz extends FormzInput<String, FormError> {
  const SearchQueryFormz.pure([super.value = '']) : super.pure();
  const SearchQueryFormz.dirty([super.value = '']) : super.dirty();

  @override
  FormError? validator(String? value) {
    return null;
  }

  String? errorOf(BuildContext context) {
    return null;
  }
}
