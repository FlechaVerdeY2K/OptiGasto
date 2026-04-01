# Plan de Desarrollo - Aplicación OptiGasto
## Flutter para Android y iOS

---

## 📋 Resumen Ejecutivo

OptiGasto es una aplicación móvil que permite a los consumidores costarricenses encontrar ofertas, promociones y descuentos geolocalizados en comercios cercanos. La plataforma se basa en un modelo colaborativo donde usuarios y comercios actualizan información en tiempo real.

**Objetivo:** Desarrollar una aplicación Flutter multiplataforma (Android/iOS) que implemente todas las funcionalidades identificadas en el proyecto de mercadeo.

---

## 🎯 Requerimientos Funcionales Principales

### 1. **Gestión de Usuarios**
- Registro y autenticación (email, Google, Apple Sign-In)
- Perfil de usuario con historial de ahorro
- Sistema de reputación y gamificación
- Programa de embajadores comunitarios
- Acceso como invitado (sin registro)

### 2. **Geolocalización y Mapas**
- Visualización de comercios cercanos en mapa
- Filtrado por distancia y tipo de comercio
- Ruta de Ahorro Inteligente (optimización de ruta)
- Notificaciones push basadas en ubicación
- Detección automática de zona geográfica

### 3. **Gestión de Promociones**
- Visualización de ofertas geolocalizadas
- Publicación de promociones con evidencia fotográfica
- Sistema de validación comunitaria
- Reportar promociones vencidas
- Guardar promociones favoritas
- Compartir promociones en redes sociales

### 4. **Sistema Colaborativo**
- Subir fotos de promociones (OCR opcional)
- Validar ofertas existentes (thumbs up/down)
- Sistema de confiabilidad de información
- Rankings de colaboradores activos
- Insignias y recompensas

### 5. **Búsqueda y Filtros**
- Búsqueda por producto, categoría o comercio
- Filtros por tipo de descuento
- Filtros por categoría de producto
- Ordenamiento por distancia, descuento, fecha

### 6. **Notificaciones**
- Alertas de promociones cercanas
- Notificaciones de promociones guardadas
- Recordatorios de caducidad
- Notificaciones personalizadas según historial

### 7. **Panel de Comercios (B2B)**
- Registro de comercios
- Publicación de promociones propias
- Estadísticas de visibilidad
- Planes freemium (básico/premium)

### 8. **Analítica y Métricas**
- Dashboard de ahorro personal
- Historial de promociones utilizadas
- Estadísticas de uso
- Métricas de ahorro mensual

---

## 🏗️ Arquitectura de la Aplicación

### **Patrón de Arquitectura: Clean Architecture + BLoC**

```
lib/
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── promotions/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── map/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── profile/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── commerce/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart
```

### **Capas de la Arquitectura**

1. **Presentation Layer (UI + BLoC)**
   - Widgets y pantallas
   - BLoC para gestión de estado
   - Manejo de eventos y estados

2. **Domain Layer (Business Logic)**
   - Entidades
   - Casos de uso
   - Interfaces de repositorios

3. **Data Layer**
   - Implementación de repositorios
   - Modelos de datos
   - Data sources (remote/local)

---

## 🛠️ Stack Tecnológico

### **Framework y Lenguaje**
- **Flutter 3.x** (Dart 3.x)
- Soporte para Android 6.0+ (API 23+)
- Soporte para iOS 12.0+

### **Gestión de Estado**
- **flutter_bloc** (^8.1.0) - Patrón BLoC
- **equatable** (^2.0.5) - Comparación de objetos

### **Backend y Base de Datos**
- **Firebase Suite:**
  - Firebase Auth (autenticación)
  - Cloud Firestore (base de datos NoSQL)
  - Firebase Storage (almacenamiento de imágenes)
  - Firebase Cloud Messaging (notificaciones push)
  - Firebase Analytics (analítica)
  - Firebase Crashlytics (monitoreo de errores)

