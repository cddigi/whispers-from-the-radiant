# GDScript 4.6 Modern Patterns

**Purpose**: Comprehensive GDScript patterns for Godot 4.6, optimized for AI code generation
**Focus**: Type safety, performance, modern idioms, and 4.6-specific features

---

## Naming Conventions (Official Godot Standard)

### File Naming
```gdscript
# Pattern: snake_case matching scene root node name
# Scene root: WeaponPickup → Files: weapon_pickup.tscn, weapon_pickup.gd
# Scene root: EnemySpawner → Files: enemy_spawner.tscn, enemy_spawner.gd

# Benefits:
# - Instant searchability (type "weapon" finds all weapon-related files)
# - Clear scene-to-script association
# - Consistent with Godot's internal naming
```

### Code Naming Rules

| Element | Convention | Example |
|---------|-----------|---------|
| **Files** | snake_case | `player_controller.gd` |
| **Classes** | PascalCase | `class_name PlayerController` |
| **Variables** | snake_case | `var current_health: int` |
| **Functions** | snake_case (verb-noun) | `func calculate_damage()` |
| **Constants** | CONSTANT_CASE | `const MAX_SPEED = 300` |
| **Enums** | PascalCase | `enum State { IDLE, RUNNING }` |
| **Enum Members** | CONSTANT_CASE | `State.IDLE` |
| **Signals** | snake_case (past tense) | `signal door_opened` |
| **Private Members** | _snake_case | `var _internal_state: int` |
| **Node Names** | PascalCase | `$PlayerSprite`, `$CollisionShape` |

### Signal Naming (Critical Pattern)

```gdscript
# CORRECT - Past tense (events that happened):
signal health_changed(new_health: int)
signal door_opened
signal animation_finished
signal item_collected(item_type: String)
signal player_died

# WRONG - Present tense or imperative (creates confusion):
signal change_health  # Sounds like a command
signal open_door  # Is this triggering or reporting?
signal door_opens  # Ambiguous timing

# Durative actions (has start and end):
signal dialogue_started
signal dialogue_finished
signal attack_started
signal attack_finished
```

**Rationale**: Signals represent events that already occurred. Past tense makes this explicit and prevents confusion about causation.

### Function Naming Patterns

```gdscript
# Descriptive verb-noun combinations:
func calculate_damage(base: int, multiplier: float) -> int
func get_nearest_enemy() -> Enemy
func apply_status_effect(effect: StatusEffect) -> void
func is_player_in_range() -> bool
func has_required_item(item_id: String) -> bool

# Avoid abbreviations:
# WRONG: func calc_dmg(), func get_nrst_enmy()
# RIGHT: func calculate_damage(), func get_nearest_enemy()

# Private function convention:
func _recalculate_pathfinding() -> void
func _update_internal_state() -> void
var _cached_distance: float
```

**AI Code Generation Rule**: Always use explicit, searchable names over abbreviations.

---

## Type System (4.6 Enhanced)

### Strict Typing Requirements

```gdscript
# Project Settings configuration:
# Debug → GDScript → Untyped Declaration: Error
# Debug → GDScript → Unsafe Method Access: Error

# These settings enforce type discipline project-wide
```

### Variable Type Hints

```gdscript
# Explicit typing (always prefer for clarity):
var health: int = 100
var speed: float = 5.5
var player_name: String = "Hero"
var position: Vector2 = Vector2(10, 20)

# Type inference with := (when type is obvious):
var velocity := Vector2.ZERO  # Clearly Vector2
var count := 0  # WRONG - ambiguous (int or float?)
var count: int = 0  # CORRECT - explicit for primitives

# Typed collections (4.5+):
var enemies: Array[Enemy] = []
var projectiles: Array[Projectile] = []
var damage_numbers: Array[float] = [10.5, 25.0, 30.5]

# Typed dictionaries (4.5+):
var player_scores: Dictionary[String, int] = {}
var entity_data: Dictionary[int, EntityData] = {}

# NEW in 4.5 - Constant constructors:
const WEAPON_TYPES: Array[String] = ["sword", "bow", "staff"]
const DEFAULT_SETTINGS: Dictionary = {"volume": 0.8, "fullscreen": false}
```

### Function Signatures

