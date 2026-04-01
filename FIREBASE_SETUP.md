# Configuración de Firebase para OptiGasto

## ⚠️ IMPORTANTE: Archivos Sensibles

Los siguientes archivos contienen claves API y configuraciones sensibles de Firebase. **NUNCA** deben ser compartidos públicamente o subidos a repositorios públicos:

### Archivos Protegidos (ya incluidos en .gitignore)

1. **`android/app/google-services.json`** - Configuración de Firebase para Android
2. **`ios/Runner/GoogleService-Info.plist`** - Configuración de Firebase para iOS
3. **`lib/firebase_options.dart`** - Opciones de Firebase generadas por FlutterFire CLI

## 🔧 Configuración Inicial para Nuevos Desarrolladores

Si eres un nuevo desarrollador trabajando en este proyecto, necesitarás configurar Firebase localmente:

### Paso 1: Instalar Firebase CLI

```bash
npm install -g firebase-tools
```

### Paso 2: Iniciar Sesión en Firebase

```bash
firebase login
```

### Paso 3: Instalar FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Paso 4: Configurar Firebase para el Proyecto

```bash
flutterfire configure
```

Este comando:
- Te pedirá seleccionar el proyecto de Firebase (OptiGasto)
- Generará automáticamente los archivos de configuración necesarios
- Creará `lib/firebase_options.dart`
- Actualizará `google-services.json` y `GoogleService-Info.plist`

## 🔐 Seguridad

### Reglas de Firestore

Las reglas de seguridad de Firestore están configuradas para:
- Permitir lectura pública de promociones
- Requerir autenticación para escritura
- Validar estructura de datos

### Reglas de Storage

Las reglas de Firebase Storage están configuradas para:
- Requerir autenticación para subir imágenes
- Limitar tamaño de archivos a 5MB
- Validar tipos de archivo (solo imágenes)

## 📝 Variables de Entorno

Para mayor seguridad en producción, considera usar variables de entorno:

1. Crea un archivo `.env` (ya incluido en .gitignore)
2. Define tus claves:
   ```
   FIREBASE_API_KEY=tu_api_key
   FIREBASE_PROJECT_ID=tu_project_id
   ```
3. Usa el paquete `flutter_dotenv` para cargarlas

## 🚀 Despliegue

### Android
- El archivo `google-services.json` debe estar presente antes de compilar
- Asegúrate de tener las credenciales correctas para el entorno (dev/prod)

### iOS
- El archivo `GoogleService-Info.plist` debe estar en `ios/Runner/`
- Verifica que el Bundle ID coincida con el configurado en Firebase

### Web
- Las configuraciones están en `lib/firebase_options.dart`
- Considera usar diferentes proyectos de Firebase para dev/prod

## 📚 Recursos

- [Documentación de Firebase](https://firebase.google.com/docs)
- [FlutterFire](https://firebase.flutter.dev/)
- [Reglas de Seguridad](https://firebase.google.com/docs/rules)

## ⚡ Comandos Útiles

```bash
# Ver configuración actual
flutterfire configure

# Actualizar dependencias de Firebase
flutter pub upgrade

# Verificar reglas de seguridad
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

## 🆘 Solución de Problemas

### Error: "Firebase not initialized"
- Verifica que `firebase_options.dart` existe
- Asegúrate de que `Firebase.initializeApp()` se llama en `main()`

### Error: "google-services.json not found"
- Ejecuta `flutterfire configure` nuevamente
- Verifica que el archivo está en `android/app/`

### Error: "GoogleService-Info.plist not found"
- Ejecuta `flutterfire configure` nuevamente
- Verifica que el archivo está en `ios/Runner/`

---

**Nota**: Si necesitas los archivos de configuración originales, contacta al administrador del proyecto.