### **Mapas y Geolocalización**
- **google_maps_flutter** (^2.5.0) - Mapas
- **geolocator** (^10.1.0) - Geolocalización
- **geocoding** (^2.1.1) - Geocodificación
- **flutter_polyline_points** (^2.0.0) - Rutas optimizadas

### **Imágenes y Multimedia**
- **image_picker** (^1.0.4) - Captura de fotos
- **cached_network_image** (^3.3.0) - Cache de imágenes
- **image_cropper** (^5.0.0) - Recorte de imágenes
- **google_ml_kit** (^0.16.0) - OCR (opcional)

### **Networking**
- **dio** (^5.3.3) - Cliente HTTP
- **retrofit** (^4.0.3) - API REST
- **connectivity_plus** (^5.0.1) - Estado de conexión

### **Almacenamiento Local**
- **shared_preferences** (^2.2.2) - Preferencias
- **hive** (^2.2.3) - Base de datos local
- **flutter_secure_storage** (^9.0.0) - Almacenamiento seguro

### **UI/UX**
- **flutter_svg** (^2.0.9) - Iconos SVG
- **shimmer** (^3.0.0) - Efectos de carga
- **flutter_rating_bar** (^4.0.1) - Calificaciones
- **badges** (^3.1.2) - Insignias
- **animations** (^2.0.8) - Animaciones

### **Notificaciones**
- **flutter_local_notifications** (^16.1.0) - Notificaciones locales
- **firebase_messaging** (^14.7.0) - Push notifications

### **Utilidades**
- **intl** (^0.18.1) - Internacionalización
- **url_launcher** (^6.2.1) - Abrir URLs
- **share_plus** (^7.2.1) - Compartir contenido
- **permission_handler** (^11.0.1) - Permisos

### **Testing**
- **mockito** (^5.4.3) - Mocks
- **bloc_test** (^9.1.5) - Testing de BLoCs
- **integration_test** - Tests de integración

---

## 📱 Pantallas Principales

### **1. Onboarding y Autenticación**
- Splash Screen
- Onboarding (3-4 slides)
- Login/Registro
- Recuperación de contraseña

### **2. Home y Navegación**
- Home con mapa de promociones
- Lista de promociones cercanas
- Búsqueda y filtros
- Bottom Navigation Bar (Home, Mapa, Agregar, Favoritos, Perfil)

### **3. Mapa y Geolocalización**
- Mapa interactivo con markers
- Detalle de comercio al tocar marker
- Ruta de Ahorro Inteligente
- Filtros en mapa

### **4. Promociones**
- Detalle de promoción
- Galería de fotos
- Validación comunitaria
- Compartir promoción
- Reportar promoción

### **5. Agregar Promoción**
- Captura de foto
- Selección de comercio
- Formulario de promoción
- Categorización
- Fecha de vencimiento

### **6. Perfil de Usuario**
- Información personal
- Estadísticas de ahorro
- Historial de promociones
- Insignias y logros
- Configuración

### **7. Comercios**
- Listado de comercios
- Detalle de comercio
- Promociones del comercio
- Cómo llegar

### **8. Panel de Comercio (B2B)**
- Dashboard de comercio
- Publicar promoción
- Estadísticas
- Gestión de promociones

---

## 🗄️ Modelo de Datos

### **User**
```dart
{
  id: String,
  email: String,
  name: String,
  photoUrl: String?,
  phone: String?,
  location: GeoPoint,
  reputation: int,
  badges: List<String>,
  savedPromotions: List<String>,
  totalSavings: double,
  createdAt: Timestamp,
  isCommerce: bool
}
```

