import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:optigasto/core/errors/failures.dart';
import 'package:optigasto/features/gamification/domain/entities/badge_entity.dart';
import 'package:optigasto/features/gamification/domain/entities/commerce_loyalty_entity.dart';
import 'package:optigasto/features/gamification/domain/entities/leaderboard_entry_entity.dart';
import 'package:optigasto/features/gamification/domain/entities/points_transaction_entity.dart';
import 'package:optigasto/features/gamification/domain/entities/user_badge_entity.dart';
import 'package:optigasto/features/gamification/domain/entities/user_gamification_stats_entity.dart';
import 'package:optigasto/features/gamification/domain/repositories/gamification_repository.dart';
import 'package:optigasto/features/gamification/domain/usecases/get_all_badges.dart';
import 'package:optigasto/features/gamification/domain/usecases/get_commerce_loyalty.dart';
import 'package:optigasto/features/gamification/domain/usecases/get_leaderboard.dart';
import 'package:optigasto/features/gamification/domain/usecases/get_points_balance.dart';
import 'package:optigasto/features/gamification/domain/usecases/get_points_history.dart';
import 'package:optigasto/features/gamification/domain/usecases/get_user_badges.dart';
import 'package:optigasto/features/gamification/domain/usecases/get_user_gamification_stats.dart';
import 'package:optigasto/features/gamification/domain/usecases/get_user_loyalty_records.dart';

class MockGamificationRepository extends Mock
    implements GamificationRepository {}

// Helper to unwrap Right value from Either
T _right<T>(Either<Failure, T> either) =>
    either.fold((_) => throw Exception('Expected Right'), (v) => v);