```gdscript
# Always type parameters and return values:
func heal(amount: int) -> void:
    health += amount
    health = min(health, max_health)

func get_move_direction() -> Vector2:
    return Vector2(
        Input.get_axis("move_left", "move_right"),
        Input.get_axis("move_up", "move_down")
    )

# Multiple return types use Variant (use sparingly):
func find_entity(id: int) -> Variant:  # Can return Entity or null
    if id in entities:
        return entities[id]
    return null

# Better approach - use null-safe patterns:
func find_entity_safe(id: int) -> Enemy:
    if id in entities:
        return entities[id]
    return null  # Caller must check for null
```

### Node Reference Typing (Critical)

```gdscript
# WRONG - No type information:
@onready var sprite = $Sprite2D  # Type is Node, loses autocomplete

# CORRECT - Explicit typing:
@onready var sprite: Sprite2D = $Sprite2D
# OR with cast:
@onready var sprite := $Sprite2D as Sprite2D
# OR with typed get_node:
@onready var sprite := get_node("Sprite2D") as Sprite2D

# Multiple node references:
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

# Optional node references (may not exist):
@onready var optional_sprite: Sprite2D = get_node_or_null("Sprite") as Sprite2D

# Dynamic node access (requires checking):
var child_node := get_node_or_null("DynamicChild") as Node2D
if child_node:
    child_node.position += Vector2(10, 0)
```

**Why This Matters**: Without explicit types, the editor treats nodes as generic `Node`, losing all autocompletion and compile-time checking. This is the #1 typing mistake.

### Abstract Classes (NEW in 4.5)

```gdscript
# Define abstract base class:
@abstract
class_name BaseEnemy extends CharacterBody2D

## Abstract methods MUST be implemented by derived classes
@abstract
func take_damage(amount: float) -> void:
    pass  # No implementation in base class

@abstract
func get_reward_value() -> int:
    pass

# Can mix abstract and concrete methods:
func move_toward_target(target: Vector2, delta: float) -> void:
    # Concrete implementation available to all derived classes
    velocity = position.direction_to(target) * speed
    move_and_slide()

# Concrete implementation:
class_name Goblin extends BaseEnemy

# MUST implement abstract methods:
func take_damage(amount: float) -> void:
    health -= amount
    if health <= 0:
        die()

func get_reward_value() -> int:
    return 10

# Attempting to instantiate abstract class causes error:
# var enemy = BaseEnemy.new()  # ERROR: Cannot instantiate abstract class
```

**Use Cases**:
- Plugin systems requiring specific interface implementation
- State machines with abstract state interface
- Game systems with enforced contracts
- Factory patterns

### Variant Type (Use Sparingly)

```gdscript
# NEW in 4.5 - Export Variant:
@export var flexible_property: Variant

# Use when type is truly dynamic:
func process_message(data: Variant) -> void:
    if data is String:
        print("Message: ", data)
    elif data is Dictionary:
        print("Data packet: ", data)
    elif data is PackedScene:
        instantiate_scene(data)

# Better approach - use specific types when possible:
# Instead of Variant, use inheritance:
class_name Message extends Resource
@export var content: String

class_name DataMessage extends Message
@export var payload: Dictionary

# Type-safe processing:
func process_message_safe(msg: Message) -> void:
    print(msg.content)
    if msg is DataMessage:
        print((msg as DataMessage).payload)
```

---

## Script Organization (Standard Structure)

### Complete Script Template

