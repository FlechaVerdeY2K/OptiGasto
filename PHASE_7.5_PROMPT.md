# Prompt para Claude Code — Fase 7.5: Guardar y Reordenar Rutas

**Versión:** 1.0 | **Última actualización:** [usuario completará después de cada checkpoint]

---

## 📋 Estado Actual del Desarrollo

**Checkpoint actual:** TASK 9 — DI Registration + main.dart (siguiente a ejecutar)

| Tarea | Estado | Completado por | Fecha |
|-------|--------|-----------------|-------|
| 1. Migración SQL + RLS | ✅ COMPLETADO | Claude (subagent) | 2026-04-16 |
| 2. Domain layer (`SavedRouteEntity`) | ✅ COMPLETADO | Claude (subagent) | 2026-04-16 |
| 3. Data layer (CRUD) | ✅ COMPLETADO | Claude (subagent) | 2026-04-16 |
| 4. BLoC SavedRoutesBloc | ✅ COMPLETADO | Claude (subagent) | 2026-04-16 |
| 5. UI: Listar rutas guardadas | ⬜ NO INICIADO | — | — |
| 6. UI: Guardar ruta post-cálculo | ⬜ NO INICIADO | — | — |
| 7. UI: Reordenar manual + recalcular | ⬜ NO INICIADO | — | — |
| 8. Tests + refinamiento | ⬜ NO INICIADO | — | — |

### Detalle de commits en branch `feature/phase-7.5-saved-routes`

| Plan Task | Commit | Descripción |
|-----------|--------|-------------|
| T1: StorageFailure | `4811410` | feat(core): add StorageFailure |
| T2: SQL Migration | `ac1362d` | feat(db): add saved_routes table with RLS |
| T3: Domain Entity + Repo | `51cc403` | feat(route): add SavedRouteEntity and SavedRoutesRepository |
| T4: CalculateOrderedRoute | `850df8b` | feat(route): add CalculateOrderedRoute use case |
| T5: SavedRouteModel | `6a302d8` | feat(route): add SavedRouteModel with Supabase serialization |
| T6: Datasource | `f944c2c` | feat(route): add SavedRoutesRemoteDataSource |
| T7: Repo Impl | `cc3e5d4` | feat(route): add SavedRoutesRepositoryImpl |
| T8: BLoC | `27809d8` | feat(route): add SavedRoutesBloc |

### Archivos nuevos ya creados

- `supabase/migrations/20260416000001_create_saved_routes_table.sql`
- `lib/core/errors/failures.dart` (modificado — StorageFailure agregado)
- `lib/features/route/domain/entities/saved_route_entity.dart`
- `lib/features/route/domain/repositories/saved_routes_repository.dart`
- `lib/features/route/domain/usecases/calculate_ordered_route.dart`
- `lib/features/route/data/models/saved_route_model.dart`
- `lib/features/route/data/datasources/saved_routes_remote_data_source.dart`
- `lib/features/route/data/repositories/saved_routes_repository_impl.dart`
- `lib/features/route/presentation/bloc/saved_routes_event.dart`
- `lib/features/route/presentation/bloc/saved_routes_state.dart`
- `lib/features/route/presentation/bloc/saved_routes_bloc.dart`

### Próximas tareas (T9–T16)

Continuar con el plan en `docs/superpowers/plans/2026-04-16-phase-7.5-saved-routes.md` desde **Task 9**.

Usar skill `superpowers:subagent-driven-development`. Ejecutar un subagente por task, revisar spec + calidad antes de continuar.

**Token budget:** nueva sesión

---

## 🎯 Contexto General

Estás en **OptiGasto**, feature de rutas inteligentes ya completa (Fase 7). Ahora extendés con **Fase 7.5: persistencia y edición de rutas**.

**Qué agregamos:**
- Tabla `saved_routes` en Supabase: `id`, `user_id`, `name`, `origin`, `stops` (JSON), `distance_meters`, `duration_seconds`, `created_at`, `updated_at`.
- Cambios mínimos en `RouteResultPage`: botón "Guardar ruta" al calcular.
- Nueva página `SavedRoutesPage`: lista swipeable de rutas guardadas, botón "Editar" abre el reordenador.
- Nueva página `RouteEditorPage`: lista de stops con drag-and-drop (mediante `reorderable_grid`), botón "Recalcular" re-llama a Directions API con el nuevo orden.

