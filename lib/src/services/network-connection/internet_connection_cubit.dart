import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

enum InternetStatusState { connected, disconnected }

class InternetConnectionCubit extends Cubit<InternetStatusState> {
  final InternetConnection _internetConnection = InternetConnection();
  late StreamSubscription<InternetStatus> _subscription;

  InternetConnectionCubit() : super(InternetStatusState.connected) {
    _subscription = _internetConnection.onStatusChange.listen((status) {
      if (status == InternetStatus.connected) {
        emit(InternetStatusState.connected);
      } else {
        emit(InternetStatusState.disconnected);
      }
    });
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