### **Promotion**
```dart
{
  id: String,
  title: String,
  description: String,
  commerceId: String,
  commerceName: String,
  category: String,
  discount: String,
  originalPrice: double?,
  discountedPrice: double?,
  images: List<String>,
  location: GeoPoint,
  address: String,
  validUntil: Timestamp,
  createdBy: String,
  validations: {
    positive: int,
    negative: int,
    users: List<String>
  },
  views: int,
  saves: int,
  isActive: bool,
  isPremium: bool,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

### **Commerce**
```dart
{
  id: String,
  name: String,
  type: String, // supermercado, pulpería, comercio chino, etc.
  location: GeoPoint,
  address: String,
  phone: String?,
  email: String?,
  logo: String?,
  photos: List<String>,
  rating: double,
  totalPromotions: int,
  isPremium: bool,
  ownerId: String?,
  createdAt: Timestamp
}
```

### **Validation**
```dart
{
  id: String,
  promotionId: String,
  userId: String,
  isValid: bool,
  comment: String?,
  createdAt: Timestamp
}
```

---

## 🔐 Seguridad y Privacidad

### **Autenticación**
- Firebase Authentication
- Tokens JWT para API
- Refresh tokens
- Biometría (opcional)

### **Permisos**
- Ubicación (siempre/en uso)
- Cámara
- Almacenamiento
- Notificaciones

### **Protección de Datos**
- Encriptación de datos sensibles
- HTTPS para todas las comunicaciones
- Cumplimiento con GDPR y leyes locales
- Política de privacidad clara

### **Reglas de Firestore**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Promotions
    match /promotions/{promotionId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.createdBy;
      allow delete: if request.auth.uid == resource.data.createdBy;
    }
    
    // Commerces
    match /commerces/{commerceId} {
      allow read: if true;
      allow write: if request.auth != null && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isCommerce == true;
    }
  }
}
```

---

## 📊 Analítica y Métricas

### **Eventos a Trackear**
- Registro de usuario
- Login
- Visualización de promoción
- Guardado de promoción
- Validación de promoción
- Publicación de promoción
- Búsqueda realizada
- Filtros aplicados
- Ruta generada
- Compartir promoción

### **KPIs Principales**
- DAU/MAU (usuarios activos)
- Tasa de retención
- Promociones publicadas/día
- Validaciones por promoción
- Ahorro promedio por usuario
- Tiempo en app
- Tasa de conversión (invitado → registrado)

---

## 🚀 Fases de Desarrollo

### **FASE 1: MVP (8-10 semanas)**

#### Semana 1-2: Setup y Fundamentos
- [ ] Configuración del proyecto Flutter
- [ ] Configuración de Firebase
- [ ] Estructura de carpetas (Clean Architecture)
- [ ] Setup de dependencias
- [ ] Configuración de CI/CD básico
- [ ] Diseño de UI/UX (Figma)

#### Semana 3-4: Autenticación y Perfil
- [ ] Implementar Firebase Auth
- [ ] Pantallas de login/registro
- [ ] Perfil de usuario básico
- [ ] Gestión de sesión
- [ ] Onboarding screens

#### Semana 5-6: Promociones Core
- [ ] Modelo de datos de promociones
- [ ] Listado de promociones
- [ ] Detalle de promoción
- [ ] Búsqueda básica
- [ ] Filtros simples

#### Semana 7-8: Geolocalización y Mapa
- [ ] Integración de Google Maps
- [ ] Geolocalización del usuario
- [ ] Markers de comercios
- [ ] Filtrado por distancia
- [ ] Detalle de comercio

#### Semana 9-10: Publicación y Validación
- [ ] Captura de fotos
- [ ] Formulario de promoción
- [ ] Publicación en Firestore
- [ ] Sistema de validación (like/dislike)
- [ ] Reportar promociones

**Entregables Fase 1:**
- App funcional con features core
- Usuarios pueden ver y publicar promociones
- Geolocalización básica
- Sistema de validación comunitaria

---

### **FASE 2: Funcionalidades Avanzadas (6-8 semanas)**

#### Semana 11-12: Ruta Inteligente
- [ ] Algoritmo de optimización de ruta
- [ ] Integración con Google Directions API
- [ ] Visualización de ruta en mapa
- [ ] Estimación de tiempo y distancia
- [ ] Guardar rutas favoritas

