part of 'profile_edit_bloc.dart';

enum ProfileEditStatus {
  initial,
  loading,
  uploading,
  success,
  error,
}

class ProfileEditState extends Equatable {
  const ProfileEditState({
    required this.name,
    required this.bio,
    this.status = ProfileEditStatus.initial,
    this.user,
    this.avatarUrl,
    this.localAvatarPath,
    this.uploadProgress = 0.0,
  });

  final ProfileEditStatus status;
  final MUser? user;
  final NameFormzInput name;
  final BioFormzInput bio;
  final String? avatarUrl;
  final String? localAvatarPath;
  final double uploadProgress;

  bool get isLoading => status == ProfileEditStatus.loading;
  bool get isUploading => status == ProfileEditStatus.uploading;
  bool get isValidated => Formz.validate([name, bio]);
  bool get hasChanges =>
      (name.value != user?.name) ||
      (bio.value != user?.bio) ||
      localAvatarPath != null;

  @override
  List<Object?> get props => [
        status,
        user,
        name,
        bio,
        avatarUrl,
        localAvatarPath,
        uploadProgress,
      ];

  ProfileEditState copyWith({
    ProfileEditStatus? status,
    MUser? user,
    NameFormzInput? name,
    BioFormzInput? bio,
    String? avatarUrl,
    String? localAvatarPath,
    double? uploadProgress,
  }) {
    return ProfileEditState(
      status: status ?? this.status,
      user: user ?? this.user,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      localAvatarPath: localAvatarPath ?? this.localAvatarPath,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}
