# Prompt para Claude Code / GPT Codex — Web Compatibility + Vercel Deploy

**Versión:** 1.0
**Branch:** `chore/web-vercel-deploy`
**Prioridad máxima:** No romper mobile. Web es aditivo.

---

## Contexto

**OptiGasto** es una app Flutter (fases 1-8 completas) que corre en Android e iOS.
El build web ya compila (`flutter build web` no da errores), pero hay incompatibilidades
runtime que hay que parchear antes de hacer el deploy a Vercel.

**Regla absoluta:** Todo cambio para web DEBE estar envuelto en `kIsWeb` o
`defaultTargetPlatform` checks. **Nunca** eliminar código que mobile necesita.
Si mobile hacía X antes, mobile sigue haciendo X después. Web puede hacer Y distinto
o simplemente no hacer nada.

---

## Setup

```bash
git checkout main
git pull origin main
git checkout -b chore/web-vercel-deploy
```

---

## PASO 0 — Diagnóstico (leer antes de tocar nada)

Lee estos archivos y reportá el estado actual:

1. `web/index.html` — ¿tiene script de Google Maps?
2. `lib/main.dart` — ¿dónde se inicializa Firebase, FCM, notificaciones?
3. `lib/features/notifications/` — ¿hay una clase wrapper para notificaciones?
4. `pubspec.yaml` — confirmar presencia de `flutter_local_notifications`, `firebase_messaging`, `share_plus`, `path_provider`
5. `web/firebase-messaging-sw.js` — ¿existe?

Después de leer, reportá:
- ¿`flutter_local_notifications` ya tiene guards `kIsWeb`? (sí/no)
- ¿`firebase_messaging` tiene Service Worker en `web/`? (sí/no)
- ¿`web/index.html` ya tiene script de Google Maps? (sí/no)
- ¿Hay imports de `dart:io` directos en features? (lista de archivos)

**No hagas ningún cambio hasta reportar este diagnóstico.**

## ⏸️ PAUSA #0 — Esperá confirmación del usuario antes de continuar.

---

## TAREA 1 — Notificaciones Locales para Web

**Problema:** `flutter_local_notifications` no tiene implementación web.
Llamarlo en web lanza `MissingPluginException`.

### 1a. Encontrar todos los usos

```bash
grep -r "FlutterLocalNotificationsPlugin\|flutterLocalNotificationsPlugin\|flutter_local_notifications" \
  lib/ --include="*.dart" -l
```

### 1b. Parchear con kIsWeb

Para **cada archivo encontrado**, envolvé las llamadas:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

