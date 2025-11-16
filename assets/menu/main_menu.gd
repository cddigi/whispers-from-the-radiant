extends Control

## Main menu for Whispers from the Radiant.
## Provides options to start a new calculation, view instructions, or exit.
## Features animated cards flying in to form a deck in the background.

## Scenes to load
const INTRO_SCENE := "res://assets/intro/intro_animation.tscn"
const CardScene := preload("res://assets/cards/card.tscn")

## Animation parameters
const ANIMATION_DURATION := 2.0  # Seconds for cards to reach center
const FLIP_START_RATIO := 0.3  # When to start flip (0.0 to 1.0 of journey)
const FLIP_END_RATIO := 0.5  # When to finish flip
const CARD_ARRIVAL_STAGGER := 0.04  # Seconds between card arrivals
const DECK_CENTER := Vector2(1600, 800)  # Bottom right corner for deck
const VIEWPORT_SIZE := Vector2(1920, 1080)

## UI nodes
@onready var start_button: Button = $MenuPanel/VBoxContainer/StartButton
@onready var instructions_button: Button = $MenuPanel/VBoxContainer/InstructionsButton
@onready var quit_button: Button = $MenuPanel/VBoxContainer/QuitButton
@onready var instructions_panel: Panel = $InstructionsPanel
@onready var close_instructions_button: Button = $InstructionsPanel/MarginContainer/VBoxContainer/CloseButton
@onready var card_container: Control = $CardContainer

## Card animation state
var animated_cards: Array[Node] = []
var full_deck: Array[CardData] = []


func _ready() -> void:
	print("=== Whispers from the Radiant - Main Menu ===")

	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	instructions_button.pressed.connect(_on_instructions_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	close_instructions_button.pressed.connect(_on_close_instructions_pressed)

	# Hide instructions panel initially
	instructions_panel.visible = false

	# Start card fly-in animation
	spawn_and_animate_cards()

	# Focus the start button after a brief delay to let animation start
	await get_tree().create_timer(0.1).timeout
	start_button.grab_focus()


func _on_start_pressed() -> void:
	print("Starting new calculation...")
	# Play intro animation first, which then loads the game
	get_tree().change_scene_to_file(INTRO_SCENE)


func _on_instructions_pressed() -> void:
	print("Showing instructions...")
	instructions_panel.visible = true
	close_instructions_button.grab_focus()


func _on_close_instructions_pressed() -> void:
	instructions_panel.visible = false
	instructions_button.grab_focus()


func _on_quit_pressed() -> void:
	print("Exiting to consensus reality...")
	get_tree().quit()


## Spawns cards from screen edges and animates them flying to the deck
func spawn_and_animate_cards() -> void:
	# Generate full deck
	full_deck = DeckGenerator.generate_full_deck()

	# Create cards at screen edge positions
	for i: int in range(full_deck.size()):
		var card_data := full_deck[i]
		var card_instance := CardScene.instantiate() as Card

		# Add to card container (behind menu UI)
		card_container.add_child(card_instance)
		animated_cards.append(card_instance)

		# Set card data (starts face-up)
		card_instance.set_card_data(card_data)
		card_instance.set_face_up(true)

		# Position at screen edges (spawn from outside viewport)
		var spawn_pos := get_edge_spawn_position()
		card_instance.global_position = spawn_pos

		# Random initial rotation
		card_instance.rotation = randf_range(-0.4, 0.4)

		# Disable mouse interaction during animation
		card_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Start animation after brief delay
	await get_tree().create_timer(0.2).timeout
	animate_cards_to_deck()


## Returns a random position along the screen edges (outside viewport)
func get_edge_spawn_position() -> Vector2:
	var edge := randi() % 4  # 0=top, 1=right, 2=bottom, 3=left
	var offset := 100.0  # Distance outside viewport

	match edge:
		0:  # Top edge
			return Vector2(randf_range(0, VIEWPORT_SIZE.x), -offset)
		1:  # Right edge
			return Vector2(VIEWPORT_SIZE.x + offset, randf_range(0, VIEWPORT_SIZE.y))
		2:  # Bottom edge
			return Vector2(randf_range(0, VIEWPORT_SIZE.x), VIEWPORT_SIZE.y + offset)
		3:  # Left edge
			return Vector2(-offset, randf_range(0, VIEWPORT_SIZE.y))
		_:
			return Vector2.ZERO


## Animates all cards flying to the deck center with arcs and flips
func animate_cards_to_deck() -> void:
	for i: int in range(animated_cards.size()):
		var card := animated_cards[i] as Card

		# Stagger the animations
		var delay := i * CARD_ARRIVAL_STAGGER
		var duration := ANIMATION_DURATION + randf_range(-0.3, 0.3)

		# Start animation after delay
		animate_single_card(card, delay, duration, i)


## Animates a single card along a bezier curve to the deck center
func animate_single_card(card: Card, delay: float, duration: float, stack_index: int) -> void:
	# Wait for staggered start
	if delay > 0:
		await get_tree().create_timer(delay).timeout

	# Store starting position
	var start_pos := card.global_position
	var end_pos := DECK_CENTER

	# Create bezier curve control point
	var mid_point := (start_pos + end_pos) / 2.0
	var direction := (end_pos - start_pos).normalized()
	var perpendicular := Vector2(-direction.y, direction.x)

	# Random arc for whimsical flight
	var arc_height := randf_range(200.0, 500.0)
	var arc_direction := 1.0 if randf() > 0.5 else -1.0
	var control_point := mid_point + perpendicular * arc_height * arc_direction

	# Create tween for position and rotation
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Animate position along bezier curve
	tween.tween_method(
		func(t: float) -> void:
			card.global_position = bezier_point(start_pos, control_point, end_pos, t),
		0.0,
		1.0,
		duration
	)

	# Animate rotation to flat
	tween.tween_property(card, "rotation", 0.0, duration)

	# Handle flip animation
	var flip_delay := duration * FLIP_START_RATIO
	var flip_duration := duration * (FLIP_END_RATIO - FLIP_START_RATIO)

	# Wait until flip should start
	await get_tree().create_timer(flip_delay).timeout

	# Create flip animation
	var flip_tween := create_tween()
	flip_tween.set_ease(Tween.EASE_IN_OUT)
	flip_tween.set_trans(Tween.TRANS_SINE)

	# Shrink to 0 (first half of flip)
	flip_tween.tween_property(card, "scale:x", 0.0, flip_duration / 2.0)

	# Flip to face-down at midpoint
	flip_tween.tween_callback(func() -> void:
		card.set_face_up(false)
	)

	# Expand back to 1 (second half of flip)
	flip_tween.tween_property(card, "scale:x", 1.0, flip_duration / 2.0)

	# After animation completes, set final position with slight offset
	await get_tree().create_timer(duration - flip_delay).timeout

	# Add slight random offset for realistic deck stack
	var stack_offset := Vector2(
		randf_range(-1.5, 1.5),
		randf_range(-1.5, 1.5)
	)
	card.global_position = DECK_CENTER + stack_offset

	# Set z_index based on stack position
	card.z_index = stack_index - 100  # Keep behind menu UI


## Calculates a point on a quadratic bezier curve
func bezier_point(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var u := 1.0 - t
	var tt := t * t
	var uu := u * u

	var point := uu * p0  # (1-t)^2 * P0
	point += 2.0 * u * t * p1  # 2(1-t)t * P1
	point += tt * p2  # t^2 * P2

	return point
