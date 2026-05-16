# Godot AI Guidelines — Claude Code Entry Point

**Target Engine**: Godot 4.7-beta2 (built atop 4.6.0-stable baseline; 4.7 cycle has now entered beta — API surface is frozen)
**Document Purpose**: Automatically loaded context for Claude Code when working in this directory. Provides a navigation map to the detailed guideline files plus the highest-leverage version-specific facts inline.
**Last Updated**: 2026-05-16

> This file is the **entry point**. For depth on any topic, follow the links into the numbered guideline files. The `README.md` in this directory is a human-readable navigation index; this `CLAUDE.md` is the AI-optimized counterpart.

---

## Maintenance Rule — Keep These Guidelines Generic

**This directory is portable across projects.** Every file in `godot-ai-guidelines/` must remain generic Godot reference material — applicable to any genre, art style, or game type. Do **not** add narrative, character names, mechanics, screen mockups, or feature lists that are tied to one specific project.

When tempted to add a project-specific example:

- ❌ Don't write: "Useful for *Prime Radiant* glow effects" / "Card fan spread in hand" / "Mental shield pierce animation".
- ✅ Do write: "Useful for HDR-aware bloom" / "Fan/spread arrangements" / "Attention-getting effects (shake, pulse, glow)".

If a concrete example helps a reader understand a feature, choose one that could appear in any game: an `inventory` slot, a `menu button`, a `tile`, an `enemy`, a `pickup`. Avoid genre-bound vocabulary (cards, suits, decks, hands, tricks, spells, dice, etc.) unless the Godot feature itself is genre-specific (it never is).

**When a new Godot version lands or a new pattern is added:** scan the diff for project-narrative terms and genre-bound examples before committing. Run something like:

```bash
grep -niE 'whisper|radiant|mentalic|foundation|seldon|asimov|<your-project-terms>' *.md
grep -niE '\bcard[s]?\b|\bdeal(ing)?\b|\bsuit\b|<your-mechanics>' *.md
```

…to surface anything that crept in. This file (`CLAUDE.md`) is part of the rule's scope — it must remain generic too.

---

## How to Use These Guidelines

When you (Claude) start a task in a Godot project, decide which numbered guideline file is most relevant based on the task type, then read that file before generating code. The matrix below is the routing table.

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
| [00-version-and-migration.md](00-version-and-migration.md) | Version timeline, breaking changes, migration checklist | 4.5 → 4.6 → **4.7-beta2** |
| [01-gdscript-modern-patterns.md](01-gdscript-modern-patterns.md) | Language idioms, typing, abstract classes, `reserve()` | 4.7-beta2 |
| [02-scene-architecture.md](02-scene-architecture.md) | Scene composition, signals, autoloads, resources | 4.7-beta2 |
| [03-core-systems.md](03-core-systems.md) | Memory, pooling, groups, SceneTree, globals | 4.7-beta2 |
| [04-2d-graphics-rendering.md](04-2d-graphics-rendering.md) | Sprites, TileMapLayer, Camera2D, batching | 4.7-beta2 |
| [05-animation-physics-3d.md](05-animation-physics-3d.md) | IKModifier3D, AnimationTree, Jolt Physics | 4.7-beta2 |
| [06-ui-and-controls.md](06-ui-and-controls.md) | Control nodes, containers, theming, FileDialog | 4.7-beta2 |
| [07-platform-performance.md](07-platform-performance.md) | Platforms, mobile/web, profiling, optimization | 4.7-beta2 |
| [08-quick-reference.md](08-quick-reference.md) | Pattern templates, decision trees, gotchas | 4.7-beta2 |

---

## Critical Facts (Must-Know Before Generating Code)

These are the highest-leverage facts. Memorize them; everything else is in the detailed files.

### Breaking Changes That Bite Immediately (4.5+ baseline)

1. **String conversion of math types is gone.** `String(vec)` is a compile error. Use `str(vec)`, `"%v" % vec`, or `var_to_str(vec)`.
   - Affected: `Vector2/3/4(i)`, `Transform2D/3D`, `Basis`, `Projection`, `Callable`, `Signal`, `IPAddress`, `NodePath`.

2. **Abstract uses an annotation, not a keyword.** `abstract func foo()` → `@abstract\nfunc foo()`. Same for classes.

3. **Object script access uses getters/setters.** `obj.script` → `obj.get_script()` / `obj.set_script(s)`.

4. **Glow renders before tonemapping.** Default blend mode is now "screen" (was additive). Projects with significant glow effects must re-tune.

5. **Quaternion in Variant defaults to identity** `(0, 0, 0, 1)`. Don't rely on uninitialized values.

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

