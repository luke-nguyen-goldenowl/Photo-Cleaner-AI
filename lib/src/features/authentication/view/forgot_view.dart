import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/features/authentication/logic/forgot_bloc.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import 'package:myapp/src/router/coordinator.dart';
import 'package:myapp/widgets/button/primary_button.dart';
import 'package:myapp/widgets/forms/input.dart';
import 'package:myapp/widgets/header/screen_header.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  Timer? _resendTimer;
  int _resendCountdown = 0;

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ForgotBloc(),
      child: BlocListener<ForgotBloc, ForgotState>(
        listener: (context, state) {
          if (state.currentStep == ForgotPasswordStep.enterOtp &&
              _resendCountdown == 0) {
            _startResendTimer();
          }
          if (state.currentStep == ForgotPasswordStep.enterEmail) {
            _resendTimer?.cancel();
            setState(() {
              _resendCountdown = 0;
            });
          }
        },
        child: BlocBuilder<ForgotBloc, ForgotState>(
          builder: (context, ForgotState state) {
            return Scaffold(
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: state.currentStep != ForgotPasswordStep.enterEmail
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          context.read<ForgotBloc>().goBack();
                        },
                      )
                    : null,
              ),
              body: Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50),
                    child: _buildCurrentStep(context, state),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, ForgotState state) {
    switch (state.currentStep) {
      case ForgotPasswordStep.enterEmail:
        return _buildEnterEmailStep(context, state);
      case ForgotPasswordStep.enterOtp:
        return _buildEnterOtpStep(context, state);
      case ForgotPasswordStep.resetPassword:
        return _buildResetPasswordStep(context, state);
    }
  }

  Widget _buildEnterEmailStep(BuildContext context, ForgotState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_unread_outlined,
            size: 80, color: Color(0xFF6C63FF)),
        XScreenHeader(
          title: S.of(context).common_forgotPass_Title,
          subtitle: S.of(context).common_forgotPass_subTitle,
        ),
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            XInput(
              value: state.email.value,
              hintText: S.of(context).common_emailTitle,
              prefixIcon: Icons.email_outlined,
              onChanged: (value) {
                context.read<ForgotBloc>().onEmailChanged(value);
              },
              errorText:
                  !state.email.isPure ? state.email.errorOf(context) : null,
            ),
          ],
        ),
        const SizedBox(height: 20),
        XPrimaryButton(
          text: S.of(context).common_button_senOTP,
          onPressed: state.isValidated
              ? () {
                  context.read<ForgotBloc>().sendOtpToEmail(context);
                }
              : null,
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            AppCoordinator.showSignInScreen();
          },
          child: Text(
            S.of(context).common_button_gobackLogin,
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnterOtpStep(BuildContext context, ForgotState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.pin_outlined, size: 80, color: Color(0xFF6C63FF)),
        XScreenHeader(
          title: S.of(context).common_sendOTP_Title,
          subtitle: S.of(context).common_sendOTP_subTitle,
        ),
        const SizedBox(height: 40),
        XInput(
          hintText: S.of(context).common_hintTextOTP,
          prefixIcon: Icons.lock_outline,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            context.read<ForgotBloc>().onOtpChanged(value);
            if (value.length == 6) {
              context.read<ForgotBloc>().verifyOtp(context);
            }
          },
          value: state.otp,
        ),
        const SizedBox(height: 20),
        XPrimaryButton(
          text: S.of(context).common_button_verify,
          onPressed: state.isOtpValid
              ? () {
                  context.read<ForgotBloc>().verifyOtp(context);
                }
              : null,
        ),
        const SizedBox(height: 20),
        _resendCountdown > 0
            ? Text(
                '${S.of(context).common_sendOTPAgain_s} $_resendCountdown s',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              )
            : GestureDetector(
                onTap: () {
                  context.read<ForgotBloc>().resendOtp(context);
                  _startResendTimer();
                },
                child: Text(
                  S.of(context).common_sendOTPAgain,
                  style: const TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildResetPasswordStep(BuildContext context, ForgotState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_reset, size: 80, color: Color(0xFF6C63FF)),
        XScreenHeader(
          title: S.of(context).common_recoverPass_title,
          subtitle: S.of(context).common_recoverPass_subTitle,
        ),
        const SizedBox(height: 40),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            XInput(
              value: state.password.value,
              hintText: S.of(context).common_passwordTitle,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              onChanged: (value) {
                context.read<ForgotBloc>().onPasswordChanged(value);
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
              hintText: S.of(context).common_confirmPass_signUp,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              onChanged: (value) {
                context.read<ForgotBloc>().onConfirmPasswordChanged(value);
              },
              errorText: !state.confirmPassword.isPure
                  ? state.confirmPassword.errorOf(context)
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 20),
        XPrimaryButton(
          text: S.of(context).common_recoverPass_title,
          onPressed: state.isPasswordValid
              ? () {
                  context.read<ForgotBloc>().resetPassword(context);
                }
              : null,
        ),
      ],
    );
  }
}
