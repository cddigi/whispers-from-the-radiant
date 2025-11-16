# 2D Graphics and Rendering

**Purpose**: Comprehensive 2D rendering patterns for Godot 4.6, optimized for AI code generation
**Focus**: Sprite management, TileMapLayer architecture (4.3+), animation, Camera2D, and rendering optimization

---

## Sprite2D Management

### Basic Sprite2D Usage

```gdscript
# Sprite2D displays 2D textures
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
    # Set texture:
    sprite.texture = load("res://player.png")

    # Transform properties:
    sprite.position = Vector2(100, 100)
    sprite.rotation = deg_to_rad(45)
    sprite.scale = Vector2(2, 2)

    # Visual properties:
    sprite.modulate = Color(1, 0.5, 0.5)  # Tint red
    sprite.self_modulate = Color(1, 1, 1, 0.5)  # 50% transparent

    # Flipping:
    sprite.flip_h = true  # Flip horizontally
    sprite.flip_v = false # Flip vertically

    # Centering:
    sprite.centered = true  # Sprite centered on position
    sprite.offset = Vector2(-10, -5)  # Offset from center
```

### Texture Regions (Sprite Sheets)

```gdscript
# Enable region mode for sprite sheets:
@onready var sprite: Sprite2D = $Sprite2D

func setup_sprite_sheet() -> void:
    sprite.texture = load("res://spritesheet.png")
    sprite.region_enabled = true

    # Show specific frame (64x64 grid):
    show_frame(2, 1)  # Column 2, Row 1

func show_frame(col: int, row: int, frame_size: int = 64) -> void:
    sprite.region_rect = Rect2(
        col * frame_size,
        row * frame_size,
        frame_size,
        frame_size
    )

# Animation via region:
var current_frame: int = 0
const FRAME_SIZE: int = 64
const FRAMES_PER_ROW: int = 8

func _process(delta: float) -> void:
    current_frame = (current_frame + 1) % 32  # 32 total frames
    var col = current_frame % FRAMES_PER_ROW
    var row = current_frame / FRAMES_PER_ROW
    show_frame(col, row)
```

### AtlasTexture for Organized Frames

```gdscript
# Create atlas frames programmatically:
var frames: Array[AtlasTexture] = []

func create_animation_frames() -> void:
    var base_texture = load("res://character_sheet.png")
    const FRAME_SIZE = 64

    # Extract 8 frames from sprite sheet:
    for i in 8:
        var atlas = AtlasTexture.new()
        atlas.atlas = base_texture
        atlas.region = Rect2(i * FRAME_SIZE, 0, FRAME_SIZE, FRAME_SIZE)
        frames.append(atlas)

# Use in animation:
var current_frame_index: int = 0

func _process(delta: float) -> void:
    sprite.texture = frames[current_frame_index]
    current_frame_index = (current_frame_index + 1) % frames.size()
```

### Import Settings for Sprites

```gdscript
# For PIXEL ART:
# Project Settings → Rendering → Textures:
# - Default Texture Filter: Nearest
# - Default Texture Repeat: Disabled

# Per-texture import settings:
# Select texture → Import tab:
# - Filter: Nearest (pixel art) or Linear (smooth)
# - Mipmaps: Disabled (pixel art) or Enabled (3D/zooming)
# - Compress Mode: VRAM Compressed (large), Lossless (UI), Lossy (photos)

# Pixel-perfect movement:
# Project Settings → Rendering → 2D:
# - Snap 2D Transforms to Pixel: ON
# - Snap 2D Vertices to Pixel: ON
```

---

## AnimatedSprite2D vs AnimationPlayer

### When to Use AnimatedSprite2D

**Use AnimatedSprite2D for**:
- Simple frame-based sprite animation
- Character run/walk/idle cycles
- Flipbook-style animation
- When you only need texture swapping