// Inicialización:
if (!kIsWeb) {
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// Mostrar notificación:
if (!kIsWeb) {
  await flutterLocalNotificationsPlugin.show(id, title, body, details);
}

// Cancelar:
if (!kIsWeb) {
  await flutterLocalNotificationsPlugin.cancel(id);
}

// Scheduled:
if (!kIsWeb) {
  await flutterLocalNotificationsPlugin.zonedSchedule(...);
}
```

### 1c. Si hay una clase wrapper (NotificationService o similar)

Patrón más limpio — agregar guards a nivel de método:

```dart
Future<void> initialize() async {
  if (kIsWeb) return; // Web no soporta notificaciones locales
  // ... código existente sin cambios
}

Future<void> showNotification({required String title, required String body}) async {
  if (kIsWeb) return;
  // ... código existente sin cambios
}
```

### 1d. Verificar que mobile no regresionó

```bash
flutter analyze --fatal-infos
```

No deben aparecer warnings nuevos en archivos de notificaciones.

**Commit:** `fix(web): guard flutter_local_notifications behind kIsWeb checks`

## ⏸️ PAUSA #1 — Esperá confirmación del usuario antes de continuar.

---

## TAREA 2 — Firebase Messaging en Web

**Problema:** FCM en web necesita un Service Worker. Sin él, puede lanzar errores
al inicializarse.

### 2a. Verificar Service Worker

```bash
ls web/firebase-messaging-sw.js
```

**Si existe:** verificá que tenga la configuración de Firebase. Si está correcto, ir a 2c.

**Si NO existe:** crear `web/firebase-messaging-sw.js`:

```javascript
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

// Estos son valores PÚBLICOS del Web App config en Firebase Console.
// NO son las credenciales de Service Account.
// Edgar debe reemplazarlos con los valores reales de:
// Firebase Console > Project Settings > Your Apps > Web App
firebase.initializeApp({
  apiKey: "REPLACE_WITH_FIREBASE_WEB_API_KEY",
  authDomain: "REPLACE_WITH_AUTH_DOMAIN",
  projectId: "REPLACE_WITH_PROJECT_ID",
  storageBucket: "REPLACE_WITH_STORAGE_BUCKET",
  messagingSenderId: "REPLACE_WITH_SENDER_ID",
  appId: "REPLACE_WITH_APP_ID"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notificationTitle = payload.notification?.title ?? 'OptiGasto';
  const notificationOptions = {
    body: payload.notification?.body ?? '',
    icon: '/icons/Icon-192.png'
  };
  self.registration.showNotification(notificationTitle, notificationOptions);
});
```

### 2b. Guard en inicialización de FCM

Encontrá donde se llama `FirebaseMessaging.instance.requestPermission()` o
donde se obtiene el token, y envolvé:

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

// Request permission:
NotificationSettings settings;
if (!kIsWeb) {
  settings = await FirebaseMessaging.instance.requestPermission(
    alert: true, badge: true, sound: true,
  );
} else {
  // En web el permiso lo pide el browser automáticamente al suscribirse
  // Para la demo, simplemente no pedirlo activamente
  settings = await FirebaseMessaging.instance.requestPermission();
}

// Obtener token:
if (!kIsWeb) {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    // guardar token en Supabase (código existente)
  }
}
// En web no guardamos token — las push notifications son feature mobile
```

### 2c. onMessage en foreground

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  if (kIsWeb) {
    // Web no tiene flutter_local_notifications
    // Para la demo: loggear o mostrar un SnackBar si hay contexto disponible
    debugPrint('[Web] Notification: ${message.notification?.title}');
    return;
  }
  // Código existente de mobile sin cambios
  _showLocalNotification(message);
});
```

**Commit:** `fix(web): handle FCM initialization and messaging for web platform`

## ⏸️ PAUSA #2 — Esperá confirmación del usuario antes de continuar.

---

## TAREA 3 — Google Maps en web/index.html

**Problema:** `google_maps_flutter` en web necesita el script de Maps JS API
cargado en `index.html` antes del script de Flutter.

### 3a. Modificar `web/index.html`

Abrí `web/index.html`. En el `<head>`, **antes del script de Flutter**,
agregá esta línea con el placeholder:

```html
<head>
  <!-- Contenido existente... -->

  <!-- Google Maps JS API (requerido para google_maps_flutter web) -->
  <!-- La key real se inyecta en el build de Vercel via sed -->
  <script src="https://maps.googleapis.com/maps/api/js?key=GOOGLE_MAPS_PLACEHOLDER&libraries=geometry"></script>

  <!-- El script de Flutter debe ir DESPUÉS de Google Maps -->
</head>
```

El placeholder `GOOGLE_MAPS_PLACEHOLDER` será reemplazado por el build
command de Vercel con `sed` (lo configuramos en la Tarea 5).

### 3b. Verificar google_maps_flutter_web

```bash
flutter pub deps | grep google_maps_flutter_web
```

Si no aparece, agregar en `pubspec.yaml` bajo `dependencies`:
```yaml
google_maps_flutter_web: ^0.5.9
```

Correr `flutter pub get` después.

**Commit:** `fix(web): add Google Maps JS API script placeholder to index.html`

## ⏸️ PAUSA #3 — Esperá confirmación del usuario antes de continuar.

---

## TAREA 4 — Guards de Compatibilidad Generales

### 4a. Buscar usos de dart:io y Platform

```bash
grep -r "import 'dart:io'" lib/ --include="*.dart" -l
grep -r "Platform\.\(isAndroid\|isIOS\|isMacOS\)" lib/ --include="*.dart" -l
```

Para cada archivo encontrado, reemplazar `Platform.isAndroid` / `Platform.isIOS`
con alternativas web-safe:

```dart
// ANTES (no funciona en web):
import 'dart:io';
if (Platform.isAndroid) { ... }

// DESPUÉS (funciona en web):
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

final bool isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
final bool isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

if (isAndroid) { ... }
```

Si `dart:io` se usa para `File` o `Directory` (operaciones de archivo):
```dart
if (!kIsWeb) {
  final file = File(path);
  // operaciones de archivo...
}
```

### 4b. image_picker — lectura de archivos

Si hay código que hace `File(image.path)` después de `ImagePicker().pickImage()`:

```dart
final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
if (image == null) return;

