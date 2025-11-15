# Core Systems: Memory, Resources, and Global Utilities

**Purpose**: Core system patterns for memory management, resource handling, and global utilities in Godot 4.6
**Focus**: Reference counting, object pooling, resource caching, groups, and SceneTree utilities

---

## Memory Management

### Reference Counting (Not Garbage Collection)

**Key Concept**: Godot uses **automatic reference counting**, not garbage collection

```gdscript
# Reference counting means:
# - Objects freed IMMEDIATELY when refcount reaches 0
# - NO garbage collection pauses
# - NO unpredictable delays
# - Deterministic cleanup

# Objects in Godot are Reference-counted:
var my_resource = Resource.new()  # Refcount = 1
var copy = my_resource             # Refcount = 2
copy = null                        # Refcount = 1
my_resource = null                 # Refcount = 0 → FREED IMMEDIATELY
```

**Implications**:
- No GC pauses affecting frame rate
- Predictable memory management
- Must manually free nodes (scene tree holds references)
- Circular references can cause leaks (rare in practice)

### Node Lifecycle and Cleanup

```gdscript
# Creating nodes:
var enemy = preload("res://enemy.tscn").instantiate()
add_child(enemy)  # Enemy enters scene tree

# Node lifecycle:
# 1. instantiate() - Creates node (refcount = 1)
# 2. add_child()   - Adds to tree (scene tree holds reference)
# 3. Node active in tree (processing, rendering)
# 4. queue_free() or free() - Cleanup initiated
# 5. Node removed and destroyed

# SAFE DELETION (recommended):
enemy.queue_free()  # Deleted at end of current frame
# - Safe for self-deletion
# - Safe during signal callbacks
# - Safe in _process() or _physics_process()

# IMMEDIATE DELETION (dangerous):
enemy.free()  # Deleted NOW
# - Can crash if other code references the node
# - Only use when CERTAIN no other references exist
# - Never use in signal callbacks or during iteration

# WRONG - Memory leak:
remove_child(enemy)  # Enemy removed from tree but still in memory!
# Must call queue_free() separately:
remove_child(enemy)
enemy.queue_free()
```

### Common Memory Patterns

```gdscript
# PATTERN 1: Safe node deletion
func delete_all_enemies() -> void:
    for enemy in get_tree().get_nodes_in_group("enemies"):
        enemy.queue_free()  # Safe, deferred

# PATTERN 2: Self-deletion in callback
signal died

func _on_health_depleted() -> void:
    died.emit()
    queue_free()  # Safe - waits for frame end

# PATTERN 3: Clear array of node references
var enemies: Array[Node] = []

func clear_enemies() -> void:
    for enemy in enemies:
        if is_instance_valid(enemy):  # Check not already freed
            enemy.queue_free()
    enemies.clear()

# PATTERN 4: Temporary nodes
func create_particle_effect(position: Vector2) -> void:
    var particle = ParticleScene.instantiate()
    particle.global_position = position
    add_child(particle)

    # Auto-cleanup after duration:
    await get_tree().create_timer(2.0).timeout
    if is_instance_valid(particle):
        particle.queue_free()
```

### Resource Memory Management

```gdscript
# Resources (textures, audio, materials) are reference-counted:
var texture = load("res://sprite.png")  # Refcount = 1
var duplicate = texture                 # Refcount = 2
texture = null                          # Refcount = 1
duplicate = null                        # Refcount = 0 → freed

# Resources are CACHED by path:
var tex1 = load("res://sprite.png")  # Loads from disk
var tex2 = load("res://sprite.png")  # Returns cached instance
# tex1 and tex2 are THE SAME object

# Clear resource cache (rarely needed):
ResourceLoader.clear_cache("res://sprite.png")

# Preload creates permanent reference:
const SPRITE = preload("res://sprite.png")
# SPRITE never freed (const holds reference)

# Large resources - manual management:
var large_texture: Texture2D = null

func load_level() -> void:
    large_texture = load("res://huge_texture.png")

func unload_level() -> void:
    large_texture = null  # Allow GC if no other references
    ResourceLoader.clear_cache("res://huge_texture.png")
```

### Memory Leak Prevention

