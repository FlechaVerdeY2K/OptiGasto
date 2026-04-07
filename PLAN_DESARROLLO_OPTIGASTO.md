# Plan de Desarrollo - Aplicación OptiGasto
## Flutter para Android y iOS

---

## 📋 Resumen Ejecutivo

OptiGasto es una aplicación móvil que permite a los consumidores costarricenses encontrar ofertas, promociones y descuentos geolocalizados en comercios cercanos. La plataforma se basa en un modelo colaborativo donde usuarios y comercios actualizan información en tiempo real.

**Objetivo:** Desarrollar una aplicación Flutter multiplataforma (Android/iOS) que implemente todas las funcionalidades identificadas en el proyecto de mercadeo.

**Estado Actual:** ✅ Fases 1-4 completadas (Autenticación, Promociones Core, Geolocalización y Mapas, Publicación y Validación)

---

## 🎯 Requerimientos Funcionales Principales

### 1. **Gestión de Usuarios** ✅ PARCIALMENTE COMPLETADO
- ✅ Registro y autenticación con email
- ✅ Perfil de usuario básico
- ✅ Gestión de sesión con BLoC
- ✅ Logout funcional
- [ ] Google Sign-In
- [ ] Apple Sign-In
- [ ] Editar perfil completo
- [ ] Sistema de reputación y gamificación
- [ ] Programa de embajadores comunitarios
- [ ] Acceso como invitado (sin registro)
- [ ] Dashboard de ahorro personal

### 2. **Geolocalización y Mapas** ✅ COMPLETADO
- ✅ Visualización de comercios cercanos en mapa
- ✅ Filtrado por distancia y tipo de comercio
- ✅ Detección automática de zona geográfica
- ✅ Markers con clustering
- ✅ Info windows personalizados
- [ ] Ruta de Ahorro Inteligente (optimización de ruta)
- [ ] Notificaciones push basadas en ubicación

### 3. **Gestión de Promociones** ✅ COMPLETADO
- ✅ Visualización de ofertas geolocalizadas
- ✅ Publicación de promociones con evidencia fotográfica
- ✅ Sistema de validación comunitaria
- ✅ Reportar promociones vencidas
- ✅ Guardar promociones favoritas
- [ ] Compartir promociones en redes sociales
- [ ] Búsqueda avanzada por producto

### 4. **Sistema Colaborativo** ✅ COMPLETADO
- ✅ Subir fotos de promociones
- ✅ Validar ofertas existentes (thumbs up/down)
- ✅ Sistema de confiabilidad de información
- [ ] Rankings de colaboradores activos
- [ ] Insignias y recompensas
- [ ] OCR para lectura automática (opcional)

### 5. **Búsqueda y Filtros** ✅ PARCIALMENTE COMPLETADO
- ✅ Filtros por categoría de producto
- ✅ Ordenamiento por distancia
- [ ] Búsqueda por producto específico
- [ ] Búsqueda por comercio
- [ ] Filtros por tipo de descuento
- [ ] Ordenamiento por descuento, fecha

### 6. **Notificaciones** ❌ PENDIENTE
- [ ] Alertas de promociones cercanas
- [ ] Notificaciones de promociones guardadas
- [ ] Recordatorios de caducidad
- [ ] Notificaciones personalizadas según historial

### 7. **Panel de Comercios (B2B)** ❌ PENDIENTE
- [ ] Registro de comercios
- [ ] Publicación de promociones propias
- [ ] Estadísticas de visibilidad
- [ ] Planes freemium (básico/premium)

### 8. **Analítica y Métricas** ❌ PENDIENTE
- [ ] Dashboard de ahorro personal
- [ ] Historial de promociones utilizadas
- [ ] Estadísticas de uso
- [ ] Métricas de ahorro mensual

---

## 🏗️ Arquitectura de la Aplicación

### **Patrón de Arquitectura: Clean Architecture + BLoC** ✅ IMPLEMENTADO

