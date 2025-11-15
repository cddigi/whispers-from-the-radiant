# Animation, Physics, and 3D Systems

**Purpose**: Comprehensive animation and physics patterns for Godot 4.6
**Focus**: AnimationPlayer/Tree, IKModifier3D (NEW), Jolt Physics (default 4.6), navigation, collision systems

---

## Animation System

### AnimationPlayer Fundamentals

```gdscript
# AnimationPlayer: Multi-track property animation system
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
    # Play animation:
    animation_player.play("walk")

    # Play with custom blend time:
    animation_player.play("run", -1, 1.0, false)  # name, custom_blend, speed, from_end

    # Queue animation (play after current):
    animation_player.queue("jump")

    # Stop animation:
    animation_player.stop()
    animation_player.stop(true)  # reset to beginning

    # Pause/resume:
    animation_player.pause()
    animation_player.play()  # Resume

# Animation properties:
animation_player.current_animation = "idle"
animation_player.playback_speed = 1.5  # 1.5x speed
animation_player.seek(2.5)  # Jump to 2.5 seconds

# Signals:
func _connect_signals() -> void:
    animation_player.animation_finished.connect(_on_animation_finished)
    animation_player.animation_changed.connect(_on_animation_changed)
    animation_player.animation_started.connect(_on_animation_started)

func _on_animation_finished(anim_name: String) -> void:
    match anim_name:
        "attack":
            animation_player.play("idle")
        "death":
            queue_free()
```

### Animation Tracks

```gdscript
# AnimationPlayer can animate multiple tracks:
# 1. Property tracks - Animate node properties
# 2. Method call tracks - Call functions at specific times
# 3. Audio tracks - Play sounds in sync
# 4. Animation tracks - Trigger other animations

# Creating animations in code (rare, usually in editor):
func create_bounce_animation() -> void:
    var animation = Animation.new()
    animation.length = 1.0
    animation.loop_mode = Animation.LOOP_LINEAR

    # Add property track for position.y:
    var track_index = animation.add_track(Animation.TYPE_VALUE)
    animation.track_set_path(track_index, ".:position:y")

    # Add keyframes:
    animation.track_insert_key(track_index, 0.0, 0.0)
    animation.track_insert_key(track_index, 0.5, -50.0)
    animation.track_insert_key(track_index, 1.0, 0.0)

    # Add to AnimationPlayer:
    animation_player.add_animation("bounce", animation)

# Method call track example:
# In editor: Add track → Call Method Track
# Select frames to call methods:
# Frame 5: spawn_particle()
# Frame 10: play_sound()
# Frame 15: create_hitbox()
```

### AnimationTree and State Machines

```gdscript
# AnimationTree: Advanced animation blending and state machines
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback

func _ready() -> void:
    animation_tree.active = true
    state_machine = animation_tree.get("parameters/playback")

func _physics_process(delta: float) -> void:
    # Update state machine:
    var velocity_length = velocity.length()

    if velocity_length < 10:
        state_machine.travel("idle")
    elif velocity_length < 200:
        state_machine.travel("walk")
    else:
        state_machine.travel("run")

    # Set blend parameters:
    animation_tree.set("parameters/walk_blend/blend_amount", velocity_length / 200.0)

# AnimationTree features:
# - State machines (like game state machines but for animation)
# - Blend spaces (2D blending based on parameters)
# - Blend trees (mathematical blending)
# - IK (inverse kinematics)
# - Root motion
```

### Animation Blending

```gdscript
# BlendSpace2D: Blend animations based on 2D parameter
# Example: Blend walk animations based on direction

@onready var animation_tree: AnimationTree = $AnimationTree

func _physics_process(delta: float) -> void:
    var move_direction = velocity.normalized()

    # Update blend space position:
    animation_tree.set("parameters/movement_blend/blend_position", Vector2(
        move_direction.x,  # -1 (left) to 1 (right)
        move_direction.z   # -1 (back) to 1 (forward)
    ))

# In editor: Create BlendSpace2D node
# Add animations at positions:
# - walk_forward at (0, 1)
# - walk_back at (0, -1)
# - walk_left at (-1, 0)
# - walk_right at (1, 0)
# - walk_forward_left at (-0.7, 0.7)
# etc.
```

---

## IKModifier3D System (NEW in 4.6)

### IKModifier3D Replaces SkeletonIK

**CRITICAL**: SkeletonIK is DEPRECATED. Use IKModifier3D in 4.6+

