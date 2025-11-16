# Scene Architecture and Communication Patterns

**Purpose**: Comprehensive scene design patterns for Godot 4.6, optimized for AI code generation
**Focus**: Scene composition, parent-child communication, signals, resources, and 4.6-specific improvements

---

## Scene Composition Fundamentals

### Scenes vs Nodes

**Definition**:
- **Node**: Single component/entity in the scene tree
- **Scene**: Reusable node tree saved as `.tscn` file (collection of nodes with relationships)

| Aspect | Nodes | Scenes |
|--------|-------|--------|
| **Purpose** | Individual components | Reusable compositions |
| **File format** | Part of parent scene | `.tscn` file |
| **Reusability** | Single instance | Multiple instances |
| **Editing** | Direct in parent | Edit as separate scene |
| **Complexity** | Simple | Can contain sub-scenes |

```gdscript
# When to create a NEW SCENE:
# ✓ Component will be instantiated multiple times (enemies, bullets, UI widgets)
# ✓ Component should be testable in isolation
# ✓ Component has clear responsibility boundary
# ✓ Component will be shared across projects

# When to keep as NODES in parent:
# ✓ Functionality specific to THIS scene only
# ✓ Helper nodes (Timers, internal collision shapes)
# ✓ Layout/organizational nodes
# ✓ One-off configurations
```

### Scene Hierarchy Design

```gdscript
# GOOD - Clear hierarchy with distinct responsibilities:
Main (Node)
├── GameManager (Node)                 # Game state/logic
├── LevelContainer (Node)
│   └── Level1 (Scene Instance)         # Reusable level
│       ├── Environment (Node2D)
│       ├── Entities (Node)
│       │   ├── Player (Scene)          # Reusable character
│       │   └── Enemies (Node)
│       │       ├── Goblin (Scene)      # Instanced multiple times
│       │       └── Goblin (Scene)
│       └── SpawnPoints (Node)
└── UILayer (CanvasLayer)
    └── HUD (Scene Instance)             # Reusable UI

# BAD - Flat, unorganized, no reuse:
Main (Node)
├── Player (CharacterBody2D)            # Embedded, can't reuse
├── Goblin1 (CharacterBody2D)           # Duplicated code
├── Goblin2 (CharacterBody2D)           # Should be scene instances
├── HealthBar (Control)                 # Can't reuse
└── ScoreLabel (Label)
```

**Principles**:
1. **Group related nodes** under organizational parents
2. **Extract reusable components** as scenes
3. **Keep hierarchy depth reasonable** (3-5 levels maximum)
4. **Use descriptive names** (not "Node2D", "Sprite2D")

### Self-Contained Scenes

```gdscript
# player.tscn - SELF-CONTAINED design
Player (CharacterBody2D)                # Root node with script
├── Sprite (Sprite2D)                   # Visual representation
├── CollisionShape (CollisionShape2D)   # Physics shape
├── AnimationPlayer (AnimationPlayer)   # Animations
├── AudioPlayer (AudioStreamPlayer2D)   # Sound effects
└── HurtBox (Area2D)                    # Damage detection
    └── CollisionShape (CollisionShape2D)

# player.gd - Scene script attached to root
class_name Player
extends CharacterBody2D

signal health_changed(new_health: int)
signal died

@export var max_health: int = 100

# Only reference DIRECT children (self-contained):
@onready var sprite: Sprite2D = $Sprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

# External dependencies via exports (dependency injection):
@export var spawn_point: Marker2D

func _ready() -> void:
    if spawn_point:
        global_position = spawn_point.global_position
```

**Self-Containment Rules**:
- **All required nodes** are children of the scene root
- **One script** attached to root node (controller script)
- **No external node references** (use signals or exports)
- **Complete functionality** without parent scene
- **Testable in isolation** (can run scene alone)

---

## Parent-Child Communication

### The Golden Rule: Call Down, Signal Up