void main() {
  late MockGamificationRepository repo;

  setUp(() {
    repo = MockGamificationRepository();
  });

  // ---------------------------------------------------------------------------
  // Fixtures
  // ---------------------------------------------------------------------------
  const tUserId = 'user-1';

  const tStats = UserGamificationStatsEntity(
    userId: tUserId,
    username: 'TestUser',
    points: 250,
    level: 2,
    pointsToNextLevel: 250,
    badgeCount: 3,
    totalTransactions: 10,
  );

  final tTransaction = PointsTransactionEntity(
    id: 'tx-1',
    userId: tUserId,
    points: 10,
    eventType: 'publish',
    createdAt: DateTime(2026, 4, 17),
  );

  final tBadge = BadgeEntity(
    id: 'badge-1',
    name: 'Fotógrafo',
    description: '10 promociones publicadas',
    iconUrl: '📸',
    category: 'general',
    unlockConditions: const {'metric': 'published', 'value': 10},
    displayOrder: 2,
    createdAt: DateTime(2026, 4, 17),
  );

  final tUserBadge = UserBadgeEntity(
    id: 'ub-1',
    badgeId: 'badge-1',
    userId: tUserId,
    unlockedAt: DateTime(2026, 4, 17),
  );

  const tLeaderboardEntry = LeaderboardEntryEntity(
    userId: tUserId,
    username: 'TestUser',
    points: 250,
    level: 2,
    rank: 5,
    badgeCount: 3,
  );

  final tLoyalty = CommerceLoyaltyEntity(
    id: 'loyalty-1',
    userId: tUserId,
    commerceId: 'commerce-1',
    commerceName: 'Walmart',
    purchaseCount: 7,
    tier: 'customer',
    createdAt: DateTime(2026, 4, 17),
    updatedAt: DateTime(2026, 4, 17),
  );

  // ---------------------------------------------------------------------------
  // GetUserGamificationStats
  // ---------------------------------------------------------------------------
  group('GetUserGamificationStats', () {
    late GetUserGamificationStats useCase;
    setUp(() => useCase = GetUserGamificationStats(repo));

    test('returns stats on success', () async {
      when(() => repo.getUserStats(tUserId))
          .thenAnswer((_) async => const Right(tStats));

      final result = await useCase(tUserId);

      expect(result.isRight(), isTrue);
      expect(_right(result), equals(tStats));
      verify(() => repo.getUserStats(tUserId)).called(1);
    });

    test('returns failure on error', () async {
      const failure = ServerFailure(message: 'Network error');
      when(() => repo.getUserStats(tUserId))
          .thenAnswer((_) async => const Left(failure));

      final result = await useCase(tUserId);

      expect(result.isLeft(), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // GetPointsHistory
  // ---------------------------------------------------------------------------
  group('GetPointsHistory', () {
    late GetPointsHistory useCase;
    setUp(() => useCase = GetPointsHistory(repo));

    test('returns history list on success', () async {
      when(
        () => repo.getPointsHistory(
          userId: tUserId,
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => Right([tTransaction]));

      final result = await useCase(userId: tUserId);

      expect(result.isRight(), isTrue);
      expect(_right(result), contains(tTransaction));
    });

    test('returns empty list when no history', () async {
      when(
        () => repo.getPointsHistory(
          userId: tUserId,
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => const Right([]));

      final result = await useCase(userId: tUserId);

      expect(result.isRight(), isTrue);
      expect(_right(result), isEmpty);
    });

    test('returns failure on error', () async {
      const failure = ServerFailure(message: 'Error');
      when(
        () => repo.getPointsHistory(
          userId: tUserId,
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(userId: tUserId);

      expect(result.isLeft(), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // GetPointsBalance
  // ---------------------------------------------------------------------------
  group('GetPointsBalance', () {
    late GetPointsBalance useCase;
    setUp(() => useCase = GetPointsBalance(repo));

    test('returns balance on success', () async {
      when(() => repo.getPointsBalance(tUserId))
          .thenAnswer((_) async => const Right(250));

      final result = await useCase(tUserId);

      expect(result, const Right<Failure, int>(250));
    });

    test('returns zero when user has no points', () async {
      when(() => repo.getPointsBalance(tUserId))
          .thenAnswer((_) async => const Right(0));

      final result = await useCase(tUserId);

      expect(result, const Right<Failure, int>(0));
    });
  });

  // ---------------------------------------------------------------------------
  // GetAllBadges
  // ---------------------------------------------------------------------------
  group('GetAllBadges', () {
    late GetAllBadges useCase;
    setUp(() => useCase = GetAllBadges(repo));

    test('returns badge list on success', () async {
      when(() => repo.getAllBadges()).thenAnswer((_) async => Right([tBadge]));

      final result = await useCase();

      expect(result.isRight(), isTrue);
      expect(_right(result), contains(tBadge));
    });

    test('returns empty list when no badges', () async {
      when(() => repo.getAllBadges()).thenAnswer((_) async => const Right([]));

      final result = await useCase();

      expect(result.isRight(), isTrue);
      expect(_right(result), isEmpty);
    });

    test('returns failure on error', () async {
      const failure = ServerFailure(message: 'Error');
      when(() => repo.getAllBadges())
          .thenAnswer((_) async => const Left(failure));

      final result = await useCase();

      expect(result.isLeft(), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // GetUserBadges
  // ---------------------------------------------------------------------------
  group('GetUserBadges', () {
    late GetUserBadges useCase;
    setUp(() => useCase = GetUserBadges(repo));

    test('returns user badges on success', () async {
      when(() => repo.getUserBadges(tUserId))
          .thenAnswer((_) async => Right([tUserBadge]));

      final result = await useCase(tUserId);

      expect(result.isRight(), isTrue);
      expect(_right(result), contains(tUserBadge));
    });

    test('returns empty list when no badges unlocked', () async {
      when(() => repo.getUserBadges(tUserId))
          .thenAnswer((_) async => const Right([]));

      final result = await useCase(tUserId);

      expect(result.isRight(), isTrue);
      expect(_right(result), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // GetLeaderboard
  // ---------------------------------------------------------------------------
  group('GetLeaderboard', () {
    late GetLeaderboard useCase;
    setUp(() => useCase = GetLeaderboard(repo));

    test('weekly — returns list on success', () async {
      when(() => repo.getWeeklyLeaderboard(limit: any(named: 'limit')))
          .thenAnswer((_) async => const Right([tLeaderboardEntry]));

      final result = await useCase(period: 'weekly');

      expect(result.isRight(), isTrue);
      expect(_right(result), contains(tLeaderboardEntry));
    });

    test('monthly — returns list on success', () async {
      when(() => repo.getMonthlyLeaderboard(limit: any(named: 'limit')))
          .thenAnswer((_) async => const Right([tLeaderboardEntry]));

      final result = await useCase(period: 'monthly');

      expect(result.isRight(), isTrue);
      expect(_right(result), contains(tLeaderboardEntry));
    });

    test('yearly — returns list on success', () async {
      when(() => repo.getYearlyLeaderboard(limit: any(named: 'limit')))
          .thenAnswer((_) async => const Right([tLeaderboardEntry]));

      final result = await useCase(period: 'yearly');

      expect(result.isRight(), isTrue);
      expect(_right(result), contains(tLeaderboardEntry));
    });

    test('invalid period — returns ValidationFailure', () async {
      final result = await useCase(period: 'invalid');

      expect(result.isLeft(), isTrue);
    });

    test('empty leaderboard — returns empty list', () async {
      when(() => repo.getWeeklyLeaderboard(limit: any(named: 'limit')))
          .thenAnswer((_) async => const Right([]));

      final result = await useCase(period: 'weekly');

      expect(result.isRight(), isTrue);
      expect(_right(result), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // GetUserLoyaltyRecords
  // ---------------------------------------------------------------------------
  group('GetUserLoyaltyRecords', () {
    late GetUserLoyaltyRecords useCase;
    setUp(() => useCase = GetUserLoyaltyRecords(repo));

    test('returns loyalty list on success', () async {
      when(() => repo.getUserLoyaltyRecords(tUserId))
          .thenAnswer((_) async => Right([tLoyalty]));

      final result = await useCase(tUserId);

      expect(result.isRight(), isTrue);
      expect(_right(result), contains(tLoyalty));
    });

    test('returns empty list when no loyalty records', () async {
      when(() => repo.getUserLoyaltyRecords(tUserId))
          .thenAnswer((_) async => const Right([]));

      final result = await useCase(tUserId);

      expect(result.isRight(), isTrue);
      expect(_right(result), isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // GetCommerceLoyalty
  // ---------------------------------------------------------------------------
  group('GetCommerceLoyalty', () {
    late GetCommerceLoyalty useCase;
    setUp(() => useCase = GetCommerceLoyalty(repo));

    test('returns loyalty entity on success', () async {
      when(
        () => repo.getCommerceLoyalty(
          userId: tUserId,
          commerceId: 'commerce-1',
        ),
      ).thenAnswer((_) async => Right(tLoyalty));

      final result = await useCase(
        userId: tUserId,
        commerceId: 'commerce-1',
      );

      expect(result.isRight(), isTrue);
      expect(_right(result), equals(tLoyalty));
    });

    test('returns null when no loyalty record exists', () async {
      when(
        () => repo.getCommerceLoyalty(
          userId: tUserId,
          commerceId: 'commerce-999',
        ),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(
        userId: tUserId,
        commerceId: 'commerce-999',
      );

      expect(result.isRight(), isTrue);
      expect(_right(result), isNull);
    });

    test('returns failure on error', () async {
      const failure = ServerFailure(message: 'Not found');
      when(
        () => repo.getCommerceLoyalty(
          userId: tUserId,
          commerceId: 'commerce-1',
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        userId: tUserId,
        commerceId: 'commerce-1',
      );

      expect(result.isLeft(), isTrue);
    });
  });

  // ---------------------------------------------------------------------------
  // Entity computed properties
  // ---------------------------------------------------------------------------
  group('CommerceLoyaltyEntity computed properties', () {
    test('tierInt maps string tiers correctly', () {
      expect(
        CommerceLoyaltyEntity(
          id: 'x',
          userId: 'u',
          commerceId: 'c',
          commerceName: 'Shop',
          purchaseCount: 5,
          tier: 'customer',
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        ).tierInt,
        equals(1),
      );
      expect(
        CommerceLoyaltyEntity(
          id: 'x',
          userId: 'u',
          commerceId: 'c',
          commerceName: 'Shop',
          purchaseCount: 50,
          tier: 'vip',
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        ).tierInt,
        equals(4),
      );
    });
  });

  group('BadgeEntity computed properties', () {
    test('icon returns iconUrl', () {
      expect(tBadge.icon, equals(tBadge.iconUrl));
    });

    test('rarity returns non-empty string', () {
      expect(tBadge.rarity, isNotEmpty);
    });
  });

  group('LeaderboardEntryEntity computed properties', () {
    test('totalPoints is alias for points', () {
      expect(tLeaderboardEntry.totalPoints, equals(tLeaderboardEntry.points));
    });
  });

  group('UserGamificationStatsEntity computed properties', () {
    test('totalPoints is alias for points', () {
      expect(tStats.totalPoints, equals(tStats.points));
    });

    test('progressPercentage is between 0 and 100', () {
      expect(tStats.progressPercentage, inInclusiveRange(0.0, 100.0));
    });
  });
}
