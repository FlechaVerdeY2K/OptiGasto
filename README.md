# OptiGasto

App Flutter para encontrar ofertas y promociones geolocalizadas en Costa Rica.

## Estado del Proyecto

Fases 1–6 completadas y mergeadas a `main`.

| Fase | Descripción |
|------|-------------|
| 1 | **Autenticación** — Login/registro con email y contraseña. Google/Apple Sign-In pendiente de configuración de providers. |
| 2 | **Promociones Core** — CRUD de promociones, validación comunitaria (like/dislike), favoritos y paginación. |
| 3 | **Geolocalización** — Mapa interactivo con Google Maps, clustering de marcadores y consultas PostGIS. |
| 4 | **Publicación y Validación** — Subida de fotos a Supabase Storage, sistema de reportes y Row-Level Security. |
| 5 | **Notificaciones FCM** — Push notifications, actualizaciones en tiempo real y geofencing básico. |
| 6 | **Perfil de Usuario** — Estadísticas con fl_chart, configuración de cuenta y soporte de tema claro/oscuro. |

## Stack Tecnológico

| Grupo | Dependencias clave |
|-------|--------------------|
| State Management | `flutter_bloc`, `equatable` |
| Backend | `supabase_flutter` (Auth, DB con PostGIS, Storage, Edge Functions) |
| Maps & Location | `google_maps_flutter`, `geolocator`, `geocoding`, `flutter_polyline_points` |
| Notifications | `firebase_core`, `firebase_messaging`, `flutter_local_notifications` |
| Navigation | `go_router` |
| DI | `get_it`, `injectable` |
| Functional | `dartz` (`Either<Failure, T>`) |
| Local Storage | `hive`, `shared_preferences`, `flutter_secure_storage` |
| Charts | `fl_chart` |

## Arquitectura

Clean Architecture con tres capas:

- **Domain** — Entidades, repositorios abstractos y use cases. Los use cases retornan `Either<Failure, T>`.
- **Data** — Implementaciones de repositorios, datasources (Supabase) y modelos con serialización.
- **Presentation** — Widgets Flutter y BLoCs que consumen los use cases.

## Estructura del Proyecto

```
lib/
├── core/
│   ├── config/         # Configuración de entorno (Supabase, etc.)
│   ├── constants/      # Constantes de la app
│   ├── di/             # Inyección de dependencias (get_it + injectable)
│   ├── errors/         # Failures y excepciones
│   ├── routes/         # Rutas (go_router)
│   ├── theme/          # Tema claro/oscuro
│   └── utils/          # Utilidades
├── features/
│   ├── auth/           # Autenticación (Fase 1)
│   ├── promotions/     # Promociones core (Fases 2 y 4)
│   ├── location/       # Geolocalización y mapas (Fase 3)
│   ├── notifications/  # Notificaciones FCM (Fase 5)
│   ├── profile/        # Perfil y estadísticas (Fase 6)
│   ├── settings/       # Configuración y tema
│   ├── home/           # Pantalla principal
│   └── onboarding/     # Onboarding inicial
└── main.dart
```

## Setup Local

### 1. Clonar el repositorio

```bash
git clone https://github.com/FlechaVerdeY2K/OptiGasto.git
cd OptiGasto
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar variables de entorno

```bash
cp .env.example .env
# Editar .env con tus credenciales de Supabase y Google Maps
```

### 4. Configurar Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

> Los archivos `firebase_options.dart`, `google-services.json` y `GoogleService-Info.plist` están en `.gitignore`. Debes generarlos localmente con `flutterfire configure`.

### 5. Correr la app

```bash
flutter run --dart-define-from-file=.env
```

> **IMPORTANTE:** El flag `--dart-define-from-file=.env` es obligatorio. Sin él, la app no puede leer las credenciales de Supabase y fallará al iniciar.

## Scripts Útiles

```bash
flutter run --dart-define-from-file=.env   # Correr en debug
flutter analyze                             # Static analysis
dart format --set-exit-if-changed .        # Verificar formato
flutter test                                # Correr tests
flutter test --coverage                     # Tests con coverage
```

## Seguridad

- Todas las credenciales se inyectan vía `String.fromEnvironment()` usando `--dart-define-from-file`.
- Row-Level Security (RLS) habilitado en todas las tablas de Supabase con `auth.uid()`.
- Los buckets de Storage son owner-only.
- La Edge Function `send-fcm-notification` maneja tokens FCM del lado del servidor para no exponer la Service Account al cliente.
- **NO hardcodear API keys bajo ninguna circunstancia.**

## Roadmap

- **Fase 7** — Ruta Inteligente (optimización de recorrido de compras)
- **Fase 8** — Búsqueda Avanzada (filtros, etiquetas, historial)
- **Fase 9** — Gamificación (insignias, rankings, recompensas)
- **Fase 10** — Google/Apple Sign-In completo
- **Fase B2B** — Panel de comercios (pospuesta)

## Contribución

Ver [CONTRIBUTING.md](CONTRIBUTING.md).

## Licencia

MIT — ver [LICENSE](LICENSE).

## Contacto

- **Maintainer:** Edgar Herrera
- **Repositorio:** [FlechaVerdeY2K/OptiGasto](https://github.com/FlechaVerdeY2K/OptiGasto)
