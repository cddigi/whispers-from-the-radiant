# Quick Reference Guide

**Purpose**: Fast lookup tables, common patterns, and decision trees for Godot 4.6
**Focus**: Rapid reference for AI code generation, pattern matching, common gotchas

---

## Common Patterns Quick Reference

### Scene Instantiation

```gdscript
# Pattern 1: Preload and instantiate
const EnemyScene = preload("res://enemy.tscn")

func spawn_enemy(position: Vector2) -> void:
    var enemy = EnemyScene.instantiate()
    enemy.global_position = position
    enemy.died.connect(_on_enemy_died)
    add_child(enemy)

# Pattern 2: Runtime load
func load_level(level_id: int) -> void:
    var path = "res://levels/level_%d.tscn" % level_id
    var scene = load(path)
    if scene:
        var level = scene.instantiate()
        add_child(level)

# Pattern 3: NEW in 4.6 - change_scene_to_node
var new_scene = MyScene.instantiate()
new_scene.configure(params)
get_tree().change_scene_to_node(new_scene)
```

### Signal Connection

```gdscript
# Pattern 1: Standard connection
player.health_changed.connect(_on_player_health_changed)

# Pattern 2: Lambda
button.pressed.connect(func(): print("Clicked"))

# Pattern 3: With binds
for i in 5:
    var button = Button.new()
    button.pressed.connect(_on_button_pressed.bind(i))
    add_child(button)

# Pattern 4: One-shot
player.died.connect(_on_player_died, CONNECT_ONE_SHOT)

# Pattern 5: Deferred
enemy.spawned.connect(_on_enemy_spawned, CONNECT_DEFERRED)
```

### Node Access

```gdscript
# Pattern 1: Cached @onready reference (BEST)
@onready var sprite: Sprite2D = $Sprite2D

# Pattern 2: Scene unique name
@onready var player: Player = %Player

# Pattern 3: Group access
var player = get_tree().get_first_node_in_group("player")

# Pattern 4: Dynamic with null check
var optional = get_node_or_null("MaybeExists")
if optional:
    optional.do_something()

# Pattern 5: Find parent
var spawner = find_parent("EnemySpawner")
```

---

## Decision Trees

### When to Use Scene vs Script

```
Need visual composition? (sprites, nodes arranged in space)
├─ YES → Scene (.tscn)
│   ├─ Will instantiate multiple times? → Scene
│   ├─ Needs testing in isolation? → Scene
│   └─ Complex node hierarchy? → Scene
└─ NO → Script (.gd)
    ├─ Pure logic/algorithms? → Script
    ├─ Data structure? → Resource script
    └─ Utility functions? → Static script class

Examples:
- Player character → Scene
- Enemy type → Scene
- UI widget → Scene
- Inventory data → Resource script
- Pathfinding algorithm → Static script
- State machine logic → Script
```

### Animation System Choice

```
What are you animating?

Simple sprite frames only?
└─ YES → AnimatedSprite2D
    ✓ Character walk cycles
    ✓ Flipbook animation
    ✓ Simple effects

Multiple properties? (position, rotation, scale, color)
└─ YES → AnimationPlayer
    ✓ Complex movements
    ✓ Multi-node coordination
    ✓ Method calls in animation

State-based with blending?
└─ YES → AnimationTree + AnimationPlayer
    ✓ Character locomotion
    ✓ Directional blending
    ✓ Smooth transitions

3D skeletal animation?
└─ YES → AnimationPlayer + Skeleton3D
    ├─ Need IK? → Add IKModifier3D (NEW 4.6)
    └─ Need physics bones? → Add SpringBoneSimulator3D
```

### Physics Body Choice

```
What physics behavior do you need?

Player/character movement (manual control)?
└─ CharacterBody2D/3D
    ✓ Player character
    ✓ AI-controlled enemy
    ✓ Moving platform

Realistic physics simulation?
└─ RigidBody2D/3D
    ✓ Crate, barrel, physics object
    ✓ Projectile with gravity
    ✓ Ragdoll

Static obstacle (never moves)?
└─ StaticBody2D/3D
    ✓ Floor, wall
    ✓ Static platform
    ✓ Collision barrier

Trigger zone (no collision)?
└─ Area2D/3D
    ✓ Damage zone
    ✓ Trigger area
    ✓ Sensor
```

