import 'dart:async';
import 'package:myapp/src/network/domain_manager.dart';
import 'package:myapp/src/network/model/common/result.dart';
import 'package:myapp/src/services/network-connection/internet_connection_cubit.dart';
import 'package:myapp/src/services/user_prefs.dart';

class FavoritePhotoSyncService {
  factory FavoritePhotoSyncService() => instance;
  FavoritePhotoSyncService._internal();
  static final FavoritePhotoSyncService instance =
      FavoritePhotoSyncService._internal();
  static FavoritePhotoSyncService get I => instance;

  StreamSubscription<InternetStatusState>? _subscription;
  DomainManager get domain => DomainManager();
  bool _isSyncing = false;

  void initialize(InternetConnectionCubit cubit) {
    _subscription?.cancel();
    _subscription = cubit.stream.listen((state) {
      if (state == InternetStatusState.connected) {
        _onInternetConnected();
      }
    });
  }

  Future<void> _onInternetConnected() async {
    final userId = UserPrefs.I.getUser()?.id;
    if (userId == null || userId.isEmpty) return;

    await syncAllPending(userId);
  }

  Future<MResult<void>> syncAllPending(String userId) async {
    if (_isSyncing) return MResult.success(null);

    _isSyncing = true;
    try {
      final hasPending = await domain.favoritePhoto.hasPendingUploads(userId);
      if (!hasPending) return MResult.success(null);

      await domain.favoritePhoto.syncPendingUploads(userId);
    } catch (e) {
      return MResult.exception(e);
    } finally {
      _isSyncing = false;
    }
    return MResult.success(null);
  }

  Future<void> triggerSync() async {
    final userId = UserPrefs.I.getUser()?.id;
    if (userId == null || userId.isEmpty) return;

    await syncAllPending(userId);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
