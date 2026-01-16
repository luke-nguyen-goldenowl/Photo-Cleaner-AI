import 'package:equatable/equatable.dart';

class MSecureVault extends Equatable {
  const MSecureVault({
    required this.id,
    required this.userId,
    required this.passwordHash,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String passwordHash;
  final DateTime? createdAt;
  factory MSecureVault.fromJson(Map<String, dynamic> json) {
    return MSecureVault(
      id: json['id'].toString(),
      userId: (json['userId'] ?? json['userId']).toString(),
      passwordHash: (json['passwordHash'] ?? json['passwordHash']).toString(),
      createdAt: (json['createdAt'] ?? json['createdAt']) != null
          ? DateTime.parse((json['createdAt'] ?? json['createdAt']).toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'passwordHash': passwordHash,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, userId, passwordHash, createdAt];
}