**Stack:**
- `reorderable_grid: ^2.4.2` (ya agregar a pubspec si no está)
- Supabase ya configurado
- BLoC + Clean Architecture consistente con Fase 7

**Branch:** `feature/phase-7.5-saved-routes` (crear al empezar)

**Decisión crítica ya tomada:** 
- Rutas guardadas son **privadas al usuario** (RLS `WHERE user_id = auth.uid()`).
- NO guardar polylines en la BD, solo calcularlas on-demand cuando abras la ruta.
- NO integrar con gamificación (eso es Fase 8+).

---

## ✅ Checklist de Contexto a Leer (antes de empezar)

**IMPORTANTE: Leé estos archivos para entender patrones REALES:**

1. `lib/features/route/domain/entities/optimized_route_entity.dart` — estructura de ruta calculada.
2. `lib/features/route/presentation/bloc/route_planner_bloc.dart` — patrón de BLoC existente.
3. `lib/features/promotions/presentation/pages/promotions_list_page.dart` — patrón de lista con pull-to-refresh.
4. `lib/features/profile/presentation/pages/edit_profile_page.dart` — si hay drag-and-drop, ejemplo.
5. `lib/core/errors/failures.dart` — qué Failures existen (agregar `StorageFailure` si no existe).
6. `pubspec.yaml` — qué paquetes están (si `reorderable_grid` no existe, documentar para agregar).

---

## 📝 Tareas Detalladas

### CHECKPOINT 1: Migración SQL + Models

**Descripción:** Crear tabla `saved_routes` y modelos Dart correspondientes.

**Tareas:**

1. **Migración SQL:** Creá `supabase/migrations/[timestamp]_create_saved_routes_table.sql`
   ```sql
   CREATE TABLE saved_routes (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
     name TEXT NOT NULL,
     origin JSONB NOT NULL,         -- {lat, lng, displayName, type}
     stops JSONB NOT NULL,          -- [{id, promotionId, name, lat, lng, order}]
     distance_meters INT NOT NULL,
     duration_seconds INT NOT NULL,
     created_at TIMESTAMP DEFAULT now(),
     updated_at TIMESTAMP DEFAULT now()
   );

   ALTER TABLE saved_routes ENABLE ROW LEVEL SECURITY;
   CREATE POLICY "User can view own saved routes"
     ON saved_routes FOR SELECT USING (user_id = auth.uid());
   CREATE POLICY "User can insert own saved routes"
     ON saved_routes FOR INSERT WITH CHECK (user_id = auth.uid());
   CREATE POLICY "User can update own saved routes"
     ON saved_routes FOR UPDATE USING (user_id = auth.uid());
   CREATE POLICY "User can delete own saved routes"
     ON saved_routes FOR DELETE USING (user_id = auth.uid());

   CREATE INDEX saved_routes_user_id_idx ON saved_routes(user_id);
   ```

2. **Model Dart:** `lib/features/route/data/models/saved_route_model.dart`
   - Extiende `SavedRouteEntity`
   - Campo `origin` y `stops` como JSONB → convertir a/desde `Map<String, dynamic>`
   - Factory `fromSupabase()` y método `toSupabase()`

3. **Entity Dart:** `lib/features/route/domain/entities/saved_route_entity.dart`
   - `id` (String UUID)
   - `userId` (String UUID)
   - `name` (String, ej "Ruta domingal")
   - `origin` (RouteOriginEntity)
   - `stops` (List<RouteStopEntity>)
   - `distanceMeters` (int)
   - `durationSeconds` (int)
   - `createdAt` (DateTime)
   - `updatedAt` (DateTime)
   - Extiende `Equatable`

**Commit esperado:**
```
feat(route): add saved_routes table with RLS and models
```

**Al terminar, reportá:**
- ¿Migración creada? (sí/no)
- ¿Models y entidades compilando? (sí/no)
- ¿Algún problema con JSONB encoding? (detalles si hay)