```
lib/
├── core/
│   ├── config/supabase_config.dart ✅
│   ├── constants/ ✅
│   ├── di/injection_container.dart ✅
│   ├── errors/ ✅
│   ├── routes/app_router.dart ✅
│   ├── theme/ ✅
│   └── utils/ ✅
├── features/
│   ├── auth/ ✅ COMPLETADO
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── promotions/ ✅ COMPLETADO
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── location/ ✅ COMPLETADO
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── onboarding/ ✅ COMPLETADO
│   │   └── presentation/pages/
│   ├── home/ ✅ COMPLETADO
│   │   └── presentation/pages/home_page.dart
│   ├── route/ ❌ PENDIENTE
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── notifications/ ❌ PENDIENTE
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── profile/ ❌ PENDIENTE (parcial en auth)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── gamification/ ❌ PENDIENTE
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── commerce/ ❌ PENDIENTE
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart ✅
```

---

## 🛠️ Stack Tecnológico

### **Framework y Lenguaje** ✅
- **Flutter 3.x** (Dart 3.x)
- Soporte para Android 6.0+ (API 23+)
- Soporte para iOS 12.0+
- Soporte para Web

### **Gestión de Estado** ✅
- **flutter_bloc** (^8.1.0) - Patrón BLoC
- **equatable** (^2.0.5) - Comparación de objetos

### **Backend y Base de Datos** ✅
- **Supabase:**
  - ✅ Supabase Auth (autenticación)
  - ✅ Supabase Database (PostgreSQL con PostGIS)
  - ✅ Supabase Storage (almacenamiento de imágenes)
  - ✅ Row Level Security (RLS)
  - [ ] Supabase Realtime (actualizaciones en tiempo real)
  - [ ] Supabase Edge Functions (funciones serverless)

### **Mapas y Geolocalización** ✅
- **google_maps_flutter** (^2.5.0) - Mapas
- **geolocator** (^10.1.0) - Geolocalización
- **geocoding** (^2.1.1) - Geocodificación
- [ ] **flutter_polyline_points** (^2.0.0) - Rutas optimizadas

### **Imágenes y Multimedia** ✅ PARCIALMENTE
- ✅ **image_picker** (^1.0.4) - Captura de fotos
- ✅ **flutter_image_compress** (^2.1.0) - Compresión
- ✅ **path_provider** (^2.1.4) - Acceso a directorios
- [ ] **cached_network_image** (^3.3.0) - Cache de imágenes
- [ ] **image_cropper** (^5.0.0) - Recorte de imágenes
- [ ] **google_ml_kit** (^0.16.0) - OCR (opcional)

### **Networking** ✅
- **supabase_flutter** (^2.0.0) - Cliente Supabase
- **dartz** (^0.10.1) - Programación funcional

### **Almacenamiento Local** ❌ PENDIENTE
- [ ] **shared_preferences** (^2.2.2) - Preferencias
- [ ] **hive** (^2.2.3) - Base de datos local
- [ ] **flutter_secure_storage** (^9.0.0) - Almacenamiento seguro

### **UI/UX** ✅ PARCIALMENTE
- ✅ Material Design 3
- ✅ Tema personalizado
- [ ] **flutter_svg** (^2.0.9) - Iconos SVG
- [ ] **shimmer** (^3.0.0) - Efectos de carga
- [ ] **flutter_rating_bar** (^4.0.1) - Calificaciones
- [ ] **badges** (^3.1.2) - Insignias
- [ ] **animations** (^2.0.8) - Animaciones

### **Notificaciones** ❌ PENDIENTE
- [ ] **flutter_local_notifications** (^16.1.0) - Notificaciones locales
- [ ] **supabase_flutter** (^2.0.0) - Push notifications con Realtime

### **Utilidades** ✅ PARCIALMENTE
- ✅ **intl** (^0.18.1) - Internacionalización
- ✅ **go_router** (^13.0.0) - Navegación
- ✅ **get_it** (^7.6.0) - Dependency Injection
- [ ] **url_launcher** (^6.2.1) - Abrir URLs
- [ ] **share_plus** (^7.2.1) - Compartir contenido
- [ ] **permission_handler** (^11.0.1) - Permisos

---

## 🚀 Fases de Desarrollo

### **FASE 1: MVP - Autenticación y Fundamentos** ✅ COMPLETADA
**Duración:** Semanas 1-4

