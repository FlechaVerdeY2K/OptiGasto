# Plan de Desarrollo - Aplicación OptiGasto
## Flutter para Android y iOS

---

## 📋 Resumen Ejecutivo

OptiGasto es una aplicación móvil que permite a los consumidores costarricenses encontrar ofertas, promociones y descuentos geolocalizados en comercios cercanos. La plataforma se basa en un modelo colaborativo donde usuarios y comercios actualizan información en tiempo real.

**Objetivo:** Desarrollar una aplicación Flutter multiplataforma (Android/iOS) que implemente todas las funcionalidades identificadas en el proyecto de mercadeo.

**Estado Actual:** Fases 1–6 implementadas. La funcionalidad core está completa. Los 4 bugs activos de la Fase 6 fueron corregidos el 14 de abril de 2026 (ver sección de bugs más abajo). Listo para iniciar Fase 7.

**Versión del documento:** 3.0 — 14 de abril de 2026

---

## 🚨 Correcciones de Seguridad Prioritarias

> Estas correcciones deben completarse **antes de iniciar la Fase 7**. Son cambios menores pero críticos.

### SEC-1: `.env.example` expone el Project ID real de Supabase ❌ PENDIENTE
El archivo `.env.example` commiteado en `main` contiene la URL real del proyecto Supabase. Esto permite a cualquier persona intentar ataques de enumeración de usuarios o fuerza bruta contra el endpoint de Auth.

**Acción:** Reemplazar la URL real con `https://tu-proyecto.supabase.co` y hacer commit a `main`.

### SEC-2: JWT de Supabase CLI hardcodeado en `.env.example` ❌ PENDIENTE
El `LOCAL_SUPABASE_ANON_KEY` tiene el JWT demo hardcodeado. Aunque es un token público conocido, establece un patrón inseguro.

**Acción:** Reemplazar con el placeholder `your-local-anon-key-here`.

### SEC-3: Google Maps API Key en texto plano en código ❌ PENDIENTE
El README indica editar `lib/core/constants/api_constants.dart` directamente con la API key, lo cual la expone en el repositorio.

**Acción:**
- Mover la key a `.env` y leerla con `flutter_dotenv`.
- Configurar restricciones de App en Google Cloud Console (SHA-1 para Android, Bundle ID para iOS) para limitar el abuso aunque la key sea visible.

### SEC-4: Políticas RLS en Supabase Storage ⚠️ VERIFICAR
Confirmar que los buckets de imágenes de promociones no tienen escritura pública irrestricta.

**Política requerida en Storage:**
```sql
-- Solo el owner puede insertar sus propios archivos
CREATE POLICY "Users can upload own images"
ON storage.objects FOR INSERT
WITH CHECK (auth.uid()::text = (storage.foldername(name))[1]);

-- Solo el owner puede eliminar sus propios archivos
CREATE POLICY "Users can delete own images"
ON storage.objects FOR DELETE
USING (auth.uid()::text = (storage.foldername(name))[1]);

-- Lectura pública (para mostrar imágenes de promociones)
CREATE POLICY "Public can read promotion images"
ON storage.objects FOR SELECT
USING (bucket_id = 'promotion-images');
```

---


## 🐛 Historial de Bugs

> No hay bugs activos pendientes. Todos los bugs de Fases 1–6 están resueltos.

### ✅ Bugs Corregidos — 14 de abril de 2026

