# Feature: Notifications (Notificaciones)

## 📋 Descripción

Sistema completo de notificaciones para OptiGasto que incluye:
- Notificaciones locales con `flutter_local_notifications`
- Notificaciones en tiempo real con Supabase Realtime
- Preferencias de usuario personalizables
- Notificaciones de promociones cercanas (geofencing básico)
- Sistema de permisos robusto

## 🏗️ Arquitectura

Sigue **Clean Architecture** con tres capas:

```
lib/features/notifications/
├── domain/
│   ├── entities/
│   │   ├── notification_entity.dart
│   │   └── notification_preference_entity.dart
│   ├── repositories/
│   │   └── notification_repository.dart
│   └── usecases/
│       ├── check_nearby_promotions.dart
│       ├── get_notification_preferences.dart
│       ├── get_notifications.dart
│       ├── mark_as_read.dart
│       ├── send_local_notification.dart
│       └── update_notification_preferences.dart
├── data/
│   ├── models/
│   │   ├── notification_model.dart
│   │   └── notification_preference_model.dart
│   ├── datasources/
│   │   └── notification_remote_data_source.dart
│   └── repositories/
│       └── notification_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── notification_bloc.dart
    │   ├── notification_event.dart
    │   └── notification_state.dart
    └── pages/
        └── notification_settings_page.dart
```

## 🎯 Funcionalidades Implementadas

### 1. Tipos de Notificaciones

- ✅ **Promociones Cercanas** (`promotion_nearby`) - Alertas de ofertas cerca del usuario
- ✅ **Promociones por Vencer** (`promotion_expiring`) - Recordatorios de promociones que expiran pronto
- ✅ **Nuevas Promociones** (`promotion_new`) - Notificaciones de promociones recién publicadas
- ✅ **Nuevos Comercios** (`commerce_new`) - Alertas de comercios recién registrados
- ✅ **Insignias Desbloqueadas** (`badge_unlocked`) - Notificaciones de logros (preparado para Fase 6)
- ✅ **Subida de Nivel** (`level_up`) - Alertas de progreso (preparado para Fase 6)
- ✅ **Sistema** (`system`) - Mensajes importantes de la aplicación

### 2. Notificaciones Locales

- ✅ Envío de notificaciones inmediatas
- ✅ Programación de notificaciones futuras
- ✅ Cancelación de notificaciones programadas
- ✅ Soporte para Android e iOS
- ✅ Payload personalizado con datos adicionales

### 3. Supabase Realtime

- ✅ Suscripción automática a notificaciones en tiempo real
- ✅ Actualización instantánea de la UI cuando llegan notificaciones
- ✅ Manejo de reconexión automática
- ✅ Stream de notificaciones con BLoC

### 4. Preferencias de Usuario

- ✅ Activar/desactivar cada tipo de notificación
- ✅ Configurar radio de búsqueda (1-20 km)
- ✅ Filtros por categorías (preparado para futuro)
- ✅ Activar/desactivar todas las notificaciones con un clic
- ✅ Persistencia en Supabase

### 5. Geofencing Básico

- ✅ Detección de promociones cercanas basada en ubicación
- ✅ Respeta las preferencias de radio del usuario
- ✅ Integración con el sistema de ubicación existente
- ✅ Notificaciones automáticas cuando hay ofertas cerca

### 6. Gestión de Notificaciones

- ✅ Lista de notificaciones con paginación
- ✅ Marcar como leída (individual)
- ✅ Marcar todas como leídas
- ✅ Eliminar notificación (individual)
- ✅ Eliminar todas las notificaciones
- ✅ Contador de notificaciones no leídas

## 🗄️ Base de Datos

### Tablas Creadas

#### `notifications`
```sql
- id (UUID, PK)
- user_id (UUID, FK -> users)
- title (TEXT)
- body (TEXT)
- type (TEXT) - Enum de tipos
- data (JSONB) - Datos adicionales
- is_read (BOOLEAN)
- read_at (TIMESTAMPTZ)
- created_at (TIMESTAMPTZ)
- updated_at (TIMESTAMPTZ)
```

#### `notification_preferences`
```sql
- user_id (UUID, PK, FK -> users)
- enable_promotion_nearby (BOOLEAN)
- enable_promotion_expiring (BOOLEAN)
- enable_promotion_new (BOOLEAN)
- enable_badge_unlocked (BOOLEAN)
- enable_level_up (BOOLEAN)
- enable_commerce_new (BOOLEAN)
- enable_system (BOOLEAN)
- radius_km (DECIMAL)
- enabled_categories (TEXT[])
- created_at (TIMESTAMPTZ)
- updated_at (TIMESTAMPTZ)
```

