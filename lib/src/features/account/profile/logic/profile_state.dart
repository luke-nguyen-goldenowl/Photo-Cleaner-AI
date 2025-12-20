part of 'profile_bloc.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  error,
}

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.photoCount = 0,
    this.friendCount = 0,
  });

  final ProfileStatus status;
  final MUser? user;
  final int photoCount;
  final int friendCount;

  bool get isLoading => status == ProfileStatus.loading;
  bool get isLoaded => status == ProfileStatus.loaded;
  bool get hasError => status == ProfileStatus.error;

  @override
  List<Object?> get props => [
        status,
        user,
        photoCount,
        friendCount,
      ];

  ProfileState copyWith({
    ProfileStatus? status,
    MUser? user,
    int? photoCount,
    int? friendCount,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      photoCount: photoCount ?? this.photoCount,
      friendCount: friendCount ?? this.friendCount,
    );
  }
}