**Completado:**
- [x] Configuración del proyecto Flutter
- [x] Configuración de Supabase (Auth, Database, Storage)
- [x] Estructura de carpetas (Clean Architecture)
- [x] Setup de dependencias (flutter_bloc, get_it, dartz, go_router)
- [x] Tema y constantes de la app (AppColors, AppTheme)
- [x] Implementar Supabase Auth completo
- [x] Pantallas de login/registro funcionales
- [x] Perfil de usuario con datos reales
- [x] Gestión de sesión con BLoC
- [x] Onboarding screens (3 slides)
- [x] Logout funcional con confirmación
- [x] Gestión de sesión en rutas (redirect en go_router)
- [x] Recuperación de contraseña (ForgotPasswordPage)

**Entregables:**
- ✅ App funcional con autenticación completa
- ✅ Usuarios pueden registrarse y hacer login
- ✅ Gestión de sesión persistente
- ✅ Recuperación de contraseña

---

### **FASE 2: Promociones Core** ✅ COMPLETADA
**Duración:** Semanas 5-6

**Completado:**
- [x] Crear modelo de datos de promociones
  - `PromotionEntity` (domain) ✅
  - `PromotionModel` (data) ✅
  - `CategoryEntity` y `CommerceEntity` ✅
- [x] Implementar repositorio de promociones
  - `PromotionRepository` (abstracto) ✅
  - `PromotionRepositoryImpl` con Supabase ✅
  - `PromotionRemoteDataSource` ✅
- [x] Crear BLoC de promociones
  - Estados: Initial, Loading, Loaded, Error, DetailLoaded, SaveToggled ✅
  - Eventos: Fetch, Filter, Search, Detail, Validate, ToggleSave ✅
- [x] Pantallas de promociones
  - Lista de promociones con cards ✅
  - Detalle de promoción ✅
  - Filtros por categoría ✅
  - Scroll infinito con paginación ✅
- [x] Integrar con HomePage (tab de Ofertas) ✅

**Entregables:**
- [x] Usuarios pueden ver promociones ✅
- [x] Sistema de filtros por categoría ✅
- [x] Detalle completo de promoción ✅
- [x] Botón de favoritos funcional ✅
- [x] Sistema de validación comunitaria (likes/dislikes) ✅
- [x] Pull-to-refresh ✅

---

### **FASE 3: Geolocalización y Mapas** ✅ COMPLETADA
**Duración:** Semanas 7-8

**Completado:**
- [x] Integración de Google Maps
  - Configurar API key para Android, iOS y Web ✅
  - Implementar mapa interactivo con `google_maps_flutter` ✅
  - Markers de comercios y promociones ✅
  - Clustering de markers ✅
- [x] Geolocalización del usuario
  - Permisos de ubicación (Android/iOS) ✅
  - Obtener ubicación actual con `geolocator` ✅
  - Actualización en tiempo real con stream ✅
  - Manejo de estados de permisos ✅
- [x] Funcionalidades de mapa
  - Filtrado por distancia (1km, 5km, 10km, 20km) ✅
  - Detalle de comercio/promoción al tocar marker ✅
  - Navegación a ubicación del usuario ✅
  - Controles de zoom y tipo de mapa ✅
- [x] Tab de Mapa funcional
  - Visualización de promociones cercanas ✅
  - Info windows personalizados ✅
  - Filtros por tipo (promociones/comercios) ✅
  - Modal de detalles con información completa ✅

**Arquitectura Implementada:**
- Domain Layer:
  - `LocationEntity` con cálculo de distancias (Haversine) ✅
  - `MapMarkerEntity` con tipos de marcadores ✅
  - `LocationRepository` (abstracto) con 12 métodos ✅
  - 5 Use Cases completos ✅

- Data Layer:
  - `LocationModel` con conversión desde Geolocator ✅
  - `MapMarkerModel` con factory methods ✅
  - `LocationRemoteDataSource` ✅
  - `LocationRepositoryImpl` ✅

- Presentation Layer:
  - `LocationBloc` con 14 handlers ✅
  - `MapPage` con UI completa ✅

**Base de Datos:**
- Migración SQL con funciones PostGIS:
  - `nearby_promotions(lat, lng, radius_km)` ✅
  - `nearby_commerces(lat, lng, radius_km)` ✅
  - `calculate_distance(lat1, lng1, lat2, lng2)` ✅