### New in the 4.7 Cycle (dev3 → beta2)

The 4.7 cycle has now entered **beta** — the API surface is frozen and remaining work is regression fixing. As of beta1, **1,265 fixes from 309 contributors** have landed since 4.6-stable.

#### Headline features (carry from dev3, still current)

1. **Transform Offset for Controls** (GH-87081) — Translate, rotate, or scale a `Control` independently without disturbing container layout. Useful for any hover, tilt, or lift effect on Controls inside containers.
2. **PopupMenu Search Bar** (GH-114236) — Visible search field for long popup menus. ⚠ Beta2 known issue: item tooltips don't render while the search bar is enabled (GH-119407).
3. **RichTextLabel** — Triple-click paragraph selection (GH-116868); improved table rendering (GH-116277); `em`-unit `[img]` scaling (GH-112617, **breaking**) since dev5.
4. **AtlasTexture tiling in `TextureRect`** (GH-113808).
5. **Animation system optimization** (GH-116394, GH-117277) — `Animation`, `AnimationLibrary`, `AnimationMixer`, `AnimationPlayer`, `AnimationTree`.
6. **Signal thread safety** (GH-117511).
7. **`Polygon2D` fast path** (GH-117334).
8. **HDR output** — Apple (GH-106814) and Linux/Wayland (GH-102987) since dev3; **Windows** added in beta1 (GH-94496). Beta2 added per-surface HDR detection (GH-119091) and fixed Wayland HDR support reporting (GH-117913).
9. **Android Picture-in-Picture** (GH-114505); embedded game window is now moveable/resizable (GH-118417 in dev5).
10. **Device IDs in input events** (GH-116274) — useful for local multiplayer with multiple keyboards/mice.
11. **Tracy on-demand by default** (GH-117583).
12. **Editor additions** — 3D vertex snapping with B-key (GH-117235) extended to subgizmo points (GH-117922) in dev5; MeshLibrary editor (GH-117376); Scene Painter (GH-109360); autocomplete-no-longer-eats-words (GH-117464); remote inspector improvements (GH-115738, GH-117357).
13. **`wasm64` web builds** (GH-102378).

#### Added in dev4 (April 9, 2026 — 188 fixes / 88 contributors)

14. **Nearest-neighbor 3D viewport scaling** (GH-79731) — Crisp pixel-art and low-res 3D without performance compromise.
15. **`custom_maximum_size` on Controls** (GH-116640) — Symmetric with `custom_minimum_size`.
16. **Improved Tree drag-and-drop** (GH-112993) — Cursor x-position picks parent depth (vector-design-software style).
17. **3D Ruler with vector components** (GH-106785) — Per-axis distance display.
18. **GDExtension reload from editor** (GH-118063); GDExtension viewer in project settings.
19. **Particles** — Angular velocity direction corrected (GH-117861, ⚠ **breaking**); timescale=0 no longer drifts (GH-109911).
20. **Windows** — OneCore TTS (GH-116349); emoji picker integration (GH-116351).

#### Added in dev5 (April 17, 2026 — 135 fixes / 71 contributors)

21. **Asset Library new API** (GH-112992) — Improved item display, metadata, single-click version switching.
22. **Per-platform export-template download** (GH-117072) — No more bulk-only.
23. **`AreaLight3D`** (GH-108219) — Real-time rectangular area lights.
24. **Inline shader previews** (GH-117726) — In-editor visual feedback while editing shaders.
25. **Audio bus UI revamp** (GH-118266).
26. **Wayland touch support** (GH-113886).
27. **Android splash screen customization** (GH-114671).

#### Added in beta1 (April 24, 2026 — 85 fixes / 47 contributors; cumulative: 1,265 since 4.6-stable)