```gdscript
# OLD SYSTEM (DEPRECATED - Don't use):
var ik = SkeletonIK.new()
ik.set_target_node(target_path)
ik.set_tip_bone("Hand.R")
ik.set_root_bone("UpperArm.R")
$Skeleton3D.add_child(ik)

# NEW SYSTEM (4.6+):
var ik_modifier = IKModifier3D.new()
ik_modifier.target = target_node  # Node3D reference
ik_modifier.tip_bone = "Hand.R"
ik_modifier.root_bone = "UpperArm.R"
ik_modifier.chain_length = 2  # Number of bones in chain
$Skeleton3D.add_child(ik_modifier)

# Enable/disable:
ik_modifier.enabled = true
```

### IK Setup Patterns

```gdscript
# Character looking at target:
class_name Character
extends Node3D

@onready var skeleton: Skeleton3D = $Skeleton3D
var head_ik: IKModifier3D
var look_target: Node3D

func _ready() -> void:
    # Create look-at IK:
    head_ik = IKModifier3D.new()
    head_ik.tip_bone = "Head"
    head_ik.root_bone = "Neck"
    head_ik.chain_length = 2
    skeleton.add_child(head_ik)

    # Create target marker:
    look_target = Node3D.new()
    add_child(look_target)
    head_ik.target = look_target

func look_at_position(world_pos: Vector3) -> void:
    look_target.global_position = world_pos

# Two-bone IK (arm reaching):
var arm_ik: IKModifier3D

func setup_arm_ik() -> void:
    arm_ik = IKModifier3D.new()
    arm_ik.tip_bone = "Hand.R"
    arm_ik.root_bone = "UpperArm.R"
    arm_ik.chain_length = 2  # UpperArm → LowerArm → Hand
    skeleton.add_child(arm_ik)

    var hand_target = Node3D.new()
    add_child(hand_target)
    arm_ik.target = hand_target

func reach_for(position: Vector3) -> void:
    arm_ik.target.global_position = position
```

### SpringBone System (NEW in 4.6)

```gdscript
# SpringBone: Physics-based bone simulation (hair, cloth, tails)
# Part of SkeletonModifier system alongside IK

var spring_bone: SpringBoneSimulator3D

func setup_spring_bones() -> void:
    spring_bone = SpringBoneSimulator3D.new()

    # Configure spring properties:
    spring_bone.stiffness = 0.5  # How rigid (0-1)
    spring_bone.damping = 0.1    # Energy loss (0-1)
    spring_bone.gravity = Vector3(0, -9.8, 0)

    # Add bones to simulate:
    spring_bone.add_bone("Hair.1")
    spring_bone.add_bone("Hair.2")
    spring_bone.add_bone("Tail.1")
    spring_bone.add_bone("Tail.2")

    skeleton.add_child(spring_bone)

# Bone constraints (limit rotation):
func add_bone_constraint() -> void:
    var constraint = BoneConstraint3D.new()
    constraint.bone_name = "Elbow.L"
    constraint.min_angle = Vector3(-120, -30, -30)
    constraint.max_angle = Vector3(0, 30, 30)
    skeleton.add_child(constraint)
```

---

## Physics Systems

### Jolt Physics (Default in 4.6+)

**CRITICAL**: New projects in 4.6 use Jolt Physics by default

```gdscript
# Project Settings → Physics/3D → Physics Engine:
# - GodotPhysics3D (legacy, still available)
# - Jolt (NEW DEFAULT in 4.6)

# Jolt benefits:
# - Better performance (10-100x faster for complex scenes)
# - More accurate collision detection
# - Better stability for ragdolls
# - Better large-scale physics

# API is the SAME - no code changes needed
# Existing GodotPhysics code works with Jolt
```

### 2D Physics (GodotPhysics)

```gdscript
# CharacterBody2D: Kinematic physics character
class_name Player
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
    # Gravity:
    if not is_on_floor():
        velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

    # Jump:
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Movement:
    var direction = Input.get_axis("left", "right")
    if direction:
        velocity.x = direction * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)

    # Apply movement:
    move_and_slide()

    # Collision detection:
    for i in get_slide_collision_count():
        var collision = get_slide_collision(i)
        print("Collided with: ", collision.get_collider().name)
        print("Normal: ", collision.get_normal())
        print("Position: ", collision.get_position())

# RigidBody2D: Dynamic physics object
class_name Crate
extends RigidBody2D

func _ready() -> void:
    # Physics properties:
    mass = 10.0
    gravity_scale = 1.0
    linear_damp = 0.1  # Air resistance
    angular_damp = 0.1  # Rotation resistance

    # Apply force:
    apply_central_impulse(Vector2(100, -200))

    # Apply torque:
    apply_torque_impulse(50.0)

# StaticBody2D: Immovable collision
# - Floors, walls, platforms
# - No code needed, just collision shapes

# Area2D: Trigger zones (no physics collision)
class_name TriggerZone
extends Area2D

func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        print("Player entered zone")

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        print("Player exited zone")
```