**Entregables:**
- ✅ Mapa interactivo funcional
- ✅ Geolocalización en tiempo real
- ✅ Markers con clustering
- ✅ Filtros por distancia
- ✅ Detalle de promociones desde mapa

---

### **FASE 4: Publicación y Validación** ✅ COMPLETADA
**Duración:** Semanas 9-10

**Completado:**
- [x] Captura y subida de fotos
  - Integrar `image_picker` ✅
  - Comprimir imágenes con `flutter_image_compress` ✅
  - Subir a Supabase Storage ✅
  - Manejo de permisos de cámara y galería ✅
- [x] Formulario de promoción
  - Selección de comercio con búsqueda ✅
  - Categorización (8 categorías) ✅
  - Fecha de vencimiento ✅
  - Descripción y precio ✅
  - Validación completa de formulario ✅
- [x] Sistema de validación comunitaria
  - Like/Dislike de promociones ✅
  - Contador de validaciones ✅
  - Actualización en tiempo real ✅
- [x] Reportar promociones
  - Formulario de reporte con motivos ✅
  - Tabla `reports` en base de datos ✅
  - RLS policies configuradas ✅

**Arquitectura Implementada:**
- Domain Layer:
  - Use Case: `CreatePromotion` ✅
  - Use Case: `UploadPromotionImages` ✅
  - Use Case: `ReportPromotion` ✅

- Data Layer:
  - Métodos de Storage en data source ✅
  - UPSERT para favoritos ✅

- Presentation Layer:
  - `PublishPromotionBloc` completo ✅
  - `ImagePickerWidget` ✅
  - `CommerceSearchWidget` ✅
  - `PublishPromotionPage` ✅

**Bugs Corregidos:**
- ✅ Selección de imágenes desde galería
- ✅ Slider de radio en mapa
- ✅ Filtros de categoría
- ✅ Toggle de favoritos (UPSERT)

**Entregables:**
- ✅ Usuarios pueden publicar promociones
- ✅ Captura y compresión de fotos
- ✅ Selección de comercio
- ✅ Validación comunitaria funcional
- ✅ Sistema de reportes

---

### **FASE 5: Funcionalidades Avanzadas** 🚀 PENDIENTE
**Duración:** Semanas 11-14

#### **Ruta Inteligente (Semanas 11-12):** ❌ PENDIENTE
- [ ] Algoritmo de optimización de ruta (TSP - Traveling Salesman Problem)
- [ ] Integración con Google Directions API
- [ ] Visualización de ruta en mapa con polylines
- [ ] Estimación de tiempo y distancia total
- [ ] Guardar rutas favoritas
- [ ] Reordenar puntos de la ruta manualmente
- [ ] Exportar ruta a Google Maps/Waze

**Dependencias necesarias:**
```yaml
flutter_polyline_points: ^2.0.0
google_directions_api: ^0.9.0
```

**Arquitectura necesaria:**
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

#### **Notificaciones (Semanas 13-14):** ❌ PENDIENTE
- [ ] Supabase Realtime setup para notificaciones
- [ ] Notificaciones push de promociones cercanas
- [ ] Notificaciones locales programadas
- [ ] Preferencias de notificaciones por categoría
- [ ] Notificaciones geolocalizadas (geofencing)
- [ ] Recordatorios de caducidad de promociones guardadas
- [ ] Notificaciones de nuevas promociones en comercios favoritos

**Dependencias necesarias:**
```yaml
supabase_flutter: ^2.0.0  # Ya incluido, usar Realtime
flutter_local_notifications: ^16.1.0
```

**Arquitectura necesaria:**
```
lib/features/notifications/
├── domain/
│   ├── entities/
│   │   ├── notification_entity.dart
│   │   └── notification_preference_entity.dart
│   ├── repositories/notification_repository.dart
│   └── usecases/
│       ├── send_notification.dart
│       ├── schedule_notification.dart
│       ├── get_notification_preferences.dart
│       └── update_notification_preferences.dart
├── data/
│   ├── models/
│   │   ├── notification_model.dart
│   │   └── notification_preference_model.dart
│   ├── datasources/notification_remote_data_source.dart
│   └── repositories/notification_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── notification_bloc.dart
    │   ├── notification_event.dart
    │   └── notification_state.dart
    └── pages/
        └── notification_settings_page.dart
```

