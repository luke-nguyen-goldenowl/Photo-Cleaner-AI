import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Mất kết nối Internet"),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đã kết nối mạng lại"),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: child,
    );
  }
}