### 3D Physics (Jolt/GodotPhysics)

```gdscript
# CharacterBody3D: First-person character
class_name FPSCharacter
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var camera: Camera3D = $Camera3D

func _physics_process(delta: float) -> void:
    # Gravity:
    if not is_on_floor():
        velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta

    # Jump:
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Movement relative to camera:
    var input_dir = Input.get_vector("left", "right", "forward", "back")
    var direction = (camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)

    move_and_slide()

# RigidBody3D: Dynamic physics
class_name PhysicsObject
extends RigidBody3D

func _ready() -> void:
    mass = 10.0
    gravity_scale = 1.0
    contact_monitor = true
    max_contacts_reported = 10

    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    print("Hit: ", body.name)

func explode(force: float) -> void:
    # Apply radial impulse:
    var direction = Vector3.UP + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
    apply_central_impulse(direction.normalized() * force)
    apply_torque_impulse(Vector3(randf_range(-5, 5), randf_range(-5, 5), randf_range(-5, 5)))
```

### Collision Layers and Masks

```gdscript
# Layers define WHAT the object is
# Masks define WHAT it collides with

# Define layers (Project Settings → Layer Names → 2D/3D Physics):
# Layer 1: World (floors, walls)
# Layer 2: Player
# Layer 3: Enemies
# Layer 4: Projectiles
# Layer 5: Items

# Setup collision:
func setup_player() -> void:
    # Player is on layer 2:
    collision_layer = 1 << 1  # Bit 2

    # Player collides with layers 1 (world) and 3 (enemies):
    collision_mask = (1 << 0) | (1 << 2)  # Bits 1 and 3

# Helper functions:
func set_collision_layer_value(layer: int, enabled: bool) -> void:
    if enabled:
        collision_layer |= (1 << (layer - 1))
    else:
        collision_layer &= ~(1 << (layer - 1))

func set_collision_mask_value(layer: int, enabled: bool) -> void:
    if enabled:
        collision_mask |= (1 << (layer - 1))
    else:
        collision_mask &= ~(1 << (layer - 1))

# Example: Projectile setup
func setup_bullet() -> void:
    set_collision_layer_value(4, true)  # Projectile layer
    set_collision_mask_value(1, true)   # Collide with world
    set_collision_mask_value(3, true)   # Collide with enemies
    set_collision_mask_value(2, false)  # Don't collide with player
```

### Raycasting and Shape Queries

```gdscript
# RayCast2D/3D: Continuous ray detection
@onready var raycast: RayCast3D = $RayCast3D

func _physics_process(delta: float) -> void:
    if raycast.is_colliding():
        var collider = raycast.get_collider()
        var point = raycast.get_collision_point()
        var normal = raycast.get_collision_normal()

        print("Hit: ", collider.name, " at ", point)

# Immediate raycasts (one-shot):
func check_line_of_sight(from: Vector3, to: Vector3) -> bool:
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.create(from, to)
    query.collision_mask = 1  # Only check world layer

    var result = space_state.intersect_ray(query)
    return result.is_empty()  # True if no obstruction

# Shape casting:
func check_sphere_area(center: Vector3, radius: float) -> Array:
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsShapeQueryParameters3D.new()

    var shape = SphereShape3D.new()
    shape.radius = radius
    query.shape = shape
    query.transform = Transform3D(Basis(), center)

    var results = space_state.intersect_shape(query)
    return results

# ShapeCast3D (continuous shape):
var shape_cast: ShapeCast3D

func setup_shape_cast() -> void:
    shape_cast = ShapeCast3D.new()
    shape_cast.shape = SphereShape3D.new()
    shape_cast.shape.radius = 0.5
    shape_cast.target_position = Vector3(0, -2, 0)
    add_child(shape_cast)

func _physics_process(delta: float) -> void:
    if shape_cast.is_colliding():
        var hit_count = shape_cast.get_collision_count()
        for i in hit_count:
            var collider = shape_cast.get_collider(i)
            print("Shape hit: ", collider.name)
```

