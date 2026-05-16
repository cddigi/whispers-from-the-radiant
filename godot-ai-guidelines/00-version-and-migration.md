# Godot Version Information and Migration Guide

**Target Version**: Godot 4.7-beta2
**Previous Baseline**: Godot 4.5.0 → 4.6.0 → 4.7-dev1..dev5 → 4.7-beta1 → 4.7-beta2
**Document Purpose**: AI-optimized reference for version-specific changes and migration patterns

---

## Version Timeline

### Godot 4.5.0 (Baseline)
- Major GDScript type system enhancements
- TileMapLayer architecture (replaced legacy TileMap)
- Abstract classes and variadic functions
- Jolt Physics engine integration
- visionOS support
- SVG textures and UI improvements

### Godot 4.5.1 (Patch Release)
- Bug fixes for animation, physics, rendering
- Editor improvements and stability fixes
- Platform-specific fixes (Android, iOS, macOS)
- No breaking changes

### Godot 4.6.0 (Stable)
- **LibGodot**: Engine as standalone library via GodotInstance class
- **Modern Theme**: New default editor theme (formerly "Godot Minimal Theme")
- **IKModifier3D System**: 8 new IK modifier classes (CCDIK3D, FABRIK3D, JacobianIK3D, etc.)
- **Jolt Physics**: Production-ready status, default for new 3D projects
- **Enhanced Rendering**:
  - Glow now renders before tonemapping with improved blend modes
  - AgX tonemapper: white balance, contrast, HDR support
  - Screen space reflections: 2x quality at half performance cost
  - 2D renderer batching: 1.1x to 7x GPU performance gains
  - SSAO in Compatibility/GLES3 renderer
- **Editor Dock Refactor**: New EditorDock class with flexible layouts
- **Array Inspector Redesign**: Reduced visual clutter
- **XR**: OpenXR 1.1 with spatial entities extensions
- **Platform Updates**:
  - Windows: Direct3D 12 as default RenderingDevice driver
  - Linux/Wayland: Game embedding parity with X11
  - Android: Storage Access Framework support
  - iOS: Auto-enable minimum performance tier for Forward+/Mobile
- **Performance**: Decreased RAM use, faster array sorting, accelerated Object casts
- **Tracing Profilers**: Tracy, Perfetto, Apple Instruments integration

### Godot 4.7-dev3
- **Transform Offset for Controls** (GH-87081): Translate, rotate, or scale Control nodes independently without affecting container layout
- **Animation System Optimized** (GH-116394, GH-117277): Optimized Animation Resource/Library/Mixer/Player and AnimationTree internals with improved thread group safety
- **Signal Thread Safety** (GH-117511): Enhanced thread-safety of Object signals
- **Polygon2D Fast Path** (GH-117334): Rendering optimization for Polygon2D nodes
- **CSG Automatic Smoothing** (GH-116749): Automatic smoothing for CSG nodes
- **PopupMenu Search Bar** (GH-114236): Visible search for long popup menus
- **RichTextLabel Improvements** (GH-116868, GH-116277): Triple-click paragraph selection and enhanced table rendering
- **AtlasTexture Tiling in TextureRect** (GH-113808): Support for tiling atlas textures
- **HDR Output on Apple Platforms** (GH-106814) and **Linux/Wayland** (GH-102987): Full EDR display support
- **Android Picture-in-Picture** (GH-114505): `DisplayServer.pip_mode_enter()` with auto-enter
- **Android Joypad Unfocus** (GH-115119): Project setting to ignore joypad when unfocused
- **Device IDs for Input** (GH-116274): Keyboard/mouse events now include device identifiers
- **wasm64 Web Builds** (GH-102378): Extended WebAssembly compatibility
- **Tracy On-Demand** (GH-117583): `TRACY_ON_DEMAND` by default for lighter profiling overhead
- **Editor**: 3D vertex snapping (GH-117235), MeshLibrary editor (GH-117376), Scene Painter (GH-109360), autocomplete fix (GH-117464), remote inspector improvements (GH-115738, GH-117357)
- **Statistics**: 297 fixes from 113 contributors (dev2: 248 / 105)

### Godot 4.7-dev4 (April 9, 2026)
- **Nearest-Neighbor 3D Viewport Scaling** (GH-79731): Three-year refinement — crisp pixel-art and low-resolution 3D rendering without performance compromise
- **Control `custom_maximum_size`** (GH-116640): Symmetric counterpart to `custom_minimum_size` for tighter layout control
- **Improved Tree Drag-and-Drop** (GH-112993): Vertical indicator shows the potential parent chain; cursor x-position selects which ancestor to parent into (mirrors vector-design-software behavior)
- **Array Property Inspector** (GH-118008): Increased available horizontal space (corrected default offset)
- **Visual Profiler Tree Folding** (GH-118120)
- **Type Filters in Create Dialog** (GH-111518)
- **Renderer Selector Hideable** (GH-117754): Via editor setting
- **Right-Click on Unfocused Scene Tabs** (GH-112919)
- **TileSet Editor Proxy Objects Rework** (GH-117574)
- **3D Ruler Tool** (GH-106785): Vector component display added
- **Particles — Angular Velocity Fix** (GH-117861): ⚠ **Breaking change** — behavior now aligns with documentation
- **Particles — Timescale Zero Fix** (GH-109911): Particles no longer drift when timescale equals 0
- **GDExtension Project Settings Visibility** (GH-118063) and **Extension Reload** from editor
- **GDScript LSP Server-Side String Insertions** (GH-117710)
- **Android — Java Interface Implementation from GDScript** (GH-115498)
- **Windows — OneCore TTS via C++/WinRT** (GH-116349); **Emoji Picker Integration** (GH-116351)
- **Statistics**: 188 fixes from 88 contributors