**Entregables Fase 5:**
- [ ] Ruta de Ahorro Inteligente funcional
- [ ] Sistema de notificaciones completo
- [ ] Preferencias de notificaciones
- [ ] Geofencing implementado

---

### **FASE 6: Gamificación** 🎮 PENDIENTE
**Duración:** Semanas 15-16

#### **Sistema de Puntos y Reputación:**
- [ ] Puntos por publicar promociones (+10 pts)
- [ ] Puntos por validar promociones (+5 pts)
- [ ] Puntos por usar promociones (+3 pts)
- [ ] Puntos por reportar promociones inválidas (+2 pts)
- [ ] Sistema de niveles (Bronce, Plata, Oro, Platino, Diamante)
- [ ] Multiplicadores de puntos por racha
- [ ] Penalización por reportes falsos (-10 pts)
- [ ] Tabla de usuarios en base de datos con campo `points` y `level`

#### **Insignias y Logros:**
- [ ] Diseño de 15+ badges diferentes
- [ ] Sistema de desbloqueo progresivo
- [ ] Insignias especiales por eventos
- [ ] Visualización en perfil
- [ ] Compartir logros en redes sociales
- [ ] Notificaciones de nuevas insignias
- [ ] Tabla `badges` y `user_badges` en base de datos

**Insignias propuestas:**
- 🥉 "Primer Ahorro" - Primera promoción guardada
- 📸 "Fotógrafo" - 10 promociones publicadas
- 📸 "Paparazzi" - 50 promociones publicadas
- ✅ "Validador" - 50 validaciones realizadas
- ✅ "Inspector" - 200 validaciones realizadas
- 🗺️ "Explorador" - Visitar 20 comercios diferentes
- 🗺️ "Aventurero" - Visitar 50 comercios diferentes
- 💰 "Ahorrador" - Ahorrar ₡10,000 en un mes
- 💰 "Ahorrador Pro" - Ahorrar ₡50,000 en un mes
- 💎 "Millonario del Ahorro" - Ahorrar ₡100,000 en un mes
- 🔥 "Racha de Fuego" - 7 días consecutivos usando la app
- 🔥 "Imparable" - 30 días consecutivos usando la app
- 👑 "Embajador" - Top 10 del ranking mensual
- 🌟 "Leyenda" - Top 3 del ranking mensual
- 🎯 "Precisión" - 100% de validaciones correctas (mínimo 20)

#### **Rankings y Leaderboards:**
- [ ] Leaderboard semanal/mensual/anual
- [ ] Top colaboradores por región
- [ ] Top ahorradores
- [ ] Ranking de comercios más populares
- [ ] Filtros por categoría en rankings
- [ ] Tabla `leaderboards` en base de datos

**Arquitectura necesaria:**
```
lib/features/gamification/
├── domain/
│   ├── entities/
│   │   ├── badge_entity.dart
│   │   ├── achievement_entity.dart
│   │   ├── leaderboard_entity.dart
│   │   └── user_level_entity.dart
│   ├── repositories/gamification_repository.dart
│   └── usecases/
│       ├── award_points.dart
│       ├── unlock_badge.dart
│       ├── get_leaderboard.dart
│       ├── get_user_badges.dart
│       └── check_achievements.dart
├── data/
│   ├── models/
│   │   ├── badge_model.dart
│   │   ├── achievement_model.dart
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
    │   ├── leaderboard_page.dart
    │   └── achievements_page.dart
    └── widgets/
        ├── badge_card.dart
        ├── leaderboard_item.dart
        ├── level_progress_bar.dart
        └── achievement_card.dart
```

**Entregables Fase 6:**
- [ ] Sistema de puntos funcional
- [ ] 15+ insignias implementadas
- [ ] Leaderboards semanales y mensuales
- [ ] Visualización de logros en perfil

---

### **FASE 7: Panel de Comercios (B2B)** 🏪 PENDIENTE
**Duración:** Semanas 17-18

#### **Registro y Verificación:**
- [ ] Formulario de registro de comercio
- [ ] Verificación de comercio (manual/automática)
- [ ] Subida de documentos (cédula jurídica, patente)
- [ ] Aprobación por administrador
- [ ] Notificación de aprobación/rechazo
- [ ] Tabla `commerce_applications` en base de datos

