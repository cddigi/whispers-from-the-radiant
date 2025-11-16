# Platform Requirements and Performance Optimization

**Purpose**: Platform-specific requirements and performance patterns for Godot 4.6
**Focus**: Platform minimums (Windows 10+, Android API 24+), platform-specific features, performance optimization patterns

---

## Platform Requirements (4.6 Changes)

### Minimum Platform Versions

| Platform | Previous | 4.5+ Requirement | Impact |
|----------|----------|------------------|--------|
| **Windows** | Windows 7+ | **Windows 10+** | HIGH |
| **Android** | API 21 (Android 5.0) | **API 24 (Android 7.0)** | Medium |
| **Android NDK** | r23c | **r28b** | Medium |
| **.NET (C#)** | .NET 6.0 | **.NET 8.0** | HIGH |
| **Linux PowerPC** | 32-bit supported | **Dropped** | Low |

**CRITICAL Changes**:
- **Windows 7/8/8.1 no longer supported** (minimum: Windows 10 version 1809)
- **Android minimum raised to 7.0** (API level 24)
- **C# projects require .NET 8.0** (9.0 for Android in some cases)

```csharp
// C# Project file must target .NET 8.0:
<Project Sdk="Godot.NET.Sdk/4.6.0">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>
</Project>

// Android C# may require .NET 9.0:
<PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|Android'">
  <TargetFramework>net9.0</TargetFramework>
</PropertyGroup>
```

---

## Android Platform (4.6 Specific)

### Android API 24+ Requirements

```gdscript
# Export Settings → Android:
# Min SDK: 24 (Android 7.0)
# Target SDK: 34 (Android 14)

# Permissions (AndroidManifest.xml):
# - INTERNET (if using networking)
# - WRITE_EXTERNAL_STORAGE (if saving files)
# - READ_EXTERNAL_STORAGE (if reading files)
```

### 16KB Page Support (NEW Requirement)

```gdscript
# Android devices are moving to 16KB memory pages
# NDK r28b required for compatibility

# Export settings:
# - Use Android NDK r28b or later
# - Enable "16KB Page Support" in export template

# Code considerations:
# - No code changes needed
# - Existing games work automatically
# - Performance may improve on newer devices
```

### Sparse PCK Files (NEW Feature)

```gdscript
# Sparse PCK: Efficient packaging for large games
# Reduces install size by avoiding duplicate data

# Enable in export settings:
# Export → Android → Use Sparse PCK: ON

# Benefits:
# - Smaller APK/AAB size
# - Faster downloads
# - Efficient asset streaming
# - No code changes required
```

### Android Permissions

```gdscript
# Request runtime permissions (Android 6.0+):
func request_storage_permission() -> void:
    if OS.request_permissions():
        print("Permissions granted")
    else:
        print("Permissions denied")

# Check permission status:
func check_permission(permission: String) -> bool:
    return OS.get_granted_permissions().has(permission)

# Common permissions:
# - android.permission.INTERNET
# - android.permission.WRITE_EXTERNAL_STORAGE
# - android.permission.READ_EXTERNAL_STORAGE
# - android.permission.CAMERA
# - android.permission.RECORD_AUDIO
```

---

## iOS / macOS Platform

### SwiftUI Lifecycle (NEW in 4.6)

```gdscript
# NEW in 4.6: iOS/macOS use SwiftUI lifecycle by default
# Replaces legacy UIKit/AppKit lifecycle

# Benefits:
# - Better integration with iOS/macOS features
# - SwiftUI compatibility
# - Modern app lifecycle management

# No code changes required for existing games
# New export template automatically uses SwiftUI
```

### Liquid Glass Icons (macOS 15+)

```gdscript
# macOS 15+ supports new icon style
# Export settings auto-generate when exporting for macOS

# Provide high-resolution icon:
# - 1024x1024 PNG minimum
# - Transparent background
# - Export template generates Liquid Glass variant

# No code changes needed
```

### Embedded Windows (iOS/macOS)

```gdscript
# Better support for embedded native windows
# Useful for native UI integration

# Create native window (macOS):
func create_native_window() -> void:
    if OS.get_name() == "macOS":
        DisplayServer.window_set_flag(
            DisplayServer.WINDOW_FLAG_BORDERLESS,
            true,
            get_window().get_window_id()
        )
```

---

## Web Platform

### WebAssembly SIMD (Default in 4.6)

```gdscript
# WASM SIMD enabled by default in 4.6
# Provides significant performance improvements

# Export settings:
# Export → Web → Enable SIMD: ON (default)

# Benefits:
# - 2-4x performance improvement for math operations
# - Better physics performance
# - Faster rendering

# Browser requirements:
# - Chrome 91+
# - Firefox 89+
# - Safari 16.4+
# - Edge 91+
```

### SharedArrayBuffer and Multithreading

```gdscript
# SharedArrayBuffer allows multithreading in web builds
# Requires specific server headers

# Server configuration (Apache .htaccess):
# Header set Cross-Origin-Embedder-Policy "require-corp"
# Header set Cross-Origin-Opener-Policy "same-origin"

# Or nginx:
# add_header Cross-Origin-Embedder-Policy "require-corp";
# add_header Cross-Origin-Opener-Policy "same-origin";

# Enable threads in export:
# Export → Web → Threads: ON
```

### Web Export Optimization

```gdscript
# Reduce web build size:

# 1. Enable compression:
# Export → Web → Compress: ON

# 2. Use WebP for textures:
# Import → Texture → Compress Mode: VRAM Compressed

# 3. Optimize audio:
# Import → Audio → Compress: ON
# Use OGG Vorbis instead of WAV

# 4. Remove unused features:
# Project Settings → Modules → Disable unused modules

# 5. Strip debug symbols:
# Export → Strip Debug: ON (release builds)
```

---

## Performance Patterns

### Array and Collection Pre-allocation (NEW in 4.6)

```gdscript
# NEW in 4.6: reserve() for Array, Dictionary, String

# Array pre-allocation (avoids reallocations):
var entities: Array[Entity] = []
entities.reserve(1000)  # Pre-allocate for 1000 elements
for i in 1000:
    entities.append(create_entity())

# Dictionary pre-allocation:
var lookup: Dictionary[int, Entity] = {}
lookup.reserve(500)
for entity in entities:
    lookup[entity.id] = entity

# String pre-allocation (for string building):
var log_text := ""
log_text.reserve(10000)  # Pre-allocate 10KB
for i in 100:
    log_text += "Log entry %d\n" % i

# Performance impact:
# - Eliminates repeated reallocations
# - Critical for large collections (500+ elements)
# - Minimal overhead for small collections
```

### StringName Optimization

```gdscript
# StringName (&"string") is cached and faster for:
# - Signal names
# - Node names
# - Group names
# - Action names
# - Method names

# SLOW (String allocation every frame):
func _process(delta: float) -> void:
    if Input.is_action_pressed("move_left"):  # String allocation
        move_left()

# FAST (cached StringName):
const ACTION_MOVE_LEFT: StringName = &"move_left"

func _process(delta: float) -> void:
    if Input.is_action_pressed(ACTION_MOVE_LEFT):  # No allocation
        move_left()

# Node access optimization:
const NODE_SPRITE: StringName = &"Sprite2D"
@onready var sprite := get_node(NODE_SPRITE)

# Group usage:
const GROUP_ENEMIES: StringName = &"enemies"

func alert_enemies() -> void:
    get_tree().call_group(GROUP_ENEMIES, "on_alert")

# Performance gain: 10-50% in hot paths
```

### Node Iteration (4.6 Optimization)

```gdscript
# NEW in 4.6: iterate_children() (C++/GDExtension only)
# GDScript still uses get_children()

# GDScript pattern (allocates array):
for child in get_children():
    child.update()

# Optimization: Cache children if iterating frequently:
@onready var _children_cache: Array[Node] = []

func _ready() -> void:
    _children_cache.assign(get_children())

func update_all() -> void:
    for child in _children_cache:
        child.update()

# Update cache when children change:
func _on_child_added(node: Node) -> void:
    _children_cache.append(node)

func _on_child_removed(node: Node) -> void:
    _children_cache.erase(node)
```

### Visibility-Based Optimization

```gdscript
# Disable processing for off-screen objects:
@onready var visibility_notifier: VisibleOnScreenNotifier2D = $VisibilityNotifier

func _ready() -> void:
    visibility_notifier.screen_entered.connect(_on_screen_entered)
    visibility_notifier.screen_exited.connect(_on_screen_exited)

func _on_screen_entered() -> void:
    set_process(true)
    set_physics_process(true)
    animated_sprite.play()

func _on_screen_exited() -> void:
    set_process(false)
    set_physics_process(false)
    animated_sprite.stop()

# Distance-based LOD:
const LOD_DISTANCE_FAR = 1000.0
const LOD_DISTANCE_MEDIUM = 500.0
const LOD_DISTANCE_NEAR = 200.0

func _process(delta: float) -> void:
    var camera = get_viewport().get_camera_2d()
    if not camera:
        return

    var distance = global_position.distance_to(camera.global_position)

    if distance > LOD_DISTANCE_FAR:
        hide()
    elif distance > LOD_DISTANCE_MEDIUM:
        show()
        animated_sprite.speed_scale = 0.25  # 1/4 speed
    elif distance > LOD_DISTANCE_NEAR:
        animated_sprite.speed_scale = 0.5   # Half speed
    else:
        animated_sprite.speed_scale = 1.0   # Full speed
```

### Physics Optimization

```gdscript
# Use collision layers efficiently:
# Only check necessary layers

# Disable physics when not needed:
func disable_physics() -> void:
    set_physics_process(false)
    collision_shape.disabled = true

func enable_physics() -> void:
    set_physics_process(true)
    collision_shape.disabled = false

# Use Area2D for triggers (faster than RigidBody2D):
# Area2D has no physics simulation, only overlap detection

# Simplify collision shapes:
# Use primitive shapes (Rectangle, Circle) over complex polygons
# Reduce collision shape complexity

# Sleep inactive bodies:
# RigidBody2D automatically sleeps when stationary
# Don't wake sleeping bodies unless necessary

# Jolt Physics (4.6 default) optimizations:
# - Better performance for complex scenes
# - Better scaling with many physics objects
# - No code changes needed
```

### Rendering Optimization

```gdscript
# Batching (automatic in Godot 4):
# - Use same texture for multiple sprites
# - Use same material
# - Keep similar sprites under same parent
# - Group by z-index

# Texture atlases:
const ATLAS_TEXTURE = preload("res://atlas.png")

func create_sprite(region: Rect2) -> Sprite2D:
    var sprite = Sprite2D.new()
    sprite.texture = ATLAS_TEXTURE
    sprite.region_enabled = true
    sprite.region_rect = region
    return sprite

# Reduce draw calls:
# - Use MultiMesh for many identical objects
# - Use TileMapLayer efficiently
# - Minimize unique materials/shaders

# MultiMesh example (1000s of objects):
var multi_mesh = MultiMesh.new()
multi_mesh.mesh = preload("res://tree.mesh")
multi_mesh.transform_format = MultiMesh.TRANSFORM_2D
multi_mesh.instance_count = 1000

for i in 1000:
    var transform = Transform2D()
    transform.origin = Vector2(randf() * 2000, randf() * 1000)
    multi_mesh.set_instance_transform_2d(i, transform)

var multi_mesh_instance = MultiMeshInstance2D.new()
multi_mesh_instance.multimesh = multi_mesh
add_child(multi_mesh_instance)
```

### Memory Optimization

```gdscript
# Resource caching:
# Load resources once, reuse everywhere

class_name ResourceCache
extends Node

var _cache: Dictionary[String, Resource] = {}

func get_resource(path: String) -> Resource:
    if path in _cache:
        return _cache[path]

    var resource = load(path)
    if resource:
        _cache[path] = resource
    return resource

func clear() -> void:
    _cache.clear()

# Use object pools for frequent instantiation:
# See 03-core-systems.md#object-pooling

# Texture compression:
# Project Settings → Rendering → Textures:
# - Use VRAM Compressed for large textures
# - Use Lossless for UI elements
# - Use Uncompressed only when necessary

# Audio compression:
# Import → Audio:
# - Use OGG Vorbis for music/long sounds
# - Use WAV for short sound effects
# - Adjust bitrate based on quality needs
```

---

## Profiling and Debugging

### Built-in Profiler

```gdscript
# Enable profiler:
# Debug → Profiler
# Or F3 key (toggle frame time display)

# Profiler sections:
# - Frame Time: Total frame duration
# - CPU: Script and engine time
# - GPU: Rendering time
# - Memory: RAM usage
# - Network: Bandwidth usage
# - Physics: Physics simulation time

# Monitor custom metrics:
func add_custom_monitor(name: String, value: float) -> void:
    Performance.add_custom_monitor("game/" + name, func(): return value)

# Example:
Performance.add_custom_monitor("game/enemies_alive", func(): return enemy_count)
Performance.add_custom_monitor("game/memory_mb", func(): return OS.get_static_memory_usage() / 1024.0 / 1024.0)
```

### Performance Debugging

```gdscript
# Measure function execution time:
func measure_performance(callable: Callable, iterations: int = 1000) -> float:
    var start_time = Time.get_ticks_usec()

    for i in iterations:
        callable.call()

    var end_time = Time.get_ticks_usec()
    var avg_time = (end_time - start_time) / float(iterations)

    print("Average time: ", avg_time, " microseconds")
    return avg_time

# Usage:
measure_performance(func(): process_heavy_algorithm())

# Memory leak detection:
func check_orphan_nodes() -> void:
    print("Orphan nodes: ", Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
    print("Total objects: ", Performance.get_monitor(Performance.OBJECT_COUNT))

# Frame rate monitoring:
func _process(delta: float) -> void:
    var fps = Engine.get_frames_per_second()
    if fps < 30:
        push_warning("Low FPS: %d" % fps)
```

---

## Shader Compilation and Caching (4.6)

### Shader Compilation

```gdscript
# 4.6 improvements to shader compilation and caching

# Shader compilation modes:
# Project Settings → Rendering → Shader Compiler:
# - Synchronous: Compile on demand (stutters)
# - Asynchronous: Compile in background (recommended)

# Shader cache:
# Automatically caches compiled shaders
# Reduces stuttering on subsequent runs

# Pre-compile shaders (for critical materials):
func precompile_shaders() -> void:
    # Load and compile materials at loading screen:
    var materials = [
        preload("res://materials/player.material"),
        preload("res://materials/enemy.material"),
        preload("res://materials/environment.material"),
    ]

    for material in materials:
        # Material compilation happens here
        pass

# Disable shaders for low-end devices:
func disable_advanced_shaders() -> void:
    if OS.get_processor_count() < 4:
        # Use simpler materials
        player_material = preload("res://materials/player_simple.material")
```

---

## Platform-Specific Code

### Detecting Platform

```gdscript
# Detect current platform:
func get_platform() -> String:
    return OS.get_name()
    # Returns: "Windows", "macOS", "Linux", "Android", "iOS", "Web"

# Platform-specific code:
func setup_input() -> void:
    match OS.get_name():
        "Windows", "macOS", "Linux":
            setup_keyboard_mouse()
        "Android", "iOS":
            setup_touch_controls()
        "Web":
            setup_web_controls()

# Feature detection (better than platform detection):
func setup_based_on_features() -> void:
    if Input.get_connected_joypads().size() > 0:
        setup_gamepad()
    elif DisplayServer.is_touchscreen_available():
        setup_touch()
    else:
        setup_keyboard_mouse()
```

### Mobile-Specific Features

```gdscript
# Touch controls:
func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var touch = event as InputEventScreenTouch
        if touch.pressed:
            handle_touch(touch.position)

    elif event is InputEventScreenDrag:
        var drag = event as InputEventScreenDrag
        handle_drag(drag.relative)

# Vibration (mobile):
func vibrate(duration_ms: int) -> void:
    if OS.get_name() in ["Android", "iOS"]:
        Input.vibrate_handheld(duration_ms)

# Battery status:
func check_battery() -> void:
    var battery_percent = OS.get_power_percent_left()
    var is_charging = OS.get_power_state() == OS.POWERSTATE_CHARGING

    if battery_percent < 20 and not is_charging:
        reduce_graphics_quality()
```

---

## Cross-Reference

**Related Guidelines**:
- Memory management → `03-core-systems.md#memory-management`
- Object pooling → `03-core-systems.md#object-pooling`
- GDScript performance → `01-gdscript-modern-patterns.md#performance-patterns`
- Rendering optimization → `04-2d-graphics-rendering.md#performance`
- Physics optimization → `05-animation-physics-3d.md#physics-systems`

---

**Document Version**: 1.0
**Last Updated**: 2025-11-15
**Godot Version**: 4.6.0-dev4
**AI Optimization**: Maximum (platform requirements, 4.6 features, performance recipes)
