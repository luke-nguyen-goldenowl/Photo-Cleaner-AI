import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/features/authentication/logic/signin_bloc.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/widgets/button/primary_button.dart';
import 'package:myapp/widgets/forms/input.dart';
import 'package:myapp/widgets/header/screen_header.dart';
import 'package:myapp/widgets/logo/app_logo.dart';

class SigninView extends StatelessWidget {
  const SigninView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SigninBloc(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: BlocBuilder<SigninBloc, SigninState>(builder: _builder),
          ),
        ),
      ),
    );
  }

  Widget _builder(BuildContext context, SigninState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const XAppLogo(),
          XScreenHeader(
            title: S.of(context).common_appTitle,
            subtitle: S.of(context).common_subTitle_Signin,
          ),
          const SizedBox(height: 40),
          XInput(
            hintText: S.of(context).common_emailTitle,
            prefixIcon: Icons.email_outlined,
            onChanged: (value) {
              context.read<SigninBloc>().onEmailChanged(value);
            },
            value: state.email.value,
          ),
          const SizedBox(height: 20),
          XInput(
            value: state.password.value,
            hintText: S.of(context).common_passwordTitle,
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            onChanged: (value) {
              context.read<SigninBloc>().onPasswordChanged(value);
            },
          ),
          const SizedBox(height: 10),
          XPrimaryButton(
            text: S.of(context).common_buttonSignin_Title,
            onPressed: state.isValidated
                ? () {
                    context.read<SigninBloc>().loginWithEmail(context);
                  }
                : null,
          ),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () {
              AppCoordinator.showForgotPasswordScreen();
            },
            child: Text(
              S.of(context).common_forgotPass_Title,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  S.of(context).common_Or_Title,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<SigninBloc>().loginWithGoogle(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                shadowColor: Colors.black.withOpacity(0.08),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image,
                          size: 24, color: Colors.grey);
                    },
                  ),
                  const SizedBox(width: 12),
                  Text(
                    S.of(context).sign_signin_signinWithGoogle,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                S.of(context).common_dontHaveAccount_title,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              GestureDetector(
                onTap: () {
                  AppCoordinator.showSignUpScreen();
                },
                child: Text(
                  S.of(context).common_SignupNow_title,
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
