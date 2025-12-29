import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myapp/src/dialogs/toast_wrapper.dart';
import 'package:myapp/src/localization/localization_utils.dart';
import './internet_connection_cubit.dart';

class InternetListener extends StatelessWidget {
  final Widget child;
  const InternetListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<InternetConnectionCubit, InternetStatusState>(
      listenWhen: (previous, current) {
        return (previous == InternetStatusState.disconnected) !=
            (current == InternetStatusState.disconnected);
      },
      listener: (context, state) {
        if (state == InternetStatusState.disconnected) {
          XToast.error(S.of(context).common_offline_mode);
        } else {
          XToast.success(S.of(context).common_online_mode);
        }
      },
      child: child,
    );
  }
}