**Pausa y espera:** Usuarios confirman "continúa" antes de pasar a checkpoint 2.

---

### CHECKPOINT 2: Data Layer (CRUD)

**Descripción:** Datasource + Repository para operaciones CRUD en rutas guardadas.

**Tareas:**

1. **Datasource:** `lib/features/route/data/datasources/saved_routes_remote_data_source.dart`
   ```dart
   abstract class SavedRoutesRemoteDataSource {
     Future<List<SavedRouteModel>> getSavedRoutes();
     Future<SavedRouteModel> createSavedRoute(SavedRouteModel route);
     Future<SavedRouteModel> updateSavedRoute(SavedRouteModel route);
     Future<void> deleteSavedRoute(String routeId);
   }
   ```

   Implementación con Supabase:
   - `getSavedRoutes()` → `supabase.from('saved_routes').select().order('created_at', ascending: false)`
   - `createSavedRoute()` → `insert()` → retorna el modelo creado
   - `updateSavedRoute()` → `update().match({'id': ...})` → retorna actualizado
   - `deleteSavedRoute()` → `delete().match({'id': ...})`

   Manejo de errores: `ServerException` para errores técnicos, `StorageFailure` en el repo.

2. **Repository:** `lib/features/route/data/repositories/saved_routes_repository_impl.dart`
   ```dart
   abstract class SavedRoutesRepository {
     Future<Either<Failure, List<SavedRouteEntity>>> getSavedRoutes();
     Future<Either<Failure, SavedRouteEntity>> createSavedRoute(SavedRouteEntity route);
     Future<Either<Failure, SavedRouteEntity>> updateSavedRoute(SavedRouteEntity route);
     Future<Either<Failure, void>> deleteSavedRoute(String routeId);
   }
   ```

   Impl: wrapper estándar que maneja excepciones → Failures.

3. **Inyección:** Registrá en `injection_container.dart`
   - `SavedRoutesRemoteDataSource` (singleton)
   - `SavedRoutesRepository` (singleton)

**Commit esperado:**
```
feat(route): add saved routes data layer with Supabase CRUD
```

**Al terminar, reportá:**
- ¿Tests locales de datasource con mock Supabase? (hecho/saltado)
- ¿Algún problema con conversiones JSONB? (detalles si hay)

**Pausa y espera:** Usuarios confirman "continúa" antes de pasar a checkpoint 3.

---

### CHECKPOINT 3: BLoC SavedRoutesBloc

**Descripción:** State management para listar, cargar, y guardar rutas.

**Tareas:**

1. **Events:**
   - `SavedRoutesInitialize` — carga la lista
   - `SavedRouteCreate({required SavedRouteEntity route, required String name})` — guarda una nueva
   - `SavedRouteUpdate({required SavedRouteEntity route})` — actualiza (orden de stops, nombre)
   - `SavedRouteDelete({required String routeId})` — borra
   - `SavedRouteLoad({required String routeId})` — carga una ruta guardada

2. **States:**
   - `SavedRoutesInitial`
   - `SavedRoutesLoading`
   - `SavedRoutesLoaded({required List<SavedRouteEntity> routes})`
   - `SavedRouteOperationInProgress` — mientras guarda/actualiza/borra
   - `SavedRouteLoaded({required SavedRouteEntity route})` — cuando se carga una para editar
   - `SavedRoutesError({required String message})`

3. **Handlers:**
   - Cada CRUD operation → emit Loading → call repo → emit result
   - Después de crear/actualizar/borrar, re-cargar la lista

**Commit esperado:**
```
feat(route): add SavedRoutesBloc with CRUD state management
```

**Al terminar, reportá:**
- ¿BLoC compila sin errores? (sí/no)
- ¿States coherentes? (lista/detalle bien separados)

**Pausa y espera:** Usuarios confirman "continúa" antes de pasar a checkpoint 4.

---

### CHECKPOINT 4: UI Parte 1 — Listar y Guardar

**Descripción:** `SavedRoutesPage` (lista) + botón "Guardar" en `RouteResultPage`.

**Tareas:**