```gdscript
# PATTERN 1: Parent calls methods on children (call down)
# Parent knows about children and can command them directly

# level.gd (Parent)
@onready var player: Player = $Player
@onready var enemy: Enemy = $Enemy

func _ready() -> void:
    # Parent can call child methods directly:
    player.set_spawn_point(Vector2(100, 100))
    player.heal(50)
    enemy.set_target(player)

# PATTERN 2: Children signal events upward (signal up)
# Children don't know about parent, just emit signals

# enemy.gd (Child)
signal died(enemy_type: String, position: Vector2)

func take_lethal_damage() -> void:
    died.emit("goblin", global_position)  # Child signals event
    queue_free()

# level.gd (Parent listens)
func _ready() -> void:
    $Enemy.died.connect(_on_enemy_died)

func _on_enemy_died(enemy_type: String, position: Vector2) -> void:
    score += get_enemy_value(enemy_type)
    spawn_loot(enemy_type, position)
```

**Why This Pattern**:
- **Decouples children from parents** (children are reusable)
- **Parents maintain control** (orchestration layer)
- **Children remain testable** (no parent dependencies)
- **Signals enable multiple listeners** (flexible event system)

### Communication Patterns by Relationship

| Relationship | Pattern | Method |
|--------------|---------|--------|
| Parent → Child | Direct method call | `$Child.do_something()` |
| Child → Parent | Signal | `signal event_occurred` |
| Sibling → Sibling | Via parent signal | Signal to parent, parent calls sibling |
| Cousin → Cousin | Groups or event bus | `get_tree().call_group()` or global Events |
| Any → Any (loose) | Event bus | Autoload with signals |

### Cross-Branch Communication (AVOID Direct References)

```gdscript
# WRONG - Brittle cross-branch navigation:
func attack_player() -> void:
    var player = get_parent().get_node("../Player/PlayerCharacter")
    player.take_damage(10)  # Breaks if hierarchy changes

# CORRECT - Use groups:
func attack_player() -> void:
    var player = get_tree().get_first_node_in_group("player")
    if player and player.has_method("take_damage"):
        player.take_damage(10)

# CORRECT - Dependency injection via exports:
@export var target: Node2D  # Parent sets this reference

func attack_target() -> void:
    if target and target.has_method("take_damage"):
        target.take_damage(10)

# CORRECT - Signal through parent:
signal attack_requested(damage: int)

func attack() -> void:
    attack_requested.emit(10)  # Parent handles routing
```

### Scene Unique Nodes (`%NodeName` - NEW in 4.3+)

```gdscript
# Scene unique nodes are findable from anywhere within the scene
# Mark nodes as unique in the inspector (% prefix)

# player.tscn hierarchy:
Player (CharacterBody2D)
├── Visual (Node2D)
│   └── %PlayerSprite (Sprite2D)        # Marked as unique
└── Components (Node)
    └── %HealthComponent (Node)          # Marked as unique

# player.gd - Access from anywhere in scene:
@onready var sprite: Sprite2D = %PlayerSprite  # Works even if moved
@onready var health: Node = %HealthComponent   # No path needed

# Benefits:
# - Reorganize hierarchy without breaking references
# - Find nodes by name, not path
# - Still scoped to current scene (not global)
```

---

## Scene Instancing Patterns

### Loading Scenes

```gdscript
# PATTERN 1: Preload (compile-time, preferred)
const BulletScene: PackedScene = preload("res://bullet.tscn")

func spawn_bullet(position: Vector2) -> void:
    var bullet = BulletScene.instantiate()
    bullet.global_position = position
    add_child(bullet)

# PATTERN 2: Load (runtime, dynamic paths)
func load_level(level_number: int) -> void:
    var path = "res://levels/level_%d.tscn" % level_number
    var level_scene = load(path)
    if level_scene:
        var level = level_scene.instantiate()
        add_child(level)

# PATTERN 3: Resource preloader node
@onready var preloader: ResourcePreloader = $ResourcePreloader

func spawn_enemy(type: String) -> void:
    var scene = preloader.get_resource(type) as PackedScene
    if scene:
        var enemy = scene.instantiate()
        add_child(enemy)
```

**When to Use Each**:
- **preload()**: Known paths at compile time (most common)
- **load()**: Dynamic paths determined at runtime
- **ResourcePreloader**: Multiple scene variations preloaded