28. **`AwaitTweener`** (GH-79712) — Tweens can `await` specific signals.
29. **VirtualJoystick control** (GH-110933) — FIXED / DYNAMIC / FOLLOWING modes for touch input.
30. **2D one-way collision in all directions** (GH-104736) — Previously "up" only.
31. **Vulkan raytracing groundwork** (GH-99119); **`DrawableTexture`** for direct drawing (GH-105701).
32. **Accessibility landmark roles** (GH-114449); **conic gradient** in `GradientTexture2D` (GH-115394).
33. **Animation track group collapse** (GH-113479) and Path3D collider snapping (GH-102085).
34. **Joypad motion sensors** (GH-111679); SDL3 joystick on iOS (GH-114316); long-press haptic feedback (GH-117198); `DisplayServer` device-orientation signal (GH-115434).
35. **Windows HDR via WinRT** (GH-94496); per-pass environment UBOs (GH-115177); Metal acyclic render graph (GH-114484); Vulkan SDK 1.4.335.0 (GH-114075).
36. ⚠ **Multiple breaking changes** — see [00-version-and-migration.md § 4.7 BETA 1 BREAKING CHANGES](00-version-and-migration.md#47-beta-1-breaking-changes). Audit: `RichTextLabel` `[img]` sizing, particle angular velocity, Android `.obb` removal, shader preprocessor grammar, Jolt soft body / area detection, GDExtension `ConnectFlags` as bitfield.

#### Added in beta2 (May 11, 2026 — 153 fixes / 74 contributors; 100+ regressions resolved)

37. **3D Pilot Mode undo/redo** (GH-119349) — Camera moves are now undoable.
38. **`ResourceLoader::load_threaded_request()` race condition fixed** (GH-118824).
39. **Material inheritance for internal children** (GH-115637) — Built-in node internals now use parent's material.
40. **Android Gradle build de-experimentalized** (GH-119172) — No longer carries the "experimental" warning.
41. **GDExtension API tidy** (GH-119254) — `object_cast_to` and `classdb_get_class_tag` deprecated in favor of `is_class` casts.
42. **OpenXR default action map updated** (GH-118975).
43. **Animation signal parameter rename** (GH-119316) — Audit any callbacks that relied on a parameter literally named `name`.

---

## Compatibility Matrix (Version → Feature)

A condensed version of the table in `00-version-and-migration.md`. Use this for quick "is X available in version Y?" lookups.

| Feature | 4.5.0 | 4.6.0 | 4.7-beta2 | Landed |
|---------|:-----:|:-----:|:---------:|:------:|
| Abstract classes (`@abstract`) | ✅ | ✅ | ✅ | 4.5 |
| Variadic functions | ✅ | ✅ | ✅ | 4.5 |
| Const Array/Dict constructors | ✅ | ✅ | ✅ | 4.5 |
| String implicit conversion of math types | ❌ | ❌ | ❌ | removed 4.5 |
| `Array/Dictionary/String.reserve()` | ❌ | ✅ | ✅ | 4.6 |
| `IKModifier3D` (+ 8 subclasses) | ❌ | ✅ | ✅ | 4.6 |
| Jolt Physics default for 3D | ❌ | ✅ | ✅ | 4.6 |
| LibGodot (engine as library) | ❌ | ✅ | ✅ | 4.6 |
| D3D12 default on Windows | ❌ | ✅ | ✅ | 4.6 |
| 2D batching 1.1–7× GPU gains | ❌ | ✅ | ✅ | 4.6 |
| Tracy / Perfetto / Instruments profilers | ❌ | ✅ | ✅ | 4.6 |
| Transform Offset for Controls | ❌ | ❌ | ✅ | dev3 |
| Animation system optimizations | ❌ | ❌ | ✅ | dev3 |
| `AnimationTree` thread safety | ❌ | ❌ | ✅ | dev3 |
| Signal thread safety | ❌ | ❌ | ✅ | dev3 |
| `Polygon2D` fast path | ❌ | ❌ | ✅ | dev3 |
| HDR on Apple platforms | ❌ | ❌ | ✅ | dev3 |
| HDR on Linux/Wayland | ❌ | ❌ | ✅ | dev3 |
| HDR on Windows | ❌ | ❌ | ✅ | beta1 |
| Android Picture-in-Picture | ❌ | ❌ | ✅ | dev3 |
| Device IDs in input events | ❌ | ❌ | ✅ | dev3 |
| `wasm64` web builds | ❌ | ❌ | ✅ | dev3 |
| PopupMenu search bar | ❌ | ❌ | ✅ | dev3 |
| `AtlasTexture` tiling in `TextureRect` | ❌ | ❌ | ✅ | dev3 |
| Tracy on-demand default | ❌ | ❌ | ✅ | dev3 |
| Nearest-neighbor 3D scaling | ❌ | ❌ | ✅ | dev4 |
| Control `custom_maximum_size` | ❌ | ❌ | ✅ | dev4 |
| 3D Ruler vector components | ❌ | ❌ | ✅ | dev4 |
| GDExtension hot-reload | ❌ | ❌ | ✅ | dev4 |
| Asset Library new API | ❌ | ❌ | ✅ | dev5 |
| Per-platform export-template download | ❌ | ❌ | ✅ | dev5 |
| `AreaLight3D` rectangular area lights | ❌ | ❌ | ✅ | dev5 |
| Inline shader previews | ❌ | ❌ | ✅ | dev5 |
| Audio bus UI revamp | ❌ | ❌ | ✅ | dev5 |
| Wayland touch support | ❌ | ❌ | ✅ | dev5 |
| RichTextLabel `em`-unit `[img]` (⚠ breaking) | ❌ | ❌ | ✅ | dev5 |
| `AwaitTweener` | ❌ | ❌ | ✅ | beta1 |
| VirtualJoystick control | ❌ | ❌ | ✅ | beta1 |
| 2D one-way collision (all directions) | ❌ | ❌ | ✅ | beta1 |
| Vulkan raytracing groundwork | ❌ | ❌ | ✅ | beta1 |
| `DrawableTexture` | ❌ | ❌ | ✅ | beta1 |
| Accessibility landmark roles | ❌ | ❌ | ✅ | beta1 |
| Conic gradient in `GradientTexture2D` | ❌ | ❌ | ✅ | beta1 |
| Joypad motion sensors | ❌ | ❌ | ✅ | beta1 |
| 3D Pilot Mode undo/redo | ❌ | ❌ | ✅ | beta2 |
| Per-surface HDR detection | ❌ | ❌ | ✅ | beta2 |
| Android Gradle build (stable) | ❌ | ❌ | ✅ | beta2 |

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

## Known Issues — 4.7-beta2 (Current Cycle)

- **macOS XR crash on editor exit** (GH-119146) — Editor crashes when exiting an XR project on macOS. Workaround: don't run XR scenes from the editor on macOS until fixed.
- **PopupMenu tooltips suppressed when search bar enabled** (GH-119407) — When a `PopupMenu` has its 4.7 search bar enabled, individual item tooltips fail to display. Workaround: embed the hint in the menu item label, or disable the search bar for tooltip-critical menus.

Inherited from beta1 (verify before relying on workarounds — beta2 fixed 100+ regressions):

- Asset Store API: cached-URL load failure (GH-118755)
- Vulkan renderer: system hang on project open in specific configurations (GH-116414)
- Android: VisualShader crash with `vertex_lighting` enabled (GH-116990)

Inherited from the 4.6 baseline (may still surface in 4.7 builds):

- **Motion vectors broken in Compatibility renderer** — geometry can render mostly black. Workaround: use Forward+ or Mobile, or disable motion vectors.

For the full list including beta1 breaking changes, see `00-version-and-migration.md` § "4.7-BETA 2 KNOWN ISSUES" and § "4.7 BETA 1 BREAKING CHANGES".

---

## Workflow Recipes (Generic)

### Starting a New Feature

1. Determine the surface area (UI? gameplay? rendering?).
2. Open the matching numbered file from the routing table above.
3. If migrating or porting older code, pre-read `00-version-and-migration.md`.
4. Apply the "Features You Should Reach For (4.6+)" list when relevant.

### Animating Controls Inside Containers (4.7+)

1. Use `transform_offset` properties so animations don't disturb container layout — see `06-ui-and-controls.md` § Transform Offset for Controls.
2. Drive the animation via `AnimationPlayer` or `Tween` — patterns in `05-animation-physics-3d.md` (despite the name, 2D animation idioms are covered).
3. For procedural decorative effects, consider `Polygon2D` (now with a fast path in 4.7) or shader-driven approaches in `04-2d-graphics-rendering.md`.

### Fixing a Performance Regression

1. Profile with Tracy/Perfetto/Instruments (Tracy is on-demand by default in 4.7).
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

    # For the 4.7 Control transform offset, check the property exists:
    var probe := Control.new()
    if "transform_offset" in probe:  # placeholder name — verify in 4.7 docs
        pass
    probe.free()

    # For 4.7-dev5+ rectangular area lights:
    if ClassDB.class_exists("AreaLight3D"):
        # 4.7-dev5+
        pass

    # For 4.7-beta1+ awaitable tweens:
    if ClassDB.class_exists("AwaitTweener"):
        # 4.7-beta1+
        pass
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

- **Document Version**: 1.2
- **Combines**: `README.md` (navigation) + `00-version-and-migration.md` (extended through 4.7-beta2)
- **Scope Rule**: Generic Godot reference only — no project-specific narrative, mechanics, or examples (see "Maintenance Rule" at top).
- **Maintenance**: Update this file whenever (a) a new guideline file is added, (b) a new minor/dev Godot version lands with breaking changes, or (c) the routing tables become inaccurate.
- **Coverage**: 4.5.0 → 4.6.0 → 4.7-dev1..dev5 → 4.7-beta1 → **4.7-beta2 (target)**.
- **AI Optimization Level**: High — designed for quick routing and inline answers to the most common version questions.
