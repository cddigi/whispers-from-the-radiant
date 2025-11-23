class_name Card
extends Control

## Visual representation of a CardData resource.
## Displays aspect color, value, and ability indicator.
## This is the basic version for Stage 1 - will be enhanced in Stage 3.

signal card_selected(card: Card)
signal card_hovered(card: Card)
signal card_unhovered(card: Card)

## The data this card represents
var card_data: CardData = null

## Interaction state
var is_playable: bool = true
var is_selectable: bool = true
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO

## Visual elements (scene-unique node references)
@onready var background := %CardBackground as ColorRect
@onready var aspect_border := %AspectBorder as ColorRect
@onready var value_label := %ValueLabel as Label
@onready var aspect_label := %AspectLabel as Label
@onready var ability_indicator := %AbilityIndicator as Label


func _ready() -> void:
	# Ensure the card can receive mouse input
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Make sure all child elements ignore mouse events so parent receives them
	card_face.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_back.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# If card_data was set before _ready, update visuals
	if card_data:
		update_visuals()

	# Update face visibility
	update_face_visibility()


## Sets the card data and updates the visual representation
func set_card_data(data: CardData) -> void:
	card_data = data
	if is_node_ready():
		update_visuals()


## Updates all visual elements to match card_data
func update_visuals() -> void:
	if not card_data:
		return

	# Set value
	value_label.text = str(card_data.value)

	# Set aspect color and name
	var aspect_color := card_data.get_aspect_color()
	aspect_border.color = aspect_color
	aspect_label.text = card_data.get_aspect_name().to_upper()
	aspect_label.add_theme_color_override("font_color", aspect_color)

	# Show ability indicator for special cards
	if card_data.has_ability:
		ability_indicator.visible = true
		ability_indicator.tooltip_text = card_data.ability_description
	else:
		ability_indicator.visible = false

	# Add subtle border effect
	background.color = aspect_color.darkened(0.7)


## Returns the card data this visual represents
func get_card_data() -> CardData:
	return card_data


## Sets whether this card can be played (affects visual state)
func set_playable(playable: bool) -> void:
	is_playable = playable
	update_visual_state()


## Sets whether this card can be selected (interaction enabled/disabled)
func set_selectable(selectable: bool) -> void:
	is_selectable = selectable
	mouse_filter = Control.MOUSE_FILTER_STOP if selectable else Control.MOUSE_FILTER_IGNORE
	update_visual_state()


## Updates visual appearance based on current state
func update_visual_state() -> void:
	if not is_selectable:
		# Disabled state - heavily dimmed and grayed out
		modulate = Color(0.4, 0.4, 0.4, 0.6)
		z_index = 0
	elif not is_playable:
		# Unplayable but visible - dimmed with red tint indicating invalid
		modulate = Color(0.8, 0.5, 0.5, 0.8)
		z_index = 0
	else:
		# Normal playable state - white with slight glow
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		z_index = 0


## Highlights the card (for hover state)
func set_highlighted(highlighted: bool) -> void:
	if not is_selectable or not is_playable:
		return  # Don't highlight unplayable/unselectable cards

	if highlighted:
		# Mentalic glow - bright with significant emphasis and elevation
		modulate = Color(1.3, 1.25, 1.4, 1.0)  # Slight blue-purple glow for psychic power
		z_index = 10
		# Significant elevation effect for hover feedback
		position.y -= 15
		# Add a subtle scale up for additional feedback
		scale = Vector2(1.08, 1.08)
	else:
		# Return to normal playable state
		update_visual_state()
		z_index = 0
		position.y += 15
		scale = Vector2(1.0, 1.0)


## Sets whether the card is face-up or face-down
func set_face_up(face_up: bool) -> void:
	is_face_up = face_up
	update_face_visibility()


## Updates the visibility of card elements based on face-up state
func update_face_visibility() -> void:
	if not is_node_ready():
		return

	# When face-down, show only the card back
	card_back.visible = not is_face_up

	# When face-up, show the card face
	card_face.visible = is_face_up


## Smoothly returns the card to its original position
func return_to_original_position() -> void:
	# Create a tween for smooth animation
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", original_position, 0.3)

	# Reset z_index after animation completes
	tween.finished.connect(func() -> void:
		z_index = 0
	)


func _gui_input(event: InputEvent) -> void:
	# Only respond to input if card is selectable
	if not is_selectable:
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				if not is_playable:
					# Visual feedback for unplayable card
					show_invalid_selection()
					accept_event()
					return

				# Start dragging
				is_dragging = true
				original_position = global_position
				drag_offset = get_global_mouse_position() - global_position
				z_index = 100  # Bring to front while dragging
				# Show immediate visual feedback that card was selected
				show_selection_feedback()
				card_selected.emit(self)
				accept_event()
			elif is_dragging:
				# Stop dragging and return to original position
				is_dragging = false
				return_to_original_position()
				accept_event()

	elif event is InputEventMouseMotion:
		if is_dragging:
			# Update position while dragging
			global_position = get_global_mouse_position() - drag_offset
			accept_event()


## Shows visual feedback for card selection (when starting to drag)
func show_selection_feedback() -> void:
	# Pulse effect to show card was selected
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)

	# Brief bright flash
	var original_modulate := modulate
	tween.tween_property(self, "modulate", Color(1.4, 1.35, 1.5), 0.1)
	tween.tween_property(self, "modulate", Color(1.2, 1.15, 1.3), 0.15)


## Shows visual feedback when player tries to select an unplayable card
func show_invalid_selection() -> void:
	# Quick shake animation with red tint to indicate rejection
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)

	var original_pos := position
	tween.tween_property(self, "position", original_pos + Vector2(8, 0), 0.05)
	tween.tween_property(self, "position", original_pos - Vector2(8, 0), 0.05)
	tween.tween_property(self, "position", original_pos + Vector2(5, 0), 0.05)
	tween.tween_property(self, "position", original_pos, 0.05)

	# Red flash to show rejection
	var original_modulate := modulate
	modulate = Color(1.3, 0.6, 0.6, 1.0)
	await tween.finished
	modulate = original_modulate


func _on_mouse_entered() -> void:
	if is_selectable:
		set_highlighted(true)
		card_hovered.emit(self)


func _on_mouse_exited() -> void:
	if is_selectable:
		set_highlighted(false)
		card_unhovered.emit(self)


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
