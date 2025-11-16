class_name CardTemplate
extends Control

## Enhanced card template with support for custom card face textures.
## Allows overlaying rank, aspect, and ability text on card face images.

signal card_selected(card: CardTemplate)
signal card_hovered(card: CardTemplate)

## The data this card represents
var card_data: CardData = null

## Drag-and-drop state
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO

## Visual elements (scene-unique node references)
@onready var card_face_texture := %CardFaceTexture as TextureRect
@onready var aspect_border := %AspectBorder as ColorRect
@onready var rank_label := %RankLabel as Label
@onready var aspect_label := %AspectLabel as Label
@onready var ability_text := %AbilityText as Label
@onready var card_back := %CardBack as TextureRect

## Whether this card is currently face-up
var is_face_up: bool = true

## Optional custom card face texture
var card_face: Texture2D = null


func _ready() -> void:
	# Ensure the card can receive mouse input
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Make sure all child elements ignore mouse events so parent receives them
	card_face_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aspect_border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rank_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	aspect_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ability_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
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


## Sets a custom card face texture
func set_card_face(texture: Texture2D) -> void:
	card_face = texture
	if is_node_ready():
		card_face_texture.texture = texture


## Updates all visual elements to match card_data
func update_visuals() -> void:
	if not card_data:
		return

	# Set card face texture if available
	if card_face:
		card_face_texture.texture = card_face
		card_face_texture.visible = true
	else:
		card_face_texture.visible = false

	# Set rank
	rank_label.text = str(card_data.value)

	# Set aspect color and name
	var aspect_color := card_data.get_aspect_color()
	aspect_border.color = aspect_color
	aspect_label.text = card_data.get_aspect_name().to_upper()
	aspect_label.add_theme_color_override("font_color", aspect_color)

	# Show ability text for special cards
	if card_data.has_ability:
		ability_text.visible = true
		ability_text.text = get_short_ability_text(card_data.value)
		ability_text.tooltip_text = card_data.ability_description
	else:
		ability_text.visible = false

	# Add subtle tint to rank label based on aspect
	rank_label.add_theme_color_override("font_color", aspect_color)


## Returns abbreviated ability text for card display
func get_short_ability_text(value: int) -> String:
	match value:
		1:
			return "Whispered Redirection"
		3:
			return "Mental Static"
		5:
			return "Intuitive Leap"
		7:
			return "Conversion Point"
		9:
			return "Mentalic Resonance"
		11:
			return "Speaker's Command"
		_:
			return ""


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
	card_face_texture.visible = is_face_up and card_face != null
	aspect_border.visible = is_face_up
	rank_label.visible = is_face_up
	aspect_label.visible = is_face_up
	ability_text.visible = is_face_up and (card_data != null and card_data.has_ability)


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