```gdscript
# ============================================================================
# SECTION 1: Tool and Icon Annotations
# ============================================================================
@tool  # Makes script run in editor
@icon("res://icons/player.svg")  # Custom icon in scene tree

# ============================================================================
# SECTION 2: Class Declaration
# ============================================================================
class_name Player  # Global class name
extends CharacterBody2D  # Inheritance

# ============================================================================
# SECTION 3: Documentation
# ============================================================================
## Player controller for platformer movement.
##
## Handles input processing, physics-based movement, and animation states.
## Emits signals for gameplay events like health changes and death.

# ============================================================================
# SECTION 4: Signals (Past Tense)
# ============================================================================
signal health_changed(new_health: int)
signal died
signal item_collected(item_type: String, quantity: int)
signal ability_used(ability_name: String)

# ============================================================================
# SECTION 5: Enums
# ============================================================================
enum State {
    IDLE,
    RUNNING,
    JUMPING,
    FALLING,
    ATTACKING,
}

enum Faction {
    PLAYER,
    ENEMY,
    NEUTRAL,
}

# ============================================================================
# SECTION 6: Constants (CONSTANT_CASE)
# ============================================================================
const MAX_SPEED: float = 300.0
const JUMP_VELOCITY: float = -500.0
const ACCELERATION: float = 1500.0
const FRICTION: float = 1200.0

# NEW in 4.5 - Constant arrays/dictionaries:
const VALID_STATES: Array[int] = [State.IDLE, State.RUNNING, State.JUMPING]
const STATE_SPEEDS: Dictionary = {
    State.IDLE: 0.0,
    State.RUNNING: MAX_SPEED,
    State.JUMPING: MAX_SPEED * 0.8,
}

# ============================================================================
# SECTION 7: Exported Variables (@export)
# ============================================================================
@export_category("Health")
@export var max_health: int = 100
@export var regeneration_rate: float = 5.0

@export_category("Movement")
@export var max_speed: float = MAX_SPEED
@export var jump_strength: float = JUMP_VELOCITY

@export_category("References")
@export var weapon_scene: PackedScene
@export var hit_effect: PackedScene

# NEW in 4.5 - File path export (no UID):
@export_file_path("*.json") var config_file: String

# ============================================================================
# SECTION 8: Public Variables
# ============================================================================
var health: int = 100
var is_invulnerable: bool = false
var current_state: State = State.IDLE
var facing_direction: int = 1  # 1 = right, -1 = left

# ============================================================================
# SECTION 9: Private Variables (_underscore prefix)
# ============================================================================
var _velocity_history: Array[Vector2] = []
var _last_ground_position: Vector2 = Vector2.ZERO
var _input_buffer: Array[String] = []

# ============================================================================
# SECTION 10: @onready Variables (Node References)
# ============================================================================
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

# ============================================================================
# SECTION 11: Built-in Virtual Methods (Lifecycle Order)
# ============================================================================
func _ready() -> void:
    health = max_health
    animation_player.play("idle")

func _process(delta: float) -> void:
    _update_animation_state()

func _physics_process(delta: float) -> void:
    _handle_movement(delta)
    move_and_slide()

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("jump"):
        _attempt_jump()

# ============================================================================
# SECTION 12: Public Methods (External API)
# ============================================================================
func take_damage(amount: int) -> void:
    if is_invulnerable:
        return

    health -= amount
    health = max(health, 0)
    health_changed.emit(health)

    if health <= 0:
        die()

func heal(amount: int) -> void:
    health = min(health + amount, max_health)
    health_changed.emit(health)

func set_invulnerable(enabled: bool, duration: float = 0.0) -> void:
    is_invulnerable = enabled
    if duration > 0.0:
        await get_tree().create_timer(duration).timeout
        is_invulnerable = false

# ============================================================================
# SECTION 13: Private Methods (Internal Implementation)
# ============================================================================
func _handle_movement(delta: float) -> void:
    var input_dir := Input.get_axis("move_left", "move_right")

    if input_dir != 0:
        velocity.x = move_toward(velocity.x, input_dir * max_speed, ACCELERATION * delta)
        facing_direction = sign(input_dir)
    else:
        velocity.x = move_toward(velocity.x, 0, FRICTION * delta)

    velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

func _update_animation_state() -> void:
    if not is_on_floor():
        animation_player.play("jump" if velocity.y < 0 else "fall")
    elif velocity.x != 0:
        animation_player.play("run")
        sprite.flip_h = velocity.x < 0
    else:
        animation_player.play("idle")

func _attempt_jump() -> void:
    if is_on_floor():
        velocity.y = JUMP_VELOCITY
        audio_player.play()

# ============================================================================
# SECTION 14: Signal Callbacks (_on_ prefix)
# ============================================================================
func _on_hurt_box_area_entered(area: Area2D) -> void:
    if area.is_in_group("enemy_attacks"):
        take_damage(10)

func _on_animation_player_animation_finished(anim_name: String) -> void:
    if anim_name == "death":
        queue_free()

func _on_heal_timer_timeout() -> void:
    if health < max_health:
        heal(int(regeneration_rate))
```

**Ordering Rationale**:
1. Properties before methods (understand state first)
2. Public before private (external API is most important)
3. Virtual callbacks first (lifecycle understanding)
4. Signal callbacks last (event handling is often last concern)

