class_name CardTemplate
extends Control

## Card template with ornate border, rank, suit, portrait area, and ability text.
## Designed for Foundation universe card game with all 33 cards in deck.
## Odd-numbered cards (1,3,5,7,9,11) display ability text; even cards show only rank/suit.

signal card_selected(card: CardTemplate)
signal card_hovered(card: CardTemplate)

## The data this card represents
var card_data: CardData = null

## Drag-and-drop state
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO

## Visual elements (scene-unique node references)
@onready var border_frame := %BorderFrame as TextureRect
@onready var portrait_area := %PortraitArea as TextureRect
@onready var rank_top := %RankTop as Label
@onready var rank_bottom := %RankBottom as Label
@onready var suit_top := %SuitTop as Label
@onready var suit_bottom := %SuitBottom as Label
@onready var ability_panel := %AbilityPanel as PanelContainer
@onready var ability_name := %AbilityName as Label
@onready var ability_description := %AbilityDescription as Label
@onready var card_back := %CardBack as TextureRect

## Whether this card is currently face-up
var is_face_up: bool = true

## Optional custom portrait texture for this card
var portrait_texture: Texture2D = null

## Optional custom border texture (defaults to template border)
var border_texture: Texture2D = null


func _ready() -> void:
	# Ensure the card can receive mouse input
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Make sure all child elements ignore mouse events so parent receives them
	border_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rank_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rank_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	suit_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	suit_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ability_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ability_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ability_description.mouse_filter = Control.MOUSE_FILTER_IGNORE
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


## Sets a custom portrait texture for this card
func set_portrait(texture: Texture2D) -> void:
	portrait_texture = texture
	if is_node_ready():
		portrait_area.texture = texture


## Sets a custom border frame texture
func set_border(texture: Texture2D) -> void:
	border_texture = texture
	if is_node_ready():
		border_frame.texture = texture


## Updates all visual elements to match card_data
func update_visuals() -> void:
	if not card_data:
		return

	# Set border texture if available
	if border_texture:
		border_frame.texture = border_texture

	# Set portrait texture if available
	if portrait_texture:
		portrait_area.texture = portrait_texture

	# Set rank in both top-left and bottom-right corners
	var rank_text := str(card_data.value)
	rank_top.text = rank_text
	rank_bottom.text = rank_text

	# Set aspect/suit indicators
	var suit_text := get_suit_symbol(card_data.aspect)
	var aspect_color := card_data.get_aspect_color()

	suit_top.text = suit_text
	suit_bottom.text = suit_text
	suit_top.add_theme_color_override("font_color", aspect_color)
	suit_bottom.add_theme_color_override("font_color", aspect_color)

	# Color the rank labels with aspect color
	rank_top.add_theme_color_override("font_color", aspect_color)
	rank_bottom.add_theme_color_override("font_color", aspect_color)

	# Show ability panel only for odd-numbered cards (1,3,5,7,9,11)
	if card_data.has_ability:
		ability_panel.visible = true
		ability_name.text = get_ability_name(card_data.value)
		ability_description.text = card_data.ability_description
	else:
		ability_panel.visible = false


## Returns the suit symbol for the aspect
func get_suit_symbol(aspect: CardData.Aspect) -> String:
	match aspect:
		CardData.Aspect.MENTAL:
			return "🧠"  # Mental (Blue)
		CardData.Aspect.PHYSICAL:
			return "⚔️"  # Physical (Gold)
		CardData.Aspect.TEMPORAL:
			return "⏳"  # Temporal (Red)
		_:
			return "?"


## Returns ability name for card display
func get_ability_name(value: int) -> String:
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
			return "Imperial Decree"
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
	border_frame.visible = is_face_up
	portrait_area.visible = is_face_up
	rank_top.visible = is_face_up
	rank_bottom.visible = is_face_up
	suit_top.visible = is_face_up
	suit_bottom.visible = is_face_up
	ability_panel.visible = is_face_up and (card_data != null and card_data.has_ability)


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