#### Semana 13-14: Notificaciones
- [ ] Firebase Cloud Messaging
- [ ] Notificaciones push
- [ ] Notificaciones locales
- [ ] Preferencias de notificaciones
- [ ] Notificaciones geolocalizadas

#### Semana 15-16: Gamificación
- [ ] Sistema de puntos
- [ ] Insignias y logros
- [ ] Rankings de usuarios
- [ ] Programa de embajadores
- [ ] Recompensas

#### Semana 17-18: Panel de Comercios
- [ ] Registro de comercios
- [ ] Dashboard de comercio
- [ ] Publicación de promociones propias
- [ ] Estadísticas básicas
- [ ] Modelo freemium

**Entregables Fase 2:**
- Ruta de Ahorro Inteligente
- Sistema de notificaciones completo
- Gamificación implementada
- Panel B2B funcional

---

### **FASE 3: Optimización y Lanzamiento (4-6 semanas)**

#### Semana 19-20: Analítica y Métricas
- [ ] Firebase Analytics
- [ ] Dashboard de ahorro personal
- [ ] Métricas de uso
- [ ] Reportes de ahorro
- [ ] A/B testing setup

#### Semana 21-22: Optimización
- [ ] Optimización de rendimiento
- [ ] Reducción de tamaño de app
- [ ] Mejora de UX basada en feedback
- [ ] Corrección de bugs
- [ ] Testing exhaustivo

#### Semana 23-24: Preparación para Lanzamiento
- [ ] Testing en dispositivos reales
- [ ] Preparación de assets (iconos, screenshots)
- [ ] Descripción de stores
- [ ] Política de privacidad
- [ ] Términos y condiciones
- [ ] Video promocional
- [ ] Documentación

**Entregables Fase 3:**
- App optimizada y pulida
- Documentación completa
- Assets para stores
- App lista para publicación

---

### **FASE 4: Post-Lanzamiento (Continuo)**

#### Mes 1-2 Post-Lanzamiento
- [ ] Monitoreo de crashes
- [ ] Análisis de métricas
- [ ] Recolección de feedback
- [ ] Hotfixes críticos
- [ ] Iteraciones rápidas

#### Mes 3-6 Post-Lanzamiento
- [ ] Nuevas funcionalidades basadas en feedback
- [ ] Expansión de categorías
- [ ] Mejoras de UI/UX
- [ ] Optimización de algoritmos
- [ ] Marketing y crecimiento

---

## 🧪 Estrategia de Testing

### **Unit Tests**
- Casos de uso
- Repositorios
- Modelos de datos
- Utilidades

### **Widget Tests**
- Widgets individuales
- Pantallas completas
- Interacciones de UI

### **Integration Tests**
- Flujos completos de usuario
- Integración con Firebase
- Geolocalización
- Notificaciones

### **Cobertura Objetivo**
- Unit tests: >80%
- Widget tests: >60%
- Integration tests: Flujos críticos

---

## 📦 Estrategia de Despliegue

### **Ambientes**
1. **Development**
   - Firebase proyecto dev
   - Testing continuo
   - Builds diarios

2. **Staging**
   - Firebase proyecto staging
   - Testing de QA
   - Builds semanales

3. **Production**
   - Firebase proyecto prod
   - Releases controlados
   - Builds por versión

### **CI/CD**
- **GitHub Actions** o **Codemagic**
- Build automático en cada PR
- Tests automáticos
- Deploy a Firebase App Distribution
- Deploy a TestFlight (iOS) y Play Console (Android)

### **Versionamiento**
- Semantic Versioning (MAJOR.MINOR.PATCH)
- Changelog detallado
- Release notes

---

## 💰 Estimación de Costos

### **Desarrollo**
- **Equipo Mínimo:**
  - 1 Flutter Developer Senior (Lead)
  - 1 Flutter Developer Mid
  - 1 UI/UX Designer
  - 1 Backend Developer (Firebase)
  - 1 QA Tester

