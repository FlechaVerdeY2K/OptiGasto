# OptiGasto 🛒💰

Aplicación móvil para encontrar ofertas y promociones geolocalizadas en Costa Rica.

## 📱 Descripción

OptiGasto es una plataforma colaborativa que permite a los consumidores costarricenses encontrar ofertas, promociones y descuentos disponibles en comercios cercanos. La aplicación utiliza geolocalización para mostrar las mejores oportunidades de ahorro en tiempo real.

## ✨ Características Principales

- 🗺️ **Mapa interactivo** con promociones geolocalizadas
- 📸 **Sistema colaborativo** para publicar y validar ofertas
- 🎯 **Ruta de Ahorro Inteligente** para optimizar compras
- 🔔 **Notificaciones** de promociones cercanas
- 🏆 **Gamificación** con insignias y recompensas
- 💼 **Panel B2B** para comercios
- 📊 **Estadísticas** de ahorro personal

## 🛠️ Tecnologías

- **Framework:** Flutter 3.x
- **Lenguaje:** Dart 3.x
- **Arquitectura:** Clean Architecture + BLoC
- **Backend:** Firebase Suite
- **Mapas:** Google Maps
- **Estado:** flutter_bloc

## 📋 Requisitos Previos

- Flutter SDK 3.5.0 o superior
- Dart SDK 3.5.0 o superior
- Android Studio / Xcode
- Cuenta de Firebase
- Google Maps API Key

## 🚀 Instalación

1. Clonar el repositorio:
```bash
git clone https://github.com/tu-usuario/optigasto.git
cd optigasto
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Configurar Firebase (⚠️ IMPORTANTE):
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase
flutterfire configure
```

**Nota:** Los archivos de configuración de Firebase (`google-services.json`, `GoogleService-Info.plist`, `firebase_options.dart`) están en `.gitignore` por seguridad. Ver [FIREBASE_SETUP.md](FIREBASE_SETUP.md) para más detalles.

4. Configurar Google Maps API Key:
   - Editar `lib/core/constants/api_constants.dart`
   - Reemplazar `YOUR_GOOGLE_MAPS_API_KEY` con tu API key

5. Ejecutar la aplicación:
```bash
flutter run
```

## 🔐 Seguridad y Configuración

### Archivos Sensibles (NO subir a GitHub)

Los siguientes archivos contienen información sensible y están protegidos en `.gitignore`:

- `android/app/google-services.json` - Configuración Firebase Android
- `ios/Runner/GoogleService-Info.plist` - Configuración Firebase iOS
- `lib/firebase_options.dart` - Opciones Firebase generadas
- `.env` - Variables de entorno

**Para configurar estos archivos en tu entorno local, consulta [FIREBASE_SETUP.md](FIREBASE_SETUP.md)**

### Antes de Subir a GitHub

1. Verifica que los archivos sensibles están en `.gitignore`
2. Nunca hagas commit de claves API o credenciales
3. Usa variables de entorno para información sensible
4. Revisa el historial de commits antes de push

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/      # Constantes de la app
│   ├── errors/         # Manejo de errores
│   ├── network/        # Configuración de red
│   ├── theme/          # Tema y estilos
│   └── utils/          # Utilidades
├── features/
│   ├── auth/           # Autenticación
│   ├── promotions/     # Promociones
│   ├── map/            # Mapa y geolocalización
│   ├── profile/        # Perfil de usuario
│   └── commerce/       # Panel de comercios
└── main.dart
```

## 🏗️ Arquitectura

El proyecto sigue **Clean Architecture** con tres capas:

1. **Presentation Layer:** UI + BLoC
2. **Domain Layer:** Entidades y casos de uso
3. **Data Layer:** Repositorios y fuentes de datos

## 🎨 Diseño

### Paleta de Colores

- **Primary:** #2E7D32 (Verde - ahorro)
- **Secondary:** #FF6F00 (Naranja - promociones)
- **Accent:** #0277BD (Azul - confianza)

### Tipografía

- **Font Family:** Roboto
- **Headings:** Roboto Bold
- **Body:** Roboto Regular

## 🧪 Testing

Ejecutar tests:
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test
```

## 📦 Build

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📝 Convenciones de Código

- Seguir [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Usar `flutter analyze` antes de commit
- Mantener cobertura de tests >80%
- Documentar funciones públicas

## 🗺️ Roadmap

### Fase 1: MVP (Actual)
- [x] Setup del proyecto
- [x] Estructura Clean Architecture
- [x] Tema y constantes
- [ ] Autenticación
- [ ] Listado de promociones
- [ ] Mapa básico

### Fase 2: Funcionalidades Avanzadas
- [ ] Ruta de Ahorro Inteligente
- [ ] Notificaciones push
- [ ] Gamificación
- [ ] Panel de comercios

### Fase 3: Optimización
- [ ] Analítica
- [ ] Optimización de rendimiento
- [ ] Testing exhaustivo

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Equipo

- **Product Owner:** Edgar Herrera
- **Tech Lead:** Edgar Herrera
- **Developers:** Edgar Herrera
- **UI/UX Designer:** [Nombre]

## 📞 Contacto

- **Email:** contacto@optigasto.com
- **Website:** https://optigasto.com
- **Twitter:** @optigasto

## 🙏 Agradecimientos

- Universidad Hispanoamericana de Costa Rica
- Comunidad Flutter Costa Rica
- Todos los contribuidores

---

Hecho con ❤️ en Costa Rica 🇨🇷
