# Contributing to OptiGasto

## Setup

Follow the setup instructions in [README.md](README.md) to get the project running locally.

## Branch Flow

All work branches from `main` and is merged back via Pull Request:

```
main
 └── feature/<name>    # New features
 └── fix/<name>        # Bug fixes
 └── chore/<name>      # Maintenance, dependencies, config
```

Never commit directly to `main`.

## Commit Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix   | When to use                                  |
|----------|----------------------------------------------|
| `feat:`  | A new user-facing feature                    |
| `fix:`   | A bug fix                                    |
| `chore:` | Config, dependencies, tooling, build         |
| `docs:`  | Documentation only                           |
| `test:`  | Adding or updating tests                     |
| `refactor:` | Code change that is neither a fix nor a feature |

Examples:
```
feat(promotions): add filter by expiry date
fix(auth): handle token refresh race condition
chore(deps): upgrade supabase_flutter to 2.6.0
test(profile): add unit test for GetUserStats use case
```

## PR Checklist

Before opening a Pull Request, verify all of the following:

- [ ] `flutter analyze` passes without new warnings.
- [ ] `dart format .` has been applied (no format diff).
- [ ] `flutter test` passes with no failures.
- [ ] If you added a new feature, it has at least one unit test.
- [ ] README or docs updated if the setup or architecture changed.

Run the full quality check locally:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## Clean Architecture Reminders

This project follows Clean Architecture. When adding or modifying code:

- **Entities** go in `lib/features/<feature>/domain/entities/`.
- **Use cases** go in `lib/features/<feature>/domain/usecases/` and must return `Either<Failure, T>`.
- **Repository contracts** go in `lib/features/<feature>/domain/repositories/` (abstract classes only).
- **Repository implementations** go in `lib/features/<feature>/data/repositories/`.
- **BLoCs** live in `lib/features/<feature>/presentation/bloc/` and depend on use cases (or repositories when there is no use case layer).
- No `dart:io` or Supabase imports in the `domain` layer.
- No `flutter_bloc` imports in the `data` layer.

## Security

- **Never hardcode API keys or credentials** in source code.
- All credentials must be loaded via `String.fromEnvironment()` using `--dart-define-from-file=.env`.
- Do not commit `.env` files. Use `.env.example` to document required variables.
