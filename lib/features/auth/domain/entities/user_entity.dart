import 'package:equatable/equatable.dart';

/// Entidad de usuario en la capa de dominio
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final int reputation;
  final List<String> badges;
  final List<String> savedPromotions;
  final double totalSavings;
  final DateTime createdAt;
  final bool isCommerce;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phone,
    this.latitude,
    this.longitude,
    this.reputation = 0,
    this.badges = const [],
    this.savedPromotions = const [],
    this.totalSavings = 0.0,
    required this.createdAt,
    this.isCommerce = false,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        photoUrl,
        phone,
        latitude,
        longitude,
        reputation,
        badges,
        savedPromotions,
        totalSavings,
        createdAt,
        isCommerce,
      ];

  /// Copia la entidad con campos actualizados
  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? phone,
    double? latitude,
    double? longitude,
    int? reputation,
    List<String>? badges,
    List<String>? savedPromotions,
    double? totalSavings,
    DateTime? createdAt,
    bool? isCommerce,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      reputation: reputation ?? this.reputation,
      badges: badges ?? this.badges,
      savedPromotions: savedPromotions ?? this.savedPromotions,
      totalSavings: totalSavings ?? this.totalSavings,
      createdAt: createdAt ?? this.createdAt,
      isCommerce: isCommerce ?? this.isCommerce,
    );
  }
}

// Made with Bob
