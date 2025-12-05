import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/generated/i18n/app_localizations.dart';
import 'package:myapp/src/features/authentication/logic/signup_bloc.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/widgets/button/primary_button.dart';
import 'package:myapp/widgets/forms/input.dart';
import 'package:myapp/widgets/header/screen_header.dart';
import 'package:myapp/widgets/logo/app_logo.dart';

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
          XScreenHeader(
            title: AppLocalizations.of(context)!.common_appTitle,
            subtitle: AppLocalizations.of(context)!.common_signUp_subTitle,
          ),
          const SizedBox(height: 30),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              XInput(
                value: state.name.value,
                hintText: AppLocalizations.of(context)!.common_userName_signUp,
                prefixIcon: Icons.person_outline,
                onChanged: (value) {
                  context.read<SignupBloc>().onNameChanged(value);
                },
                errorText:
                    !state.name.isPure ? state.name.errorOf(context) : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              XInput(
                value: state.email.value,
                hintText: AppLocalizations.of(context)!.common_emailTitle,
                prefixIcon: Icons.email_outlined,
                onChanged: (value) {
                  context.read<SignupBloc>().onEmailChanged(value);
                },
                errorText:
                    !state.email.isPure ? state.email.errorOf(context) : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              XInput(
                value: state.password.value,
                hintText: AppLocalizations.of(context)!.common_passwordTitle,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                onChanged: (value) {
                  context.read<SignupBloc>().onPasswordChanged(value);
                },
                errorText: !state.password.isPure
                    ? state.password.errorOf(context)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              XInput(
                value: state.confirmPassword.value,
                hintText:
                    AppLocalizations.of(context)!.common_confirmPass_signUp,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                onChanged: (value) {
                  context.read<SignupBloc>().onConfirmPasswordChanged(value);
                },
                errorText: !state.confirmPassword.isPure
                    ? state.confirmPassword.errorOf(context)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 10),
          XPrimaryButton(
            text: AppLocalizations.of(context)!.common_buttonSignUp_title,
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
              Text(AppLocalizations.of(context)!.common_haveAccount_title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              GestureDetector(
                onTap: () {
                  AppCoordinator.showSignInScreen();
                },
                child: Text(
                  AppLocalizations.of(context)!.common_buttonSignin_Title,
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