```gdscript
# AnimatedSprite2D - Frame-based animation
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
    # Animations created in SpriteFrames resource:
    # - "idle" animation
    # - "run" animation
    # - "jump" animation

    animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
    var direction = Input.get_axis("left", "right")

    if direction != 0:
        velocity.x = direction * SPEED
        animated_sprite.play("run")
        animated_sprite.flip_h = direction < 0
    else:
        velocity.x = 0
        animated_sprite.play("idle")

    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY
        animated_sprite.play("jump")

    move_and_slide()

# Signal: animation_finished
func _on_animated_sprite_animation_finished() -> void:
    if animated_sprite.animation == "attack":
        animated_sprite.play("idle")

# Signal: animation_looped
func _on_animated_sprite_animation_looped() -> void:
    print("Animation looped")

# Signal: frame_changed
func _on_animated_sprite_frame_changed() -> void:
    if animated_sprite.animation == "attack" and animated_sprite.frame == 3:
        spawn_projectile()  # Spawn on specific frame
```

### When to Use AnimationPlayer

**Use AnimationPlayer for**:
- Multi-property animation (position + rotation + scale)
- Coordinating multiple nodes
- Method calls and audio cues
- Complex animation trees

```gdscript
# AnimationPlayer - Multi-property animation
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

# Animations can animate:
# - Sprite2D: texture, modulate, position, rotation, scale
# - Node2D: position, rotation, scale
# - Call methods at specific frames
# - Trigger audio/particles

func play_intro() -> void:
    animation_player.play("intro")
    await animation_player.animation_finished
    animation_player.play("idle")

# Animation tracks can include:
# - Property tracks (position, rotation, etc.)
# - Method call tracks (call_method() at specific times)
# - Audio tracks (play sounds in sync)
# - Animation tracks (trigger other animations)
```

### Hybrid Approach

```gdscript
# Use BOTH for maximum flexibility:
# - AnimatedSprite2D for sprite frames
# - AnimationPlayer for complex movements

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func attack() -> void:
    # AnimationPlayer coordinates:
    # - Calls animated_sprite.play("attack") at frame 0
    # - Moves character forward
    # - Calls spawn_hitbox() at frame 10
    # - Plays attack sound at frame 5

    animation_player.play("attack_combo")
    await animation_player.animation_finished

func _on_animation_method_call(method: String) -> void:
    # Called from AnimationPlayer method tracks:
    match method:
        "spawn_hitbox":
            create_attack_hitbox()
        "play_attack_sprite":
            animated_sprite.play("attack")
```

---

## TileMapLayer Architecture (4.3+ CRITICAL)

### BREAKING CHANGE from Legacy TileMap

**4.2 and Earlier** (DEPRECATED):
```gdscript
# OLD SYSTEM (DO NOT USE):
var tilemap = TileMap.new()
tilemap.set_cell(0, Vector2i(0, 0), 1, Vector2i(0, 0))  # Layer as parameter
```

**4.3+** (REQUIRED):
```gdscript
# NEW SYSTEM - Each layer is a separate node:
var ground_layer = TileMapLayer.new()
var walls_layer = TileMapLayer.new()
var decoration_layer = TileMapLayer.new()

add_child(ground_layer)
add_child(walls_layer)
add_child(decoration_layer)

# Each layer has its own methods:
ground_layer.set_cell(Vector2i(0, 0), 0, Vector2i(0, 0))
walls_layer.set_cell(Vector2i(1, 1), 1, Vector2i(2, 0))
```

### Modern TileMapLayer Structure

```gdscript
# Recommended scene hierarchy:
Level (Node2D)
├── Background (TileMapLayer)        # z_index: -20
├── Ground (TileMapLayer)            # z_index: -10
├── Walls (TileMapLayer)             # z_index: -5
├── Decorations (TileMapLayer)       # z_index: 0
├── Player/Enemies (Node2D)          # z_index: 0
└── Foreground (TileMapLayer)        # z_index: 10

# Each TileMapLayer references the same TileSet resource
# Configure z_index to control rendering order
```

### TileMapLayer API