### Proper Instancing Workflow

```gdscript
# CORRECT - Configure BEFORE adding to tree:
func spawn_enemy(enemy_type: String, spawn_pos: Vector2) -> void:
    var enemy = EnemyScenes[enemy_type].instantiate()

    # 1. Set properties BEFORE add_child():
    enemy.global_position = spawn_pos
    enemy.difficulty_level = current_difficulty
    enemy.target = player

    # 2. Connect signals BEFORE add_child():
    enemy.died.connect(_on_enemy_died)
    enemy.player_detected.connect(_on_enemy_detected_player)

    # 3. NOW add to tree (triggers _ready()):
    enemies_container.add_child(enemy)

    # 4. Post-initialization (after _ready()):
    enemy.start_ai()

# WRONG - Adding before configuration:
func spawn_enemy_wrong(enemy_type: String, spawn_pos: Vector2) -> void:
    var enemy = EnemyScenes[enemy_type].instantiate()
    add_child(enemy)  # _ready() runs with uninitialized state!

    enemy.global_position = spawn_pos  # Too late, _ready() already ran
    enemy.target = player  # May cause null errors in _ready()
```

**Why Order Matters**:
- `add_child()` triggers `_ready()` and enters the tree
- `_ready()` expects initial configuration to be complete
- Signals should be connected before the node starts processing

### Scene Changing (NEW in 4.6)

```gdscript
# NEW in 4.6 - change_scene_to_node() for pre-instantiated scenes:
var new_scene_instance = MyScene.instantiate()
# Configure the scene before switching:
new_scene_instance.level = 5
new_scene_instance.difficulty = "hard"
get_tree().change_scene_to_node(new_scene_instance)

# Traditional - change_scene_to_file():
get_tree().change_scene_to_file("res://levels/level_2.tscn")

# Traditional - change_scene_to_packed():
var packed_scene = load("res://levels/level_2.tscn")
get_tree().change_scene_to_packed(packed_scene)

# Deferred scene change (safer):
func change_level(level_path: String) -> void:
    # Finish current frame processing first:
    await get_tree().process_frame
    get_tree().change_scene_to_file(level_path)
```

---

## Signal System

### Signal Declaration and Usage

```gdscript
# Signal naming: past tense, describes what happened
signal health_changed(new_health: int, max_health: int)
signal died
signal item_collected(item: Item, quantity: int)
signal ability_cooldown_finished(ability_name: String)

# Emitting signals:
func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health, max_health)

    if health <= 0:
        died.emit()

# Connecting signals (code):
func _ready() -> void:
    $Player.health_changed.connect(_on_player_health_changed)
    $Player.died.connect(_on_player_died)

func _on_player_health_changed(new_health: int, max_health: int) -> void:
    health_bar.value = float(new_health) / max_health

func _on_player_died() -> void:
    show_game_over_screen()

# Connecting signals (editor):
# - Select node with signal
# - Go to Node tab → Signals
# - Double-click signal → select target node → select method
```

### Signal Connection Patterns

```gdscript
# PATTERN 1: Direct connection (most common)
player.died.connect(_on_player_died)

# PATTERN 2: One-shot connection (disconnect after first emit)
player.died.connect(_on_player_died, CONNECT_ONE_SHOT)

# PATTERN 3: Deferred connection (emit next frame)
player.health_changed.connect(_on_health_changed, CONNECT_DEFERRED)

# PATTERN 4: Lambda/anonymous function
player.died.connect(func(): print("Player died!"))

# PATTERN 5: With binds (pass extra arguments)
for i in 5:
    var button = Button.new()
    button.pressed.connect(_on_button_pressed.bind(i))
    add_child(button)

func _on_button_pressed(button_index: int) -> void:
    print("Button %d pressed" % button_index)

# Disconnecting signals (important for cleanup):
func _exit_tree() -> void:
    if player.died.is_connected(_on_player_died):
        player.died.disconnect(_on_player_died)
```

### Event Bus Pattern (Global Events)