if (kIsWeb) {
  // En web: leer como bytes y subir directo a Supabase Storage
  final bytes = await image.readAsBytes();
  await supabase.storage.from('bucket').uploadBinary(path, bytes);
} else {
  // En mobile: código existente sin cambios
  final file = File(image.path);
  await supabase.storage.from('bucket').upload(path, file);
}
```

### 4c. share_plus — manejo de error en web

`Web Share API` no está disponible en Safari y puede fallar en otros browsers:

```dart
try {
  await Share.shareXFiles(files, text: text);
} catch (e) {
  if (kIsWeb) {
    // Fallback: copiar al portapapeles
    await Clipboard.setData(ClipboardData(text: shareUrl));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copiado al portapapeles')),
      );
    }
  } else {
    rethrow; // En mobile, propagar el error
  }
}
```

### 4d. path_provider en web (export PDF/CSV)

Si Fase 11 usa `getApplicationDocumentsDirectory()` para guardar archivos:

```dart
if (kIsWeb) {
  // En web no hay filesystem local — usar share_plus con bytes en memoria
  // o simplemente deshabilitar la opción de descarga en web
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Descarga disponible en la app móvil')),
  );
  return;
}
// Código existente de mobile sin cambios
final dir = await getApplicationDocumentsDirectory();
```

**Commit:** `fix(web): add platform guards for dart:io, image_picker and share_plus`

## ⏸️ PAUSA #4 — Esperá confirmación del usuario antes de continuar.

---

## TAREA 5 — Crear vercel.json

Crear en la **raíz del proyecto** el archivo `vercel.json`:

```json
{
  "buildCommand": "if cd flutter; then git pull && cd ..; else git clone --depth 1 https://github.com/flutter/flutter.git; fi && flutter/bin/flutter config --enable-web && flutter/bin/flutter pub get && flutter/bin/flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY --dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY && sed -i 's/GOOGLE_MAPS_PLACEHOLDER/$GOOGLE_MAPS_API_KEY/g' build/web/index.html",
  "outputDirectory": "build/web",
  "installCommand": "echo 'Flutter install is handled inside buildCommand'",
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ],
  "headers": [
    {
      "source": "/flutter_service_worker.js",
      "headers": [
        { "key": "Cache-Control", "value": "no-cache" }
      ]
    },
    {
      "source": "/(.*\\.dart\\.js)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
      ]
    }
  ]
}
```

**Por qué cada parte:**
- `rewrites`: sin esto, navegar a `/route/planner` directamente o hacer F5 da 404.
  Vercel busca un archivo real con ese path y no lo encuentra. El rewrite redirige
  todo al `index.html` y Flutter Router maneja el resto.
- `flutter_service_worker.js` sin cache: evita que usuarios reciban la app vieja
  después de un deploy.
- `*.dart.js` con cache máximo: los archivos JS de Flutter llevan hash en el nombre
  (ej `main.dart.abcd1234.js`), así que cachearlos agresivamente es seguro.
- `sed`: inyecta la API key real de Maps en el placeholder de `index.html`
  durante el build, sin exponerla en el repo.

**Commit:** `chore(web): add vercel.json with Flutter build config and SPA rewrites`

## ⏸️ PAUSA #5 — Esperá confirmación del usuario antes de continuar.

---

## TAREA 6 — Actualizar .env.example

Asegurate de que `.env.example` documenta TODAS las variables que Vercel necesita:

```bash
# ================================================
# Supabase
# ================================================
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-supabase-anon-key

# ================================================
# Google Maps (Maps SDK + Directions API)
# Restringir en Google Cloud Console a tu dominio de Vercel
# ================================================
GOOGLE_MAPS_API_KEY=your-google-maps-api-key

# ================================================
# Sentry (opcional - crash reporting)
# ================================================
SENTRY_DSN=your-sentry-dsn

# ================================================
# Firebase Web Config
# Valores PÚBLICOS del Web App en Firebase Console
# > Project Settings > Your Apps > Web App
# Requerido para notificaciones push en web
# ================================================
# FIREBASE_WEB_API_KEY=your-firebase-web-api-key
# FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
# FIREBASE_PROJECT_ID=your-project-id
# FIREBASE_STORAGE_BUCKET=your-project.appspot.com
# FIREBASE_MESSAGING_SENDER_ID=your-sender-id
# FIREBASE_APP_ID=your-app-id
```

**Commit:** `docs: update .env.example with all variables needed for Vercel deploy`

## ⏸️ PAUSA #6 — Esperá confirmación del usuario antes de continuar.

---

## TAREA 7 — Verificación Final de Builds

### 7a. Build web

```bash
flutter clean
flutter pub get
flutter build web --release \
  --dart-define=SUPABASE_URL=https://placeholder.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=placeholder \
  --dart-define=GOOGLE_MAPS_API_KEY=placeholder