1. **SavedRoutesPage:** `lib/features/route/presentation/pages/saved_routes_page.dart`
   - AppBar "Mis rutas guardadas"
   - Si vacío: mensaje "No tienes rutas guardadas. ¡Crea una desde el planificador!"
   - Si hay: lista con cards que muestran:
     - Nombre (editable, doble-tap abre input dialog)
     - Distancia + duración
     - Fecha de creación (formateada)
     - Botón "Editar" → navega a `RouteEditorPage` con la ruta pre-cargada
     - Swipe left → delete (con confirmación)
   - Botón FAB azul "Crear nueva ruta" → navega al planner

2. **RouteResultPage - Cambios:**
   - Después de `ExportRouteButtons`, agregar input dialog "Guardar esta ruta"
   - Input: nombre de la ruta (string, required)
   - Botón "Guardar" → llama a `SavedRoutesBloc.add(SavedRouteCreate(...))`
   - Toast/snackbar: "Ruta guardada como '{name}'"
   - Botón secundario "Descartar y volver" → pop

3. **Dialog de nombre:** Widget reutilizable `SaveRouteDialog`

**Commit esperado:**
```
feat(route): add SavedRoutesPage and save route dialog
```

**Al terminar, reportá:**
- ¿UI se ve bien en light + dark mode? (sí/no)
- ¿Guardar ruta funciona end-to-end? (sí/no, si no qué error)
- ¿Listar rutas guardadas funciona? (sí/no)

**Pausa y espera:** Usuarios confirman "continúa" antes de pasar a checkpoint 5.

---

### CHECKPOINT 5: UI Parte 2 — Reordenar y Recalcular

**Descripción:** `RouteEditorPage` con drag-and-drop + recalcular ruta.

**Tareas:**

1. **RouteEditorPage:** `lib/features/route/presentation/pages/route_editor_page.dart`
   - Recibe `SavedRouteEntity route` por parámetro
   - AppBar "Editar ruta: {name}"
   - Sección origen (no editable, solo display)
   - Lista de stops CON **reorderable drag-and-drop** (usar `reorderable_grid` o Flutter nativo `ReorderableListView`)
   - Cada stop muestra:
     - Número (1, 2, 3...) — se actualiza al reordenar
     - Nombre
     - Distancia del anterior
     - Ícono de arrastre (seis puntos)
   - Botón flotante "Recalcular ruta" — llama a `CalculateOptimalRoute` con los stops en nuevo orden
   - Botón secundario "Guardar cambios" — llama a `SavedRoutesBloc.add(SavedRouteUpdate(...))` con el orden nuevo
   - Toast: "Ruta actualizada"

2. **Integración con `CalculateOptimalRoute`:**
   - El use case ya existe (Fase 7), BUT: lo usamos de nuevo aquí
   - Pasamos los stops EN el orden que el usuario eligió (no vuelve a hacer TSP, asume el usuario sabe)
   - Se recalculan las polylines + distancias con Directions API
   - Se actualiza el estado local de la página con los nuevos valores

3. **Dependencias:**
   - Si `reorderable_grid` no está en pubspec, agregar `reorderable_grid: ^2.4.2`
   - Verificar que compila

**Commit esperado:**
```
feat(route): add RouteEditorPage with drag-and-drop reordering
```

**Al terminar, reportá:**
- ¿`reorderable_grid` agregado? (sí/no)
- ¿Drag-and-drop funciona? (sí/no)
- ¿Recalcular ruta funciona? (sí/no, si no qué error)
- ¿Guardar cambios persiste? (sí/no)

**Pausa y espera:** Usuarios confirman "continúa" antes de pasar a checkpoint 6.

---

### CHECKPOINT 6: Routing + Entry Points

**Descripción:** Agregar rutas al router y puntos de entrada desde otras páginas.

**Tareas:**

1. **app_router.dart — Nuevas rutas:**
   ```dart
   GoRoute(
     path: 'saved',
     name: 'saved-routes',
     builder: (ctx, state) => SavedRoutesPage(),
   ),
   GoRoute(
     path: 'edit/:routeId',
     name: 'route-editor',
     builder: (ctx, state) {
       final routeId = state.pathParameters['routeId'];
       final route = state.extra as SavedRouteEntity?;
       return RouteEditorPage(route: route);
     },
   ),
   ```