| ID | Síntoma | Causa raíz | Archivos modificados |
|----|---------|-----------|----------------------|
| BUG-1 | App redirige al cambiar tema claro/oscuro | `AppRouter.router(context)` se llamaba dentro del `builder` del `BlocBuilder`, creando una instancia nueva de `GoRouter` en cada rebuild y reseteando la pila de navegación | `lib/main.dart` |
| BUG-2 | Slider de radio en mapa no aplicaba el filtro | `LocationLoading` destruía el `GoogleMap` completo mostrando un spinner, reseteando el mapa al volver. El radio SÍ se enviaba al bloc; el problema era visual | `lib/features/location/presentation/pages/map_page.dart` |
| BUG-3 | Filtros de configuración no afectaban la lista de promociones | `FiltersSettingsPage` y `LocationSettingsPage` creaban instancias factory nuevas de `SettingsBloc` vía `BlocProvider(create: sl<SettingsBloc>()...)`, aisladas del bloc global | `filters_settings_page.dart`, `location_settings_page.dart` |
| BUG-4 | Navegación rota al volver del detalle de una promoción | `PromotionDetailPage` dejaba el `PromotionBloc` global en estado `PromotionDetailLoaded`; `PromotionsListPage` no manejaba ese estado y mostraba un spinner indefinido | `lib/features/promotions/presentation/pages/promotions_list_page.dart` |

**Detalle de los fixes:**

- **BUG-1:** `OptiGastoApp` ahora entrega `const _AppView()` (nuevo `StatefulWidget`) al `MultiBlocProvider`. `_AppViewState` crea el router una sola vez en `initState` y el `BlocBuilder` de tema reutiliza la misma instancia.
- **BUG-2:** El spinner de pantalla completa solo se muestra en la carga inicial (`!_mapInitialized`). Las recargas subsecuentes muestran un `LinearProgressIndicator` overlay sin desmontar el `GoogleMap`.
- **BUG-3:** Se eliminó el `BlocProvider` local de `FiltersSettingsPage` y `LocationSettingsPage`. Ambas páginas ahora usan el `SettingsBloc` global del `MultiBlocProvider` de `main.dart`.
- **BUG-4:** Se añadió `PromotionLoaded? _lastLoadedState` en `_PromotionsListPageState`. Al regresar del detalle, la lista se renderiza desde la caché en lugar de mostrar spinner indefinido.

### ✅ Bugs corregidos en fases anteriores
- ✅ Errores de compilación en `promotions_list_page.dart`
- ✅ Tema oscuro con textos ilegibles en `promotion_detail_page.dart`
- ✅ Toggle de favoritos (UPSERT)
- ✅ Selección de imágenes desde galería

---

## 🎯 Requerimientos Funcionales

### 1. Gestión de Usuarios ✅ MAYORMENTE COMPLETADO
- ✅ Registro y autenticación con email
- ✅ Perfil de usuario completo
- ✅ Gestión de sesión con BLoC
- ✅ Logout funcional
- ✅ Editar perfil (nombre, email, foto)
- ✅ Dashboard de ahorro personal con gráficas
- ✅ Estadísticas de usuario
- ✅ Sistema de configuraciones completo
- ✅ Tema claro/oscuro funcional
- ✅ Preferencias de ubicación y filtros de contenido
- [ ] Google Sign-In (dependencia ya en pubspec)
- [ ] Apple Sign-In (requiere Apple Developer Program)
- [ ] Sistema de reputación y gamificación (Fase 8)
- [ ] Acceso como invitado (post-lanzamiento)

### 2. Geolocalización y Mapas ✅ COMPLETADO
- ✅ Visualización de comercios cercanos en mapa
- ✅ Filtrado por distancia y tipo de comercio
- ✅ Detección automática de zona geográfica
- ✅ Markers con clustering
- ✅ Info windows personalizados
- [ ] Ruta de Ahorro Inteligente (Fase 7)
- [ ] Notificaciones push por ubicación (Fase 5 parcial — geofencing básico implementado)

### 3. Gestión de Promociones ✅ COMPLETADO
- ✅ Visualización de ofertas geolocalizadas
- ✅ Publicación de promociones con evidencia fotográfica
- ✅ Sistema de validación comunitaria
- ✅ Reportar promociones vencidas
- ✅ Guardar promociones favoritas
- [ ] Compartir promociones en redes sociales (Fase 10 — `share_plus` ya en pubspec)
- [ ] Búsqueda avanzada por producto (Fase 10)