### UI Layout Choice

```
How should children be arranged?

Vertical stack?
└─ VBoxContainer

Horizontal row?
└─ HBoxContainer

Grid pattern?
└─ GridContainer (set columns property)

Single child with padding?
└─ MarginContainer

Single child, scrollable?
└─ ScrollContainer

Single child, centered?
└─ CenterContainer

Two children, resizable split?
└─ VSplitContainer / HSplitContainer

Tabbed interface?
└─ TabContainer

Manual positioning?
└─ Control (no container)
```

---

## API Quick Reference

### Vector2/Vector3 Common Operations

```gdscript
# Distance
var dist = pos1.distance_to(pos2)
var dist_sq = pos1.distance_squared_to(pos2)  # Faster (no sqrt)

# Direction
var dir = pos1.direction_to(pos2)  # Normalized

# Normalization
var normalized = velocity.normalized()
var length = velocity.length()
var length_sq = velocity.length_squared()  # Faster

# Movement
position += velocity * delta
position = position.move_toward(target, speed * delta)
position = position.lerp(target, 0.1)  # Smooth interpolation

# Rotation
var angle = vector.angle()
var angle_to = from.angle_to(to)
var rotated = vector.rotated(angle)

# Common vectors
Vector2.ZERO     # (0, 0)
Vector2.ONE      # (1, 1)
Vector2.UP       # (0, -1)
Vector2.DOWN     # (0, 1)
Vector2.LEFT     # (-1, 0)
Vector2.RIGHT    # (1, 0)
```

### Transform2D/3D Operations

```gdscript
# Position
transform.origin = Vector2(100, 100)

# Rotation
transform = transform.rotated(angle)
global_rotation = angle

# Scale
transform = transform.scaled(Vector2(2, 2))
scale = Vector2(2, 2)

# Look at
look_at(target_position)
global_transform = global_transform.looking_at(target)

# Direction vectors (3D)
var forward = -global_transform.basis.z
var right = global_transform.basis.x
var up = global_transform.basis.y
```

### Input Common Patterns

```gdscript
# Button pressed this frame
if Input.is_action_just_pressed("jump"):
    jump()

# Button held
if Input.is_action_pressed("fire"):
    shoot()

# Button released this frame
if Input.is_action_just_released("charge"):
    release_charge()

# Axis input (-1 to 1)
var horizontal = Input.get_axis("left", "right")
var vertical = Input.get_axis("up", "down")

# Vector input
var input_dir = Input.get_vector("left", "right", "up", "down")

# Mouse position
var mouse_pos = get_global_mouse_position()
var viewport_mouse_pos = get_viewport().get_mouse_position()
```

### Timer Patterns

```gdscript
# SceneTree one-shot timer
await get_tree().create_timer(2.0).timeout
print("2 seconds elapsed")

# Defer to next frame
await get_tree().process_frame
print("Next frame")

# Defer to next physics frame
await get_tree().physics_frame
print("Next physics frame")

# Timer node (reusable)
var timer = Timer.new()
timer.wait_time = 1.0
timer.one_shot = false
timer.autostart = true
add_child(timer)
timer.timeout.connect(_on_timer_timeout)
```

### Random Number Generation

```gdscript
# Random int between min and max (inclusive)
var random_int = randi_range(1, 10)

# Random float between min and max
var random_float = randf_range(0.0, 1.0)

# Random boolean
var random_bool = randf() > 0.5

# Random element from array
var items = ["sword", "shield", "potion"]
var random_item = items[randi() % items.size()]

# Random position in rectangle
var random_pos = Vector2(
    randf_range(0, 1000),
    randf_range(0, 600)
)

# Random direction
var random_direction = Vector2.RIGHT.rotated(randf() * TAU)
```

---

## Common Gotchas and Solutions

### Float Comparison

```gdscript
# WRONG - Precision issues
if value == 0.3:
    print("Equal")

# CORRECT - Use epsilon comparison
if is_equal_approx(value, 0.3):
    print("Equal")

# For zero
if is_zero_approx(value):
    print("Essentially zero")
```