```gdscript
# LEAK 1: Circular references (rare, but possible)
class_name Parent extends Node
var child_ref: Node

class_name Child extends Node
var parent_ref: Node  # Circular reference!

# SOLUTION: Use weak references or break manually
func _exit_tree() -> void:
    parent_ref = null  # Break cycle

# LEAK 2: Forgotten signal connections
var timer: Timer

func _ready() -> void:
    timer = Timer.new()
    add_child(timer)
    timer.timeout.connect(_on_timer_timeout)
    # If timer outlives this node, connection remains!

# SOLUTION: Disconnect in _exit_tree()
func _exit_tree() -> void:
    if timer and timer.timeout.is_connected(_on_timer_timeout):
        timer.timeout.disconnect(_on_timer_timeout)

# LEAK 3: Nodes removed but not freed
var cached_nodes: Array[Node] = []

func cache_node(node: Node) -> void:
    remove_child(node)  # Removed from tree
    cached_nodes.append(node)  # But still in memory!

# SOLUTION: Explicitly free when done
func clear_cache() -> void:
    for node in cached_nodes:
        node.queue_free()
    cached_nodes.clear()
```

---

## Object Pooling

### When to Use Object Pools

**Use Pools For**:
- High-frequency instantiation (>50 objects/second)
- Bullet patterns, particle systems
- UI elements that appear/disappear frequently
- Network entities in multiplayer

**Don't Use Pools For**:
- One-time or rare instantiation
- Large, complex objects
- Objects with significant state

### Basic Object Pool Pattern

```gdscript
class_name ObjectPool
extends Node

@export var scene: PackedScene
@export var initial_size: int = 20
@export var max_size: int = 100

var _pool: Array[Node] = []

func _ready() -> void:
    _pool.reserve(initial_size)

    # Pre-instantiate pool:
    for i in initial_size:
        var obj = scene.instantiate()
        _prepare_pooled_object(obj)
        add_child(obj)
        _pool.append(obj)

func _prepare_pooled_object(obj: Node) -> void:
    obj.process_mode = Node.PROCESS_MODE_DISABLED
    obj.hide()
    if obj is Node2D:
        obj.position = Vector2.ZERO
    elif obj is Node3D:
        obj.position = Vector3.ZERO

func acquire() -> Node:
    if _pool.is_empty():
        # Pool exhausted - expand if under max:
        if get_child_count() < max_size:
            var obj = scene.instantiate()
            add_child(obj)
            return obj
        else:
            push_warning("Pool at max capacity!")
            return null

    var obj = _pool.pop_back()
    obj.process_mode = Node.PROCESS_MODE_INHERIT
    obj.show()
    return obj

func release(obj: Node) -> void:
    if not is_instance_valid(obj):
        return

    _prepare_pooled_object(obj)
    _pool.append(obj)

func clear() -> void:
    for obj in _pool:
        obj.queue_free()
    _pool.clear()
```

### Pooled Object Pattern

```gdscript
# bullet.gd - Designed for pooling
class_name Bullet
extends Area2D

signal lifetime_expired

var damage: int = 10
var speed: float = 500.0
var lifetime: float = 3.0
var _lifetime_timer: float = 0.0

func reset(spawn_pos: Vector2, direction: Vector2) -> void:
    global_position = spawn_pos
    rotation = direction.angle()
    _lifetime_timer = 0.0
    show()
    set_physics_process(true)

func _physics_process(delta: float) -> void:
    position += Vector2.RIGHT.rotated(rotation) * speed * delta

    _lifetime_timer += delta
    if _lifetime_timer >= lifetime:
        return_to_pool()

func _on_body_entered(body: Node2D) -> void:
    if body.has_method("take_damage"):
        body.take_damage(damage)
    return_to_pool()

func return_to_pool() -> void:
    set_physics_process(false)
    hide()
    lifetime_expired.emit()

# weapon.gd - Uses bullet pool
@onready var bullet_pool: ObjectPool = $BulletPool

func fire(direction: Vector2) -> void:
    var bullet = bullet_pool.acquire() as Bullet
    if bullet:
        bullet.reset(global_position, direction)
        bullet.lifetime_expired.connect(
            func(): bullet_pool.release(bullet),
            CONNECT_ONE_SHOT
        )
```

### Advanced Pool with Type Safety

