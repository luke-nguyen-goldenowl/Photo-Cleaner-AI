import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:myapp/src/network/model/user/user.dart';
import 'package:myapp/src/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: camel_case_types
class _keys {
  static const String theme = 'app-theme';
  static const String user = 'user';
  static const String token = 'token';
  static const String loginProvider = 'login_provider';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String isLoggedIn = 'is_logged_in';
}

class UserPrefs {
  factory UserPrefs() => instance;
  UserPrefs._internal();

  static final UserPrefs instance = UserPrefs._internal();
  static UserPrefs get I => instance;
  late SharedPreferences _prefs;
  Future initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // theme
  ThemeMode getTheme() {
    final value = _prefs.getString(_keys.theme);
    return ThemeMode.values.firstWhere(
      (e) => e.toString().toLowerCase() == '$value'.toLowerCase(),
      orElse: () => ThemeMode.system,
    );
  }

  void setTheme(ThemeMode value) {
    _prefs.setString(_keys.theme, value.toString().toLowerCase());
  }

  String getToken() {
    try {
      return _prefs.getString(_keys.token) ?? '';
    } catch (_) {}
    return '';
  }

  void setToken(String? value) {
    if (value == null) {
      _prefs.remove(_keys.token);
    } else {
      _prefs.setString(_keys.token, value);
    }
  }

  // user
  Future<void> setUser(MUser? value) async {
    if (value == null) {
      _prefs.remove(_keys.user);
    } else {
      _prefs.setString(_keys.user, jsonEncode(value.toJson()));
    }
  }

  MUser? getUser() {
    final value = _prefs.getString(_keys.user);
    try {
      if ((value ?? '').isEmpty) {
        return null;
      } else {
        final map = jsonDecode(value!);
        if (map['id'] == null) {
          return null;
        } else {
          return MUser.fromJson(map);
        }
      }
    } catch (e) {
      xLog.e(e);
      return null;
    }
  }

  Future<void> setLoginProvider(String? value) async {
    if (value == null) {
      _prefs.remove(_keys.loginProvider);
    } else {
      _prefs.setString(_keys.loginProvider, value);
    }
  }

  String? getLoginProvider() {
    try {
      return _prefs.getString(_keys.loginProvider);
    } catch (_) {
      return null;
    }
  }

  void clearLoginProvider() {
    _prefs.remove(_keys.loginProvider);
  }

  bool hasSeenOnboarding() {
    try {
      return _prefs.getBool(_keys.hasSeenOnboarding) ?? false;
    } catch (_) {
      return false;
    }
  }

  void setHasSeenOnboarding(bool value) {
    _prefs.setBool(_keys.hasSeenOnboarding, value);
  }

  bool isLoggedIn() {
    try {
      return _prefs.getBool(_keys.isLoggedIn) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> setIsLoggedIn(bool value) async {
    _prefs.setBool(_keys.isLoggedIn, value);
  }

  Future<void> clearAll() async {
    await _prefs.remove(_keys.user);
    await _prefs.remove(_keys.token);
    await _prefs.remove(_keys.loginProvider);
    await _prefs.remove(_keys.isLoggedIn);
  }
}