```gdscript
# events.gd (Autoload as "Events")
extends Node

# Global signals for cross-system communication:
signal player_died
signal level_completed(level_id: int, score: int)
signal item_collected(item_type: String, quantity: int)
signal game_paused
signal game_resumed
signal achievement_unlocked(achievement_id: String)

# Any script can emit:
# player.gd
func die() -> void:
    Events.player_died.emit()
    queue_free()

# Any script can listen:
# ui_manager.gd
func _ready() -> void:
    Events.player_died.connect(_show_game_over)
    Events.level_completed.connect(_show_victory_screen)
    Events.achievement_unlocked.connect(_display_achievement_popup)

func _show_game_over() -> void:
    game_over_screen.show()
```

**Event Bus Guidelines**:
- **Use for**: Cross-system events, UI responding to gameplay, achievements
- **Avoid for**: Parent-child communication, local scene events
- **Benefits**: Decouples systems, easy to add listeners
- **Drawbacks**: Obscures program flow, harder to debug

---

## Groups and Tags

### Group System

```gdscript
# Adding nodes to groups (in editor or code):
func _ready() -> void:
    add_to_group("enemies")
    add_to_group("damageable")
    add_to_group("ai_agents")

# Calling methods on all nodes in group:
get_tree().call_group("enemies", "alert_nearby", player_position)

# Getting all nodes in group:
var enemies = get_tree().get_nodes_in_group("enemies")
for enemy in enemies:
    enemy.take_damage(10)

# Getting first node in group:
var player = get_tree().get_first_node_in_group("player")
if player:
    player.heal(50)

# Checking if node is in group:
if is_in_group("enemies"):
    print("I am an enemy")

# Removing from group:
remove_from_group("enemies")
```

**Common Group Patterns**:

```gdscript
# PATTERN 1: Entity types
add_to_group("enemies")
add_to_group("allies")
add_to_group("neutral")

# PATTERN 2: Capabilities/interfaces
add_to_group("damageable")
add_to_group("interactable")
add_to_group("combustible")

# PATTERN 3: Game systems
add_to_group("pause_on_menu")  # Pause when menu opens
add_to_group("save_state")     # Needs to be saved
add_to_group("networked")      # Replicated over network

# PATTERN 4: Gameplay mechanics
add_to_group("water_hazards")
add_to_group("checkpoint_triggers")
add_to_group("loot_containers")

# Example usage - damage all in radius:
func explode(explosion_center: Vector2, radius: float, damage: int) -> void:
    var damageable = get_tree().get_nodes_in_group("damageable")
    for node in damageable:
        if node.global_position.distance_to(explosion_center) <= radius:
            if node.has_method("take_damage"):
                node.take_damage(damage)
```

---

## Autoloads (Singletons)

### When to Use Autoloads

**Appropriate Use Cases**:
- Global services (AudioManager, SaveManager, InputManager)
- Read-only configuration data (GameConstants)
- Event buses (global signal hub)
- Truly persistent state (player progression across scenes)

**Inappropriate Use Cases** (use scene-based instead):
- Level-specific state
- Player character instance (should be in scene)
- UI managers (should be in UI scenes)
- Game mode logic (should be in game scene)

### Autoload Patterns

```gdscript
# audio_manager.gd (Autoload as "AudioManager")
extends Node

const MAX_SFX_CHANNELS: int = 16

var music_player := AudioStreamPlayer.new()
var sfx_players: Array[AudioStreamPlayer] = []

func _ready() -> void:
    # Setup audio system:
    add_child(music_player)

    sfx_players.resize(MAX_SFX_CHANNELS)
    for i in MAX_SFX_CHANNELS:
        var player = AudioStreamPlayer.new()
        add_child(player)
        sfx_players[i] = player

func play_music(track: AudioStream, fade_duration: float = 0.0) -> void:
    if fade_duration > 0:
        var tween = create_tween()
        tween.tween_property(music_player, "volume_db", -80, fade_duration)
        await tween.finished

    music_player.stream = track
    music_player.play()

    if fade_duration > 0:
        var tween = create_tween()
        tween.tween_property(music_player, "volume_db", 0, fade_duration)

func play_sfx(sound: AudioStream, pitch_scale: float = 1.0) -> void:
    for player in sfx_players:
        if not player.playing:
            player.stream = sound
            player.pitch_scale = pitch_scale
            player.play()
            return
    # All channels busy, oldest sound gets replaced
    sfx_players[0].stream = sound
    sfx_players[0].pitch_scale = pitch_scale
    sfx_players[0].play()

# Usage from any script:
AudioManager.play_music(preload("res://music/battle_theme.ogg"))
AudioManager.play_sfx(preload("res://sfx/coin.wav"))
```

