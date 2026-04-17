# Gamification Feature

## Overview

The Gamification feature adds a comprehensive points, badges, and leaderboard system to OptiGasto. It encourages user engagement through rewards for discovering, validating, and using promotions, while also tracking loyalty to specific commerce locations.

## Architecture

This feature follows Clean Architecture principles with three distinct layers:

```
lib/features/gamification/
├── data/
│   ├── datasources/
│   │   └── gamification_remote_data_source.dart
│   ├── models/
│   │   ├── badge_model.dart
│   │   ├── commerce_loyalty_model.dart
│   │   ├── leaderboard_entry_model.dart
│   │   ├── points_transaction_model.dart
│   │   ├── user_badge_model.dart
│   │   └── user_gamification_stats_model.dart
│   └── repositories/
│       └── gamification_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── badge_entity.dart
│   │   ├── commerce_loyalty_entity.dart
│   │   ├── leaderboard_entry_entity.dart
│   │   ├── points_transaction_entity.dart
│   │   ├── user_badge_entity.dart
│   │   └── user_gamification_stats_entity.dart
│   ├── repositories/
│   │   └── gamification_repository.dart
│   └── usecases/
│       ├── award_points.dart
│       ├── get_available_badges.dart
│       ├── get_commerce_loyalty.dart
│       ├── get_leaderboard.dart
│       ├── get_points_history.dart
│       ├── get_user_badges.dart
│       ├── get_user_stats.dart
│       └── update_commerce_loyalty.dart
└── presentation/
    ├── bloc/
    │   ├── badges_bloc.dart
    │   ├── gamification_bloc.dart
    │   └── leaderboard_bloc.dart
    ├── pages/
    │   ├── badges_page.dart
    │   └── leaderboard_page.dart
    └── widgets/
        ├── badge_card_widget.dart
        ├── badge_detail_dialog.dart
        ├── badge_grid_widget.dart
        ├── badges_showcase_widget.dart
        ├── commerce_loyalty_widget.dart
        ├── level_progress_widget.dart
        └── points_display_widget.dart
```

## Points System

### Point Events

Users earn points through various actions:

| Action | Points | Description |
|--------|--------|-------------|
| Publish Promotion | +10 | Create a new promotion |
| Validate Promotion | +5 | Confirm a promotion is valid |
| Use Promotion | +3 | Mark a promotion as used |
| Valid Report | +2 | Report an invalid promotion (confirmed) |
| False Report | -10 | Report a valid promotion (penalty) |

### Levels

Users progress through 5 levels based on total points:

| Level | Name | Points Required | Color |
|-------|------|-----------------|-------|
| 1 | Novato | 0 | Grey |
| 2 | Explorador | 100 | Blue |
| 3 | Experto | 500 | Purple |
| 4 | Maestro | 2000 | Orange |
| 5 | Leyenda | 5000 | Gold |

### Server-Side Enforcement

**CRITICAL**: All point calculations are performed server-side via PostgreSQL triggers to prevent client-side manipulation:

- `award_points()` trigger on `points_ledger` table
- Automatic level calculation based on total points
- Immutable point history (INSERT only, no UPDATE/DELETE)
- Audit logging for all point transactions

## Badge System

### Badge Structure

Each badge has:
- **ID**: Unique identifier
- **Name**: Display name (e.g., "First Steps")
- **Description**: What the badge represents
- **Icon**: Emoji or icon identifier
- **Rarity**: Common, Rare, Epic, Legendary
- **Unlock Conditions**: JSONB object with criteria

### Badge Categories

1. **Milestone Badges** (7 badges)
   - First Steps, Explorer, Expert, Master, Legend
   - Promotion Hunter, Validation Master

2. **Activity Badges** (4 badges)
   - Early Bird, Night Owl, Weekend Warrior, Streak Master

3. **Social Badges** (2 badges)
   - Social Butterfly, Helpful Hand

4. **Special Badges** (2 badges)
   - Treasure Hunter, Loyalty Champion

### Unlock Conditions Format

Badges use JSONB conditions checked server-side:

```json
{
  "type": "points_threshold",
  "value": 100
}
```

```json
{
  "type": "promotion_count",
  "value": 10
}
```

```json
{
  "type": "validation_count",
  "value": 50
}
```

```json
{
  "type": "usage_count",
  "value": 25
}
```

```json
{
  "type": "streak_days",
  "value": 7
}
```

```json
{
  "type": "time_range",
  "start_hour": 5,
  "end_hour": 9
}
```

### Badge Checking

The `check_and_unlock_badges()` function runs automatically:
- After each point transaction
- Checks all unlockable badges
- Awards badges that meet conditions
- Prevents duplicate awards

