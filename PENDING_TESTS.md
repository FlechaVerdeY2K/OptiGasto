# Pending Gamification Tests

**Phase 9 checkpoint:** Coverage = 4.7% (use cases only). These tests target 80% goal.

---

## Model Tests (6 files)

- [ ] **`test/features/gamification/data/models/badge_model_test.dart`**
  - `BadgeModel.fromJson()` — validate all fields map correctly
  - `BadgeModel.toJson()` — validate serialization round-trip
  - Edge cases: missing fields, null dates, empty unlockConditions

- [ ] **`test/features/gamification/data/models/user_gamification_stats_model_test.dart`**
  - `UserGamificationStatsModel.fromJson()` with all fields
  - `UserGamificationStatsModel.toJson()` round-trip
  - Entity conversion: `toEntity()`

- [ ] **`test/features/gamification/data/models/user_badge_model_test.dart`**
  - `UserBadgeModel.fromJson()`
  - `UserBadgeModel.toEntity()` conversion

- [ ] **`test/features/gamification/data/models/leaderboard_entry_model_test.dart`**
  - `LeaderboardEntryModel.fromJson()`
  - `LeaderboardEntryModel.toEntity()`

- [ ] **`test/features/gamification/data/models/points_transaction_model_test.dart`**
  - `PointsTransactionModel.fromJson()`
  - `PointsTransactionModel.toEntity()`

- [ ] **`test/features/gamification/data/models/commerce_loyalty_model_test.dart`**
  - `CommerceLoyaltyModel.fromJson()`
  - `CommerceLoyaltyModel.toEntity()`

---

## Repository Implementation Tests

- [ ] **`test/features/gamification/data/repositories/gamification_repository_impl_test.dart`**
  - Mock `GamificationRemoteDataSource`
  - Test each method delegates correctly: `getUserStats()`, `getPointsHistory()`, `getPointsBalance()`, `getAllBadges()`, `getUserBadges()`, `getWeeklyLeaderboard()`, `getMonthlyLeaderboard()`, `getYearlyLeaderboard()`, `getUserLoyaltyRecords()`, `getCommerceLoyalty()`
  - Verify error handling: `ServerException` → `ServerFailure`

---

## BLoC Tests (3 files) — **Highest ROI**

- [ ] **`test/features/gamification/presentation/bloc/gamification_bloc_test.dart`**
  - Mock `GamificationRepository`
  - `LoadUserGamificationStats` event → `GamificationStatsLoaded` state
  - `LoadPointsHistory` event → `PointsHistoryLoaded` state
  - `LoadPointsBalance` event → `PointsBalanceLoaded` state
  - Error cases → `GamificationError` state

- [ ] **`test/features/gamification/presentation/bloc/badges_bloc_test.dart`**
  - Mock `GamificationRepository`
  - `LoadAllBadges` event → `AllBadgesLoaded` state
  - `LoadUserBadges` event → `UserBadgesLoaded` state (with allBadges)
  - Error cases → `BadgesError` state

- [ ] **`test/features/gamification/presentation/bloc/leaderboard_bloc_test.dart`**
  - Mock `GamificationRepository`
  - `LoadWeeklyLeaderboard` event → `LeaderboardLoaded` state
  - `LoadMonthlyLeaderboard` event → `LeaderboardLoaded` state
  - `LoadYearlyLeaderboard` event → `LeaderboardLoaded` state
  - Error cases → `LeaderboardError` state

---

## Entity Remaining Coverage

- [ ] **`test/features/gamification/domain/entities/badge_entity_test.dart`**
  - `icon` getter (already in usecases_test but isolated test helps)
  - `rarity` getter and `_computeRarity()` logic (displayOrder → rarity mapping)
  - Equatable: two badges with same data are equal

- [ ] **`test/features/gamification/domain/entities/commerce_loyalty_entity_test.dart`**
  - `tierInt` mapping for all tiers (customer→1, frequent→2, loyal→3, vip→4)
  - `tierColor` hex string mapping
  - Equatable checks

- [ ] **`test/features/gamification/domain/entities/user_gamification_stats_entity_test.dart`**
  - `progressPercentage` calculation (0–100 range)
  - `totalPoints` alias
  - `levelName` getter (level 1→5 maps to Spanish names)

- [ ] **`test/features/gamification/domain/entities/leaderboard_entry_entity_test.dart`**
  - `totalPoints` alias

---

## Summary

**Total tests to write:** ~60–80 tests (BLoCs = ~30, models = ~20, repo impl = ~10, entities = ~5)

**Estimated coverage gain:** 4.7% → ~55–65%

**To reach 80%:** Add widget tests for `BadgesPage`, `LeaderboardPage`, `PointsDisplayWidget`, `BadgesShowcaseWidget` (out of Phase 9 scope).

---

## Notes

- Use `mocktail` for mocking (consistent with existing tests)
- BLoC tests: use `BlockTest<Event, State>` pattern from `flutter_bloc_test`
- Model tests: test both happy path and edge cases (null, missing fields)
- Run: `flutter test test/features/gamification/` to verify all pass