---

## Navigation System

### NavigationRegion Setup

```gdscript
# 2D Navigation:
# Scene structure:
# Level (Node2D)
# ├── NavigationRegion2D
# │   └── Polygon2D (defines walkable area)
# └── Enemies/Player

# Create navigation polygon:
@onready var nav_region: NavigationRegion2D = $NavigationRegion2D

func setup_navigation() -> void:
    var nav_polygon = NavigationPolygon.new()

    # Define walkable area:
    var outline = PackedVector2Array([
        Vector2(0, 0),
        Vector2(1000, 0),
        Vector2(1000, 600),
        Vector2(0, 600)
    ])
    nav_polygon.add_outline(outline)
    nav_polygon.make_polygons_from_outlines()

    nav_region.navigation_polygon = nav_polygon

# 3D Navigation:
# Level (Node3D)
# ├── NavigationRegion3D
# │   └── MeshInstance3D (floor mesh)
# └── Enemies/Player

# Bake navigation mesh (in editor or code):
func bake_navmesh() -> void:
    var nav_mesh = NavigationMesh.new()
    nav_mesh.agent_radius = 0.5
    nav_mesh.agent_height = 2.0
    nav_mesh.cell_size = 0.25
    nav_region_3d.navigation_mesh = nav_mesh
    # Bake in editor: NavigationRegion3D → Bake NavigationMesh
```

### Pathfinding

```gdscript
# 2D Pathfinding:
func get_path_to(target_position: Vector2) -> PackedVector2Array:
    var nav_map = get_world_2d().navigation_map
    var path = NavigationServer2D.map_get_path(
        nav_map,
        global_position,
        target_position,
        true  # optimize
    )
    return path

# Follow path:
var current_path: PackedVector2Array = []
var path_index: int = 0
const SPEED = 200.0

func move_to(target: Vector2) -> void:
    current_path = get_path_to(target)
    path_index = 0

func _physics_process(delta: float) -> void:
    if current_path.is_empty() or path_index >= current_path.size():
        return

    var target_point = current_path[path_index]
    var direction = global_position.direction_to(target_point)
    var distance = global_position.distance_to(target_point)

    if distance < 10:
        path_index += 1
        if path_index >= current_path.size():
            current_path.clear()  # Reached destination
    else:
        velocity = direction * SPEED
        move_and_slide()

# 3D Pathfinding (same pattern):
func get_path_to_3d(target_position: Vector3) -> PackedVector3Array:
    var nav_map = get_world_3d().navigation_map
    return NavigationServer3D.map_get_path(
        nav_map,
        global_position,
        target_position,
        true
    )
```

### NavigationAgent (Helper Node)

```gdscript
# NavigationAgent2D/3D simplifies pathfinding:
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
    # Configure:
    nav_agent.max_speed = 200.0
    nav_agent.path_desired_distance = 10.0
    nav_agent.target_desired_distance = 10.0

    # Signals:
    nav_agent.velocity_computed.connect(_on_velocity_computed)
    nav_agent.target_reached.connect(_on_target_reached)

    # Wait for navigation map to be ready:
    await get_tree().physics_frame

    # Set target:
    nav_agent.target_position = target.global_position

func _physics_process(delta: float) -> void:
    if nav_agent.is_navigation_finished():
        return

    # Get next path position:
    var next_path_pos = nav_agent.get_next_path_position()
    var direction = global_position.direction_to(next_path_pos)

    # Set velocity (triggers avoidance):
    nav_agent.set_velocity(direction * nav_agent.max_speed)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
    # Apply computed velocity (includes avoidance):
    velocity = safe_velocity
    move_and_slide()

func _on_target_reached() -> void:
    print("Reached destination")
```

---

## Cross-Reference

**Related Guidelines**:
- Scene architecture → `02-scene-architecture.md`
- 2D animation → `04-2d-graphics-rendering.md#animation`
- Performance optimization → `07-platform-performance.md#physics-performance`
- Version migration → `00-version-and-migration.md#ikmodifier3d`

---

**Document Version**: 1.0
**Last Updated**: 2025-11-15
**Godot Version**: 4.6.0-dev4
**AI Optimization**: Maximum (IKModifier3D migration, Jolt Physics setup, navigation patterns)