## Leaderboard System

### Leaderboard Types

Three time-based leaderboards:

1. **Weekly Leaderboard**
   - Resets every Monday at 00:00 UTC
   - Shows top 100 users by weekly points
   - Materialized view: `weekly_leaderboard`

2. **Monthly Leaderboard**
   - Resets on the 1st of each month
   - Shows top 100 users by monthly points
   - Materialized view: `monthly_leaderboard`

3. **All-Time Leaderboard**
   - Never resets
   - Shows top 100 users by total points
   - Materialized view: `all_time_leaderboard`

### Leaderboard Refresh

Materialized views are refreshed automatically:
- Every hour via `pg_cron` extension
- Manual refresh available via Supabase dashboard
- Concurrent refresh to avoid blocking reads

### Leaderboard Entry Structure

```dart
class LeaderboardEntryEntity {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final int points;
  final int level;
  final int rank;
}
```

## Commerce Loyalty System

### Loyalty Tiers

Users build loyalty with individual commerce locations:

| Tier | Name | Visits Required | Discount |
|------|------|-----------------|----------|
| 1 | Bronze | 1 | 5% |
| 2 | Silver | 5 | 10% |
| 3 | Gold | 15 | 15% |
| 4 | Platinum | 30 | 20% |

### Loyalty Tracking

- Incremented when user marks promotion as used
- Stored in `commerce_loyalty` table
- Tier calculated automatically based on visit count
- Displayed in commerce detail pages

### Loyalty Benefits

- Visual tier badge on commerce cards
- Discount percentage display
- Progress to next tier
- Exclusive promotions (future feature)

## Usage Examples

### Display User Stats

```dart
// In profile page
BlocBuilder<GamificationBloc, GamificationState>(
  builder: (context, state) {
    if (state is GamificationStatsLoaded) {
      return Column(
        children: [
          PointsDisplayWidget(
            points: state.stats.totalPoints,
            level: state.stats.level,
          ),
          LevelProgressWidget(
            currentLevel: state.stats.level,
            currentPoints: state.stats.totalPoints,
            nextLevelPoints: state.stats.pointsToNextLevel,
          ),
        ],
      );
    }
    return CircularProgressIndicator();
  },
)
```

### Show Badge Collection

```dart
// Navigate to badges page
context.push('/badges');

// Or show preview in profile
BadgesShowcaseWidget(
  userId: currentUserId,
  maxBadges: 6,
  onViewAll: () => context.push('/badges'),
)
```

### Display Leaderboard

```dart
// Navigate to leaderboard
context.push('/leaderboard');

// Or embed in home page
LeaderboardPage(
  initialPeriod: LeaderboardPeriod.weekly,
  currentUserId: userId,
)
```

### Show Commerce Loyalty

```dart
// In commerce detail page
CommerceLoyaltyWidget(
  commerceId: commerce.id,
  userId: currentUserId,
)
```

### Award Points Manually

```dart
// Award points for custom action
context.read<GamificationBloc>().add(
  AwardPointsRequested(
    userId: userId,
    points: 10,
    reason: 'custom_action',
    metadata: {'action': 'special_event'},
  ),
);
```

## BLoC Events and States

### GamificationBloc

**Events:**
- `LoadUserStats` - Load user's gamification stats
- `AwardPointsRequested` - Award points to user
- `LoadPointsHistory` - Load points transaction history
- `RefreshStats` - Refresh user stats

**States:**
- `GamificationInitial`
- `GamificationLoading`
- `GamificationStatsLoaded`
- `GamificationPointsHistoryLoaded`
- `GamificationPointsAwarded`
- `GamificationError`

### BadgesBloc

**Events:**
- `LoadUserBadges` - Load user's earned badges
- `LoadAvailableBadges` - Load all available badges
- `FilterBadges` - Filter badges by rarity/status
- `RefreshBadges` - Refresh badge data
- `BadgeUnlocked` - Handle badge unlock notification

**States:**
- `BadgesInitial`
- `BadgesLoading`
- `BadgesLoaded`
- `BadgesFiltered`
- `BadgeUnlockedState`
- `BadgesError`

### LeaderboardBloc

**Events:**
- `LoadLeaderboard` - Load leaderboard for period
- `ChangePeriod` - Switch between weekly/monthly/all-time
- `RefreshLeaderboard` - Refresh leaderboard data
- `LoadUserRank` - Load current user's rank

**States:**
- `LeaderboardInitial`
- `LeaderboardLoading`
- `LeaderboardLoaded`
- `LeaderboardError`

## Database Schema