#### **Dashboard de Comercio:**
- [ ] Estadísticas de visibilidad (vistas, clics, guardados)
- [ ] Promociones activas del comercio
- [ ] Gráficas de rendimiento (últimos 30 días)
- [ ] Análisis de competencia
- [ ] Métricas de engagement (validaciones, reportes)
- [ ] Tabla `commerce_stats` en base de datos

#### **Gestión de Promociones Propias:**
- [ ] Formulario simplificado para comercios
- [ ] Programar publicación de promociones
- [ ] Editar promociones activas
- [ ] Pausar/reactivar promociones
- [ ] Duplicar promociones
- [ ] Historial de promociones
- [ ] Plantillas de promociones

#### **Modelo Freemium:**
- [ ] Plan básico (gratis):
  - 3 promociones activas simultáneas
  - Estadísticas básicas
  - Sin destacados
  - Marca de agua en imágenes
- [ ] Plan premium (₡15,000/mes):
  - Promociones ilimitadas
  - Estadísticas avanzadas
  - Promociones destacadas (aparecen primero)
  - Soporte prioritario
  - Sin marca de agua
  - Badge de "Comercio Verificado"
- [ ] Integración de pagos (Stripe/PayPal/SINPE Móvil)
- [ ] Gestión de suscripciones
- [ ] Tabla `subscriptions` en base de datos

**Arquitectura necesaria:**
```
lib/features/commerce/
├── domain/
│   ├── entities/
│   │   ├── commerce_stats_entity.dart
│   │   ├── subscription_entity.dart
│   │   └── commerce_application_entity.dart
│   ├── repositories/commerce_repository.dart
│   └── usecases/
│       ├── register_commerce.dart
│       ├── get_commerce_stats.dart
│       ├── manage_subscription.dart
│       ├── create_commerce_promotion.dart
│       └── get_commerce_promotions.dart
├── data/
│   ├── models/
│   │   ├── commerce_stats_model.dart
│   │   └── subscription_model.dart
│   ├── datasources/commerce_remote_data_source.dart
│   └── repositories/commerce_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── commerce_bloc.dart
    │   ├── commerce_event.dart
    │   └── commerce_state.dart
    ├── pages/
    │   ├── commerce_registration_page.dart
    │   ├── commerce_dashboard_page.dart
    │   ├── commerce_promotions_page.dart
    │   └── subscription_page.dart
    └── widgets/
        ├── stats_widget.dart
        ├── promotion_manager_widget.dart
        └── subscription_card.dart
```

**Entregables Fase 7:**
- [ ] Registro de comercios funcional
- [ ] Dashboard B2B completo
- [ ] Gestión de promociones propias
- [ ] Modelo freemium implementado

---

### **FASE 8: Perfil de Usuario Completo** 👤 PENDIENTE
**Duración:** Semanas 19-20

#### **Edición de Perfil:**
- [ ] Editar nombre y teléfono
- [ ] Cambiar foto de perfil con recorte
- [ ] Cambiar contraseña
- [ ] Eliminar cuenta
- [ ] Configuración de privacidad

#### **Dashboard de Ahorro:**
- [ ] Gráfica de ahorro mensual (últimos 6 meses)
- [ ] Ahorro total acumulado
- [ ] Promociones utilizadas este mes
- [ ] Categoría con más ahorro
- [ ] Comercio favorito
- [ ] Estadísticas de uso (días activos, promociones vistas)

#### **Historial:**
- [ ] Historial de promociones guardadas
- [ ] Historial de promociones utilizadas
- [ ] Historial de validaciones
- [ ] Historial de publicaciones
- [ ] Exportar historial a PDF/CSV

#### **Configuración:**
- [ ] Preferencias de notificaciones
- [ ] Radio de búsqueda predeterminado
- [ ] Categorías favoritas
- [ ] Modo oscuro
- [ ] Idioma (Español/Inglés)
- [ ] Unidades (km/millas)

**Dependencias necesarias:**
```yaml
fl_chart: ^0.65.0  # Para gráficas
image_cropper: ^5.0.0  # Para recortar foto
pdf: ^3.10.0  # Para exportar PDF
```