### Null Safety

```gdscript
# WRONG - Will crash if null
var player = get_tree().get_first_node_in_group("player")
player.take_damage(10)

# CORRECT - Always check
var player = get_tree().get_first_node_in_group("player")
if player:
    player.take_damage(10)

# OR use assertion in development
var player = get_tree().get_first_node_in_group("player")
assert(player != null, "Player not found!")
player.take_damage(10)
```

### String Conversion (4.5+ Breaking Change)

```gdscript
# WRONG in 4.5+
var pos = Vector2(10, 20)
var text = String(pos)  # COMPILE ERROR

# CORRECT
var text = str(pos)
# OR
var text = "%v" % pos
# OR
var text = var_to_str(pos)
```

### Node Deletion

```gdscript
# WRONG - Memory leak
remove_child(node)  # Still in memory!

# CORRECT - Remove and free
remove_child(node)
node.queue_free()

# OR just free (removes automatically)
node.queue_free()
```

### Signal Disconnection

```gdscript
# WRONG - Can cause errors if signal outlives listener
func _ready():
    player.died.connect(_on_player_died)
# If this node is freed before player, crash!

# CORRECT - Disconnect in cleanup
func _exit_tree():
    if player and player.died.is_connected(_on_player_died):
        player.died.disconnect(_on_player_died)
```

### Export Variable Mutation

```gdscript
# WRONG - Overwrites designer's value
@export var max_health: int = 100

func _ready():
    max_health = 200  # Overwrites inspector value!

# CORRECT - Separate base and runtime
@export var base_max_health: int = 100
var max_health: int = 100

func _ready():
    max_health = base_max_health
    max_health += get_health_bonus()
```

---

## Performance Quick Checks

### Arrays and Collections

```gdscript
# ✓ FAST - Pre-allocate (NEW 4.6)
var items: Array[Item] = []
items.reserve(1000)
for i in 1000:
    items.append(create_item())

# ✓ FAST - Iterate without allocation
for item in items:
    item.update()

# ✗ SLOW - Repeated reallocations
var items: Array[Item] = []
for i in 1000:
    items.append(create_item())  # Reallocates multiple times
```

### Node References

```gdscript
# ✓ FAST - Cached reference
@onready var sprite: Sprite2D = $Sprite2D

func _process(delta):
    sprite.rotation += delta

# ✗ SLOW - Tree search every frame
func _process(delta):
    $Sprite2D.rotation += delta  # Searches tree each frame
```

### StringName Usage

```gdscript
# ✓ FAST - Cached StringName
const ACTION_FIRE: StringName = &"fire"

func _process(delta):
    if Input.is_action_pressed(ACTION_FIRE):
        shoot()

# ✗ SLOW - String allocation every frame
func _process(delta):
    if Input.is_action_pressed("fire"):  # Allocates string
        shoot()
```

### Heavy Processing

```gdscript
# ✓ CORRECT - Use timer for expensive operations
@onready var pathfinding_timer: Timer = $PathfindingTimer

func _ready():
    pathfinding_timer.timeout.connect(_recalculate_path)
    pathfinding_timer.start(0.5)  # Every 0.5 seconds

var _current_path: Array[Vector2] = []

func _recalculate_path():
    _current_path = find_path_to_player()

func _process(delta):
    follow_path(_current_path)

# ✗ WRONG - Expensive operation every frame
func _process(delta):
    var path = find_path_to_player()  # A* every frame!
    follow_path(path)
```

---

## Type Reference Tables

### Node Type Selection

| Need | Use | Example |
|------|-----|---------|
| 2D sprite | Sprite2D | Player character visual |
| Frame animation | AnimatedSprite2D | Character run cycle |
| 2D physics character | CharacterBody2D | Player movement |
| 2D physics object | RigidBody2D | Crate, barrel |
| 2D static collision | StaticBody2D | Floor, wall |
| 2D trigger zone | Area2D | Damage zone |
| 2D tilemap | TileMapLayer | Level terrain |
| 2D camera | Camera2D | Follow player |
| 3D model | MeshInstance3D | 3D object |
| 3D physics character | CharacterBody3D | FPS character |
| 3D physics object | RigidBody3D | Physics prop |
| 3D static collision | StaticBody3D | Level geometry |
| 3D trigger zone | Area3D | Trigger volume |
| 3D camera | Camera3D | Player view |
| UI container | VBoxContainer/HBoxContainer | Menu layout |
| UI button | Button | Click interaction |
| UI label | Label | Text display |
| UI input | LineEdit | Text input |
| Timer | Timer | Delayed actions |
| Animation | AnimationPlayer | Property animation |