### Event Bus Autoload

```gdscript
# events.gd (Autoload as "Events")
extends Node

# Define signals only, no state:
signal player_died
signal player_respawned(spawn_position: Vector2)
signal level_completed(level_id: int)
signal coin_collected(value: int)
signal enemy_killed(enemy_type: String)
signal achievement_unlocked(achievement_id: String)

# Optional: Helper methods for common patterns
func pause_game() -> void:
    get_tree().paused = true
    game_paused.emit()

func resume_game() -> void:
    get_tree().paused = false
    game_resumed.emit()
```

### Dependency Injection vs Autoloads

```gdscript
# WRONG - Heavy reliance on autoloads:
func _process(delta: float) -> void:
    if Global.player_health <= 0:
        Global.game_state = Global.GameState.GAME_OVER
    if Global.score > Global.high_score:
        Global.high_score = Global.score

# CORRECT - Dependency injection:
class_name GameManager
extends Node

signal game_over
signal new_high_score(score: int)

var player_health: int = 100
var score: int = 0
var high_score: int = 0

func check_game_state() -> void:
    if player_health <= 0:
        game_over.emit()
    if score > high_score:
        high_score = score
        new_high_score.emit(score)

# level.gd - receives manager reference:
@export var game_manager: GameManager

func _ready() -> void:
    if game_manager:
        game_manager.game_over.connect(_on_game_over)
```

---

## Resources for Data Management

### Custom Resource Types

```gdscript
# item_data.gd
class_name ItemData
extends Resource

@export var item_id: String
@export var item_name: String
@export var description: String
@export var icon: Texture2D
@export var value: int
@export var max_stack_size: int = 1
@export var weight: float = 1.0
@export var rarity: Rarity = Rarity.COMMON

enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

# Override to define behavior:
func use(target: Node) -> void:
    # Base implementation
    pass

# Save as .tres file in editor:
# Right-click in FileSystem → Create New Resource → ItemData
# Configure in inspector, save as "health_potion.tres"
```

### Resource Usage Patterns

```gdscript
# PATTERN 1: Preload resources
const HealthPotionData = preload("res://items/health_potion.tres")

func use_health_potion() -> void:
    HealthPotionData.use(player)

# PATTERN 2: Resource library
const ITEMS: Dictionary = {
    "health_potion": preload("res://items/health_potion.tres"),
    "mana_potion": preload("res://items/mana_potion.tres"),
    "sword": preload("res://items/sword.tres"),
}

func get_item_data(item_id: String) -> ItemData:
    return ITEMS.get(item_id)

# PATTERN 3: Dynamic loading
func load_item_data(item_id: String) -> ItemData:
    var path = "res://items/%s.tres" % item_id
    return load(path) as ItemData
```

### Resource Caching and Duplication

```gdscript
# Resources are SHARED by default:
var item1 = load("res://items/sword.tres")
var item2 = load("res://items/sword.tres")
# item1 and item2 are THE SAME OBJECT

# Modifying shared resource affects all users:
item1.value = 999  # Changes original file!
# item2.value is now 999 too

# CORRECT - Duplicate for instance data:
class_name InventoryItem
extends Node

var data: ItemData  # Template (shared)
var quantity: int = 1
var durability: float = 100.0  # Instance-specific

func _init(item_data: ItemData, qty: int = 1):
    data = item_data.duplicate()  # Make unique copy
    quantity = qty

# Pattern: Shared template + instance wrapper
class_name Weapon
extends Node

var template: ItemData  # Shared, read-only
var current_durability: float
var enchantments: Array[String] = []

func _init(weapon_template: ItemData):
    template = weapon_template  # Don't modify!
    current_durability = 100.0
```

