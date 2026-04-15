import 'package:equatable/equatable.dart';

/// Entidad de comercio en la capa de dominio
class CommerceEntity extends Equatable {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final String? phone;
  final String? email;
  final String? logo;
  final List<String> photos;
  final double rating;
  final int totalPromotions;
  final bool isPremium;
  final String? ownerId;
  final DateTime createdAt;

  const CommerceEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.phone,
    this.email,
    this.logo,
    this.photos = const [],
    this.rating = 0.0,
    this.totalPromotions = 0,
    this.isPremium = false,
    this.ownerId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        latitude,
        longitude,
        address,
        phone,
        email,
        logo,
        photos,
        rating,
        totalPromotions,
        isPremium,
        ownerId,
        createdAt,
      ];

  /// Copia la entidad con campos actualizados
  CommerceEntity copyWith({
    String? id,
    String? name,
    String? type,
    double? latitude,
    double? longitude,
    String? address,
    String? phone,
    String? email,
    String? logo,
    List<String>? photos,
    double? rating,
    int? totalPromotions,
    bool? isPremium,
    String? ownerId,
    DateTime? createdAt,
  }) {
    return CommerceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logo: logo ?? this.logo,
      photos: photos ?? this.photos,
      rating: rating ?? this.rating,
      totalPromotions: totalPromotions ?? this.totalPromotions,
      isPremium: isPremium ?? this.isPremium,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Made with Bob
