class_name Card
extends Control

## Visual representation of a CardData resource.
## Displays aspect color, value, and ability indicator.
## This is the basic version for Stage 1 - will be enhanced in Stage 3.

signal card_selected(card: Card)
signal card_hovered(card: Card)

## The data this card represents
var card_data: CardData = null

## Drag-and-drop state
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
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aspect_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aspect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ability_indicator.mouse_filter = Control.MOUSE_FILTER_IGNORE
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


## Highlights the card (for selection/hover)
func set_highlighted(highlighted: bool) -> void:
	if highlighted:
		modulate = Color(1.2, 1.2, 1.2)
		z_index = 10
	else:
		modulate = Color.WHITE
		z_index = 0


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

	# When face-up, show the card details
	background.visible = is_face_up
	aspect_border.visible = is_face_up
	value_label.visible = is_face_up
	aspect_label.visible = is_face_up
	ability_indicator.visible = is_face_up and (card_data != null and card_data.has_ability)


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
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				# Start dragging
				is_dragging = true
				original_position = global_position
				drag_offset = get_global_mouse_position() - global_position
				z_index = 100  # Bring to front while dragging
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


func _on_mouse_entered() -> void:
	set_highlighted(true)
	card_hovered.emit(self)


func _on_mouse_exited() -> void:
	set_highlighted(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