---

## Performance Patterns (4.6 Optimized)

### Collection Pre-allocation (NEW in 4.6)

```gdscript
# NEW in 4.6 - reserve() method for arrays, dictionaries, strings:

# Array pre-allocation (avoids reallocations):
var entities: Array[Entity] = []
entities.reserve(1000)  # Pre-allocate for 1000 elements
for i in 1000:
    entities.append(create_entity())

# Dictionary pre-allocation:
var entity_lookup: Dictionary[int, Entity] = {}
entity_lookup.reserve(500)  # Pre-allocate capacity
for entity in entities:
    entity_lookup[entity.id] = entity

# String pre-allocation (for string building):
var log_text := ""
log_text.reserve(10000)  # Pre-allocate for large string
for i in 100:
    log_text += "Log entry %d\n" % i
```

**Performance Impact**: Eliminates repeated reallocations, especially important for large collections.

### StringName for Performance (Critical)

```gdscript
# StringName (&"string") is cached and faster for:
# - Signal names
# - Node names
# - Group names
# - Action names
# - Animation names

# SLOW (creates new String each frame):
func _process(delta):
    if Input.is_action_pressed("move_left"):  # String allocation
        move_left()

# FAST (cached StringName):
const ACTION_MOVE_LEFT: StringName = &"move_left"

func _process(delta):
    if Input.is_action_pressed(ACTION_MOVE_LEFT):  # No allocation
        move_left()

# Node access optimization:
const NODE_SPRITE: StringName = &"Sprite2D"

func _ready():
    var sprite = get_node(NODE_SPRITE)  # Faster lookup

# Group usage:
const GROUP_ENEMIES: StringName = &"enemies"

func alert_enemies():
    get_tree().call_group(GROUP_ENEMIES, "on_alert")
```

### Node Iteration (NEW in 4.6 - C++/GDExtension)

```cpp
// NEW in 4.6: iterate_children() - faster than get_children()
// (Note: GDScript equivalent would use for child in get_children())

// C++ pattern (GDExtension):
node->iterate_children([](Node *child) {
    // Process child without array allocation
    child->queue_free();
    return false;  // return true to stop early
});

// GDScript equivalent (no direct iterate_children in GDScript):
# Standard pattern (still allocates array):
for child in get_children():
    child.queue_free()

# If performance critical, cache children array:
@onready var _children_cache: Array[Node] = []

func _ready():
    _children_cache.assign(get_children())  # Cache once

func process_children():
    for child in _children_cache:
        # Process without repeated get_children() calls
        pass
```

### Cache Node References

```gdscript
# SLOW (tree search every frame):
func _process(delta):
    $Sprite2D.rotation += delta
    $Sprite2D.position.x += 1

# FAST (cached reference):
@onready var sprite: Sprite2D = $Sprite2D

func _process(delta):
    sprite.rotation += delta
    sprite.position.x += 1

# Group access caching:
@onready var _enemies: Array[Node] = []

func _ready():
    _enemies.assign(get_tree().get_nodes_in_group("enemies"))
    # Re-cache when enemies spawn/die

func damage_all_enemies():
    for enemy in _enemies:
        enemy.take_damage(10)
```

### Avoid Heavy Operations in _process()

```gdscript
# WRONG - Expensive operation every frame:
func _process(delta):
    var path = _find_path_to_player()  # A* pathfinding
    follow_path(path)

# CORRECT - Use timer for expensive operations:
@onready var pathfinding_timer: Timer = $PathfindingTimer

func _ready():
    pathfinding_timer.timeout.connect(_recalculate_path)
    pathfinding_timer.start(0.5)  # Recalculate every 0.5 seconds

var _current_path: Array[Vector2] = []

func _recalculate_path():
    _current_path = _find_path_to_player()

func _process(delta):
    if _current_path.size() > 0:
        follow_path(_current_path)
```

---

## Memory Management

### Node Lifecycle

```gdscript
# Creating nodes:
var enemy = preload("res://enemy.tscn").instantiate()
add_child(enemy)

# Safe deletion (default):
enemy.queue_free()  # Deleted at end of current frame

# Immediate deletion (dangerous):
enemy.free()  # Deleted NOW - can crash if referenced elsewhere

# WRONG - Memory leak:
remove_child(enemy)  # Enemy still in memory, just not in tree!

# CORRECT - Remove and free:
remove_child(enemy)
enemy.queue_free()

# Self-deletion in signal handler:
func _on_death():
    queue_free()  # Safe - waits for frame end
```

