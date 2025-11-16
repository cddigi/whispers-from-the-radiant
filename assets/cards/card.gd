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
@onready var background := %CardBackground as ColorRect
@onready var aspect_border := %AspectBorder as ColorRect
@onready var value_label := %ValueLabel as Label
@onready var aspect_label := %AspectLabel as Label
@onready var ability_indicator := %AbilityIndicator as Label


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