```gdscript
@onready var ground: TileMapLayer = $Ground
@onready var walls: TileMapLayer = $Walls

func _ready() -> void:
    # Set cells:
    ground.set_cell(Vector2i(0, 0), 0, Vector2i(0, 0))  # pos, source_id, atlas_coords
    ground.set_cell(Vector2i(1, 0), 0, Vector2i(1, 0))

    # Get cell data:
    var source_id = ground.get_cell_source_id(Vector2i(0, 0))
    var atlas_coords = ground.get_cell_atlas_coords(Vector2i(0, 0))
    var tile_data = ground.get_cell_tile_data(Vector2i(0, 0))

    # Erase cell:
    ground.erase_cell(Vector2i(0, 0))

    # Clear all cells:
    ground.clear()

    # Get used cells:
    var used_cells = ground.get_used_cells()
    for cell_pos in used_cells:
        print("Cell at: ", cell_pos)

# Custom data layers (defined in TileSet):
func get_tile_movement_cost(pos: Vector2i) -> float:
    var tile_data = ground.get_cell_tile_data(pos)
    if tile_data:
        return tile_data.get_custom_data("movement_cost")
    return 1.0

func is_tile_walkable(pos: Vector2i) -> bool:
    var tile_data = walls.get_cell_tile_data(pos)
    if tile_data:
        return tile_data.get_custom_data("walkable")
    return true
```

### TileSet Configuration

```gdscript
# TileSet stores:
# - Tile atlas textures
# - Tile properties (collision, navigation, custom data)
# - Terrain sets (auto-tiling)
# - Physics layers
# - Custom data layers

# Creating TileSet in code (rare, usually done in editor):
var tileset = TileSet.new()

# Add atlas source:
var atlas_source = TileSetAtlasSource.new()
atlas_source.texture = load("res://tileset.png")
atlas_source.texture_region_size = Vector2i(64, 64)

# Create tiles:
for x in 8:
    for y in 4:
        var coords = Vector2i(x, y)
        atlas_source.create_tile(coords)

        # Configure tile data:
        var tile_data = atlas_source.get_tile_data(coords, 0)
        # Add collision, custom data, etc.

tileset.add_source(atlas_source, 0)

# Assign to TileMapLayer:
ground.tile_set = tileset
```

### Custom Data Layers (Gameplay Properties)

```gdscript
# Define in TileSet (in editor):
# TileSet → Custom Data Layers:
# - "movement_cost" (float): 1.0
# - "is_water" (bool): false
# - "terrain_type" (String): "grass"
# - "damage_per_second" (int): 0

# Use in gameplay:
func calculate_pathfinding_cost(from: Vector2i, to: Vector2i) -> float:
    var tile_data = ground.get_cell_tile_data(to)
    if not tile_data:
        return INF  # No tile = impassable

    var movement_cost = tile_data.get_custom_data("movement_cost")
    var is_water = tile_data.get_custom_data("is_water")

    if is_water and not player.has_ability("swim"):
        return INF

    return movement_cost

func apply_terrain_effects(player_pos: Vector2i) -> void:
    var tile_data = ground.get_cell_tile_data(player_pos)
    if tile_data:
        var damage = tile_data.get_custom_data("damage_per_second")
        if damage > 0:
            player.take_damage(damage)

        var terrain = tile_data.get_custom_data("terrain_type")
        match terrain:
            "lava":
                player.apply_burning_effect()
            "ice":
                player.reduce_speed(0.5)
```

### Terrain Auto-Tiling

```gdscript
# Terrain sets enable auto-tiling:
# TileSet → Terrains → Add Terrain Set
# - Configure terrain types (grass, dirt, stone)
# - Paint peering bits (tile connections)

# Use terrain painting in editor:
# Select TileMapLayer → Terrains tab → Paint
# Godot automatically selects correct tiles based on neighbors

# Programmatic terrain setting:
func set_terrain_cell(pos: Vector2i, terrain_set: int, terrain: int) -> void:
    ground.set_cell(pos, 0, Vector2i.ZERO)  # Use terrain system
    # Terrain auto-tiling happens automatically
```

---

## Z-Index and Rendering Order

### Z-Index System

```gdscript
# Z-index controls draw order (higher = drawn on top)
@onready var background: Node2D = $Background
@onready var player: CharacterBody2D = $Player
@onready var foreground: Node2D = $Foreground

func _ready() -> void:
    # Standard z-index ranges:
    background.z_index = -100       # Far background
    # Background tilemaps: -20 to -10
    # Game entities: 0
    player.z_index = 0
    # Foreground tilemaps: 10 to 20
    foreground.z_index = 100        # UI elements

# Relative vs absolute z-index:
func setup_relative_z() -> void:
    var parent = Node2D.new()
    parent.z_index = 10
    parent.z_as_relative = true  # DEFAULT
    add_child(parent)

    var child = Node2D.new()
    child.z_index = 5
    child.z_as_relative = true
    parent.add_child(child)

    # Effective z-index = parent (10) + child (5) = 15

func setup_absolute_z() -> void:
    var child = Node2D.new()
    child.z_index = 100
    child.z_as_relative = false  # Ignores parent z-index
    parent.add_child(child)
    # Effective z-index = 100 (absolute)
```