**Arquitectura necesaria:**
```
lib/features/profile/
├── domain/
│   ├── entities/
│   │   ├── user_stats_entity.dart
│   │   ├── savings_history_entity.dart
│   │   └── user_preferences_entity.dart
│   ├── repositories/profile_repository.dart
│   └── usecases/
│       ├── update_profile.dart
│       ├── get_user_stats.dart
│       ├── get_savings_history.dart
│       ├── update_preferences.dart
│       └── export_history.dart
├── data/
│   ├── models/
│   │   ├── user_stats_model.dart
│   │   ├── savings_history_model.dart
│   │   └── user_preferences_model.dart
│   ├── datasources/profile_remote_data_source.dart
│   └── repositories/profile_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── profile_bloc.dart
    │   ├── profile_event.dart
    │   └── profile_state.dart
    ├── pages/
    │   ├── edit_profile_page.dart
    │   ├── savings_dashboard_page.dart
    │   ├── history_page.dart
    │   └── settings_page.dart
    └── widgets/
        ├── stats_card.dart
        ├── savings_chart.dart
        ├── history_item.dart
        └── preference_tile.dart
```

**Entregables Fase 8:**
- [ ] Edición completa de perfil
- [ ] Dashboard de ahorro con gráficas
- [ ] Historial completo
- [ ] Configuración avanzada

---

### **FASE 9: Búsqueda y Filtros Avanzados** 🔍 PENDIENTE
**Duración:** Semanas 21-22

#### **Búsqueda Avanzada:**
- [ ] Búsqueda por producto específico
- [ ] Búsqueda por comercio
- [ ] Búsqueda por rango de precio
- [ ] Búsqueda por porcentaje de descuento
- [ ] Historial de búsquedas
- [ ] Sugerencias de búsqueda (autocomplete)
- [ ] Búsqueda por voz
- [ ] Búsqueda con filtros combinados

#### **Filtros Avanzados:**
- [ ] Filtro por tipo de descuento (%, ₡, 2x1, 3x2)
- [ ] Filtro por rango de fechas
- [ ] Filtro por calificación de comercio
- [ ] Filtro por validaciones positivas (>80%)
- [ ] Ordenamiento múltiple (distancia + descuento)
- [ ] Guardar filtros favoritos
- [ ] Filtros rápidos predefinidos

#### **Compartir y Social:**
- [ ] Compartir promoción en WhatsApp
- [ ] Compartir en Facebook/Instagram
- [ ] Generar imagen para compartir (con QR)
- [ ] Link profundo a promoción
- [ ] Programa de referidos con código
- [ ] Invitar amigos con recompensa

**Dependencias necesarias:**
```yaml
share_plus: ^7.2.1  # Para compartir
url_launcher: ^6.2.1  # Para abrir URLs
speech_to_text: ^6.5.0  # Para búsqueda por voz
qr_flutter: ^4.1.0  # Para generar QR
```

**Entregables Fase 9:**
- [ ] Búsqueda avanzada funcional
- [ ] Filtros combinados
- [ ] Compartir en redes sociales
- [ ] Programa de referidos

---

### **FASE 10: Optimización y Lanzamiento** 🎯 PENDIENTE
**Duración:** Semanas 23-24

#### **Analítica y Métricas:**
- [ ] Supabase Analytics configurado
- [ ] Eventos personalizados trackeados
- [ ] Dashboard de métricas en tiempo real
- [ ] A/B testing setup
- [ ] Crashlytics (opcional con Sentry)

#### **Optimización:**
- [ ] Optimización de rendimiento (60 FPS)
- [ ] Reducción de tamaño de app (<50MB)
- [ ] Lazy loading de imágenes
- [ ] Cache de datos
- [ ] Mejora de UX basada en feedback
- [ ] Corrección de bugs
- [ ] Testing exhaustivo

#### **Preparación para Lanzamiento:**
- [ ] Testing en dispositivos reales (10+ dispositivos)
- [ ] Preparación de assets:
  - Icono de app (1024x1024)
  - Screenshots (6+ por plataforma)
  - Feature graphic
  - Video promocional (30 segundos)
- [ ] Descripción de stores (ES/EN)
- [ ] Política de privacidad
- [ ] Términos y condiciones
- [ ] Documentación completa
- [ ] Guía de usuario
- [ ] FAQs