- **Duración:** 18-24 semanas
- **Costo Estimado:** $40,000 - $60,000 USD

### **Infraestructura (Mensual)**
- Firebase Blaze Plan: $50-200/mes
- Google Maps API: $100-300/mes
- Hosting web: $10-20/mes
- **Total:** $160-520/mes

### **Servicios Adicionales**
- Apple Developer Program: $99/año
- Google Play Console: $25 (único)
- Dominio: $15/año
- SSL Certificate: Gratis (Let's Encrypt)

---

## 🎨 Guía de Diseño

### **Paleta de Colores**
```dart
// Colores principales
Primary: #2E7D32 (Verde - ahorro, sostenibilidad)
Secondary: #FF6F00 (Naranja - promociones, urgencia)
Accent: #0277BD (Azul - confianza)

// Colores de soporte
Success: #4CAF50
Warning: #FFC107
Error: #F44336
Info: #2196F3

// Neutrales
Background: #FAFAFA
Surface: #FFFFFF
Text Primary: #212121
Text Secondary: #757575
```

### **Tipografía**
- **Primary Font:** Roboto
- **Headings:** Roboto Bold
- **Body:** Roboto Regular
- **Captions:** Roboto Light

### **Componentes Clave**
- Cards con sombras suaves
- Botones con bordes redondeados
- Iconos Material Design
- Animaciones fluidas
- Bottom sheets para acciones

---

## 📈 Roadmap de Funcionalidades Futuras

### **Corto Plazo (3-6 meses)**
- [ ] OCR para lectura automática de precios
- [ ] Comparador de precios por producto
- [ ] Lista de compras inteligente
- [ ] Integración con WhatsApp Business
- [ ] Modo oscuro

### **Mediano Plazo (6-12 meses)**
- [ ] Programa de referidos
- [ ] Cashback y recompensas
- [ ] Integración con bancos (tarjetas)
- [ ] Predicción de precios con ML
- [ ] Asistente virtual (chatbot)

### **Largo Plazo (12+ meses)**
- [ ] Expansión a otros países
- [ ] Marketplace de productos
- [ ] Delivery integrado
- [ ] Wallet digital
- [ ] Programa de fidelización multi-comercio

---

## 🚨 Riesgos y Mitigación

### **Riesgos Técnicos**

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Problemas de rendimiento con muchos markers | Media | Alto | Clustering de markers, lazy loading |
| Consumo excesivo de batería | Alta | Medio | Optimizar geolocalización, usar geofencing |
| Problemas con OCR | Media | Bajo | Hacer OCR opcional, permitir entrada manual |
| Escalabilidad de Firebase | Baja | Alto | Monitoreo constante, plan de migración |

### **Riesgos de Negocio**

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Baja adopción de usuarios | Media | Alto | Marketing agresivo, programa de referidos |
| Información desactualizada | Alta | Alto | Sistema de caducidad automática, incentivos |
| Resistencia de comercios | Media | Medio | Onboarding simplificado, casos de éxito |
| Competencia de grandes players | Alta | Alto | Enfoque en nicho local, diferenciación |

---

## 📚 Documentación Requerida

### **Técnica**
- [ ] README.md completo
- [ ] Guía de contribución
- [ ] Documentación de API
- [ ] Guía de arquitectura
- [ ] Guía de estilo de código

### **Usuario**
- [ ] Manual de usuario
- [ ] FAQs
- [ ] Tutoriales en video
- [ ] Guía de comercios

### **Legal**
- [ ] Términos y condiciones
- [ ] Política de privacidad
- [ ] Política de cookies
- [ ] Acuerdo de comercios

---

## 🎯 Métricas de Éxito

### **Técnicas**
- Tiempo de carga < 3 segundos
- Crash rate < 1%
- App size < 50MB
- Tiempo de respuesta API < 500ms

### **Negocio**
- 10,000 descargas en primer mes
- 30% de retención a 30 días
- 100 promociones activas/día
- 5,000 validaciones/semana
- 50 comercios registrados en 3 meses

---

## 🔄 Proceso de Desarrollo

### **Metodología: Scrum**
- Sprints de 2 semanas
- Daily standups
- Sprint planning
- Sprint review
- Sprint retrospective

### **Herramientas**
- **Gestión:** Jira o Linear
- **Diseño:** Figma
- **Código:** GitHub
- **CI/CD:** GitHub Actions
- **Comunicación:** Slack
- **Documentación:** Notion

---

## 📞 Equipo y Roles

### **Equipo Core**
1. **Product Owner**
   - Define prioridades
   - Gestiona backlog
   - Valida entregables

2. **Scrum Master**
   - Facilita ceremonias
   - Remueve impedimentos
   - Mejora procesos

3. **Tech Lead (Flutter)**
   - Arquitectura técnica
   - Code reviews
   - Mentoring

4. **Flutter Developers (2)**
   - Desarrollo de features
   - Testing
   - Documentación

5. **UI/UX Designer**
   - Diseño de interfaces
   - Prototipos
   - User research

6. **Backend Developer**
   - Firebase setup
   - Cloud Functions
   - APIs

7. **QA Engineer**
   - Testing manual
   - Testing automatizado
   - Reportes de bugs

---

## 🎓 Capacitación del Equipo

### **Tecnologías Clave**
- Flutter & Dart avanzado
- Clean Architecture
- BLoC pattern
- Firebase suite
- Google Maps API
- Testing en Flutter

### **Recursos**
- Documentación oficial
- Cursos en Udemy/Pluralsight
- Flutter Community
- Code reviews internos

---

## 📝 Conclusiones

Este plan de desarrollo proporciona una hoja de ruta completa para la implementación de OptiGasto en Flutter. La aplicación está diseñada para:

1. **Resolver el problema real** del consumidor costarricense
2. **Escalar eficientemente** con arquitectura limpia
3. **Mantener calidad** con testing exhaustivo
4. **Generar valor** tanto para usuarios como comercios
5. **Adaptarse** a cambios del mercado

### **Próximos Pasos Inmediatos**

1. ✅ Aprobar plan de desarrollo
2. ⏳ Conformar equipo de desarrollo
3. ⏳ Setup de infraestructura (Firebase, GitHub)
4. ⏳ Diseño UI/UX en Figma
5. ⏳ Inicio de Sprint 1

---

## 📄 Anexos

### **A. Estructura de Carpetas Detallada**
```
optigasto/
├── android/
├── ios/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   ├── api_constants.dart
│   │   │   └── route_constants.dart
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── network/
│   │   │   ├── network_info.dart
│   │   │   └── dio_client.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   ├── app_colors.dart
│   │   │   └── app_text_styles.dart
│   │   └── utils/
│   │       ├── validators.dart
│   │       ├── formatters.dart
│   │       └── helpers.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   ├── models/
│   │   │   │   └── repositories/
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   ├── repositories/
│   │   │   │   └── usecases/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       ├── pages/
│   │   │       └── widgets/
│   │   ├── promotions/
│   │   ├── map/
│   │   ├── profile/
│   │   └── commerce/
│   ├── injection_container.dart
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md
```

### **B. Comandos Útiles**
```bash
# Crear proyecto
flutter create optigasto

# Instalar dependencias
flutter pub get

# Generar código (freezed, json_serializable)
flutter pub run build_runner build --delete-conflicting-outputs

# Ejecutar tests
flutter test

# Ejecutar app
flutter run

# Build para producción
flutter build apk --release
flutter build ios --release

# Analizar código
flutter analyze

# Formatear código
dart format .
```

### **C. Configuración de Firebase**
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase
flutterfire configure

# Esto generará:
# - firebase_options.dart
# - Configuración para Android e iOS
```

---

**Documento creado:** 31 de marzo de 2026  
**Versión:** 1.0  
**Autor:** Equipo OptiGasto  
**Estado:** Aprobación pendiente
