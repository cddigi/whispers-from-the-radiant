class_name CardData
extends Resource

## Data resource representing a single card in the Seldon Plan deck.
## Each card has an aspect (Mental/Physical/Temporal), a value (1-11),
## and potentially a special psychohistorical manipulation ability.

enum Aspect {
	MENTAL,    ## Blue - psychic manipulation and control
	PHYSICAL,  ## Gold - economic and military forces
	TEMPORAL   ## Red - historical momentum and crisis points
}

## Card value from 1-11
@export var value: int = 1

## The aspect/suit this card belongs to
@export var aspect: Aspect = Aspect.MENTAL

## Whether this card has a special ability
@export var has_ability: bool = false

## Description of the card's special ability
@export var ability_description: String = ""


## Returns the human-readable name of the aspect
func get_aspect_name() -> String:
	match aspect:
		Aspect.MENTAL:
			return "Mental"
		Aspect.PHYSICAL:
			return "Physical"
		Aspect.TEMPORAL:
			return "Temporal"
		_:
			return "Unknown"


## Returns the color associated with this aspect for UI rendering
func get_aspect_color() -> Color:
	match aspect:
		Aspect.MENTAL:
			return Color(0.3, 0.4, 0.8)  # Blue
		Aspect.PHYSICAL:
			return Color(0.8, 0.6, 0.2)  # Gold
		Aspect.TEMPORAL:
			return Color(0.8, 0.2, 0.2)  # Red
		_:
			return Color.WHITE


## Returns a unique identifier for this card
func get_card_id() -> String:
	return "%s_%d" % [get_aspect_name(), value]


## Returns true if this card has a special ability based on its value
func check_ability() -> bool:
	return value in [1, 3, 5, 7, 9, 11]


## Initialize ability description based on card value
func _init(card_value: int = 1, card_aspect: Aspect = Aspect.MENTAL) -> void:
	value = card_value
	aspect = card_aspect
	has_ability = check_ability()

	# Set ability descriptions for special cards
	match value:
		1:
			ability_description = "Whispered Redirection: If you lose this trick, lead the next"
		3:
			ability_description = "Mental Static: Exchange Prime Radiant card with one from hand"
		5:
			ability_description = "Intuitive Leap: Draw 1 card, then discard 1 to bottom"
		7:
			ability_description = "Conversion Point: Winner receives 1 point per 7 in trick"
		9:
			ability_description = "Mentalic Resonance: If only 9 in trick, treated as dominant aspect"
		11:
			ability_description = "Speaker's Command: Opponent must play 1 or highest of aspect"
		_:
			ability_description = ""