**Entregables Fase 10:**
- [ ] App optimizada y pulida
- [ ] Documentación completa
- [ ] Assets para stores
- [ ] App lista para publicación

---

## 🔮 Funcionalidades Futuras (Post-Lanzamiento)

### **Corto Plazo (3-6 meses):**
- [ ] OCR para lectura automática de precios
- [ ] Comparador de precios por producto
- [ ] Lista de compras inteligente
- [ ] Integración con WhatsApp Business
- [ ] Modo oscuro completo
- [ ] Widget de home screen

### **Mediano Plazo (6-12 meses):**
- [ ] Programa de referidos con recompensas
- [ ] Cashback y recompensas
- [ ] Integración con bancos (tarjetas)
- [ ] Predicción de precios con ML
- [ ] Asistente virtual (chatbot)
- [ ] Realidad aumentada para ver promociones

### **Largo Plazo (12+ meses):**
- [ ] Expansión a otros países (Panamá, Nicaragua)
- [ ] Marketplace de productos
- [ ] Delivery integrado
- [ ] Wallet digital
- [ ] Programa de fidelización multi-comercio
- [ ] API pública para desarrolladores

---

## 📊 Métricas de Éxito

### **Técnicas:**
- Tiempo de carga < 3 segundos
- Crash rate < 1%
- App size < 50MB
- Tiempo de respuesta API < 500ms
- 60 FPS en animaciones
- Cobertura de tests >70%

### **Negocio:**
- 10,000 descargas en primer mes
- 30% de retención a 30 días
- 100 promociones activas/día
- 5,000 validaciones/semana
- 50 comercios registrados en 3 meses
- 4.5+ estrellas en stores

---

## 💰 Estimación de Costos

### **Desarrollo (Fases 1-10):**
- **Equipo Mínimo:**
  - 1 Flutter Developer Senior (Lead)
  - 1 Flutter Developer Mid
  - 1 UI/UX Designer
  - 1 Backend Developer (Supabase)
  - 1 QA Tester

- **Duración:** 24 semanas (6 meses)
- **Costo Estimado:** $50,000 - $70,000 USD

### **Infraestructura (Mensual):**
- Supabase Pro Plan: $25/mes (hasta 100GB)
- Google Maps API: $100-300/mes
- Hosting web: $10-20/mes
- **Total:** $185-445/mes

### **Servicios Adicionales:**
- Apple Developer Program: $99/año
- Google Play Console: $25 (único)
- Dominio: $15/año
- SSL Certificate: Gratis (Let's Encrypt)

---

## 📝 Conclusiones

Este plan de desarrollo proporciona una hoja de ruta completa para la implementación de OptiGasto en Flutter. La aplicación está diseñada para:

1. **Resolver el problema real** del consumidor costarricense
2. **Escalar eficientemente** con arquitectura limpia
3. **Mantener calidad** con testing exhaustivo
4. **Generar valor** tanto para usuarios como comercios
5. **Adaptarse** a cambios del mercado

### **Estado Actual:**
✅ **Fases 1-4 completadas** (40% del proyecto)
- Autenticación completa
- Promociones core funcionales
- Geolocalización y mapas
- Publicación y validación

### **Próximos Pasos Prioritarios:**

**Opción A - Ruta Inteligente (Fase 5):**
- Alta demanda de usuarios
- Diferenciador clave vs competencia
- Complejidad técnica media-alta
- Impacto en engagement: Alto

**Opción B - Notificaciones (Fase 5):**
- Crítico para retención
- Aumenta uso diario de la app
- Complejidad técnica media
- Impacto en retención: Muy Alto

**Opción C - Perfil Completo (Fase 8):**
- Mejora experiencia de usuario
- Necesario para gamificación
- Complejidad técnica baja
- Impacto en satisfacción: Alto

**Recomendación:** Iniciar con **Notificaciones** (Opción B) por su alto impacto en retención, seguido de **Perfil Completo** (Opción C) y luego **Ruta Inteligente** (Opción A).

---

**Documento actualizado:** 7 de abril de 2026  
**Versión:** 2.0  
**Autor:** Equipo OptiGasto  
**Estado:** Fases 1-4 completadas ✅
