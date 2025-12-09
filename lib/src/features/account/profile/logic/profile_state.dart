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
    this.errorMessage,
  });

  final ProfileStatus status;
  final MUser? user;
  final int photoCount;
  final int friendCount;
  final String? errorMessage;

  bool get isLoading => status == ProfileStatus.loading;
  bool get isLoaded => status == ProfileStatus.loaded;
  bool get hasError => status == ProfileStatus.error;

  @override
  List<Object?> get props => [
        status,
        user,
        photoCount,
        friendCount,
        errorMessage,
      ];

  ProfileState copyWith({
    ProfileStatus? status,
    MUser? user,
    int? photoCount,
    int? friendCount,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      photoCount: photoCount ?? this.photoCount,
      friendCount: friendCount ?? this.friendCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