### 4. Sistema Colaborativo ✅ COMPLETADO
- ✅ Subir fotos de promociones
- ✅ Validar ofertas (likes/dislikes)
- ✅ Sistema de confiabilidad de información
- [ ] Rankings de colaboradores (Fase 8)
- [ ] Insignias y recompensas (Fase 8)

### 5. Búsqueda y Filtros ✅ PARCIALMENTE COMPLETADO
- ✅ Filtros por categoría de producto
- ✅ Ordenamiento por distancia
- [ ] Búsqueda fulltext por producto/comercio (Fase 10)
- [ ] Filtros combinados avanzados (Fase 10)

### 6. Notificaciones ✅ COMPLETADO
- ✅ Firebase Cloud Messaging (FCM)
- ✅ Notificaciones locales
- ✅ Supabase Realtime
- ✅ Sistema de preferencias
- ✅ Geofencing básico
- ✅ 7 tipos de notificaciones

### 7. Panel de Comercios (B2B) ❌ PENDIENTE (Fase 9)

### 8. Analítica y Métricas ❌ PENDIENTE (Fase 11)

---

## 🏗️ Arquitectura de la Aplicación

### Patrón: Clean Architecture + BLoC ✅ IMPLEMENTADO

```
lib/
├── core/
│   ├── config/       # Configuración de Supabase (leer keys desde .env)
│   ├── constants/    # Constantes — SIN API keys hardcodeadas
│   ├── di/           # Inyección de dependencias (get_it + injectable)
│   ├── errors/       # Failures y Either<Failure, T>
│   ├── routes/       # go_router
│   └── theme/
├── features/
│   ├── auth/         ✅ COMPLETADO
│   ├── promotions/   ✅ COMPLETADO
│   ├── location/     ✅ COMPLETADO
│   ├── notifications/ ✅ COMPLETADO
│   ├── home/         ✅ COMPLETADO
│   ├── onboarding/   ✅ COMPLETADO
│   ├── profile/      ✅ COMPLETADO
│   ├── settings/     ✅ COMPLETADO
│   ├── route/        ❌ PENDIENTE (Fase 7)
│   ├── gamification/ ❌ PENDIENTE (Fase 8)
│   └── commerce/     ❌ PENDIENTE (Fase 9)
└── main.dart
```

---

## 🛠️ Stack Tecnológico

### Dependencias en pubspec.yaml (main) — estado real

| Categoría | Paquete | Estado |
|-----------|---------|--------|
| State | flutter_bloc ^8.1.6, equatable ^2.0.5 | ✅ |
| Backend | supabase_flutter ^2.5.0 | ✅ |
| Auth social | google_sign_in ^6.2.1, sign_in_with_apple ^6.1.2 | ✅ en pubspec, ❌ sin implementar |
| Maps | google_maps_flutter ^2.9.0, geolocator ^12.0.0 | ✅ |
| Rutas | flutter_polyline_points ^2.1.0 | ✅ en pubspec, ❌ sin usar |
| Imágenes | image_picker, image_cropper, flutter_image_compress | ✅ |
| Storage local | shared_preferences, hive, flutter_secure_storage | ✅ en pubspec |
| Notificaciones | firebase_core, firebase_messaging, flutter_local_notifications | ✅ |
| Navegación | go_router ^14.2.7 | ✅ |
| Utils | url_launcher ^6.3.0, share_plus ^10.0.2 | ✅ en pubspec, ❌ sin usar |
| DI | get_it ^7.7.0, injectable ^2.4.4 | ✅ |
| Funcional | dartz ^0.10.1 | ✅ |

---

## 🚀 Fases de Desarrollo

### FASE 1–6 ✅ COMPLETADAS
Ver historial de commits en branch `Phase_5`. El PR de merge a `main` está **pendiente**.

> **Acción inmediata:** Mergear `Phase_5` a `main` para sincronizar el repositorio con el estado real del proyecto.

---

### FASE 7: Correcciones de Seguridad 🔐
**Duración estimada:** 1–2 días  
**Costo:** $0

Resolver SEC-1, SEC-2, SEC-3 y verificar SEC-4 descritos arriba antes de continuar con el desarrollo.

