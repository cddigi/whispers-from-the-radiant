extends SceneTree

## Test script to verify player hand interaction features

func _init() -> void:
	print("=== Testing Player Hand Interaction ===")
	test_card_playability_states()
	test_card_visual_feedback()
	test_hand_update_logic()
	print("=== All Tests Passed ===")
	quit()


func test_card_playability_states() -> void:
	print("\n--- Test: Card Playability States ---")

	# Create a card instance
	var card_scene := load("res://assets/cards/card.tscn") as PackedScene
	var card: Card = card_scene.instantiate() as Card

	# Create test card data
	var card_data := CardData.new()
	card_data.value = 5
	card_data.aspect = CardData.Aspect.MENTAL
	card.set_card_data(card_data)

	# Test initial state
	assert(card.is_playable == true, "Card should be playable by default")
	assert(card.is_selectable == true, "Card should be selectable by default")

	# Test setting playable state
	card.set_playable(false)
	assert(card.is_playable == false, "Card playability should update")

	card.set_playable(true)
	assert(card.is_playable == true, "Card should be playable again")

	# Test setting selectable state
	card.set_selectable(false)
	assert(card.is_selectable == false, "Card should not be selectable")
	assert(card.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Card should ignore mouse when unselectable")

	card.set_selectable(true)
	assert(card.is_selectable == true, "Card should be selectable again")
	assert(card.mouse_filter == Control.MOUSE_FILTER_STOP, "Card should accept mouse when selectable")

	card.free()
	print("✓ Card playability states work correctly")


func test_card_visual_feedback() -> void:
	print("\n--- Test: Card Visual Feedback ---")

	var card_scene := load("res://assets/cards/card.tscn") as PackedScene
	var card: Card = card_scene.instantiate() as Card

	var card_data := CardData.new()
	card_data.value = 7
	card_data.aspect = CardData.Aspect.PHYSICAL
	card.set_card_data(card_data)

	# Test normal playable state
	card.set_playable(true)
	card.set_selectable(true)
	assert(card.modulate == Color.WHITE, "Playable card should have normal color")

	# Test unplayable state
	card.set_playable(false)
	assert(card.modulate == Color(0.7, 0.7, 0.7, 0.85), "Unplayable card should be dimmed")

	# Test unselectable state
	card.set_selectable(false)
	assert(card.modulate == Color(0.5, 0.5, 0.5, 0.7), "Unselectable card should be more dimmed")

	card.free()
	print("✓ Card visual feedback works correctly")


func test_hand_update_logic() -> void:
	print("\n--- Test: Hand Update Logic ---")

	# Create game state
	var game_state := GameState.new()
	game_state.local_player_id = 1
	game_state.active_mentalic = 1

	# Generate deck and deal cards
	var deck := DeckGenerator.generate_full_deck()
	DeckGenerator.shuffle_deck(deck)
	var deal_result := DeckGenerator.deal_cards(deck)
	game_state.mentalic1_hand = deal_result.player1
	game_state.mentalic2_hand = deal_result.player2
	game_state.radiant_display_card = deal_result.decree
	game_state.dominant_aspect = deal_result.decree.aspect

	# Test case 1: First card of trick - all cards should be playable
	assert(game_state.current_trick.is_empty(), "Trick should be empty at start")
	for card_data in game_state.mentalic1_hand:
		var playable := can_play_card(card_data, 1, game_state)
		assert(playable == true, "All cards should be playable for first card of trick")

	# Test case 2: Must follow suit
	var first_card := game_state.mentalic1_hand[0]
	game_state.play_card_to_trick(first_card, 1)
	game_state.active_mentalic = 2  # Switch to player 2

	# Player 2 must follow suit if they have cards of that aspect
	var has_lead_aspect := DeckGenerator.count_aspect_in_hand(
		game_state.mentalic2_hand,
		game_state.lead_aspect
	) > 0

	if has_lead_aspect:
		# Check that cards of lead aspect are playable
		for card_data in game_state.mentalic2_hand:
			var playable := can_play_card(card_data, 2, game_state)
			if card_data.aspect == game_state.lead_aspect:
				assert(playable == true, "Cards of lead aspect should be playable")
			else:
				assert(playable == false, "Cards not of lead aspect should not be playable when player has lead aspect")

	print("✓ Hand update logic works correctly")


## Helper function to test card playability (mirrors game_controller logic)
func can_play_card(card_data: CardData, player_id: int, game_state: GameState) -> bool:
	if game_state.current_trick.is_empty():
		return true

	var hand := game_state.mentalic1_hand if player_id == 1 else game_state.mentalic2_hand
	var has_lead_aspect := DeckGenerator.count_aspect_in_hand(hand, game_state.lead_aspect) > 0

	if has_lead_aspect:
		return card_data.aspect == game_state.lead_aspect
	else:
		return true
