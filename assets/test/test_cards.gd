extends Control

## Stage 1 test scene for verifying card generation and display.
## Creates a full deck, displays sample cards, and validates data structures.

const CardScene := preload("res://assets/cards/card.tscn")

## Scene-unique node references
@onready var card_container := %CardContainer as HBoxContainer
@onready var deck_info := %DeckInfo as Label
@onready var aspect_counts := %AspectCounts as Label
@onready var ability_cards := %AbilityCards as Label

var full_deck: Array[CardData] = []


func _ready() -> void:
	print("=== Whispers from the Radiant - Stage 1 Test ===")

	# Generate full deck
	full_deck = DeckGenerator.generate_full_deck()
	print("Generated deck with %d cards" % full_deck.size())

	# Validate deck composition
	validate_deck()

	# Display sample cards (one of each aspect, with different values)
	display_sample_cards()

	# Update info panel
	update_info_panel()


## Validates the deck has correct composition
func validate_deck() -> void:
	assert(full_deck.size() == 33, "Deck should have exactly 33 cards")

	# Count each aspect
	var mental_count := 0
	var physical_count := 0
	var temporal_count := 0

	for card: CardData in full_deck:
		match card.aspect:
			CardData.Aspect.MENTAL:
				mental_count += 1
			CardData.Aspect.PHYSICAL:
				physical_count += 1
			CardData.Aspect.TEMPORAL:
				temporal_count += 1

	assert(mental_count == 11, "Should have 11 Mental cards")
	assert(physical_count == 11, "Should have 11 Physical cards")
	assert(temporal_count == 11, "Should have 11 Temporal cards")

	print("✓ Deck composition validated: 11 Mental, 11 Physical, 11 Temporal")

	# Validate ability cards
	var ability_cards_count := 0
	for card: CardData in full_deck:
		if card.has_ability:
			ability_cards_count += 1

	# Should be 6 ability values (1,3,5,7,9,11) × 3 aspects = 18 cards
	assert(ability_cards_count == 18, "Should have 18 cards with abilities")
	print("✓ Ability cards validated: %d cards with special abilities" % ability_cards_count)


## Displays a selection of sample cards
func display_sample_cards() -> void:
	# Show one card of each aspect with different values
	# Mental 7 (has ability), Physical 5 (has ability), Temporal 9 (has ability)
	# Plus a Mental 4 (no ability) and Temporal 2 (no ability)

	var sample_configs: Array[Dictionary] = [
		{"aspect": CardData.Aspect.MENTAL, "value": 7},
		{"aspect": CardData.Aspect.PHYSICAL, "value": 5},
		{"aspect": CardData.Aspect.TEMPORAL, "value": 9},
		{"aspect": CardData.Aspect.MENTAL, "value": 4},
		{"aspect": CardData.Aspect.TEMPORAL, "value": 2},
	]

	for config: Dictionary in sample_configs:
		# Find this card in the deck
		var card_data := find_card_in_deck(config.aspect, config.value)
		if card_data:
			create_and_display_card(card_data)


## Finds a specific card in the deck
func find_card_in_deck(aspect: CardData.Aspect, value: int) -> CardData:
	for card: CardData in full_deck:
		if card.aspect == aspect and card.value == value:
			return card
	return null


## Creates a Card scene and adds it to the container
func create_and_display_card(card_data: CardData) -> void:
	var card_instance := CardScene.instantiate() as Card
	card_container.add_child(card_instance)
	card_instance.set_card_data(card_data)

	# Connect signals for testing
	card_instance.card_selected.connect(_on_card_selected)
	card_instance.card_hovered.connect(_on_card_hovered)


## Updates the info panel with deck statistics
func update_info_panel() -> void:
	deck_info.text = "Total cards in deck: %d" % full_deck.size()

	# Count aspects
	var counts := {
		CardData.Aspect.MENTAL: 0,
		CardData.Aspect.PHYSICAL: 0,
		CardData.Aspect.TEMPORAL: 0
	}

	for card: CardData in full_deck:
		counts[card.aspect] += 1

	aspect_counts.text = "Mental: %d | Physical: %d | Temporal: %d" % [
		counts[CardData.Aspect.MENTAL],
		counts[CardData.Aspect.PHYSICAL],
		counts[CardData.Aspect.TEMPORAL]
	]

	# Count ability cards
	var ability_count := 0
	for card: CardData in full_deck:
		if card.has_ability:
			ability_count += 1

	ability_cards.text = "Special ability cards: 1, 3, 5, 7, 9, 11 (%d total)" % ability_count


## Signal handlers for testing interaction
func _on_card_selected(card: Card) -> void:
	var card_data := card.get_card_data()
	print("Card selected: %s %d" % [card_data.get_aspect_name(), card_data.value])
	if card_data.has_ability:
		print("  Ability: %s" % card_data.ability_description)


func _on_card_hovered(card: Card) -> void:
	var card_data := card.get_card_data()
	print("Card hovered: %s %d" % [card_data.get_aspect_name(), card_data.value])