### Collision Layer Recommendations

| Layer | Purpose | Collides With |
|-------|---------|---------------|
| 1 | World | Player, Enemies, Projectiles |
| 2 | Player | World, Enemies, Items |
| 3 | Enemies | World, Player, Projectiles |
| 4 | Projectiles | World, Enemies (not Player) |
| 5 | Items | Player |
| 6 | Triggers | Player, Enemies |
| 7 | Hazards | Player, Enemies |
| 8 | Platforms | Player, Enemies |

---

## Breaking Changes Summary (4.5-4.6)

| Change | Old | New | Impact |
|--------|-----|-----|--------|
| String conversion | `String(vector)` | `str(vector)` | HIGH |
| Object script access | `obj.script` | `obj.get_script()` | LOW |
| Windows support | Windows 7+ | Windows 10+ | HIGH |
| Android API | API 21 | API 24 | MEDIUM |
| .NET version | .NET 6.0 | .NET 8.0 | HIGH |
| IK system | SkeletonIK | IKModifier3D | MEDIUM |
| Physics default (new) | GodotPhysics | Jolt | LOW (compatible) |
| Scene change (new) | N/A | `change_scene_to_node()` | N/A (addition) |
| Array reserve (new) | N/A | `array.reserve()` | N/A (addition) |

---

## Migration Checklist

### Upgrading from 4.4 to 4.5+

- [ ] Replace `String(value)` with `str(value)` for non-string types
- [ ] Replace `obj.script` with `obj.get_script()`
- [ ] Update Windows minimum to 10
- [ ] Update Android minimum to API 24
- [ ] Update .NET projects to target 8.0
- [ ] Replace `abstract func` with `@abstract`
- [ ] Consider using `const` for static arrays/dictionaries

### Upgrading from 4.5 to 4.6

- [ ] Replace `SkeletonIK` with `IKModifier3D`
- [ ] Consider enabling Jolt Physics for new projects
- [ ] Use `array.reserve()` for large collections
- [ ] Use `change_scene_to_node()` for pre-configured scenes
- [ ] Review pivot_offset for pivot_offset_ratio where appropriate
- [ ] Test FileDialog improvements
- [ ] Update export templates

---

## File Organization Template

```
project/
├── .godot/              # Engine files (gitignore)
├── assets/              # Scene-based organization
│   ├── player/
│   │   ├── player.tscn
│   │   ├── player.gd
│   │   ├── player_sprite.png
│   │   └── player_animations.tres
│   ├── enemies/
│   │   ├── goblin/
│   │   └── orc/
│   ├── items/
│   └── ui/
├── common/              # Shared resources
│   ├── shaders/
│   ├── materials/
│   ├── audio/
│   └── fonts/
├── autoloads/           # Global singletons
│   ├── audio_manager.gd
│   ├── events.gd
│   └── save_manager.gd
├── levels/
│   ├── level_1.tscn
│   └── level_2.tscn
├── project.godot
└── icon.svg
```

---

## Cross-Reference Index

- **GDScript patterns** → `01-gdscript-modern-patterns.md`
- **Scene architecture** → `02-scene-architecture.md`
- **Memory/pooling** → `03-core-systems.md`
- **2D rendering** → `04-2d-graphics-rendering.md`
- **Animation/physics** → `05-animation-physics-3d.md`
- **UI/controls** → `06-ui-and-controls.md`
- **Platform/performance** → `07-platform-performance.md`
- **Version migration** → `00-version-and-migration.md`

---

**Document Version**: 1.0
**Last Updated**: 2025-11-15
**Godot Version**: 4.6.0-dev4
**AI Optimization**: Maximum (quick lookup, decision trees, pattern matching, gotcha prevention)