---

### FASE 8: Ruta Inteligente 🗺️ PENDIENTE
*(anteriormente Fase 7 en el plan v2)*  
**Duración estimada:** Semanas 15–16  
**Costo:** $0 (dentro del free tier de Google Maps con crédito $200/mes)

#### Algoritmo TSP:
Implementar **Nearest Neighbor Greedy** en Dart puro para 2–10 puntos. Esta aproximación da resultados aceptables para el caso de uso (no más de 10 tiendas en una ruta de compras) sin necesidad de librerías externas.

```dart
// Pseudocódigo del algoritmo
List<RoutePointEntity> optimizeRoute(
  LocationEntity origin,
  List<RoutePointEntity> points,
) {
  final unvisited = List<RoutePointEntity>.from(points);
  final route = <RoutePointEntity>[];
  var current = origin;

  while (unvisited.isNotEmpty) {
    final nearest = unvisited.reduce((a, b) =>
      current.distanceTo(a.location) < current.distanceTo(b.location) ? a : b
    );
    route.add(nearest);
    unvisited.remove(nearest);
    current = nearest.location;
  }
  return route;
}
```

#### Integración con Google Directions API:
- Usar para trazar la ruta real por calles (no línea recta)
- `flutter_polyline_points` ya está en `pubspec.yaml`
- Dentro del free tier durante beta (crédito $200/mes de Google)

#### Exportar a Google Maps / Waze:
- `url_launcher` ya está en `pubspec.yaml`
- URL scheme Google Maps: `https://www.google.com/maps/dir/?api=1&waypoints=lat,lng|lat,lng`
- URL scheme Waze: `https://waze.com/ul?ll=lat,lng&navigate=yes`

#### Arquitectura:
```
lib/features/route/
├── domain/
│   ├── entities/
│   │   ├── route_entity.dart
│   │   ├── route_point_entity.dart
│   │   └── route_step_entity.dart
│   ├── repositories/route_repository.dart
│   └── usecases/
│       ├── calculate_optimal_route.dart
│       ├── save_route.dart
│       ├── get_saved_routes.dart
│       └── export_route.dart
├── data/
│   ├── models/
│   │   ├── route_model.dart
│   │   └── route_point_model.dart
│   ├── datasources/route_remote_data_source.dart
│   └── repositories/route_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── route_bloc.dart
    │   ├── route_event.dart
    │   └── route_state.dart
    ├── pages/
    │   ├── route_planner_page.dart
    │   └── saved_routes_page.dart
    └── widgets/
        ├── route_map_widget.dart
        ├── route_point_card.dart
        └── route_summary_widget.dart
```

**Entregables Fase 8:**
- [ ] Ruta optimizada (TSP greedy) funcional
- [ ] Visualización con polylines en mapa existente
- [ ] Estimación de distancia y tiempo total
- [ ] Exportar a Google Maps y Waze
- [ ] Guardar rutas favoritas en Supabase

---

### FASE 9: Búsqueda Avanzada y Compartir 🔍 PENDIENTE
*(anteriormente Fase 10)*  
**Duración estimada:** Semanas 17–18  
**Costo:** $0 (queries Supabase + paquetes ya en pubspec)

#### Búsqueda Avanzada:
- Búsqueda fulltext en Supabase con `to_tsvector` y `to_tsquery`
- Búsqueda por producto, comercio, y descripción
- Historial de búsquedas recientes (SharedPreferences)
- Sugerencias de búsqueda (autocomplete con debounce)

```sql
-- Índice fulltext para búsqueda (agregar a migración)
ALTER TABLE promotions
ADD COLUMN search_vector tsvector
GENERATED ALWAYS AS (
  to_tsvector('spanish', coalesce(title, '') || ' ' || coalesce(description, '') || ' ' || coalesce(commerce_name, ''))
) STORED;

CREATE INDEX promotions_search_idx ON promotions USING GIN(search_vector);
```