### Core Tables

**users** (extended columns):
- `total_points` - Total points earned
- `level` - Current level (1-5)
- `points_this_week` - Points earned this week
- `points_this_month` - Points earned this month

**points_ledger**:
- `id` - UUID primary key
- `user_id` - Foreign key to users
- `points` - Points awarded (can be negative)
- `reason` - Event type (publish, validate, use, etc.)
- `metadata` - JSONB for additional context
- `created_at` - Timestamp

**badges**:
- `id` - UUID primary key
- `name` - Badge name
- `description` - Badge description
- `icon` - Icon identifier
- `rarity` - common/rare/epic/legendary
- `unlock_conditions` - JSONB conditions
- `created_at` - Timestamp

**user_badges**:
- `id` - UUID primary key
- `user_id` - Foreign key to users
- `badge_id` - Foreign key to badges
- `unlocked_at` - Timestamp
- Unique constraint on (user_id, badge_id)

**commerce_loyalty**:
- `id` - UUID primary key
- `user_id` - Foreign key to users
- `commerce_id` - Foreign key to commerce
- `visit_count` - Number of visits
- `tier` - Loyalty tier (1-4)
- `last_visit` - Last visit timestamp
- `created_at` - Timestamp
- Unique constraint on (user_id, commerce_id)

### Materialized Views

**weekly_leaderboard**:
- Refreshed hourly
- Top 100 users by `points_this_week`

**monthly_leaderboard**:
- Refreshed hourly
- Top 100 users by `points_this_month`

**all_time_leaderboard**:
- Refreshed hourly
- Top 100 users by `total_points`

### Functions and Triggers

**award_points()**:
- Triggered on INSERT to `points_ledger`
- Updates user's point totals
- Calculates new level
- Calls `check_and_unlock_badges()`

**check_and_unlock_badges()**:
- Checks all badge unlock conditions
- Awards eligible badges
- Prevents duplicate awards

**update_commerce_loyalty()**:
- Triggered when promotion marked as used
- Increments visit count
- Updates loyalty tier

**reset_weekly_points()**:
- Scheduled via pg_cron (Mondays 00:00 UTC)
- Resets `points_this_week` to 0

**reset_monthly_points()**:
- Scheduled via pg_cron (1st of month 00:00 UTC)
- Resets `points_this_month` to 0

## Security

### Row Level Security (RLS)

All tables have RLS enabled with policies:

**points_ledger**:
- Users can read their own transactions
- Only server can insert (via triggers)

**badges**:
- Public read access
- Admin-only write access

**user_badges**:
- Users can read their own badges
- Only server can insert (via triggers)

**commerce_loyalty**:
- Users can read their own loyalty data
- Only server can insert/update (via triggers)

### Audit Logging

All point transactions are logged in `audit_log` table:
- User ID
- Action type
- Timestamp
- Metadata
- Immutable records

## Testing

### Unit Tests

Test coverage for:
- All use cases
- Repository implementation
- Model serialization
- BLoC events and states

### Integration Tests

Test coverage for:
- Point awarding flow
- Badge unlocking flow
- Leaderboard loading
- Commerce loyalty updates

### Widget Tests

Test coverage for:
- All presentation widgets
- Badge display components
- Leaderboard UI
- Points display

## Future Enhancements

1. **Achievements System**
   - Multi-step achievements
   - Progress tracking
   - Achievement chains

2. **Seasonal Events**
   - Limited-time badges
   - Bonus point periods
   - Special challenges

3. **Social Features**
   - Friend leaderboards
   - Badge sharing
   - Challenge friends

4. **Rewards Redemption**
   - Redeem points for prizes
   - Exclusive promotions
   - Partner rewards

5. **Analytics Dashboard**
   - User engagement metrics
   - Badge unlock rates
   - Leaderboard trends

## Dependencies

Required packages (already in pubspec.yaml):
- `flutter_bloc` - State management
- `equatable` - Value equality
- `supabase_flutter` - Backend integration
- `go_router` - Navigation

## Migration Notes

When deploying to production:

1. Run migrations in order:
   - `20260417000001_gamification_schema.sql`
   - `20260417000002_seed_badges.sql`
   - `20260417000003_gamification_triggers.sql`
   - `20260417000004_gamification_rls.sql`

2. Verify pg_cron extension is enabled

3. Test point awarding in staging environment

4. Monitor materialized view refresh performance

5. Set up monitoring for badge unlock rates

## Support

For questions or issues:
- Check existing code examples in similar features
- Review Supabase logs for server-side errors
- Test with mock data before production deployment
- Follow Clean Architecture patterns consistently