2. **Entry points:**
   - HomePage: nuevo botón "Mis rutas" en el navigation bar o menú
   - RouteResultPage: botón "Guardar" ya agregado en checkpoint 4
   - SavedRoutesPage: botón FAB "Crear nueva" navega al planner

3. **Registrar SavedRoutesBloc en MultiBlocProvider de main.dart** si corresponde (probablemente sí, para acceso global)

**Commit esperado:**
```
feat(route): add saved routes navigation and entry points
```

**Al terminar, reportá:**
- ¿Rutas compilan? (sí/no)
- ¿Navegación fluida entre planner → result → save → list? (sí/no)
- ¿Botones aparecen en sitios correctos? (sí/no)

**Pausa y espera:** Usuarios confirman "continúa" antes de pasar a checkpoint 7.

---

### CHECKPOINT 7: Tests + Refinamientos

**Descripción:** Tests unitarios e integración final.

**Tareas:**

1. **Unit tests:**
   - `test/features/route/data/datasources/saved_routes_remote_data_source_test.dart` — mock Supabase, test CRUD
   - `test/features/route/presentation/bloc/saved_routes_bloc_test.dart` — estados, eventos

2. **Lint + formato:**
   ```bash
   dart format .
   flutter analyze --fatal-infos
   flutter test
   ```

3. **Refinamientos detectados durante testing:**
   - Dark mode en SavedRoutesPage: backgrounds, textos
   - Validación: nombre vacío al guardar ruta
   - UX: swipe delete con undo option (opcional, si tiempo permite)

4. **README:** Actualizar docs de la feature

**Commit esperado:**
```
test(route): add unit tests for saved routes
fix(route): dark mode and validation refinements
docs(route): update feature documentation
```

**Al terminar, reportá:**
- ¿Todos los tests pasan? (sí/no, cantidad)
- ¿`flutter analyze --fatal-infos` = 0 issues? (sí/no)
- ¿Qué refinamientos se hicieron? (lista)
- ¿Algún bug descubierto? (detalles)

**Pausa y espera:** Usuarios confirman si hacer commit final o hacer ajustes.

---

### CHECKPOINT FINAL: Reporte y Push

**Tareas:**

1. Crear resumen final:
   ```
   ## Fase 7.5 — Completado
   
   **Archivos nuevos:** [N]
   **Archivos modificados:** [N]
   **Líneas agregadas:** [N]
   **Tests nuevos:** [N]
   **Commits:** [lista de hashes]
   
   **Decisiones tomadas:**
   - [detalles]
   
   **Bugs descubiertos (no corregidos en este PR):**
   - [detalles si hay]
   ```

2. Pushear branch: `git push origin feature/phase-7.5-saved-routes`

3. Comando para abrir PR:
   ```bash
   gh pr create --base main --head feature/phase-7.5-saved-routes \
     --title "feat: phase 7.5 - save and reorder routes" \
     --body "..."
   ```

---

## 📌 Para Otros AI Continuando Esta Sesión

Si llegás aquí y querés continuar con OTRO AI:

1. **Estado actual:** Leé la tabla de checkpoints arriba. Fijate cuál está ✅ COMPLETADO.
2. **Contexto:** El proyecto usa Clean Architecture + BLoC. Las rutas están en `lib/features/route/`.
3. **Lo que falta:** Si el último checkpoint completo es el 3, entonces falta UI (checkpoints 4-7).
4. **Instrucciones para el nuevo AI:** Pegale ESTE ARCHIVO COMPLETO al nuevo AI y decile: "El checkpoint X está completado. Continuá desde el checkpoint X+1. Respetá los mismos patrones que viste en checkpoints anteriores."

---

## ⚙️ Checklist Final para el Usuario

- [ ] Directions API habilitada en Google Cloud Console
- [ ] `.env` con `GOOGLE_MAPS_API_KEY` configurada
- [ ] Branch `feature/phase-7.5-saved-routes` creado y pusheado
- [ ] Supabase CLI instalado localmente (`supabase` comando disponible)
- [ ] Confirmación del usuario después de CADA checkpoint antes de continuar