### Y-Sort for Depth

```gdscript
# Y-sort creates depth illusion in top-down games
# Objects with lower Y appear behind objects with higher Y

func setup_y_sort() -> void:
    var entities = Node2D.new()
    entities.y_sort_enabled = true
    add_child(entities)

    # All children will sort by Y position:
    var player = preload("res://player.tscn").instantiate()
    var enemy1 = preload("res://enemy.tscn").instantiate()
    var enemy2 = preload("res://enemy.tscn").instantiate()

    entities.add_child(player)
    entities.add_child(enemy1)
    entities.add_child(enemy2)

    # Set Y positions:
    player.position = Vector2(100, 100)   # Appears in front of enemy1
    enemy1.position = Vector2(120, 80)    # Behind player
    enemy2.position = Vector2(110, 150)   # In front of player

# Important: Set sprite origin to bottom-center for characters
# This ensures they sort by their "foot" position
```

### CanvasLayer for UI

```gdscript
# CanvasLayer renders independently of scene transform
# Perfect for UI that shouldn't move with camera

func setup_ui() -> void:
    var ui_layer = CanvasLayer.new()
    ui_layer.layer = 10  # Higher = drawn on top
    add_child(ui_layer)

    var hud = preload("res://hud.tscn").instantiate()
    ui_layer.add_child(hud)

# CanvasLayer properties:
ui_layer.layer = 10                     # Render order
ui_layer.offset = Vector2(10, 10)       # Pixel offset
ui_layer.rotation = deg_to_rad(45)      # Rotate entire layer
ui_layer.scale = Vector2(1.5, 1.5)      # Scale entire layer
ui_layer.follow_viewport_enabled = false  # Don't follow camera
```

---

## Camera2D

### Basic Camera Setup

```gdscript
# Simple: Camera2D as child of player
Player (CharacterBody2D)
└── Camera2D

# Camera automatically follows parent node
# No code needed for basic following

# Advanced: Independent camera with control
@onready var camera: Camera2D = $Camera2D
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
    camera.enabled = true  # Only one camera active at a time

    # Limits (prevent showing outside level):
    camera.limit_left = 0
    camera.limit_right = 2000
    camera.limit_top = 0
    camera.limit_bottom = 1200
    camera.limit_smoothed = true  # Smooth deceleration at limits

    # Smoothing:
    camera.position_smoothing_enabled = true
    camera.position_smoothing_speed = 5.0

    # Zoom:
    camera.zoom = Vector2(2, 2)  # 2x zoom

func _process(delta: float) -> void:
    # Manual camera following with smoothing:
    if player:
        camera.global_position = camera.global_position.lerp(
            player.global_position,
            5.0 * delta
        )
```

### Camera Effects and Features

```gdscript
@onready var camera: Camera2D = $Camera2D

# Drag margins (deadzone):
func setup_drag_margins() -> void:
    camera.drag_horizontal_enabled = true
    camera.drag_vertical_enabled = true
    camera.drag_horizontal_offset = 0.5  # -1 to 1
    camera.drag_vertical_offset = 0.0

    # Player can move within deadzone without camera movement
    camera.drag_left_margin = 0.2      # 20% of screen width
    camera.drag_right_margin = 0.2
    camera.drag_top_margin = 0.1
    camera.drag_bottom_margin = 0.1

# Camera shake:
func shake_camera(intensity: float, duration: float) -> void:
    var original_offset = camera.offset
    var timer = 0.0

    while timer < duration:
        camera.offset = original_offset + Vector2(
            randf_range(-intensity, intensity),
            randf_range(-intensity, intensity)
        )
        await get_tree().process_frame
        timer += get_process_delta_time()

    camera.offset = original_offset

# Look-ahead (show more in movement direction):
var _look_ahead_offset := Vector2.ZERO

func _process(delta: float) -> void:
    var velocity = player.velocity.normalized()
    var target_offset = velocity * 50.0  # Look 50 pixels ahead

    _look_ahead_offset = _look_ahead_offset.lerp(target_offset, 2.0 * delta)
    camera.offset = _look_ahead_offset

# Zoom controls:
func zoom_in() -> void:
    var tween = create_tween()
    tween.tween_property(camera, "zoom", Vector2(3, 3), 0.5)

func zoom_out() -> void:
    var tween = create_tween()
    tween.tween_property(camera, "zoom", Vector2(1, 1), 0.5)
```

