There were some issues with the workflows created. 

in CI / Quality Gates (Pull request): 

The job is failing due to type safety errors in your Dart code. The analyzer found 147 issues, with the primary problems being:

    Dynamic type assignments to typed parameters - JSON parsing is returning dynamic values that aren't being properly cast to expected types
    Removed/deprecated lints - avoid_returning_null_for_future was removed in Dart 3.3.0
    Deprecated color methods - withOpacity() should be replaced with withValues()

Primary Issues to Fix
1. UserModel.fromJson() - Lines 43-65

The main issue: json['id'], json['email'], and json['name'] are dynamic and can't be directly assigned to String parameters.

Fix:
Dart

factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: (json['id'] as String?) ?? '',
    email: (json['email'] as String?) ?? '',
    name: (json['name'] as String?) ?? '',
    photoUrl: json['photo_url'] as String?,
    phone: json['phone'] as String?,
    latitude: json['latitude'] != null
        ? (json['latitude'] as num).toDouble()
        : null,
    longitude: json['longitude'] != null
        ? (json['longitude'] as num).toDouble()
        : null,
    reputation: (json['reputation'] as int?) ?? 0,
    badges: json['badges'] != null 
        ? List<String>.from(json['badges'] as List)
        : [],
    savedPromotions: json['saved_promotions'] != null
        ? List<String>.from(json['saved_promotions'] as List)
        : [],
    totalSavings: json['total_savings'] != null
        ? (json['total_savings'] as num).toDouble()
        : 0.0,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
    isCommerce: (json['is_commerce'] as bool?) ?? false,
  );
}

2. LocationModel.fromJson() - Lines 30-47

Missing null checks and type casting:
Dart

factory LocationModel.fromJson(Map<String, dynamic> json) {
  return LocationModel(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    accuracy: json['accuracy'] != null
        ? (json['accuracy'] as num).toDouble()
        : null,
    altitude: json['altitude'] != null
        ? (json['altitude'] as num).toDouble()
        : null,
    heading: json['heading'] != null 
        ? (json['heading'] as num).toDouble() 
        : null,
    speed: json['speed'] != null 
        ? (json['speed'] as num).toDouble() 
        : null,
    timestamp: json['timestamp'] != null
        ? DateTime.parse(json['timestamp'] as String)
        : DateTime.now(),
  );
}

3. LocationModel.fromGeolocator() - Lines 63-72

Add explicit type casting:
Dart

factory LocationModel.fromGeolocator(dynamic position) {
  return LocationModel(
    latitude: (position.latitude as num).toDouble(),
    longitude: (position.longitude as num).toDouble(),
    accuracy: position.accuracy != null ? (position.accuracy as num).toDouble() : null,
    altitude: position.altitude != null ? (position.altitude as num).toDouble() : null,
    heading: position.heading != null ? (position.heading as num).toDouble() : null,
    speed: position.speed != null ? (position.speed as num).toDouble() : null,
    timestamp: (position.timestamp as DateTime?) ?? DateTime.now(),
  );
}

4. auth_remote_data_source.dart - Lines 182, 234

Add type casting for metadata access:
Dart

// Line 182
name: (response.user!.userMetadata?['full_name'] as String?) ?? 'Usuario',

// Line 234
displayName = response.user!.userMetadata!['full_name'] as String;

Also Update

    analysis_options.yaml: Remove the avoid_returning_null_for_future lint rule
    Replace deprecated .withOpacity(): Update color usages in stats_card_widget.dart to use .withValues() instead

These changes will resolve the type safety violations and allow the analyzer to complete successfully.


In CI / Quality Gates (push):

This job shows the identical analyzer failures as the previous job. The logs indicate the same set of type safety issues across multiple files. Let me provide you with a comprehensive solution.
Solution for Job 71481286906

This job fails with 147 type safety and lint violations. The root causes are identical to the previous job. Here's the complete fix:
Critical Fixes Required
1. analysis_options.yaml - Remove deprecated lint

Remove the avoid_returning_null_for_future rule:
YAML

# analysis_options.yaml
linter:
  rules:
    # Remove this line:
    # - avoid_returning_null_for_future  # Removed in Dart 3.3.0

