# route — Smart Route Planner

Allows users to select up to 10 promotion stops, compute an optimized visiting order using a greedy TSP algorithm, fetch a driving polyline from Google Directions API, and export the route to Google Maps or Waze.

## Architecture

Follows Clean Architecture + BLoC, mirroring the `location` feature:

```
lib/features/route/
├── domain/
│   ├── entities/           — RouteStopEntity, RouteOriginEntity, OptimizedRouteEntity
│   ├── repositories/       — RouteRepository (abstract) + RoutePolylineData
│   └── usecases/           — CalculateOptimalRoute, BuildNavigationUrl
├── data/
│   ├── models/             — DirectionsResponseModel (parses Directions API JSON)
│   ├── datasources/        — DirectionsRemoteDataSource (Dio)
│   └── repositories/       — RouteRepositoryImpl
└── presentation/
    ├── bloc/               — RoutePlannerBloc (6 events, 5 states)
    ├── pages/              — RoutePlannerPage, RouteResultPage, MapPickerPage
    └── widgets/            — RouteSummaryCard, RouteStopList, ExportRouteButtons,
                              StopSelectionMethodPicker, RouteOriginSelector,
                              FavoritesStopPicker, NearbyStopPicker
```

## Key Design Decisions

**TSP algorithm:** Greedy nearest-neighbor. O(n²) but adequate for n ≤ 10. Runs in pure Dart in the domain layer with no external dependencies.

**No `optimize:true` in Directions API:** The `optimize:true` waypoints flag reorders stops server-side, which would conflict with our client-side TSP ordering. We send stops already ordered and ask only for the polyline.

**No `departure_time` or traffic data:** These parameters require a premium Maps API plan and are explicitly excluded to avoid unexpected billing.

**10-stop limit:** Keeps TSP runtime and Directions API cost negligible. Validated at both the UI layer (`_StopCounter`) and the use-case layer (`CalculateOptimalRoute`).

**Three stop selection methods:**
- `map` — Full-screen map picker; user taps markers to toggle selection
- `favorites` — Filtered list of user's saved promotions
- `nearby` — Radius-based search using current location (1–10 km slider)

**Export:** Google Maps receives all stops as origin + waypoints + destination. Waze only supports a single destination, so we navigate to the first stop only (displayed via Tooltip).

## API Cost Estimate

Each route calculation = 1 Directions API request. As of 2024:
- First 40,000 requests/month: $0.005 each → $200/month at scale
- Requests with > 10 waypoints are billed as Advanced tier; we stay under that threshold.

## Known Limitations

- Polyline shows the driving path between stops but does not update in real time.
- TSP is not globally optimal; for routes with stops clustered in multiple groups, a different heuristic might produce shorter paths.
- `RouteResultPage` uses `Future.delayed` replaced with `addPostFrameCallback` for map camera fit — still depends on the Google Maps SDK having finished its initial render.
- Waze export navigates only to the first stop. This is a Waze deep-link limitation.

## Entry Points

| Location | How to reach route planner |
|----------|---------------------------|
| Home nav bar | "Ruta" tab (index 3) — pushes `/route/planner` |
| Map page | Mini FAB bottom-right → `/route/planner` |
| Promotions list | "Crear ruta" FAB → `/route/planner` with `method: favorites` pre-selected |
