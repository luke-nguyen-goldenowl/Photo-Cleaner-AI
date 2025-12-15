import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/network/model/user/user.dart';

abstract class UserRepository {
  Future<MResult<MUser>> getUser(String id);
  Future<MResult<MUser>> getOrAddUser(MUser user);
  Future<MResult<List<MUser>>> getUsers();
  Future<MResult<MUser>> getUserFromSupabase(
      String email, BuildContext context);
  Future<MResult<String>> uploadAvatar(File imageFile, String userId);
  Future<MResult<MUser>> updateUser(MUser user);
}