```gdscript
class_name TypedObjectPool extends Node

var _scene: PackedScene
var _pool: Array[Node] = []
var _initial_size: int
var _max_size: int

func _init(scene: PackedScene, initial_size: int = 20, max_size: int = 100):
    _scene = scene
    _initial_size = initial_size
    _max_size = max_size

func _ready() -> void:
    _pool.reserve(_initial_size)
    for i in _initial_size:
        var obj = _scene.instantiate()
        obj.process_mode = Node.PROCESS_MODE_DISABLED
        obj.hide()
        add_child(obj)
        _pool.append(obj)

func acquire() -> Node:
    if _pool.is_empty():
        if get_child_count() < _max_size:
            var obj = _scene.instantiate()
            add_child(obj)
            return obj
        return null

    var obj = _pool.pop_back()
    obj.process_mode = Node.PROCESS_MODE_INHERIT
    obj.show()
    return obj

func release(obj: Node) -> void:
    if not is_instance_valid(obj) or obj.get_parent() != self:
        return

    obj.process_mode = Node.PROCESS_MODE_DISABLED
    obj.hide()
    _pool.append(obj)

# Usage with type safety:
var bullet_pool: TypedObjectPool
var particle_pool: TypedObjectPool

func _ready() -> void:
    bullet_pool = TypedObjectPool.new(preload("res://bullet.tscn"), 50, 200)
    add_child(bullet_pool)

    particle_pool = TypedObjectPool.new(preload("res://particle.tscn"), 30, 100)
    add_child(particle_pool)

func spawn_bullet() -> void:
    var bullet = bullet_pool.acquire() as Bullet
    if bullet:
        bullet.initialize(global_position, Vector2.RIGHT)
```

---

## Resource Caching Strategies

### Preloading vs Dynamic Loading

```gdscript
# PRELOAD - Loaded at compile time (recommended):
const PLAYER_SCENE = preload("res://player.tscn")
const BULLET_SCENE = preload("res://bullet.tscn")
const COIN_TEXTURE = preload("res://coin.png")

# Benefits:
# - Instant access (already in memory)
# - Compile-time error if file missing
# - No runtime loading delay
# - Cached permanently

# LOAD - Loaded at runtime:
func load_enemy(enemy_type: String) -> PackedScene:
    return load("res://enemies/%s.tscn" % enemy_type)

# Benefits:
# - Dynamic paths
# - Can unload later
# - Conditional loading
# - Drawbacks: slower, runtime errors

# RESOURCE PRELOADER NODE:
@onready var preloader: ResourcePreloader = $ResourcePreloader

func get_enemy_scene(type: String) -> PackedScene:
    return preloader.get_resource(type) as PackedScene

# Benefits:
# - Visual management in editor
# - Preloaded but organized
# - Easy to see what's loaded
```

### Resource Cache Management

```gdscript
# Global resource cache:
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

func preload_resources(paths: Array[String]) -> void:
    for path in paths:
        get_resource(path)

func clear_cache() -> void:
    _cache.clear()

func clear_resource(path: String) -> void:
    _cache.erase(path)

func get_memory_usage() -> int:
    var total = 0
    for resource in _cache.values():
        if resource is Texture2D:
            var tex = resource as Texture2D
            total += tex.get_width() * tex.get_height() * 4  # Approximate
    return total

# Usage:
var cache: ResourceCache

func _ready() -> void:
    cache = ResourceCache.new()
    add_child(cache)

    # Preload level resources:
    cache.preload_resources([
        "res://enemies/goblin.tscn",
        "res://enemies/orc.tscn",
        "res://items/coin.tscn",
    ])

func change_level() -> void:
    cache.clear_cache()  # Free old level resources
```

### Texture Atlases and Optimization

```gdscript
# Using texture atlases (sprite sheets):
@onready var sprite: Sprite2D = $Sprite2D

func set_sprite_region(x: int, y: int, size: int) -> void:
    sprite.region_enabled = true
    sprite.region_rect = Rect2(x * size, y * size, size, size)

# AtlasTexture for individual frames:
var atlas_frames: Array[AtlasTexture] = []

func create_atlas_frames() -> void:
    var base_texture = load("res://spritesheet.png")
    var frame_size = 64

    for y in 4:  # 4 rows
        for x in 8:  # 8 columns
            var atlas = AtlasTexture.new()
            atlas.atlas = base_texture
            atlas.region = Rect2(x * frame_size, y * frame_size, frame_size, frame_size)
            atlas_frames.append(atlas)

# Benefits of atlases:
# - Reduced draw calls (batching)
# - Better cache coherency
# - Fewer file loads
# - Easier animation management
```

---

## Groups System

### Group Management Patterns

```gdscript
# Adding to groups (multiple ways):

# 1. In editor: Select node → Node tab → Groups → Add

# 2. In code (_ready):
func _ready() -> void:
    add_to_group("enemies")
    add_to_group("damageable")
    add_to_group("ai_controlled")

# 3. In code (_init):
func _init() -> void:
    add_to_group("enemies")  # Works before entering tree

# Removing from groups:
remove_from_group("enemies")

# Check membership:
if is_in_group("enemies"):
    print("I'm an enemy")

# Get all groups:
var groups = get_groups()
for group in groups:
    print("Member of: ", group)
```

### Group Communication Patterns