2. lib/features/auth/data/models/user_model.dart - Fix type casting in fromJson
Dart

factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: (json['id'] as String?) ?? '',
    email: (json['email'] as String?) ?? '',
    name: (json['name'] as String?) ?? '',
    photoUrl: json['photo_url'] as String?,
    phone: json['phone'] as String?,
    latitude: json['latitude'] != null
        ? (json['latitude'] as num).toDouble()
        : null,
    longitude: json['longitude'] != null
        ? (json['longitude'] as num).toDouble()
        : null,
    reputation: (json['reputation'] as int?) ?? 0,
    badges: json['badges'] != null 
        ? List<String>.from(json['badges'] as List)
        : [],
    savedPromotions: json['saved_promotions'] != null
        ? List<String>.from(json['saved_promotions'] as List)
        : [],
    totalSavings: json['total_savings'] != null
        ? (json['total_savings'] as num).toDouble()
        : 0.0,
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
    isCommerce: (json['is_commerce'] as bool?) ?? false,
  );
}

3. lib/features/auth/data/datasources/auth_remote_data_source.dart - Fix metadata casting

Lines 182, 183, and 234:
Dart

// Lines 182-183 (signInWithGoogle)
name: (response.user!.userMetadata?['full_name'] as String?) ?? 'Usuario',
photoUrl: response.user!.userMetadata?['avatar_url'] as String?,

// Line 234 (signInWithApple)
displayName = response.user!.userMetadata!['full_name'] as String;

4. lib/features/location/data/models/location_model.dart - Fix geolocator casting

Lines 63-72:
Dart

factory LocationModel.fromGeolocator(dynamic position) {
  return LocationModel(
    latitude: (position.latitude as num).toDouble(),
    longitude: (position.longitude as num).toDouble(),
    accuracy: position.accuracy != null ? (position.accuracy as num).toDouble() : null,
    altitude: position.altitude != null ? (position.altitude as num).toDouble() : null,
    heading: position.heading != null ? (position.heading as num).toDouble() : null,
    speed: position.speed != null ? (position.speed as num).toDouble() : null,
    timestamp: (position.timestamp as DateTime?) ?? DateTime.now(),
  );
}

5. lib/features/profile/data/datasources/profile_remote_data_source.dart - Remove unused imports and fix casting

Lines 1-2 (remove):
Dart

// Remove these:
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';

Line 171:
Dart

// Change from: updateProfileData(data);
// To:
updateProfileData(data as Map<String, dynamic>);

Line 214:
Dart

// Add type cast:
String imageUrl = response['url'] as String;

6. lib/features/notifications/data/datasources/notification_remote_data_source.dart - Fix Map casting

Line 151:
Dart

// Add type cast:
_parseNotificationData(responseData as Map<String, dynamic>);

7. lib/features/promotions/data/datasources/promotion_remote_data_source.dart - Fix all Map castings

Apply as Map<String, dynamic> casts to lines: 147, 190, 246, 275, 303, 445, 483, 535

Example:
Dart

// Line 147
final result = await _rpc<PromotionModel>('get_promotion', params: params as Map<String, dynamic>);

// Repeat pattern for all affected lines

8. lib/features/profile/presentation/widgets/stats_card_widget.dart - Replace deprecated .withOpacity()

Replace all instances at lines 106, 140, 161, 173:
Dart

// Old:
.withOpacity(0.1)

// New:
.withValues(alpha: 0.1)

9. lib/features/notifications/presentation/pages/notifications_list_page.dart - Replace deprecated color method

Line 308:
Dart

// Old:
Colors.red.withOpacity(0.1)

// New:
Colors.red.withValues(alpha: 0.1)

10. lib/features/location/presentation/bloc/location_bloc.dart - Fix StreamSubscription type

Line 23:
Dart

// Old:
StreamSubscription? _subscription;

// New:
StreamSubscription<Position>? _subscription;

Line 318:
Dart

// Old:
onError: (error) {

// New:
onError: (Object error, StackTrace stackTrace) {

These fixes will resolve all 147 issues and allow the analyzer to pass successfully.