```

Debe completar **sin errores**. Warnings son aceptables.

### 7b. Build Android (verificar que mobile no regresionó)

```bash
flutter build apk --dart-define-from-file=.env
```

Debe compilar sin errores nuevos.

### 7c. Análisis y tests

```bash
flutter analyze --fatal-infos   # debe ser 0 issues
flutter test                    # todos deben pasar
```

### 7d. Test rápido en Chrome

```bash
flutter run -d chrome --dart-define-from-file=.env
```

Verificar manualmente en el browser:
- [ ] La app carga sin errores en la consola del browser (F12)
- [ ] Login y registro funcionan
- [ ] Google Maps carga (puede mostrar "for development purposes only"
      si la key tiene restricciones — es normal en localhost)
- [ ] Al menos una búsqueda o promoción carga correctamente

**Si algo falla en Chrome pero mobile sigue bien:** documentarlo en el
commit message. NO bloquear el PR por eso si es menor.

**Si algo falla en Android que antes funcionaba:** eso es una regresión — 
revertir los cambios de esa tarea antes de continuar.

**Commit:** `chore(web): verify web and mobile builds post-compatibility fixes`

## ⏸️ PAUSA #7 — Esperá confirmación del usuario antes de continuar.

---

## TAREA 8 — Push y PR (instrucciones para Edgar)

### 8a. Push del branch

```bash
git push origin chore/web-vercel-deploy
```

### 8b. Setup en Vercel (manual — Claude Code no puede hacer esto)

1. Ir a [vercel.com](https://vercel.com) → Log in con cuenta de GitHub
2. "Add New Project" → importar `FlechaVerdeY2K/OptiGasto`
3. Vercel detecta automáticamente el `vercel.json`
4. En **Environment Variables** del proyecto, agregar:
   - `SUPABASE_URL` = valor real del `.env` local
   - `SUPABASE_ANON_KEY` = valor real
   - `GOOGLE_MAPS_API_KEY` = valor real
5. Click **Deploy**
6. Primer build tarda ~8-10 min (descarga Flutter SDK)
7. Anotar la URL generada (ej. `optigasto-xxxx.vercel.app`)

### 8c. Restringir la API key de Google Maps

**Después de tener la URL de Vercel:**

1. Google Cloud Console → APIs & Services → Credentials → tu API key
2. Application restrictions → **HTTP referrers**
3. Agregar los dominios:
   ```
   https://*.vercel.app/*
   https://tu-dominio-custom.com/*
   http://localhost:*
   ```
4. Guardar

### 8d. Abrir PR

```bash
gh pr create \
  --base main \
  --head chore/web-vercel-deploy \
  --title "chore: web compatibility fixes and Vercel deploy config" \
  --body "Adds kIsWeb guards for flutter_local_notifications and FCM, Google Maps web script injection via placeholder+sed, vercel.json with Flutter build pipeline and SPA rewrites. Mobile builds verified unaffected."
```

---

## ⏸️ PAUSA FINAL — Reporte

Reportá:
1. ¿`flutter build web` compila sin errores? (sí/no)
2. ¿`flutter build apk` sigue compilando? (sí/no)
3. ¿`flutter analyze --fatal-infos` = 0? (sí/no)
4. ¿`flutter test` pasa? (sí/no)
5. ¿Qué features probaste en Chrome y funcionaron? (lista)
6. ¿Qué features NO funcionaron en web y por qué? (lista)
7. Archivos modificados: `git diff main --name-only`

---

## ❌ Lo que NO Hacer

- **NO** eliminar código mobile — solo envolverlo con `kIsWeb`
- **NO** cambiar lógica de autenticación — Supabase Auth funciona igual en web
- **NO** modificar archivos en `android/` o `ios/`
- **NO** poner valores reales de API keys en ningún archivo commiteado al repo
- **NO** mergear a `main` sin que Edgar verifique mobile en dispositivo real

---

## 📌 Para Otro AI Continuando

Si seguís con otro AI:
- Corrés `grep -r "kIsWeb" lib/` para ver qué guards ya están aplicados
- La Tarea 5 (`vercel.json`) es la más crítica para que Vercel funcione
- Las Tareas 1 y 4 (kIsWeb guards) son las más críticas para que mobile no rompa
- Cada tarea es un commit independiente — podés empezar desde cualquiera