### Object Pooling Pattern

```gdscript
# For high-frequency instantiation (bullets, particles, etc.):
class_name ObjectPool extends Node

var _pool: Array[Node] = []
var _scene: PackedScene
var _pool_size: int

func _init(scene: PackedScene, size: int):
    _scene = scene
    _pool_size = size

func _ready():
    # Pre-instantiate pool:
    _pool.reserve(_pool_size)
    for i in _pool_size:
        var obj = _scene.instantiate()
        obj.process_mode = Node.PROCESS_MODE_DISABLED
        obj.hide()
        add_child(obj)
        _pool.append(obj)

func acquire() -> Node:
    if _pool.is_empty():
        # Expand pool if needed:
        var obj = _scene.instantiate()
        add_child(obj)
        return obj

    var obj = _pool.pop_back()
    obj.process_mode = Node.PROCESS_MODE_INHERIT
    obj.show()
    return obj

func release(obj: Node) -> void:
    obj.process_mode = Node.PROCESS_MODE_DISABLED
    obj.hide()
    _pool.append(obj)
```

---

## Common Pitfalls and Solutions

### Null Safety

```gdscript
# WRONG - Will crash if node doesn't exist:
func damage_player():
    var player = get_tree().get_first_node_in_group("player")
    player.take_damage(10)  # CRASH if no player

# CORRECT - Always check for null:
func damage_player():
    var player = get_tree().get_first_node_in_group("player")
    if player:
        player.take_damage(10)

# Development assertions:
func damage_player():
    var player = get_tree().get_first_node_in_group("player")
    assert(player != null, "Player not found in scene!")
    player.take_damage(10)  # Only runs after assertion passes
```

### Float Comparison

```gdscript
# WRONG - Float precision issues:
var value = 0.1 + 0.2
if value == 0.3:  # FALSE due to precision!
    print("Equal")

# CORRECT - Use epsilon comparison:
if is_equal_approx(value, 0.3):
    print("Equal")

# For zero checks:
if is_zero_approx(value):
    print("Essentially zero")

# Custom epsilon:
const EPSILON = 0.001
if abs(value - target) < EPSILON:
    print("Close enough")
```

### Export Variable Mutation

```gdscript
# WRONG - Overwrites designer's inspector value:
@export var max_health: int = 100

func _ready():
    max_health = 200  # Overwrites what designer set!

# CORRECT - Separate base and runtime values:
@export var base_max_health: int = 100
var max_health: int = 100

func _ready():
    max_health = base_max_health
    # Apply runtime modifiers:
    max_health += get_health_bonus()
```

### String Conversion (4.5+ Breaking Change)

```gdscript
# WRONG in 4.5+:
var pos = Vector2(10, 20)
var text = String(pos)  # COMPILE ERROR

# CORRECT:
var text = str(pos)
# OR:
var text = "%v" % pos
# OR:
var text = var_to_str(pos)
```

---

## Modern Idioms Summary

```gdscript
# Type everything:
var health: int = 100
var enemies: Array[Enemy] = []

# Use abstract classes for interfaces:
@abstract
class_name BaseState

# Reserve collections when size known:
var items: Array[Item] = []
items.reserve(1000)

# Use StringName for repeated lookups:
const ACTION_FIRE: StringName = &"fire"

# Cache node references:
@onready var sprite: Sprite2D = $Sprite2D

# Use const for static data:
const SPEEDS: Array[float] = [100.0, 200.0, 300.0]

# Check for null:
if node:
    node.do_something()

# Use timers for expensive operations:
# Not in _process() / _physics_process()

# queue_free() over free():
enemy.queue_free()
```

---

## Cross-References

- Scene architecture → `02-scene-architecture.md`
- Type migration from 4.5 → `00-version-and-migration.md#string-conversion-changes`
- Performance optimization → `07-platform-performance.md#performance-patterns`
- Abstract classes → `00-version-and-migration.md#abstract-classes`

---

**Document Version**: 1.0
**Last Updated**: 2025-11-15
**Godot Version**: 4.6.0-dev4
**AI Optimization Level**: Maximum (pattern templates, decision trees, quick reference tables)