#### Filtros Avanzados:
- Por tipo de descuento (%, ₡, 2x1)
- Por rango de fechas
- Por porcentaje de descuento mínimo
- Por validaciones positivas (>80%)
- Ordenamiento múltiple (distancia + descuento)

#### Compartir:
- Compartir promoción en WhatsApp/redes con `share_plus` (ya en pubspec)
- Deep link a promoción específica con `go_router`
- URL scheme: `optigasto://promotion/{id}`

**Entregables Fase 9:**
- [ ] Búsqueda fulltext funcional
- [ ] Filtros combinados
- [ ] Compartir en redes sociales
- [ ] Deep links a promociones

---

### FASE 10: Gamificación 🎮 PENDIENTE
*(anteriormente Fase 8)*  
**Duración estimada:** Semanas 19–20  
**Costo:** $0 (solo SQL en Supabase + UI Dart)

#### Sistema de Puntos:
- Publicar promoción: +10 pts
- Validar promoción: +5 pts
- Usar promoción: +3 pts
- Reportar inválida (confirmado): +2 pts
- Reporte falso: -10 pts

#### Niveles:
- Bronce: 0–499 pts
- Plata: 500–1,999 pts
- Oro: 2,000–9,999 pts
- Platino: 10,000–49,999 pts
- Diamante: 50,000+ pts

#### 15 Insignias propuestas:
- 🥉 "Primer Ahorro" — Primera promoción guardada
- 📸 "Fotógrafo" — 10 promociones publicadas
- 📸 "Paparazzi" — 50 promociones publicadas
- ✅ "Validador" — 50 validaciones realizadas
- ✅ "Inspector" — 200 validaciones realizadas
- 🗺️ "Explorador" — 20 comercios diferentes visitados
- 🗺️ "Aventurero" — 50 comercios diferentes visitados
- 💰 "Ahorrador" — Ahorrar ₡10,000 en un mes
- 💰 "Ahorrador Pro" — Ahorrar ₡50,000 en un mes
- 💎 "Millonario del Ahorro" — Ahorrar ₡100,000 en un mes
- 🔥 "Racha de Fuego" — 7 días consecutivos en la app
- 🔥 "Imparable" — 30 días consecutivos en la app
- 👑 "Embajador" — Top 10 ranking mensual
- 🌟 "Leyenda" — Top 3 ranking mensual
- 🎯 "Precisión" — 100% validaciones correctas (mín. 20)

#### SQL necesario:
```sql
-- Puntos y niveles en tabla users (agregar columnas)
ALTER TABLE profiles ADD COLUMN points INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN level TEXT DEFAULT 'bronze';

-- Tabla de badges
CREATE TABLE badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla relacional usuario-badge
CREATE TABLE user_badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  badge_id UUID REFERENCES badges(id),
  earned_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, badge_id)
);

-- Leaderboard (vista materializada, actualizar diariamente)
CREATE MATERIALIZED VIEW weekly_leaderboard AS
SELECT user_id, SUM(points_delta) as weekly_points
FROM points_log
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY user_id
ORDER BY weekly_points DESC;

-- RLS
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users see own badges" ON user_badges
  FOR SELECT USING (auth.uid() = user_id);
```

#### Arquitectura:
```
lib/features/gamification/
├── domain/
│   ├── entities/
│   │   ├── badge_entity.dart
│   │   ├── leaderboard_entity.dart
│   │   └── user_level_entity.dart
│   ├── repositories/gamification_repository.dart
│   └── usecases/
│       ├── award_points.dart
│       ├── unlock_badge.dart
│       ├── get_leaderboard.dart
│       └── get_user_badges.dart
├── data/
│   ├── models/
│   │   ├── badge_model.dart
│   │   └── leaderboard_model.dart
│   ├── datasources/gamification_remote_data_source.dart
│   └── repositories/gamification_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── gamification_bloc.dart
    │   ├── gamification_event.dart
    │   └── gamification_state.dart
    ├── pages/
    │   ├── badges_page.dart
    │   └── leaderboard_page.dart
    └── widgets/
        ├── badge_card.dart
        ├── leaderboard_item.dart
        └── level_progress_bar.dart
```

