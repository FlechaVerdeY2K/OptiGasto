# 👤 Feature: Perfil de Usuario

## 📋 Descripción

Módulo completo de gestión de perfil de usuario para OptiGasto, implementado siguiendo Clean Architecture con BLoC para gestión de estado.

## ✨ Funcionalidades Implementadas

### 1. **Perfil de Usuario**
- ✅ Visualización de perfil completo
- ✅ Edición de información personal (nombre, teléfono)
- ✅ Subida y actualización de foto de perfil
- ✅ Visualización de reputación e insignias

### 2. **Estadísticas de Usuario**
- ✅ Ahorro total acumulado
- ✅ Promociones usadas
- ✅ Promociones publicadas
- ✅ Validaciones dadas
- ✅ Reportes enviados
- ✅ Ahorros por categoría
- ✅ Promociones por mes

### 3. **Historial de Promociones**
- ✅ Registro de promociones utilizadas
- ✅ Cálculo automático de ahorros
- ✅ Visualización de historial reciente
- ✅ Historial completo con paginación

## 🏗️ Arquitectura

```
lib/features/profile/
├── domain/
│   ├── entities/
│   │   ├── user_stats_entity.dart
│   │   └── promotion_history_entity.dart
│   ├── repositories/
│   │   └── profile_repository.dart
│   └── usecases/
│       ├── get_user_profile.dart
│       ├── update_user_profile.dart
│       ├── upload_profile_photo.dart
│       ├── get_user_stats.dart
│       ├── get_promotion_history.dart
│       └── mark_promotion_as_used.dart
├── data/
│   ├── models/
│   │   ├── user_stats_model.dart
│   │   └── promotion_history_model.dart
│   ├── datasources/
│   │   └── profile_remote_data_source.dart
│   └── repositories/
│       └── profile_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── profile_bloc.dart
    │   ├── profile_event.dart
    │   └── profile_state.dart
    ├── pages/
    │   └── profile_page.dart
    └── widgets/
        ├── profile_header_widget.dart
        ├── stats_card_widget.dart
        └── recent_history_widget.dart
```

## 🗄️ Base de Datos

### Tablas Creadas

#### `user_stats`
Almacena estadísticas detalladas de cada usuario:
- `total_savings`: Ahorro total acumulado
- `promotions_used`: Número de promociones usadas
- `promotions_published`: Número de promociones publicadas
- `validations_given`: Validaciones realizadas
- `reports_submitted`: Reportes enviados
- `savings_by_category`: JSONB con ahorros por categoría
- `promotions_by_month`: JSONB con promociones por mes

#### `promotion_history`
Registra el historial de promociones utilizadas:
- `user_id`: ID del usuario
- `promotion_id`: ID de la promoción
- `promotion_title`: Título de la promoción
- `commerce_name`: Nombre del comercio
- `category`: Categoría de la promoción
- `savings_amount`: Monto ahorrado
- `used_at`: Fecha de uso
- `notes`: Notas opcionales

### Storage Bucket

#### `avatars`
Bucket público para almacenar fotos de perfil de usuarios.

## 🔐 Seguridad (RLS)

Todas las tablas tienen Row Level Security (RLS) habilitado:

- **user_stats**: Los usuarios solo pueden ver/editar sus propias estadísticas
- **promotion_history**: Los usuarios solo pueden ver/editar su propio historial
- **avatars**: Los usuarios solo pueden subir/editar sus propias fotos

## 🔄 Triggers Automáticos

### `update_stats_on_promotion_publish`
Actualiza automáticamente `promotions_published` cuando un usuario publica una promoción.

### `update_stats_on_report`
Actualiza automáticamente `reports_submitted` cuando un usuario reporta una promoción.

## 📱 Uso

### Navegación al Perfil

```dart
context.push('/profile');
```

### Cargar Perfil Completo

```dart
context.read<ProfileBloc>().add(RefreshProfile(userId));
```

### Actualizar Perfil

```dart
context.read<ProfileBloc>().add(
  UpdateUserProfile(
    userId: userId,
    name: 'Nuevo Nombre',
    phone: '+506 1234-5678',
  ),
);
```

### Subir Foto de Perfil

```dart
context.read<ProfileBloc>().add(
  UploadProfilePhoto(
    userId: userId,
    filePath: imagePath,
  ),
);
```

### Marcar Promoción como Usada

```dart
context.read<ProfileBloc>().add(
  MarkPromotionAsUsed(
    userId: userId,
    promotionId: promotionId,
    savingsAmount: 5000.0,
    notes: 'Excelente oferta',
  ),
);
```

## 🎨 Widgets Reutilizables

### ProfileHeaderWidget
Muestra el header del perfil con foto, nombre, email y botón de edición.

```dart
ProfileHeaderWidget(
  user: userEntity,
  onEditPressed: () => context.push('/edit-profile'),
)
```

### StatsCardWidget
Muestra las estadísticas del usuario en cards visuales.

```dart
StatsCardWidget(stats: userStatsEntity)
```

### RecentHistoryWidget
Muestra el historial reciente de promociones usadas.

```dart
RecentHistoryWidget(
  history: historyList,
  onViewAll: () => context.push('/promotion-history'),
)
```

## 🔧 Dependencias Agregadas

```yaml
fl_chart: ^0.69.0  # Para gráficas de estadísticas (futuro)
```

## 📊 Próximas Mejoras

- [ ] Página de edición de perfil completa
- [ ] Página de estadísticas detalladas con gráficas (fl_chart)
- [ ] Página de historial completo con filtros
- [ ] Exportar historial a PDF/CSV
- [ ] Compartir estadísticas en redes sociales
- [ ] Comparación de ahorros con otros usuarios
- [ ] Metas de ahorro personalizadas

## 🧪 Testing

Para probar la funcionalidad:

1. **Aplicar migraciones de Supabase:**
   ```bash
   supabase db push
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Ejecutar la app:**
   ```bash
   flutter run
   ```

4. **Navegar al perfil desde el menú principal**

## 📝 Notas Importantes

- Las estadísticas se actualizan automáticamente mediante triggers de base de datos
- Las fotos de perfil se almacenan en Supabase Storage (bucket `avatars`)
- El historial de promociones se puede paginar para mejor rendimiento
- Todas las operaciones están protegidas con RLS para seguridad

## 🤝 Integración con Otras Features

- **Auth**: Usa `UserEntity` del módulo de autenticación
- **Promotions**: Se integra con el sistema de promociones para el historial
- **Notifications**: Las estadísticas pueden disparar notificaciones de logros

---

**Implementado por:** Bob  
**Fecha:** 2026-04-13  
**Versión:** 1.0.0