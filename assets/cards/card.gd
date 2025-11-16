class_name Card
extends Control

## Visual representation of a CardData resource.
## Displays aspect color, value, and ability indicator.
## This is the basic version for Stage 1 - will be enhanced in Stage 3.

signal card_selected(card: Card)
signal card_hovered(card: Card)

## The data this card represents
var card_data: CardData = null

## Visual elements (scene-unique node references)
@onready var card_face := %CardFace as TextureRect


func _ready() -> void:
	# If card_data was set before _ready, update visuals
	if card_data:
		update_visuals()


## Sets the card data and updates the visual representation
func set_card_data(data: CardData) -> void:
	card_data = data
	if is_node_ready():
		update_visuals()


## Updates all visual elements to match card_data
func update_visuals() -> void:
	if not card_data:
		return

	# Load the full card face image
	var card_face_path := card_data.get_card_face_path()
	var card_face_texture := load(card_face_path) as Texture2D

	if card_face_texture:
		card_face.texture = card_face_texture
	else:
		push_error("Failed to load card face texture: " + card_face_path)


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


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			card_selected.emit(self)
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
