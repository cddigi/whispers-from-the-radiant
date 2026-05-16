# Godot AI Guidelines — Claude Code Entry Point

**Target Engine**: Godot 4.7-dev3 (built atop 4.6.0-beta2 baseline)
**Document Purpose**: Automatically loaded context for Claude Code when working in this directory. Provides a navigation map to the detailed guideline files plus the highest-leverage version-specific facts inline.
**Last Updated**: 2026-05-16

> This file is the **entry point**. For depth on any topic, follow the links into the numbered guideline files. The README in this directory is a human-readable navigation index; this CLAUDE.md is the AI-optimized counterpart.

---

## How to Use These Guidelines

When you (Claude) start a task in this project, decide which numbered guideline file is most relevant based on the task type, then read that file before generating code. The matrix below is the routing table.

### Routing Table by Task Type

| If the task is about... | Read first | Then maybe |
|---|---|---|
| Version differences, migration, breaking changes | `00-version-and-migration.md` | this file's "Critical Facts" section below |
| GDScript syntax, typing, abstract classes, performance idioms | `01-gdscript-modern-patterns.md` | `07-platform-performance.md` |
| Scene tree composition, signals, autoloads, resources | `02-scene-architecture.md` | `03-core-systems.md` |
| Memory, pooling, groups, SceneTree internals | `03-core-systems.md` | `01-gdscript-modern-patterns.md` |
| Sprites, TileMapLayer, Camera2D, 2D rendering | `04-2d-graphics-rendering.md` | `07-platform-performance.md` |
| Animation, IK, physics (Jolt vs Godot), 3D | `05-animation-physics-3d.md` | `00-version-and-migration.md` |
| Control nodes, layouts, theming, FileDialog, input focus | `06-ui-and-controls.md` | `02-scene-architecture.md` |
| Platform targets, mobile/web, profiling, optimization | `07-platform-performance.md` | `03-core-systems.md` |
| "What's the pattern for X?" quick lookup | `08-quick-reference.md` | the file referenced by the answer |

### Routing Table by File

| File | Focus | Anchor Version |
|------|-------|----------------|
| [00-version-and-migration.md](00-version-and-migration.md) | Version timeline, breaking changes, migration checklist | 4.5 → 4.6 → **4.7-dev3** |
| [01-gdscript-modern-patterns.md](01-gdscript-modern-patterns.md) | Language idioms, typing, abstract classes, `reserve()` | 4.6.0-beta2 |
| [02-scene-architecture.md](02-scene-architecture.md) | Scene composition, signals, autoloads, resources | 4.6.0-beta2 |
| [03-core-systems.md](03-core-systems.md) | Memory, pooling, groups, SceneTree, globals | 4.6.0-beta2 |
| [04-2d-graphics-rendering.md](04-2d-graphics-rendering.md) | Sprites, TileMapLayer, Camera2D, batching | 4.6.0-beta2 |
| [05-animation-physics-3d.md](05-animation-physics-3d.md) | IKModifier3D, AnimationTree, Jolt Physics | 4.6.0-beta2 |
| [06-ui-and-controls.md](06-ui-and-controls.md) | Control nodes, containers, theming, FileDialog | 4.6.0-beta2 |
| [07-platform-performance.md](07-platform-performance.md) | Platforms, mobile/web, profiling, optimization | 4.6.0-beta2 |
| [08-quick-reference.md](08-quick-reference.md) | Pattern templates, decision trees, gotchas | 4.6.0-beta2 |

---

## Critical Facts (Must-Know Before Generating Code)

These are the highest-leverage facts. Memorize them; everything else is in the detailed files.

### Breaking Changes That Bite Immediately (4.5+ baseline)

1. **String conversion of math types is gone.** `String(vec)` is a compile error. Use `str(vec)`, `"%v" % vec`, or `var_to_str(vec)`.
   - Affected: `Vector2/3/4(i)`, `Transform2D/3D`, `Basis`, `Projection`, `Callable`, `Signal`, `IPAddress`, `NodePath`.