**Entregables Fase 10:**
- [ ] Sistema de puntos funcional con triggers Supabase
- [ ] 15 insignias implementadas
- [ ] Leaderboards semanal y mensual
- [ ] Visualización en perfil de usuario

---

### FASE 11: Google/Apple Sign-In 🔑 PENDIENTE
**Duración estimada:** Semana 21  
**Costo:** $0 para Google; Apple requiere Apple Developer Program ($99/año)

- `google_sign_in ^6.2.1` ya está en `pubspec.yaml`
- `sign_in_with_apple ^6.1.2` ya está en `pubspec.yaml`
- Configurar OAuth en Google Cloud Console y Apple Developer Portal
- Integrar con Supabase Auth (ya soporta ambos proveedores)

---

### FASE 12: Panel de Comercios (B2B) 🏪 PENDIENTE
*(anteriormente Fase 9)*  
**Duración estimada:** Semanas 22–23  
**Costo:** Evaluar — puede requerir Supabase Pro ($25/mes) si la DB crece

#### Registro y verificación de comercios
#### Dashboard con estadísticas de visibilidad
#### Gestión de promociones propias
#### Modelo freemium (básico gratis / premium ₡15,000/mes)

> ⚠️ La integración de pagos (Stripe/SINPE Móvil) agrega complejidad significativa. Posponer para post-beta.

---

### FASE 13: Optimización y Lanzamiento 🎯 PENDIENTE
**Duración estimada:** Semanas 24–25  
**Costo:** Google Play $25 único + Apple Developer $99/año

#### Optimización:
- [ ] Lazy loading de imágenes con `cached_network_image` (ya en pubspec)
- [ ] Cache de datos con Hive (ya en pubspec)
- [ ] Shimmer effects para loading states (ya en pubspec)
- [ ] Reducción de tamaño de app (<50MB)
- [ ] Testing en 5+ dispositivos reales

#### Preparación para Stores:
- [ ] Icono de app (1024x1024)
- [ ] Screenshots (6+ por plataforma)
- [ ] Descripción en español e inglés
- [ ] Política de privacidad (requerida por stores)
- [ ] Términos y condiciones

---

## 📊 Métricas de Éxito

### Técnicas:
- Tiempo de carga < 3 segundos
- Crash rate < 1%
- App size < 50MB
- 60 FPS en animaciones
- Cobertura de tests > 70%

### Negocio:
- 10,000 descargas en primer mes
- 30% retención a 30 días
- 100 promociones activas/día
- 5,000 validaciones/semana
- 50 comercios registrados en 3 meses

---

## 💰 Estimación de Costos Actualizados

### Infraestructura (mensual):
| Servicio | Plan | Costo |
|---------|------|-------|
| Supabase | Free tier (hasta 500MB DB, 1GB Storage) | $0 durante beta |
| Supabase | Pro (cuando sea necesario) | $25/mes |
| Google Maps API | Free tier ($200 crédito/mes) | $0 durante beta |
| Firebase (FCM) | Spark plan | $0 |
| GitHub | Free | $0 |

### Publicación (único):
| Servicio | Costo |
|---------|-------|
| Google Play Console | $25 |
| Apple Developer Program | $99/año |
| Dominio optigasto.com | ~$15/año |

### Total para llegar a lanzamiento:
- **Mínimo (solo Android):** ~$40
- **Completo (Android + iOS):** ~$140 el primer año

---

## 🔗 Referencias
- **Repo:** https://github.com/FlechaVerdeY2K/OptiGasto
- **Branch activo:** `Phase_5`
- **Documento:** `PLAN_DESARROLLO_OPTIGASTO.md`
- **Contexto para Claude:** `Prompt.md`

---

**Documento actualizado:** 14 de abril de 2026  
**Versión:** 3.0  
**Estado:** Fases 1–6 completadas ✅ | Correcciones de seguridad pendientes 🚨