### Multiple Cameras

```gdscript
# Switch between cameras:
@onready var gameplay_camera: Camera2D = $GameplayCamera
@onready var cutscene_camera: Camera2D = $CutsceneCamera

func switch_to_cutscene() -> void:
    gameplay_camera.enabled = false
    cutscene_camera.enabled = true

func switch_to_gameplay() -> void:
    cutscene_camera.enabled = false
    gameplay_camera.enabled = true

# Smooth transition between cameras:
func transition_to_camera(target_camera: Camera2D, duration: float) -> void:
    var current_pos = get_viewport().get_camera_2d().global_position
    var current_zoom = get_viewport().get_camera_2d().zoom

    target_camera.global_position = current_pos
    target_camera.zoom = current_zoom
    target_camera.enabled = true

    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(target_camera, "global_position", target_camera.position, duration)
    tween.tween_property(target_camera, "zoom", Vector2(1, 1), duration)
```

---

## Rendering Performance

### Draw Call Optimization

```gdscript
# Godot 4 automatically batches sprites with:
# - Same texture
# - Same material
# - Same z-index
# - Sequential in tree

# Maximize batching:
# 1. Use texture atlases (sprite sheets)
# 2. Share materials between sprites
# 3. Minimize unique shaders
# 4. Group similar sprites under same parent

# Texture atlas example:
const ATLAS_TEXTURE = preload("res://atlas.png")

func create_sprite(region: Rect2) -> Sprite2D:
    var sprite = Sprite2D.new()
    sprite.texture = ATLAS_TEXTURE
    sprite.region_enabled = true
    sprite.region_rect = region
    return sprite

# All sprites share the same texture → single draw call
```

### Culling and Visibility

```gdscript
# VisibleOnScreenNotifier2D: Detect when sprite is visible
@onready var visibility_notifier: VisibleOnScreenNotifier2D = $VisibilityNotifier

func _ready() -> void:
    visibility_notifier.screen_entered.connect(_on_screen_entered)
    visibility_notifier.screen_exited.connect(_on_screen_exited)

func _on_screen_entered() -> void:
    # Sprite is visible:
    set_process(true)
    set_physics_process(true)

func _on_screen_exited() -> void:
    # Sprite is off-screen:
    set_process(false)
    set_physics_process(false)

# VisibleOnScreenEnabler2D: Automatically enable/disable
# Automatically pauses processing when off-screen
# Just add to scene, no code needed
```

### LOD (Level of Detail)

```gdscript
# Distance-based LOD for sprites:
@onready var camera: Camera2D = get_viewport().get_camera_2d()

func _process(delta: float) -> void:
    if not camera:
        return

    var distance = global_position.distance_to(camera.global_position)

    # Adjust based on distance:
    if distance > 1000:
        hide()  # Too far, don't render
    elif distance > 500:
        # Far: reduce animation speed
        animated_sprite.speed_scale = 0.5
    elif distance > 200:
        # Medium: normal animation
        animated_sprite.speed_scale = 1.0
    else:
        # Close: full detail
        animated_sprite.speed_scale = 1.0
        show()
```

---

## Cross-Reference

**Related Guidelines**:
- Scene architecture → `02-scene-architecture.md`
- Animation system → `05-animation-physics-3d.md#animation-system`
- Performance optimization → `07-platform-performance.md#rendering-performance`
- UI rendering → `06-ui-and-controls.md`

---

**Document Version**: 1.0
**Last Updated**: 2025-11-15
**Godot Version**: 4.6.0-dev4
**AI Optimization**: Maximum (TileMapLayer migration, rendering patterns, camera recipes)