```gdscript
# PATTERN 1: Call method on all in group
get_tree().call_group("enemies", "alert", player_position)

# PATTERN 2: Get nodes and iterate
var enemies = get_tree().get_nodes_in_group("enemies")
for enemy in enemies:
    enemy.take_damage(10)

# PATTERN 3: Get first node in group
var player = get_tree().get_first_node_in_group("player")
if player:
    player.heal(50)

# PATTERN 4: Filter and process
var damageable = get_tree().get_nodes_in_group("damageable")
for node in damageable:
    if node.global_position.distance_to(explosion_pos) < radius:
        if node.has_method("take_damage"):
            node.take_damage(damage)

# PATTERN 5: Notify group via flags
get_tree().call_group_flags(
    SceneTree.GROUP_CALL_DEFERRED,  # Call next frame
    "enemies",
    "on_player_detected",
    player_position
)
```

### Common Group Categorizations

```gdscript
# Entity type groups:
add_to_group("player")
add_to_group("enemies")
add_to_group("allies")
add_to_group("neutrals")

# Capability groups (interface-like):
add_to_group("damageable")      # Has take_damage()
add_to_group("interactable")    # Has interact()
add_to_group("combustible")     # Can catch fire
add_to_group("pushable")        # Can be pushed

# System groups:
add_to_group("pause_on_menu")   # Pause when menu opens
add_to_group("save_state")      # Needs persistence
add_to_group("networked")       # Replicated in multiplayer
add_to_group("audio_sources")   # Manages audio

# Gameplay groups:
add_to_group("water_hazards")
add_to_group("checkpoint_triggers")
add_to_group("loot_containers")
add_to_group("quest_npcs")

# Example system using groups:
func pause_game() -> void:
    get_tree().paused = true
    get_tree().call_group("pause_on_menu", "set_physics_process", false)

func resume_game() -> void:
    get_tree().paused = false
    get_tree().call_group("pause_on_menu", "set_physics_process", true)
```

### Group-Based Queries

```gdscript
# Find nearest enemy:
func find_nearest_enemy(position: Vector2) -> Node2D:
    var enemies = get_tree().get_nodes_in_group("enemies")
    var nearest: Node2D = null
    var nearest_dist = INF

    for enemy in enemies:
        if enemy is Node2D:
            var dist = position.distance_squared_to(enemy.global_position)
            if dist < nearest_dist:
                nearest_dist = dist
                nearest = enemy

    return nearest

# Count enemies in radius:
func count_enemies_in_radius(position: Vector2, radius: float) -> int:
    var count = 0
    var enemies = get_tree().get_nodes_in_group("enemies")

    for enemy in enemies:
        if enemy is Node2D:
            if position.distance_to(enemy.global_position) <= radius:
                count += 1

    return count

# Check if any enemies see player:
func are_enemies_alerted() -> bool:
    var enemies = get_tree().get_nodes_in_group("enemies")
    for enemy in enemies:
        if enemy.has_method("is_alerted") and enemy.is_alerted():
            return true
    return false
```

---

## SceneTree Utilities

### Tree Access and Queries

```gdscript
# Access scene tree:
var tree = get_tree()

# Get root viewport:
var root = tree.root

# Get current scene root:
var scene = tree.current_scene

# Get edited scene root (editor only):
var edited = tree.edited_scene_root

# Change scenes:
tree.change_scene_to_file("res://levels/level_2.tscn")
tree.change_scene_to_packed(level_scene)
tree.change_scene_to_node(pre_configured_scene)  # NEW 4.6

# Reload current scene:
tree.reload_current_scene()

# Quit application:
tree.quit()
tree.quit(exit_code)

# Frame/physics info:
var frame = Engine.get_process_frames()
var physics_frame = Engine.get_physics_frames()
var fps = Engine.get_frames_per_second()
```

### Pause System

```gdscript
# Pause/unpause:
get_tree().paused = true
get_tree().paused = false

# Process modes (set on nodes):
process_mode = Node.PROCESS_MODE_INHERIT      # Follow parent (default)
process_mode = Node.PROCESS_MODE_PAUSABLE     # Pause with tree
process_mode = Node.PROCESS_MODE_WHEN_PAUSED  # Only when paused (UI)
process_mode = Node.PROCESS_MODE_ALWAYS       # Never pause
process_mode = Node.PROCESS_MODE_DISABLED     # Never process

# Pause menu example:
class_name PauseMenu
extends Control

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED
    hide()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("pause"):
        toggle_pause()

func toggle_pause() -> void:
    var paused = get_tree().paused
    get_tree().paused = not paused
    visible = not paused
```

### Timers and Delays