### Godot 4.7-dev5 (April 17, 2026)
- **Asset Library — New API** (GH-112992): Ported asset store to new API with improved item display, metadata visibility, changelog access, and single-click version switching
- **Export Template Dialog Redesign** (GH-117072): Individual platform downloads instead of bulk-only distribution
- **Android Embedded Game Window** (GH-118417): Moveable and resizable
- **Remote/Local SceneTreeDock Buttons** (GH-118192): Improved appearance
- **RichTextLabel `em`-Unit Image Scaling** (GH-112617): `[img]` tags scale relative to font size for responsive rich text
- **AreaLight3D — Rectangular Area Light Source** (GH-108219): Real-time 3D lighting
- **Raytracing Pipelines Refactor** (GH-118044)
- **Inline Shader Previews** (GH-117726): Text-editor previews reduce guesswork during shader development
- **Vertex Snap for Subgizmo Points** (GH-117922)
- **Audio Bus UI Revamp** (GH-118266)
- **Wayland Touch Support** (GH-113886)
- **Embedded Window Options** (GH-118079): Three-dot menu and HDR information
- **Android Splash Screen Customization** (GH-114671)
- **GDExtension — `Variant::get_type_by_name`** (GH-117160): New interface method
- **Statistics**: 135 fixes from 71 contributors

### Godot 4.7-beta1 (April 24, 2026)
First beta of the 4.7 cycle — API surface is now frozen; remaining work is regression fixes.

**Cumulative statistics since 4.6-stable**: 1,265 fixes from 309 contributors. Beta1 itself added 85 fixes from 47 contributors.

**Notable additions beyond dev5**:
- **Vulkan Raytracing Groundwork** (GH-99119) — foundation for future hardware RT features
- **DrawableTexture** (GH-105701) — direct texture drawing API
- **VirtualJoystick** (GH-110933) — touchscreen joystick control with FIXED / DYNAMIC / FOLLOWING modes
- **2D One-Way Collision in All Directions** (GH-104736) — no longer limited to "up" only
- **AwaitTweener** (GH-79712) — Tweens can `await` specific signals
- **Animation Track Group Collapse** (GH-113479)
- **Accessibility Landmark Region Roles** (GH-114449)
- **Conic Gradient Support in `GradientTexture2D`** (GH-115394)
- **Path3D Collider Snapping** (GH-102085) — snap path creation to collision surfaces
- **Joypad Motion Sensor Support** (GH-111679); **SDL3 Joystick on iOS** (GH-114316); **Haptic Long-Press Right-Click** (GH-117198)
- **DisplayServer Device-Orientation Change Signal** (GH-115434)
- **Per-Pass Unique Environment Uniform Buffers** (GH-115177); **Metal Dynamic Uniforms + Acyclic Render Graph** (GH-114484); **Vulkan SDK 1.4.335.0** (GH-114075)
- **Clearcoat Improvements** (GH-111464); **Particle 3D Scale/Rotation in process** (GH-112447)
- **Windows HDR Output via WinRT** (GH-94496) — joins macOS (GH-106814) and Linux/Wayland (GH-102987)
- **Android — Native File Picker** (GH-115257); **Gradle Platform Plugin Dependencies** (GH-115888); **Portrait Mode Script Editor** (GH-117109)
- **Editor — View3DController** (GH-115957), **Script List Navigation** (GH-112796), **OnReady Variable Parent-Type Awareness** (GH-115158), **"Follow Selection" via double-Center** (GH-99499), **Script Documentation Tooltip Shortcut** (GH-115767), **Tree size/filter optimization** (GH-110759)
- **GDScript Non-Exported Enum Metadata Retention in Remote Play** (GH-115705)
- **Build — Compilation Time Reduction** (GH-111218); **PCKPacker Buffer File Addition** (GH-108830)

**Known issues introduced in beta1**:
- Asset Store API fails to load with incorrect cached URL (GH-118755)
- Vulkan renderer system hang on project open (GH-116414)
- Android: VisualShader crash with `vertex_lighting` enabled (GH-116990)