### Funciones SQL

- ✅ `create_notification()` - Crea notificación respetando preferencias
- ✅ `get_unread_notifications_count()` - Obtiene contador de no leídas
- ✅ `mark_all_notifications_read()` - Marca todas como leídas

### RLS Policies

- ✅ Usuarios solo ven sus propias notificaciones
- ✅ Usuarios solo modifican sus propias preferencias
- ✅ Políticas de INSERT, SELECT, UPDATE, DELETE configuradas

### Realtime

- ✅ Tabla `notifications` habilitada para Realtime
- ✅ Publicación automática de cambios

## 🔧 Uso

### 1. Inicializar Notificaciones

El sistema se inicializa automáticamente en `main.dart`:

```dart
BlocProvider(
  create: (context) => di.sl<NotificationBloc>()
    ..add(const InitializeNotifications()),
),
```

### 2. Enviar Notificación Local

```dart
context.read<NotificationBloc>().add(
  SendLocalNotification(
    title: '¡Nueva promoción!',
    body: 'Hay una oferta cerca de ti',
    data: {'promotion_id': '123'},
  ),
);
```

### 3. Verificar Promociones Cercanas

```dart
context.read<NotificationBloc>().add(
  CheckNearbyPromotions(
    latitude: currentLocation.latitude,
    longitude: currentLocation.longitude,
  ),
);
```

### 4. Cargar Notificaciones

```dart
context.read<NotificationBloc>().add(
  const LoadNotifications(refresh: true),
);
```

### 5. Actualizar Preferencias

```dart
context.read<NotificationBloc>().add(
  UpdateNotificationPreferences(updatedPreferences),
);
```

## 🎨 UI

### Página de Configuración

Ruta: `/notification-settings`

Características:
- ✅ Switches para cada tipo de notificación
- ✅ Slider para configurar radio de búsqueda
- ✅ Botones de "Activar Todas" / "Desactivar Todas"
- ✅ Iconos descriptivos para cada tipo
- ✅ Feedback visual con SnackBars

## 🔐 Permisos

### Android

Configurado en `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
```

### iOS

Configurado en `Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## 📦 Dependencias

Ya incluidas en `pubspec.yaml`:
- `flutter_local_notifications: ^17.2.2`
- `supabase_flutter: ^2.5.0` (Realtime)

## 🚀 Próximos Pasos

### Mejoras Sugeridas:

1. **Lista de Notificaciones UI**
   - Crear página para ver todas las notificaciones
   - Implementar pull-to-refresh
   - Agregar filtros por tipo

2. **Notificaciones Push Reales**
   - Integrar Firebase Cloud Messaging (FCM)
   - Configurar Supabase Edge Functions para envío
   - Manejar notificaciones en background

3. **Geofencing Avanzado**
   - Usar `geofence` plugin para detección automática
   - Notificaciones cuando el usuario entra/sale de zonas
   - Optimización de batería

4. **Notificaciones Programadas**
   - Recordatorios de promociones guardadas
   - Alertas de caducidad
   - Resumen diario/semanal

5. **Analytics**
   - Tracking de notificaciones abiertas
   - Métricas de engagement
   - A/B testing de mensajes

## 🐛 Troubleshooting

### Notificaciones no aparecen en Android

1. Verificar permisos en configuración del dispositivo
2. Revisar que el canal de notificaciones esté creado
3. Comprobar que `flutter_local_notifications` esté inicializado

### Realtime no funciona

1. Verificar que la tabla tenga `ALTER PUBLICATION supabase_realtime ADD TABLE notifications;`
2. Comprobar conexión a internet
3. Revisar logs de Supabase

### Preferencias no se guardan

1. Verificar RLS policies en Supabase
2. Comprobar que el usuario esté autenticado
3. Revisar logs de errores en el BLoC

## 📝 Notas

- El sistema está preparado para gamificación (Fase 6)
- Todas las notificaciones respetan las preferencias del usuario
- El geofencing básico está implementado, pero puede mejorarse con plugins dedicados
- La migración SQL debe ejecutarse antes de usar el feature

## ✅ Testing

Para probar el sistema:

1. Ejecutar migración: `supabase db push`
2. Iniciar app y otorgar permisos de notificaciones
3. Ir a Configuración de Notificaciones
4. Activar "Promociones Cercanas"
5. Usar el mapa para verificar notificaciones de ofertas cercanas

---

**Implementado en:** Fase 5 - Funcionalidades Avanzadas  
**Fecha:** 8 de abril de 2026  
**Estado:** ✅ Completado y funcional