```gdscript
# SceneTree timers (one-shot):
await get_tree().create_timer(3.0).timeout
print("3 seconds elapsed")

# With pause mode:
var timer = get_tree().create_timer(2.0, true, false, true)
# Args: time, process_always, process_in_physics, ignore_time_scale
await timer.timeout

# Defer call to next frame:
await get_tree().process_frame
print("Next frame")

# Defer to next physics frame:
await get_tree().physics_frame
print("Next physics frame")

# Timer node (reusable):
var timer = Timer.new()
timer.wait_time = 1.0
timer.one_shot = false
add_child(timer)
timer.timeout.connect(_on_timer_timeout)
timer.start()

func _on_timer_timeout() -> void:
    print("Timer tick")
```

### Node Queries and Traversal

```gdscript
# Find nodes by path:
var sprite = get_node("Path/To/Sprite")
var sprite2 = $Path/To/Sprite  # Shorthand

# Find with null safety:
var optional = get_node_or_null("MayNotExist")
if optional:
    optional.do_something()

# Find by unique name:
var unique_node = %UniqueNodeName

# Find parent/ancestors:
var parent = get_parent()
var parent_of_type = find_parent("EnemySpawner")

# Iterate children:
for child in get_children():
    print(child.name)

# Get child by index:
var first_child = get_child(0)
var last_child = get_child(-1)

# Count children:
var count = get_child_count()

# Check if has node:
var has_sprite = has_node("Sprite2D")

# Get path:
var path = get_path()  # Returns NodePath
var path_str = str(get_path())  # As string
```

### Node Reparenting

```gdscript
# Move node to new parent:
func reparent_node(node: Node, new_parent: Node) -> void:
    var old_parent = node.get_parent()
    if old_parent:
        old_parent.remove_child(node)
    new_parent.add_child(node)

# Reparent maintaining global transform:
func reparent_node2d(node: Node2D, new_parent: Node2D) -> void:
    var global_pos = node.global_position
    var global_rot = node.global_rotation
    var global_scale = node.global_scale

    node.get_parent().remove_child(node)
    new_parent.add_child(node)

    node.global_position = global_pos
    node.global_rotation = global_rot
    node.global_scale = global_scale

# NEW in 4.6 - reparent() method (future):
# node.reparent(new_parent, keep_global_transform)
```

---

## Global State Management

### Singleton Pattern (Autoloads)

```gdscript
# game_state.gd (Autoload as "GameState")
extends Node

# Persistent game state:
var player_name: String = ""
var level_unlocked: int = 1
var total_score: int = 0
var settings: Dictionary = {
    "music_volume": 0.8,
    "sfx_volume": 1.0,
    "fullscreen": false,
}

# Save/load:
func save_game() -> void:
    var save_data = {
        "player_name": player_name,
        "level_unlocked": level_unlocked,
        "total_score": total_score,
        "settings": settings,
    }

    var file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
    file.store_var(save_data)
    file.close()

func load_game() -> void:
    if not FileAccess.file_exists("user://savegame.dat"):
        return

    var file = FileAccess.open("user://savegame.dat", FileAccess.READ)
    var save_data = file.get_var()
    file.close()

    player_name = save_data.get("player_name", "")
    level_unlocked = save_data.get("level_unlocked", 1)
    total_score = save_data.get("total_score", 0)
    settings = save_data.get("settings", {})
```

### Scene-Based State (Preferred for Level State)

```gdscript
# level_manager.gd (scene-based, not autoload)
class_name LevelManager
extends Node

signal wave_completed(wave_number: int)
signal all_enemies_defeated

var current_wave: int = 0
var enemies_remaining: int = 0
var score: int = 0

func start_wave(wave_number: int) -> void:
    current_wave = wave_number
    enemies_remaining = calculate_enemy_count(wave_number)
    spawn_enemies()

func on_enemy_defeated() -> void:
    enemies_remaining -= 1
    score += 10

    if enemies_remaining <= 0:
        all_enemies_defeated.emit()
        wave_completed.emit(current_wave)

# This state is scene-specific and resets when level reloads
# Use autoloads only for truly persistent state
```

---

## Cross-Reference

**Related Guidelines**:
- Scene architecture → `02-scene-architecture.md`
- GDScript performance → `01-gdscript-modern-patterns.md#performance-patterns`
- Platform performance → `07-platform-performance.md`
- 2D rendering optimization → `04-2d-graphics-rendering.md#performance`

---

**Document Version**: 1.0
**Last Updated**: 2025-11-15
**Godot Version**: 4.6.0-dev4
**AI Optimization**: Maximum (memory patterns, pooling templates, group strategies)