---

## SceneTree Utilities (4.6 Enhanced)

### Node Iteration (NEW in 4.6)

```cpp
// NEW in 4.6 (C++/GDExtension): iterate_children()
// Avoids array allocation of get_children()

// C++ pattern:
node->iterate_children([](Node *child) {
    // Process child without array allocation
    if (child->is_in_group("enemies")) {
        child->queue_free();
    }
    return false;  // return true to stop iteration early
});

// GDScript (no direct iterate_children, use get_children()):
for child in get_children():
    if child.is_in_group("enemies"):
        child.queue_free()

// Performance tip - cache when repeatedly iterating:
@onready var _enemy_children: Array[Node] = []

func _ready() -> void:
    _enemy_children.assign(get_children())

func update_enemies() -> void:
    for enemy in _enemy_children:
        enemy.update_ai()
```

### Common SceneTree Operations

```gdscript
# Get root node:
var root = get_tree().root

# Get current scene root:
var current_scene = get_tree().current_scene

# Get all nodes:
var all_nodes = get_tree().get_all_nodes()

# Pause/unpause:
get_tree().paused = true
get_tree().paused = false

# Reload current scene:
get_tree().reload_current_scene()

# Quit game:
get_tree().quit()

# Create timer:
var timer = get_tree().create_timer(3.0)
await timer.timeout
print("3 seconds elapsed")

# Get frame count:
var frame = Engine.get_process_frames()
var physics_frame = Engine.get_physics_frames()
```

---

## Node Lifecycle and Processing

### Lifecycle Methods (Order)

```gdscript
# Execution order:
# 1. _init()        - Constructor (no scene tree access)
# 2. _enter_tree()  - Node enters scene tree
# 3. _ready()       - Node and children are ready (most common)
# 4. _process()     - Every frame (rendering)
# 5. _physics_process() - Fixed timestep (physics)
# 6. _exit_tree()   - Node leaves scene tree
# 7. freed          - Object destroyed

func _init() -> void:
    # Called when object is created (new() or instantiate())
    # NO scene tree access, NO get_node()
    print("Object constructed")

func _enter_tree() -> void:
    # Node added to scene tree
    # Can access get_tree(), but children may not be ready
    print("Entered tree")

func _ready() -> void:
    # Node and ALL children are ready
    # Use this for initialization that requires children
    print("Ready")

func _process(delta: float) -> void:
    # Called every frame (variable timestep)
    # Use for rendering, animations, input
    pass

func _physics_process(delta: float) -> void:
    # Called at fixed rate (60 FPS by default)
    # Use for physics, movement
    pass

func _exit_tree() -> void:
    # Node removed from tree (but not freed yet)
    # Cleanup connections, timers
    print("Exited tree")
```

### Processing Modes

```gdscript
# Control when node processes:
process_mode = Node.PROCESS_MODE_INHERIT      # Follow parent
process_mode = Node.PROCESS_MODE_PAUSABLE     # Pause when tree paused
process_mode = Node.PROCESS_MODE_WHEN_PAUSED  # Process only when paused
process_mode = Node.PROCESS_MODE_ALWAYS       # Always process
process_mode = Node.PROCESS_MODE_DISABLED     # Never process

# Enable/disable processing:
set_process(false)         # Disable _process()
set_physics_process(false) # Disable _physics_process()

# Example - pause menu:
func _ready() -> void:
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func show_pause_menu() -> void:
    get_tree().paused = true
    show()  # Menu processes even when paused
```

---

## Cross-Reference

**Related Guidelines**:
- GDScript patterns → `01-gdscript-modern-patterns.md#script-organization`
- Memory management → `03-core-systems.md#memory-management`
- UI communication → `06-ui-and-controls.md#input-handling`
- Performance → `07-platform-performance.md#performance-patterns`

---

**Document Version**: 1.0
**Last Updated**: 2025-11-15
**Godot Version**: 4.6.0-dev4
**AI Optimization**: Maximum (code patterns, decision tables, anti-patterns)
