import 'package:equatable/equatable.dart';

class MSecurePhoto extends Equatable {
  const MSecurePhoto({
    required this.id,
    required this.vaultId,
    required this.fileUrl,
    this.createdAt,
  });

  final String id;
  final int vaultId;
  final String fileUrl;
  final DateTime? createdAt;
  factory MSecurePhoto.fromJson(Map<String, dynamic> json) {
    return MSecurePhoto(
      id: json['id'].toString(),
      vaultId: (json['vaultId'] ?? json['vaultId']) as int,
      fileUrl: (json['fileUrl'] ?? json['fileUrl']).toString(),
      createdAt: (json['createdAt'] ?? json['createdAt']) != null
          ? DateTime.parse((json['createdAt'] ?? json['createdAt']).toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vaultId': vaultId,
      'fileUrl': fileUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, vaultId, fileUrl, createdAt];
}
