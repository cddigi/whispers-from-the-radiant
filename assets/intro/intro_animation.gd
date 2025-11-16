extends Control

## Intro animation scene that displays all 33 cards shuffling into a deck.
## Cards start face-up, scattered across the viewport, then fly in whimsical arcs
## to the center, flipping face-down mid-flight, and stack into a deck.

const CardScene := preload("res://assets/cards/card.tscn")

## Animation parameters
const INITIAL_DISPLAY_TIME := 1.0  # Seconds to display cards face-up before animating
const ANIMATION_DURATION := 2.5  # Total seconds for cards to reach center
const FLIP_START_RATIO := 0.4  # When to start flip (0.0 to 1.0 of journey)
const FLIP_END_RATIO := 0.6  # When to finish flip
const CARD_ARRIVAL_STAGGER := 0.05  # Seconds between card arrivals
const DECK_CENTER := Vector2(960, 540)  # Center of 1920x1080 viewport
const VIEWPORT_SIZE := Vector2(1920, 1080)

## All card instances being animated
var animated_cards: Array[Node] = []

## Full deck of card data
var full_deck: Array[CardData] = []


func _ready() -> void:
	print("=== Whispers from the Radiant - Intro Animation ===")

	# Generate the full deck
	full_deck = DeckGenerator.generate_full_deck()

	# Create all card instances and position them randomly
	create_and_position_cards()

	# Wait to let player see the cards face-up
	await get_tree().create_timer(INITIAL_DISPLAY_TIME).timeout

	# Animate all cards to center
	await animate_cards_to_deck()

	# Wait a moment to show the completed deck
	await get_tree().create_timer(0.5).timeout

	# Transition to game scene
	print("Intro complete - transitioning to game...")
	get_tree().change_scene_to_file("res://assets/game/game_scene.tscn")


## Creates card instances and spreads them across the viewport
func create_and_position_cards() -> void:
	for i: int in range(full_deck.size()):
		var card_data := full_deck[i]
		var card_instance := CardScene.instantiate() as Card

		# Add to scene
		add_child(card_instance)
		animated_cards.append(card_instance)

		# Set card data (starts face-up)
		card_instance.set_card_data(card_data)
		card_instance.set_face_up(true)

		# Position randomly across viewport with some margin
		var margin := 100.0
		var random_x := randf_range(margin, VIEWPORT_SIZE.x - margin)
		var random_y := randf_range(margin, VIEWPORT_SIZE.y - margin)
		card_instance.global_position = Vector2(random_x, random_y)

		# Random initial rotation for whimsy
		card_instance.rotation = randf_range(-0.3, 0.3)

		# Disable mouse interaction during animation
		card_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE


## Animates all cards flying to the deck center with arcs and flips
func animate_cards_to_deck() -> void:
	# Calculate total animation time
	var last_card_delay := (animated_cards.size() - 1) * CARD_ARRIVAL_STAGGER
	var max_duration := ANIMATION_DURATION + 0.2  # Max variance
	var total_time := last_card_delay + max_duration

	# Start all animations (they run in parallel)
	for i: int in range(animated_cards.size()):
		var card := animated_cards[i] as Card

		# Stagger the animations slightly so cards arrive at different times
		var delay := i * CARD_ARRIVAL_STAGGER
		var duration := ANIMATION_DURATION + randf_range(-0.2, 0.2)  # Slight variance

		# Start animation (don't await - let them run in parallel)
		animate_single_card(card, delay, duration, i)

	# Wait for all animations to complete
	await get_tree().create_timer(total_time).timeout


## Animates a single card along a bezier curve to the deck center
func animate_single_card(card: Card, delay: float, duration: float, stack_index: int) -> void:
	# Wait for staggered start
	if delay > 0:
		await get_tree().create_timer(delay).timeout

	# Store starting position
	var start_pos := card.global_position

	# Create control points for bezier curve (whimsical arc)
	var end_pos := DECK_CENTER

	# Create an arc by adding a control point perpendicular to the path
	var mid_point := (start_pos + end_pos) / 2.0
	var direction := (end_pos - start_pos).normalized()
	var perpendicular := Vector2(-direction.y, direction.x)

	# Random arc height and direction for whimsy
	var arc_height := randf_range(150.0, 400.0)
	var arc_direction := 1.0 if randf() > 0.5 else -1.0
	var control_point := mid_point + perpendicular * arc_height * arc_direction

	# Create tween for smooth animation
	var tween := create_tween()
	tween.set_parallel(true)  # Run position and rotation in parallel
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Animate position along bezier curve
	# We'll use a custom method to interpolate along the curve
	tween.tween_method(
		func(t: float) -> void:
			card.global_position = _bezier_point(start_pos, control_point, end_pos, t),
		0.0,
		1.0,
		duration
	)

	# Animate rotation to flat (0)
	tween.tween_property(card, "rotation", 0.0, duration)

	# Animate flip (using scale.x for 2D flip effect)
	# Create a sequential flip animation
	var flip_delay := duration * FLIP_START_RATIO
	var flip_duration := duration * (FLIP_END_RATIO - FLIP_START_RATIO)

	# Wait until flip should start
	await get_tree().create_timer(flip_delay).timeout

	# Flip animation: scale.x goes 1 -> 0 -> -1 to create flip effect
	var flip_tween := create_tween()
	flip_tween.set_ease(Tween.EASE_IN_OUT)
	flip_tween.set_trans(Tween.TRANS_SINE)

	# First half: shrink to 0
	flip_tween.tween_property(card, "scale:x", 0.0, flip_duration / 2.0)

	# At the midpoint, flip the card face-down
	flip_tween.tween_callback(func() -> void:
		card.set_face_up(false)
	)

	# Second half: expand back to 1
	flip_tween.tween_property(card, "scale:x", 1.0, flip_duration / 2.0)

	# After animation completes, set final stacking position with slight offset
	await get_tree().create_timer(duration - flip_delay).timeout

	# Add slight random offset for realistic deck stack
	var stack_offset := Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	)
	card.global_position = DECK_CENTER + stack_offset

	# Set z_index based on stack position (later cards on top)
	card.z_index = stack_index


## Calculates a point on a quadratic bezier curve
func _bezier_point(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var u := 1.0 - t
	var tt := t * t
	var uu := u * u

	var point := uu * p0  # (1-t)^2 * P0
	point += 2.0 * u * t * p1  # 2(1-t)t * P1
	point += tt * p2  # t^2 * P2

	return point