> ⚠ Several **breaking changes** land in beta1 — see [§ 4.7 BETA 1 BREAKING CHANGES](#47-beta-1-breaking-changes) below.

### Godot 4.7-beta2 (May 11, 2026) — **Current Target**
Regression-focused release; 153 fixes from 74 contributors, 100+ regressions resolved.

- **3D — Pilot Mode Undo/Redo** (GH-119349): Camera movement in Pilot Mode is now undoable
- **Animation — Signal Parameter Renaming** (GH-119316): Various signal parameters previously called `name` were renamed (audit any `connect()` callsites that relied on parameter ordering — unlikely but possible)
- **Core — ResourceLoader Race Condition Fix** (GH-118824): `ResourceLoader::load_threaded_request()` race resolved
- **Editor — HDR Screenshot Fix** (GH-119013): Editor screenshots now work correctly with HDR enabled
- **Editor — "Clear Output" Button Positioning** (GH-118954): Improved placement
- **Export — Android Gradle Build De-Experimentalized** (GH-119172): Warning removed; feature is now considered stable
- **GDExtension — API Deprecation** (GH-119254): `object_cast_to` and `classdb_get_class_tag` deprecated in favor of `is_class` casts
- **GUI — Material Inheritance for Internal Children** (GH-115637): Built-in node internal children now use their parent's material
- **Rendering — Wayland HDR Behavior** (GH-117913): Fixed `window_is_hdr_output_supported`; warnings adjusted
- **Rendering — Surface HDR Detection** (GH-119091): Per-surface HDR-support checking implemented
- **XR — OpenXR Default Action Map Update** (GH-118975)
- **Documentation — HDR Output Tutorial** (GH-118692): Added tutorial links and platform-specific notes

**Known issues in beta2**:
- macOS XR crash on editor exit from XR projects (GH-119146)
- GUI tooltip bug — popup menu tooltips fail to display when a search bar is enabled (GH-119407)

---

## CRITICAL BREAKING CHANGES (4.5.0 → 4.6.0)

### Glow Rendering Changes (BREAKING)

**Impact**: Medium - Affects projects using glow effects

```gdscript
# CHANGE: Glow rendering now occurs BEFORE tonemapping
# Default glow blend mode changed to "screen" (was additive)
# Default glow levels have changed
# Softlight glow blending behavior has changed

# Action Required:
# 1. Open Project Settings → Environment → Glow
# 2. Review and adjust glow blend mode if needed
# 3. Test HDR 2D viewports - softlight glow now appears as it did with HDR 2D

# Projects with significant glow effects should verify visual output
```

### Quaternion Initialization (BREAKING)

**Impact**: Low - Mostly affects GDExtension/C++ code

```gdscript
# CHANGE: Quaternion now correctly initializes with identity under Variant
# Before: Uninitialized Quaternion in Variant could have undefined values
# After: Quaternion in Variant defaults to identity (0, 0, 0, 1)

# If your code relied on uninitialized quaternion behavior, update it:
var q: Quaternion = Quaternion.IDENTITY  # Explicit is always better
```

### Project Upgrade Tool for 3D Assets

**Impact**: Medium - Projects with 3D assets should run upgrade tool

```bash
# When upgrading 4.5 → 4.6 projects with 3D assets:
# Use the project upgrade tool to ensure proper migration
# Editor → Project → Tools → Upgrade Project

# The upgrade tool handles:
# - 3D asset reimport with new settings
# - IKModifier3D migration from SkeletonIK
# - Physics configuration updates
```

### String Conversion Changes (BREAKING)

**Impact**: High - Affects all code using math types

```gdscript
# BEFORE (4.4 and earlier):
var vec = Vector2(10, 20)
var text = String(vec)  # Implicit conversion worked
var path_str = String(my_node_path)  # Worked

# AFTER (4.5+): COMPILE ERROR
var vec = Vector2(10, 20)
var text = String(vec)  # ERROR: No implicit conversion

# CORRECT MIGRATION:
var text = str(vec)  # Use str() function
# OR
var text = "%v" % vec  # Use format string
# OR
var text = var_to_str(vec)  # Explicit variant conversion
```

**Affected Types**:
- `Vector2`, `Vector3`, `Vector4`, `Vector2i`, `Vector3i`, `Vector4i`
- `Transform2D`, `Transform3D`, `Basis`, `Projection`
- `Callable`, `Signal`
- `IPAddress`, `NodePath`

**Migration Pattern**:
```gdscript
# Search and replace pattern:
# Old: String(some_vector)
# New: str(some_vector)
# Old: String(some_callable)
# New: str(some_callable)
```

### Object Script Access (BREAKING)

**Impact**: Low - Mostly affects internal code

```gdscript
# BEFORE:
var script_ref = my_object.script  # Direct member access

# AFTER:
var script_ref = my_object.get_script()  # Use getter
my_object.set_script(new_script)  # Use setter
```

### LocalVector Template Changes (C++ GDExtension)

**Impact**: Medium for GDExtension developers

```cpp
// BEFORE:
LocalVector<int, true> my_vector;  // force_trivial parameter

// AFTER:
LocalVector<int> my_vector;  // Parameter removed
my_vector.resize_uninitialized(100);  // Use new method for uninitialized resize
```

### HashMap/OAHashMap Changes (C++)

**Impact**: Low - Mostly internal

```cpp
// BEFORE:
OAHashMap<String, int> my_map;

// AFTER:
AHashMap<String, int> my_map;  // Use AHashMap instead
```

---

## 4.7 BETA 1 BREAKING CHANGES

These behavior changes landed when 4.7 entered beta. Audit your project against each item before bumping to a 4.7 build.

### Animation — BlendSpace Point Naming (GH-110369)

**Impact**: Low — affects only code that drives `BlendSpace1D` / `BlendSpace2D` by index or display label.

```gdscript
# BlendSpace point name/index display and setting changed.
# If you set or read points by index, re-verify the indexing after upgrade.
# Prefer named-point lookups when available.
```

### Audio — Spectrum Analyzer & 3D Volume (GH-114355, GH-114080)

**Impact**: Medium — analyzer-driven visualizations and 3D positional audio levels may now read differently.

```gdscript
# Spectrum Analyzer jitter fixes (GH-114355): output is now smoother;
# any normalization tuned to the old jitter may need re-calibration.
#
# 3D volume calculation (GH-114080): per-listener attenuation curves can
# produce slightly different effective volumes. Re-mix scenes that relied
# on the old behavior.
```

### Core — Tag-Based `new` Overload Initialization (GH-112035)

**Impact**: Low — primarily affects C++ / GDExtension code.

```cpp
// `new` overloads now use a tag-based dispatch model.
// If you author GDExtensions that construct engine objects, follow the
// updated initialization tags exposed by the GDExtension interface.
```

### GDExtension — `Object::ConnectFlags` as Bitfield (GH-109892)

**Impact**: Medium — GDExtensions that pass connect flags through typed wrappers.

```cpp
// BEFORE: ConnectFlags exposed as an enum (single value).
// AFTER:  ConnectFlags is a bitfield (combineable via |).
// Update wrapper signatures from `ConnectFlags` to the bitfield type.
```

### GDScript — Constant Expression Evaluation (GH-113228)

**Impact**: Low — most code is unaffected; rare edge cases where constant folding produced a value the runtime would not.

```gdscript
# Constant expressions are now evaluated more strictly. If you relied on
# implicit lossy conversions at compile-time, add explicit conversions:
const MAX_HEALTH := 100        # was implicitly int even from `100.0`
const MAX_HEALTH := int(100.0) # explicit
```

### GUI — RichTextLabel Image Sizing (GH-112617)

**Impact**: Medium — visual regression for `[img]` tags with no explicit size.

```bbcode
[# `[img]` tags in RichTextLabel now scale relative to font size using
[# em units rather than raw pixels. Existing rich text with bare [img src]
[# may render at a different size.]

# Old:  [img]res://icon.png[/img]                      # raw pixel size
# New:  [img]res://icon.png[/img]                      # scales with font
# Lock to pixels: [img width=32]res://icon.png[/img]
```

### Input — Device IDs on Keyboard/Mouse Events (GH-116274)

**Impact**: Low — only affects code that compares `InputEvent` instances structurally.

```gdscript
# Keyboard and mouse InputEvent objects now carry a `device` field
# (previously joypad-only). Equality checks across captured replays must
# include or normalize the device id.
```

### Particles — Angular Velocity Direction (GH-117861)

**Impact**: High for particle-heavy scenes — sign / direction now matches the documentation.

```gdscript
# Particles' angular velocity behavior was corrected to align with docs.
# If existing particle resources rotate the wrong direction after upgrade,
# negate the angular velocity (or its randomness) on the affected
# ParticleProcessMaterial resources.
```

### Physics — Jolt Area / Soft Body Detection & SoftBody3D Tuning (GH-114198, GH-116041)

**Impact**: Medium — soft-body scenes and area sensors may behave differently with Jolt.

```gdscript
# Jolt now reports area / soft body overlaps more consistently. If your
# code assumed the old missed-detection cases, audit `body_entered` /
# `area_entered` handlers.
#
# SoftBody3D mass and stiffness ranges changed (GH-116041); re-tune
# values on existing soft bodies after upgrade.
```

### Platform — Android OBB Support Removed (GH-118283)

**Impact**: High for Android projects shipping legacy `.obb` expansion files.

```gdscript
# Android Opaque Binary Blob (.obb) expansion files are no longer
# supported. Migrate large assets to Play Asset Delivery (PAD) or
# sparse PCK distribution (see 4.5's sparse PCK support).
```

### Shaders — Preprocessor Condition Parsing (GH-117173)

**Impact**: Low — affects shaders with non-standard preprocessor expressions.

```glsl
// Shader preprocessor now restricts the grammar of `#if` conditions.
// Previously-tolerated odd whitespace or token sequences may now error.
// Normalize to: `#if defined(FOO)`, `#if X > 0`, `#elif !defined(BAR)`.
```

---

## DEPRECATED FEATURES (Marked for Future Removal)

### Classes to Avoid

```gdscript
# DEPRECATED in 4.5:
# - ParallaxBackground
# - ParallaxLayer
# REPLACEMENT: Use regular Node2D with custom parallax logic or Camera2D offset

# DEPRECATED in 4.5:
# - PackedDataContainer
# REPLACEMENT: Use Array, Dictionary, or custom Resource

# DEPRECATED (exact version unclear):
# - SkeletonIK (for 3D)
# REPLACEMENT: IKModifier3D (available in 4.6)
```

### Methods to Avoid

```gdscript
# DEPRECATED:
EditorScript.get_scene()
# USE INSTEAD:
EditorInterface.get_edited_scene_root()

# DEPRECATED:
NavigationServer.map_force_update(map_rid)
# REPLACEMENT: Automatic updates (no manual forcing needed)
```

### GDScript Keyword Changes

```gdscript
# BEFORE (4.4 and earlier):
abstract func my_method()  # abstract keyword

# AFTER (4.5+):
@abstract
func my_method()  # Use annotation instead
```

---

## PLATFORM REQUIREMENTS CHANGES

### Minimum Platform Versions

| Platform | Old Requirement | New Requirement (4.5+) | Impact |
|----------|----------------|------------------------|---------|
| Windows | Windows 7+ | Windows 10+ | **HIGH** |
| Android | API 21 (5.0) | API 24 (7.0) | Medium |
| .NET (C#) | .NET 6.0 | .NET 8.0 | **HIGH** |
| Android NDK | r23c | r28b | Medium |
| Linux | PowerPC 32-bit supported | PowerPC 32-bit **dropped** | Low |

### Platform-Specific Changes

**Windows**:
- Windows 7, 8, 8.1 **no longer supported**
- Minimum: Windows 10 (version 1809 or later recommended)

**Android**:
- Minimum SDK: API 24 (Android 7.0 Nougat)
- NDK r28b required for 16KB page support
- Sparse PCK support for large games

**C# (.NET)**:
```csharp
// Project file must target .NET 8.0:
<Project Sdk="Godot.NET.Sdk/4.6.0">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>
</Project>

// Android C# requires .NET 9.0 in some cases:
<TargetFramework Condition="'$(OS)' == 'Android'">net9.0</TargetFramework>
```

**iOS/macOS**:
- SwiftUI lifecycle (new project template)
- Liquid Glass icons (macOS 15+)
- Better embedded window support

**Web**:
- WebAssembly SIMD enabled by default
- SharedArrayBuffer improvements
- Better multithreading support

---

## NEW LANGUAGE FEATURES

### Abstract Classes and Methods (4.5+)

```gdscript
# Define abstract base class:
@abstract
class_name BaseEnemy extends CharacterBody2D

# Abstract methods must be implemented by derived classes:
@abstract
func take_damage(amount: float) -> void:
    pass  # No implementation in base class

@abstract
func get_reward_value() -> int:
    pass

# Concrete implementation:
class_name Goblin extends BaseEnemy

# MUST implement abstract methods:
func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        die()

func get_reward_value() -> int:
    return 10
```

**When to Use**:
- Defining interfaces/contracts in class hierarchies
- Ensuring derived classes implement specific methods
- Creating plugin architectures
- State machine base classes

### Variadic Functions (4.5+)

```gdscript
# Functions can accept variable arguments:
func log_message(level: String, message: String, extra_args: Array = []) -> void:
    var formatted = "[%s] %s" % [level, message]
    for arg in extra_args:
        formatted += " | %s" % str(arg)
    print(formatted)

# Usage:
log_message("INFO", "Player spawned", [player.name, player.position])
log_message("ERROR", "Connection failed")  # extra_args is empty

# Flexible parameter passing:
func create_entity(type: String, params: Dictionary = {}) -> Node:
    var entity = EntityScenes[type].instantiate()
    for key in params:
        if key in entity:
            entity.set(key, params[key])
    return entity
```

### Constant Constructors (4.5+)

```gdscript
# Arrays and Dictionaries can now be const:
const WEAPON_TYPES: Array[String] = ["sword", "bow", "staff"]
const DEFAULT_CONFIG: Dictionary = {
    "difficulty": 1,
    "sound_volume": 0.8,
    "fullscreen": false
}

# Use in class definitions:
class_name GameConfig

const DIFFICULTY_EASY: Dictionary = {"enemy_health": 0.5, "damage_multiplier": 0.75}
const DIFFICULTY_NORMAL: Dictionary = {"enemy_health": 1.0, "damage_multiplier": 1.0}
const DIFFICULTY_HARD: Dictionary = {"enemy_health": 1.5, "damage_multiplier": 1.25}
```

### Export Variant Type (4.5+)

```gdscript
# Allow any type in exports (use carefully):
@export var flexible_property: Variant

# Useful for plugin systems or dynamic content:
@export var custom_data: Variant  # Can be anything at runtime

# Better approach for known types:
@export var specific_number: int = 0
@export var specific_node: Node
```

### File Path Exports (4.5+)

```gdscript
# Export file paths WITHOUT UID conversion:
@export_file_path var config_path: String
@export_file_path("*.json") var data_file: String

# Regular export converts to UID:
@export var scene_reference: PackedScene  # Uses uid://...

# File path export keeps "res://" format:
# Useful for external tools or dynamic loading
```

---

## MIGRATION CHECKLIST

### Immediate Actions (Critical)

- [ ] Search codebase for `String(vector)`, `String(transform)`, etc.
- [ ] Replace with `str()` function or format strings
- [ ] Update `.csproj` files to target .NET 8.0
- [ ] Verify Windows 10+ for Windows builds
- [ ] Update Android min SDK to 24 in export settings
- [ ] Replace `abstract func` with `@abstract` annotation
- [ ] Test all platform builds after migration

### Recommended Updates (Non-Breaking)

- [ ] Replace `ParallaxBackground` with custom parallax logic
- [ ] Convert `SkeletonIK` to `IKModifier3D` (4.6+)
- [ ] Update `EditorScript.get_scene()` to `EditorInterface.get_edited_scene_root()`
- [ ] Remove `NavigationServer.map_force_update()` calls
- [ ] Consider using abstract classes for cleaner hierarchies
- [ ] Add `const` to static array/dictionary definitions
- [ ] Use `@export_file_path` where UIDs are not needed

### Performance Optimizations (New in 4.6)

- [ ] Add `.reserve()` calls for known collection sizes
- [ ] Use `iterate_children()` instead of `get_children()` where possible
- [ ] Enable Jolt Physics for new 3D projects
- [ ] Use typed arrays (`Array[Type]`) throughout
- [ ] Cache node references with `@onready`

---

## VERSION DETECTION IN CODE

```gdscript
# Runtime version check:
func check_version() -> void:
    var version_info = Engine.get_version_info()
    print("Godot Version: %d.%d.%d" % [
        version_info.major,
        version_info.minor,
        version_info.patch
    ])

    # Feature detection (safer than version checking):
    if ClassDB.class_exists("IKModifier3D"):
        print("IKModifier3D available (4.6+)")

    # Check for specific methods:
    if "reserve" in []:  # Check if Array has reserve method
        print("Reserve method available (4.6+)")

# Conditional compilation (GDScript doesn't support this):
# Use feature tags in export templates instead
```

---

## COMPATIBILITY MATRIX

| Feature | 4.5.0 | 4.6.0 | 4.7-beta2 | First Landed | Notes |
|---------|:-----:|:-----:|:---------:|:------------:|-------|
| Abstract classes | ✅ | ✅ | ✅ | 4.5 | Use `@abstract` |
| Variadic functions | ✅ | ✅ | ✅ | 4.5 | Array parameter |
| Const constructors | ✅ | ✅ | ✅ | 4.5 | Arrays/Dicts |
| String implicit conversion | ❌ | ❌ | ❌ | — | Removed in 4.5 |
| Array/Dict.reserve() | ❌ | ✅ | ✅ | 4.6 | Pre-allocate capacity |
| IKModifier3D | ❌ | ✅ | ✅ | 4.6 | 8 subclasses |
| Jolt Physics default | ❌ | ✅ | ✅ | 4.6 | Production-ready |
| LibGodot | ❌ | ✅ | ✅ | 4.6 | Engine as library |
| D3D12 default (Windows) | ❌ | ✅ | ✅ | 4.6 | More stable than Vulkan |
| 2D batching 1.1–7× | ❌ | ✅ | ✅ | 4.6 | GPU performance gains |
| Tracy/Perfetto profilers | ❌ | ✅ | ✅ | 4.6 | Native tracing support |
| Transform Offset for Controls | ❌ | ❌ | ✅ | 4.7-dev3 | Animate Controls without layout impact |
| Animation system optimization | ❌ | ❌ | ✅ | 4.7-dev3 | Resource/Library/Mixer/Player |
| `AnimationTree` thread safety | ❌ | ❌ | ✅ | 4.7-dev3 | Improved thread group safety |
| Signal thread safety | ❌ | ❌ | ✅ | 4.7-dev3 | Enhanced Object signal threading |
| Polygon2D fast path | ❌ | ❌ | ✅ | 4.7-dev3 | Rendering optimization |
| HDR on Apple platforms | ❌ | ❌ | ✅ | 4.7-dev3 | Full EDR display support |
| HDR on Linux/Wayland | ❌ | ❌ | ✅ | 4.7-dev3 | Wayland HDR output |
| HDR on Windows | ❌ | ❌ | ✅ | 4.7-beta1 | C++/WinRT isolation (GH-94496) |
| Android Picture-in-Picture | ❌ | ❌ | ✅ | 4.7-dev3 | `DisplayServer.pip_mode_enter()` |
| Device IDs in input events | ❌ | ❌ | ✅ | 4.7-dev3 | Keyboard/mouse device IDs |
| `wasm64` web builds | ❌ | ❌ | ✅ | 4.7-dev3 | Extended WASM compat |
| PopupMenu search bar | ❌ | ❌ | ✅ | 4.7-dev3 | Search field in popups |
| `AtlasTexture` tiling in `TextureRect` | ❌ | ❌ | ✅ | 4.7-dev3 | Tiling in TextureRect |
| Tracy on-demand default | ❌ | ❌ | ✅ | 4.7-dev3 | Lighter profiling overhead |
| Nearest-neighbor 3D scaling | ❌ | ❌ | ✅ | 4.7-dev4 | Pixel-art 3D rendering |
| Control `custom_maximum_size` | ❌ | ❌ | ✅ | 4.7-dev4 | Symmetric with `custom_minimum_size` |
| Improved Tree drag-and-drop | ❌ | ❌ | ✅ | 4.7-dev4 | Vector-design-style parenting |
| 3D Ruler vector components | ❌ | ❌ | ✅ | 4.7-dev4 | Per-axis distance |
| Extension reload from editor | ❌ | ❌ | ✅ | 4.7-dev4 | GDExtension hot-reload |
| Asset Library new API | ❌ | ❌ | ✅ | 4.7-dev5 | Improved metadata, version switching |
| Per-platform export-template download | ❌ | ❌ | ✅ | 4.7-dev5 | Individual platform installs |
| RichTextLabel `em`-unit image scaling | ❌ | ❌ | ✅ | 4.7-dev5 | Responsive `[img]` tags (breaking) |
| `AreaLight3D` (rectangular) | ❌ | ❌ | ✅ | 4.7-dev5 | Real-time area lights |
| Inline shader previews | ❌ | ❌ | ✅ | 4.7-dev5 | In-editor visual feedback |
| Vertex snap for subgizmo points | ❌ | ❌ | ✅ | 4.7-dev5 | Sub-component snapping |
| Audio bus UI revamp | ❌ | ❌ | ✅ | 4.7-dev5 | Clearer routing display |
| Wayland touch support | ❌ | ❌ | ✅ | 4.7-dev5 | Native touch events on Wayland |
| Android splash screen options | ❌ | ❌ | ✅ | 4.7-dev5 | Customizable boot screen |
| `AwaitTweener` | ❌ | ❌ | ✅ | 4.7-beta1 | `await` signals inside tweens |
| VirtualJoystick control | ❌ | ❌ | ✅ | 4.7-beta1 | FIXED / DYNAMIC / FOLLOWING |
| 2D one-way collision (all directions) | ❌ | ❌ | ✅ | 4.7-beta1 | No longer "up" only |
| Vulkan raytracing groundwork | ❌ | ❌ | ✅ | 4.7-beta1 | Foundation for hardware RT |
| `DrawableTexture` | ❌ | ❌ | ✅ | 4.7-beta1 | Direct texture drawing |
| Accessibility landmark roles | ❌ | ❌ | ✅ | 4.7-beta1 | Screen-reader regions |
| Conic gradient in `GradientTexture2D` | ❌ | ❌ | ✅ | 4.7-beta1 | New gradient mode |
| Animation track group collapse | ❌ | ❌ | ✅ | 4.7-beta1 | Editor folding |
| Path3D collider snapping | ❌ | ❌ | ✅ | 4.7-beta1 | Snap path to surfaces |
| Joypad motion sensors | ❌ | ❌ | ✅ | 4.7-beta1 | Gyro / accelerometer |
| 3D Pilot Mode undo/redo | ❌ | ❌ | ✅ | 4.7-beta2 | Camera moves are undoable |
| Surface HDR detection | ❌ | ❌ | ✅ | 4.7-beta2 | Per-surface HDR query |
| Android Gradle build (stable) | ❌ | ❌ | ✅ | 4.7-beta2 | "Experimental" tag removed |

---

## QUICK MIGRATION EXAMPLES

### Updating String Conversions

```gdscript
# Pattern 1: Direct conversion
# OLD:
var pos_text = String(player.position)
# NEW:
var pos_text = str(player.position)

# Pattern 2: Concatenation
# OLD:
print("Position: " + String(pos))
# NEW:
print("Position: " + str(pos))
# BETTER:
print("Position: %v" % pos)

# Pattern 3: NodePath
# OLD:
var path_string = String(get_path())
# NEW:
var path_string = str(get_path())
```

### Updating Physics (4.6+)

```gdscript
# For NEW projects, consider Jolt Physics:
# Project Settings → Physics/3D/Physics Engine → Jolt

# Existing GodotPhysics code works unchanged
# Jolt provides better performance and accuracy
# No code changes needed for migration
```

### Updating Animation (4.6+)

```gdscript
# OLD (SkeletonIK - still works but deprecated):
var ik = SkeletonIK.new()
ik.set_target_node(target_path)
ik.set_tip_bone("Hand.R")
ik.set_root_bone("UpperArm.R")
$Skeleton3D.add_child(ik)

# NEW (IKModifier3D - recommended):
var ik = IKModifier3D.new()
ik.target = target_node
ik.tip_bone = "Hand.R"
ik.root_bone = "UpperArm.R"
$Skeleton3D.add_child(ik)
```

---

## CROSS-REFERENCE

**Related Guidelines**:
- GDScript patterns → `01-gdscript-modern-patterns.md`
- Performance optimization → `07-platform-performance.md`
- Platform specifics → `07-platform-performance.md#platform-specifics`
- Animation system → `05-animation-physics-3d.md`
- Physics system → `05-animation-physics-3d.md#physics-systems`

**External Resources**:
- Official Migration Guide: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.html
- Interactive Changelog: https://godotengine.github.io/godot-interactive-changelog
- Breaking Changes List: https://github.com/godotengine/godot/blob/master/CHANGELOG.md

---

## NEW 4.6 FEATURES (Detailed)

### LibGodot - Engine as Library

```gdscript
# LibGodot enables embedding Godot in other applications
# Access via new GodotInstance class

# Use cases:
# - Integrating Godot into existing applications
# - Building specialized tools with Godot rendering
# - Custom launchers and editors
# - Embedding game engine in productivity apps

# This is primarily a C++/GDExtension feature
# GDScript developers typically won't interact directly with LibGodot
```

### Modern Theme (Default Editor Theme)

```gdscript
# The community-created "Godot Minimal Theme" is now default
# Renamed to "Modern Theme"
# Previous default renamed to "Classic Theme"

# Theme switching:
# Editor → Editor Settings → Interface → Theme → Preset
# Options: Modern (new default), Classic, Light, Custom

# Live theme switching now works without editor restart
```

### Editor Dock Improvements

```gdscript
# New EditorDock class enables:
# - Flexible dock layouts
# - Better bottom panel integration
# - Custom dock creation for plugins

# Array inspector redesign:
# - Reduced visual clutter
# - Cleaner property editing
# - Better performance with large arrays

# Focus state decoupling:
# - Mouse/touch focus separate from keyboard/joypad
# - Enables granular UI styling for different input modes
```

### Tracing Profiler Integration

```gdscript
# Native profiler support for performance analysis:
# - Tracy profiler (cross-platform)
# - Perfetto (Android/Chrome DevTools)
# - Apple Instruments signposts (macOS/iOS)

# Enable via build system (not runtime toggle)
# Useful for deep performance analysis in production builds

# GDScript also gains native profiler support for better debugging
```

### XR / OpenXR 1.1 Features

```gdscript
# OpenXR 1.1 automatically enabled on supporting devices
# Compatibility layer for 1.0 devices

# New spatial entities extensions:
# - Spatial anchors for persistent world positioning
# - Plane tracking for AR applications
# - Marker tracking for fiducial detection

# Improved interaction with real-world environment
```

### Focus State Improvements

```gdscript
# Focus logic now separates input methods:
# - Mouse/touch focus handling
# - Keyboard/joypad focus handling
# - Independent styling per input mode

# Useful for:
# - Console/controller UI
# - Accessibility features
# - Hybrid input games

# Control nodes gain new focus-related properties
```

### Joypad Customization Foundation

```gdscript
# New joypad customization features:
# - LED color support (DualSense, DualShock 4)
# - Foundation for future haptic improvements

# Set controller LED color:
Input.set_joy_led_color(device_id, color)

# Check LED support:
if Input.is_joy_led_color_valid(device_id):
    Input.set_joy_led_color(device_id, Color.RED)
```

### Microphone Buffer Access

```gdscript
# AudioServer now allows direct microphone buffer access
# Useful for:
# - Real-time audio processing
# - Voice chat implementations
# - Audio visualization
# - Voice-controlled games

# Access via AudioServer methods (advanced usage)
```

### Unique Node IDs

```gdscript
# Nodes can now have unique IDs that persist across scene refactoring
# Useful for:
# - Save/load systems
# - Network synchronization
# - Editor plugins
# - Scene versioning

# Get unique ID:
var uid = node.get_instance_id()  # Existing method
# New: Scene-local unique IDs for stable references
```

---

## 4.6.0-BETA 2 SPECIFIC FIXES (Baseline Reference)

> Historical reference — these fixes shipped in the 4.6 cycle's beta2 and are part of the inherited baseline. The current 4.7-beta2 fixes are listed in the "Godot 4.7-beta2" entry of the Version Timeline above.

### Regressions Fixed from Beta 1

- **Editor**: Tool button disabled for multiple selected nodes
- **Editor**: Shader editor minimum size constraints fixed
- **Editor**: FileSystem search now shows files when searched by UID
- **GUI**: TextEdit auto-scroll works properly on all vertical sizes
- **Linux/X11**: Input delay regression corrected
- **Rendering**: Mesa NIR updated to 25.3.1
- **Rendering**: SPIR-V to DXIL conversion threading improvements
- **OpenGL**: Adreno GPU crash fixed (motion vector uniforms split)

### Library Updates

- `minimp3` replaced with `dr_mp3` for audio handling
- SDL updated to version 3.2.28

### Platform-Specific Fixes

- **iOS**: Automatically enables `iphone-ipad-minimum-performance-a12` for Forward+/Mobile
- **Linux**: X11 input responsiveness restored

### Known Issues (4.6-Beta 2)

```gdscript
# Motion vectors currently broken in Compatibility renderer
# Geometry may render predominantly black
# Workaround: Use Forward+/Mobile renderer or disable motion vectors
# Expected fix in a later release
```

---

## 4.7-BETA 2 KNOWN ISSUES (Current Cycle)

```gdscript
# macOS XR crash (GH-119146):
#   Editor crashes when exiting an XR project on macOS.
#   Workaround: avoid running XR scenes from the editor on macOS until fixed.
#
# GUI tooltip + popup-menu search bar (GH-119407):
#   When a PopupMenu has its new search bar enabled, individual item
#   tooltips fail to display.
#   Workaround: encode the same hint in the menu item label, or disable
#   the search bar for menus where tooltips are load-bearing.
#
# Inherited from beta1 (verify status before relying on these as workarounds):
#   - Asset Store API: cached URL load failure (GH-118755)
#   - Vulkan renderer: system hang on project open in specific configs (GH-116414)
#   - Android: VisualShader crash with vertex_lighting enabled (GH-116990)
```

---

**Document Version**: 1.3
**Last Updated**: 2026-05-16
**Target Godot Version**: 4.7-beta2
**Coverage**: 4.5.0 → 4.6.0 → 4.7-dev1..dev5 → 4.7-beta1 → 4.7-beta2
**AI Optimization**: High (structured for rapid lookup and pattern matching)
