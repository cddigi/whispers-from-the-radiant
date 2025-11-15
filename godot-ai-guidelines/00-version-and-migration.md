# Godot 4.6 Version Information and Migration Guide

**Target Version**: Godot 4.6.0-dev4
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

### Godot 4.6.0 (Current Target)
- Jolt Physics as default for new projects
- IKModifier3D system (replaces SkeletonIK)
- Enhanced Control pivot positioning
- Editor dock refactor
- Glow rendering improvements
- SSAO in Compatibility renderer

---

## CRITICAL BREAKING CHANGES (4.5.0 → 4.6.0)

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
| IKModifier3D | ❌ | ❌ | ✅ | Replaces SkeletonIK |
| Jolt Physics default | ❌ | ❌ | ✅ | New projects only |
| String implicit conversion | ❌ | ❌ | ❌ | Removed in 4.5 |
| Array.reserve() | ❌ | ❌ | ✅ | 4.6+ only |
| Dict.reserve() | ❌ | ❌ | ✅ | 4.6+ only |
| SSAO in Compatibility | ❌ | ❌ | ✅ | Simple SSAO |

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

**Document Version**: 1.0
**Last Updated**: 2025-11-15
**Target Godot Version**: 4.6.0-dev4
**AI Optimization**: High (structured for rapid lookup and pattern matching)
