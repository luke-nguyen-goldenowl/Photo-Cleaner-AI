import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/features/authentication/logic/signup_bloc.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/widgets/button/primary_button.dart';
import 'package:myapp/widgets/header/screen_header.dart';
import 'package:myapp/widgets/logo/app_logo.dart';
import 'package:myapp/widgets/text_field/custom_text_field.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignupBloc(),
      child: BlocBuilder<SignupBloc, SignupState>(
        builder: (context, SignupState state) {
          return Scaffold(
            body: Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: _builder(context, state),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _builder(BuildContext context, SignupState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          const XAppLogo(),
          const XScreenHeader(
            title: 'Pixel Perfect',
            subtitle:
                'Tạo tài khoản tham gia cộng đồng Pixel Perfect để tối ưu hóa thư viện ảnh của bạn.',
          ),
          const SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              XCustomTextField(
                hintText: 'Tên người dùng',
                prefixIcon: Icons.person_outline,
                onChanged: (value) {
                  context.read<SignupBloc>().onNameChanged(value);
                },
              ),
              if (state.isDirty && state.name.value.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 2),
                  child: Text(
                    'Tên người dùng không được để trống',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              XCustomTextField(
                hintText: 'Email',
                prefixIcon: Icons.email_outlined,
                onChanged: (value) {
                  context.read<SignupBloc>().onEmailChanged(value);
                },
              ),
              if (state.isDirty &&
                  state.email.value.isNotEmpty &&
                  state.email.isNotValid)
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 2),
                  child: Text(
                    'Email không hợp lệ',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              XCustomTextField(
                hintText: 'Mật khẩu',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                onChanged: (value) {
                  context.read<SignupBloc>().onPasswordChanged(value);
                },
              ),
              if (state.isDirty &&
                  state.password.value.isNotEmpty &&
                  state.password.isNotValid)
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 2),
                  child: Text(
                    'Mật khẩu không hợp lệ. Yêu cầu ít nhất 6 ký tự',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              XCustomTextField(
                hintText: 'Xác nhận mật khẩu',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                onChanged: (value) {
                  context.read<SignupBloc>().onConfirmPasswordChanged(value);
                },
              ),
              if (state.isDirty &&
                  state.confirmPassword.isNotEmpty &&
                  !state.isConfirmPasswordValid)
                const Padding(
                  padding: EdgeInsets.only(left: 12, top: 2),
                  child: Text(
                    'Xác nhận mật khẩu không khớp',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          XPrimaryButton(
            text: 'Đăng Ký',
            onPressed: state.isValidated
                ? () {
                    context.read<SignupBloc>().signupWithEmail(context);
                  }
                : null,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Đã có tài khoản? ',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              GestureDetector(
                onTap: () {
                  AppCoordinator.showSignInScreen();
                },
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