2. **Abstract uses an annotation, not a keyword.** `abstract func foo()` → `@abstract\nfunc foo()`. Same for classes.

3. **Object script access uses getters/setters.** `obj.script` → `obj.get_script()` / `obj.set_script(s)`.

4. **Glow renders before tonemapping.** Default blend mode is now "screen" (was additive). Projects with significant glow effects must re-tune.

5. **Quaternion in Variant defaults to identity** `(0,0,0,1)`. Don't rely on uninitialized values.

### Platform Floors (4.5+ baseline)

| Platform | Minimum |
|----------|---------|
| Windows | 10 (1809+ recommended) — **7/8/8.1 dropped** |
| Android | API 24 (7.0 Nougat) — was 21; NDK r28b |
| .NET (C#) | .NET 8.0 — was 6.0 (Android C# may need 9.0) |

### Features You Should Reach For (4.6+)

- `Array.reserve(n)`, `Dictionary.reserve(n)`, `String.reserve(n)` — pre-allocate when size is known.
- `IKModifier3D` and its 8 subclasses (CCDIK3D, FABRIK3D, JacobianIK3D, etc.) — `SkeletonIK` is deprecated.
- `TileMapLayer` nodes — legacy `TileMap` is deprecated (this dates to 4.3 but still trips people up).
- **Jolt Physics** is the default for new 3D projects; production-ready in 4.6.
- `D3D12` is the default RenderingDevice driver on Windows.
- AgX tonemapper with white balance, contrast, and HDR support.

### New in 4.7-dev3 (Worth Knowing for This Project)

This game is tablet-focused and card-game heavy, so these 4.7-dev3 additions are especially relevant:

1. **Transform Offset for Controls** (GH-87081) — Translate, rotate, or scale a `Control` independently without disturbing container layout. **Directly useful** for card hover/play animations and the mental-shield reveal effect described in the project narrative.

2. **PopupMenu Search Bar** (GH-114236) — Visible search field for long popup menus.

3. **RichTextLabel** — Triple-click paragraph selection (GH-116868); improved table rendering (GH-116277).

4. **AtlasTexture Tiling in TextureRect** (GH-113808) — Tiles can now repeat from atlas textures, useful for backgrounds composed from sprite sheets.

5. **Animation system optimization** (GH-116394, GH-117277) — Optimized `Animation` resource, `AnimationLibrary`, `AnimationMixer`, `AnimationPlayer`, and `AnimationTree` internals with improved thread group safety.

6. **Signal thread safety** (GH-117511) — Enhanced thread-safety of `Object` signals.

7. **Polygon2D fast path** (GH-117334) — Rendering optimization for `Polygon2D`.

8. **HDR output on Apple platforms** (GH-106814) and **Linux/Wayland** (GH-102987) — Full EDR display support.

9. **Android Picture-in-Picture** (GH-114505) — `DisplayServer.pip_mode_enter()` and auto-enter.

10. **Device IDs in input events** (GH-116274) — Keyboard/mouse events now carry a `device` identifier — relevant if you ever add local multiplayer with multiple keyboards/mice.

11. **Tracy on-demand by default** (GH-117583) — Lighter profiling overhead.

12. **Editor additions** — 3D vertex snapping (B-key, GH-117235), MeshLibrary editor (GH-117376), Scene Painter (GH-109360), autocomplete-no-longer-eats-words (GH-117464), remote inspector improvements (GH-115738, GH-117357).

13. **wasm64 web builds** (GH-102378) — Extended WebAssembly compatibility.

14. **Statistics** — dev2: 248 fixes / 105 contributors; dev3: 297 fixes / 113 contributors.

---

## Compatibility Matrix (Version → Feature)

A condensed version of the table in `00-version-and-migration.md`. Use this for quick "is X available in version Y?" lookups.

| Feature | 4.5.0 | 4.6.0 | 4.7-dev3 |
|---------|:-----:|:-----:|:--------:|
| Abstract classes (`@abstract`) | ✅ | ✅ | ✅ |
| Variadic functions | ✅ | ✅ | ✅ |
| Const Array/Dict constructors | ✅ | ✅ | ✅ |
| String implicit conversion of math types | ❌ | ❌ | ❌ |
| `Array/Dictionary/String.reserve()` | ❌ | ✅ | ✅ |
| `IKModifier3D` (+ 8 subclasses) | ❌ | ✅ | ✅ |
| Jolt Physics default for 3D | ❌ | ✅ | ✅ |
| LibGodot (engine as library) | ❌ | ✅ | ✅ |
| D3D12 default on Windows | ❌ | ✅ | ✅ |
| 2D batching 1.1–7× GPU gains | ❌ | ✅ | ✅ |
| Tracy / Perfetto / Instruments profilers | ❌ | ✅ | ✅ |
| Transform Offset for Controls | ❌ | ❌ | ✅ |
| Animation system optimizations | ❌ | ❌ | ✅ |
| `AnimationTree` thread safety | ❌ | ❌ | ✅ |
| Signal thread safety | ❌ | ❌ | ✅ |
| `Polygon2D` fast path | ❌ | ❌ | ✅ |
| HDR on Apple platforms | ❌ | ❌ | ✅ |
| HDR on Linux/Wayland | ❌ | ❌ | ✅ |
| Android Picture-in-Picture | ❌ | ❌ | ✅ |
| Device IDs in input events | ❌ | ❌ | ✅ |
| `wasm64` web builds | ❌ | ❌ | ✅ |
| PopupMenu search bar | ❌ | ❌ | ✅ |
| `AtlasTexture` tiling in `TextureRect` | ❌ | ❌ | ✅ |
| Tracy on-demand default | ❌ | ❌ | ✅ |

---

## Deprecated — Migrate Away From These

| Deprecated | Replacement | Detail |
|------------|-------------|--------|
| `String(math_type)` conversion | `str(...)` or `"%v" % ...` | Compile error since 4.5 |
| `abstract func` keyword | `@abstract` annotation | 4.5+ |
| `obj.script` direct access | `obj.get_script()` / `obj.set_script()` | 4.6+ |
| `SkeletonIK` (3D) | `IKModifier3D` | 4.6+ |
| `TileMap` (legacy) | `TileMapLayer` nodes | 4.3+ |
| `ParallaxBackground` / `ParallaxLayer` | Manual `Node2D` parallax or `Camera2D` offset | 4.5+ |
| `PackedDataContainer` | `Array` / `Dictionary` / `Resource` | 4.5+ |
| `EditorScript.get_scene()` | `EditorInterface.get_edited_scene_root()` | — |
| `NavigationServer.map_force_update(rid)` | Automatic — no call needed | — |
| C++ `OAHashMap` | `AHashMap` | — |
| C++ `LocalVector<T, true>` | `LocalVector<T>` + `resize_uninitialized(n)` | — |

---

## Beta 2 Known Issues (Inherited Baseline)

These were live in 4.6.0-beta2 and may still surface in 4.7-dev3 builds:

- **Motion vectors broken in Compatibility renderer** — geometry can render mostly black. Workaround: use Forward+ or Mobile, or disable motion vectors.
- Beta 2 already fixed several Beta 1 regressions (Tool button, shader editor sizing, FileSystem UID search, TextEdit auto-scroll, X11 input delay).

For the full list, see `00-version-and-migration.md` § "BETA 2 SPECIFIC FIXES".

---

## Workflow Recipes

### Starting a New Feature

1. Determine the surface area (UI? gameplay? rendering?).
2. Open the matching numbered file from the routing table above.
3. If migrating or porting older code, pre-read `00-version-and-migration.md`.
4. Apply the "Features You Should Reach For (4.6+)" list when relevant.

### Implementing a Card Animation (project-relevant)

1. Use `Transform Offset for Controls` (4.7-dev3) so animations don't break container layout — see `06-ui-and-controls.md`.
2. Drive the animation via `AnimationPlayer` or `Tween` — patterns in `05-animation-physics-3d.md` (despite the name, 2D animation idioms are covered).
3. For mental-shield equation flow effects, consider `Polygon2D` (now with a fast path) or shader-driven approaches in `04-2d-graphics-rendering.md`.

### Fixing a Performance Regression

1. Profile with Tracy/Perfetto/Instruments (Tracy is on-demand by default in 4.7-dev3).
2. Code-level wins: `reserve()`, typed arrays, cached node references — see `01-gdscript-modern-patterns.md`.
3. System-level wins: object pooling, group iteration — see `03-core-systems.md`.
4. Rendering wins: 2D batching, visibility culling — see `04-2d-graphics-rendering.md` and `07-platform-performance.md`.

### Migrating a Pre-4.5 Snippet

1. Replace every `String(<math-type>)` with `str(...)`.
2. Replace `abstract func` with `@abstract`.
3. Replace `obj.script` reads/writes with `get_script()` / `set_script()`.
4. Verify .NET target framework if C#.
5. Verify platform export settings meet new floors (Windows 10, Android API 24, .NET 8.0).
6. Replace `SkeletonIK` (3D) and any remaining `TileMap` references.
7. Run the full migration checklist in `00-version-and-migration.md`.

---

## Version Detection at Runtime

```gdscript
func _ready() -> void:
    var v := Engine.get_version_info()
    print("Godot %d.%d.%d (%s)" % [v.major, v.minor, v.patch, v.status])

    # Prefer feature detection over version comparison:
    if ClassDB.class_exists("IKModifier3D"):
        # 4.6+
        pass

    # For 4.7-dev3 Control transform offset, check the property exists:
    var probe := Control.new()
    if "transform_offset" in probe:  # placeholder name — verify in 4.7 docs
        pass
    probe.free()
```

> Feature detection (`ClassDB.class_exists(...)`, property lookup) is more robust than `Engine.get_version_info()` comparisons because dev/beta builds can land features mid-cycle.

---

## Cross-Reference (Where Detailed Discussion Lives)

| Concept | Primary file | Secondary |
|---------|--------------|-----------|
| Abstract classes | `01-gdscript-modern-patterns.md` | `00-version-and-migration.md`, `02-scene-architecture.md` |
| Signals (basics → architecture → perf) | `01-...` → `02-...` → `07-...` | — |
| Object pooling | `03-core-systems.md` | `07-platform-performance.md`, `01-...` |
| TileMapLayer | `04-2d-graphics-rendering.md` | `00-version-and-migration.md` |
| IKModifier3D | `05-animation-physics-3d.md` | `00-version-and-migration.md` |
| Jolt vs GodotPhysics | `05-animation-physics-3d.md` | `07-platform-performance.md` |
| Control layout containers | `06-ui-and-controls.md` | `08-quick-reference.md` |
| `reserve()` and StringName | `01-gdscript-modern-patterns.md` | `07-platform-performance.md` |
| Profiling (Tracy/Perfetto/Instruments) | `07-platform-performance.md` | `00-version-and-migration.md` |

---

## External References

- **Official Migration Guide**: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.html
- **Interactive Changelog**: https://godotengine.github.io/godot-interactive-changelog
- **Class Reference**: https://docs.godotengine.org/en/stable/classes/
- **Performance Guide**: https://docs.godotengine.org/en/stable/tutorials/performance/

---

## Document Metadata

- **Document Version**: 1.0
- **Combines**: `README.md` (navigation, 4.6.0-beta2 baseline) + `00-version-and-migration.md` (extended through 4.7-dev3)
- **Maintenance**: Update this file whenever (a) a new guideline file is added, (b) a new minor/dev Godot version lands with breaking changes, or (c) the routing tables become inaccurate.
- **AI Optimization Level**: High — designed for quick routing and inline answers to the most common version questions.
