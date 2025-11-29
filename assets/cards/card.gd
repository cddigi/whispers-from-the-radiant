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
@onready var card_face := %CardFace as TextureRect
@onready var card_back := %CardBack as TextureRect

## Whether this card is currently face-up
var is_face_up: bool = true


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

	# Try to load the full card face image
	var card_face_path := card_data.get_card_face_path()
	var card_face_texture := load(card_face_path) as Texture2D

	if card_face_texture:
		card_face.texture = card_face_texture
	else:
		# Fallback: Create programmatic card face
		create_programmatic_card_face()


## Creates a programmatic card face when PNG is not available
func create_programmatic_card_face() -> void:
	# Clear existing children under CardFace
	for child in card_face.get_children():
		child.queue_free()

	# Get aspect color
	var aspect_color := card_data.get_aspect_color()

	# Create background ColorRect
	var background := ColorRect.new()
	background.name = "Background"
	background.color = aspect_color.darkened(0.3)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_face.add_child(background)

	# Create border
	var border := ColorRect.new()
	border.name = "Border"
	border.color = aspect_color
	border.set_anchors_preset(Control.PRESET_FULL_RECT)
	border.offset_left = 4
	border.offset_top = 4
	border.offset_right = -4
	border.offset_bottom = -4
	card_face.add_child(border)

	# Create inner background
	var inner_bg := ColorRect.new()
	inner_bg.name = "InnerBackground"
	inner_bg.color = Color.WHITE.darkened(0.1)
	inner_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	inner_bg.offset_left = 8
	inner_bg.offset_top = 8
	inner_bg.offset_right = -8
	inner_bg.offset_bottom = -8
	card_face.add_child(inner_bg)

	# Create value label (large in center)
	var value_label := Label.new()
	value_label.name = "ValueLabel"
	value_label.text = str(card_data.value)
	value_label.add_theme_font_size_override("font_size", 48)
	value_label.add_theme_color_override("font_color", aspect_color)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.set_anchors_preset(Control.PRESET_CENTER)
	value_label.offset_left = -30
	value_label.offset_top = -30
	value_label.offset_right = 30
	value_label.offset_bottom = 30
	card_face.add_child(value_label)

	# Create aspect label (top)
	var aspect_label := Label.new()
	aspect_label.name = "AspectLabel"
	aspect_label.text = card_data.get_aspect_name().substr(0, 3).to_upper()
	aspect_label.add_theme_font_size_override("font_size", 14)
	aspect_label.add_theme_color_override("font_color", aspect_color)
	aspect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	aspect_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	aspect_label.offset_top = 12
	aspect_label.offset_bottom = 28
	card_face.add_child(aspect_label)

	# Create small value labels in corners
	for corner: String in ["TopLeft", "BottomRight"]:
		var corner_label := Label.new()
		corner_label.name = corner + "Value"
		corner_label.text = str(card_data.value)
		corner_label.add_theme_font_size_override("font_size", 16)
		corner_label.add_theme_color_override("font_color", aspect_color)

		if corner == "TopLeft":
			corner_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
			corner_label.offset_left = 8
			corner_label.offset_top = 8
		else:
			corner_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
			corner_label.offset_right = -8
			corner_label.offset_bottom = -8
			corner_label.rotation = PI  # Upside down for bottom

		corner_label.offset_right = corner_label.offset_left + 20
		corner_label.offset_bottom = corner_label.offset_top + 20
		card_face.add_child(corner_label)

	# Add ability indicator if card has ability
	if card_data.has_ability:
		var ability_marker := Label.new()
		ability_marker.name = "AbilityMarker"
		ability_marker.text = "★"
		ability_marker.add_theme_font_size_override("font_size", 20)
		ability_marker.add_theme_color_override("font_color", Color.GOLD)
		ability_marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ability_marker.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		ability_marker.offset_bottom = -12
		ability_marker.offset_top = -28
		card_face.add_child(ability_marker)


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
		# Not your turn - cards are dimmed and desaturated
		modulate = Color(0.5, 0.5, 0.55, 0.7)
		z_index = 0
		# Stop any existing pulse animation
		_stop_playable_pulse()
	elif not is_playable:
		# Cannot play this card - show with red/gray overlay and slight offset down
		modulate = Color(0.6, 0.45, 0.45, 0.75)
		z_index = -1
		# Stop any existing pulse animation
		_stop_playable_pulse()
	else:
		# Playable card - bright and ready with subtle green tint
		modulate = Color(1.05, 1.1, 1.05, 1.0)
		z_index = 1
		# Start subtle pulse to draw attention
		_start_playable_pulse()


## Subtle pulsing glow for playable cards
var _pulse_tween: Tween = null

func _start_playable_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		return  # Already pulsing

	_pulse_tween = create_tween()
	_pulse_tween.set_loops()  # Loop forever
	_pulse_tween.set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.set_trans(Tween.TRANS_SINE)

	# Subtle brightness oscillation
	_pulse_tween.tween_property(self, "modulate", Color(1.1, 1.15, 1.1, 1.0), 0.8)
	_pulse_tween.tween_property(self, "modulate", Color(1.0, 1.05, 1.0, 1.0), 0.8)


func _stop_playable_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
		_pulse_tween = null


## Highlights the card (for hover state)
func set_highlighted(highlighted: bool) -> void:
	if not is_selectable or not is_playable:
		return  # Don't highlight unplayable/unselectable cards

	if highlighted:
		# Stop pulse animation during hover
		_stop_playable_pulse()
		# Mentalic glow - bright with significant emphasis and elevation
		modulate = Color(1.3, 1.25, 1.4, 1.0)  # Slight blue-purple glow for psychic power
		z_index = 10
		# Significant elevation effect for hover feedback
		position.y -= 15
		# Add a subtle scale up for additional feedback
		scale = Vector2(1.08, 1.08)
	else:
		# Return to normal playable state and restart pulse
		update_visual_state()
		z_index = 1
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
