# Godot 4.6 Version Information and Migration Guide

**Target Version**: Godot 4.6.0-beta2
**Previous Baseline**: Godot 4.5.0
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

### Godot 4.6.0 (Current Target - Beta 2)
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

| Feature | 4.5.0 | 4.5.1 | 4.6.0 | Notes |
|---------|-------|-------|-------|-------|
| Abstract classes | ✅ | ✅ | ✅ | Use `@abstract` |
| Variadic functions | ✅ | ✅ | ✅ | Array parameter |
| Const constructors | ✅ | ✅ | ✅ | Arrays/Dicts |
| IKModifier3D | ❌ | ❌ | ✅ | 8 subclasses (CCDIK3D, FABRIK3D, etc.) |
| Jolt Physics default | ❌ | ❌ | ✅ | Production-ready, new 3D projects |
| String implicit conversion | ❌ | ❌ | ❌ | Removed in 4.5 |
| Array.reserve() | ❌ | ❌ | ✅ | 4.6+ only |
| Dict.reserve() | ❌ | ❌ | ✅ | 4.6+ only |
| SSAO in Compatibility | ❌ | ❌ | ✅ | GLES3 renderer support |
| LibGodot | ❌ | ❌ | ✅ | Engine as standalone library |
| Modern Theme | ❌ | ❌ | ✅ | New default editor theme |
| EditorDock class | ❌ | ❌ | ✅ | Flexible dock layouts |
| OpenXR 1.1 | ❌ | ❌ | ✅ | Spatial entities extensions |
| D3D12 default (Windows) | ❌ | ❌ | ✅ | More stable than Vulkan |
| Wayland game embedding | ❌ | ❌ | ✅ | Parity with X11 |
| Android SAF support | ❌ | ❌ | ✅ | No MANAGE_EXTERNAL_STORAGE needed |
| Tracy/Perfetto profilers | ❌ | ❌ | ✅ | Native tracing support |
| AgX white/contrast | ❌ | ❌ | ✅ | Enhanced HDR tonemapping |
| SSR 2x quality | ❌ | ❌ | ✅ | Half performance cost |
| 2D batching 1.1-7x | ❌ | ❌ | ✅ | GPU performance gains |

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

## BETA 2 SPECIFIC FIXES

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

### Known Issues (Beta 2)

```gdscript
# Motion vectors currently broken in Compatibility renderer
# Geometry may render predominantly black
# Workaround: Use Forward+/Mobile renderer or disable motion vectors
# Expected fix in Beta 3 or stable release
```

---

**Document Version**: 1.1
**Last Updated**: 2025-12-22
**Target Godot Version**: 4.6.0-beta2
**AI Optimization**: High (structured for rapid lookup and pattern matching)
