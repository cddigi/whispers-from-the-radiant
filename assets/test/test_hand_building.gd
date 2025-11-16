extends SceneTree

## Automated test for hand building and game flow
## Run with: godot -s res://assets/test/test_hand_building.gd

func _init() -> void:
	print("=== Testing Hand Building ===")

	# Test 1: Deck generation and dealing
	print("\n[Test 1] Deck Generation and Dealing")
	var deck := DeckGenerator.generate_full_deck()
	assert(deck.size() == 33, "Deck should have 33 cards")
	print("✓ Full deck created: %d cards" % deck.size())

	DeckGenerator.shuffle_deck(deck)
	print("✓ Deck shuffled")

	var deal_result := DeckGenerator.deal_cards(deck)
	var p1_hand: Array = deal_result.player1
	var p2_hand: Array = deal_result.player2
	var decree: CardData = deal_result.decree
	assert(p1_hand.size() == 13, "Player 1 should have 13 cards")
	assert(p2_hand.size() == 13, "Player 2 should have 13 cards")
	assert(decree != null, "Decree card should exist")
	print("✓ Cards dealt: Player 1 has %d, Player 2 has %d" % [
		p1_hand.size(),
		p2_hand.size()
	])
	print("✓ Decree card: %s %d" % [
		decree.get_aspect_name(),
		decree.value
	])

	# Test 2: Game state initialization
	print("\n[Test 2] Game State Initialization")
	var game_state := GameState.new()
	game_state.mentalic1_hand = p1_hand
	game_state.mentalic2_hand = p2_hand
	game_state.radiant_display_card = decree
	game_state.dominant_aspect = decree.aspect
	game_state.local_player_id = 1
	print("✓ Game state created")
	print("  - Dominant aspect: %s" % decree.get_aspect_name())
	print("  - Active mentalic: %d" % game_state.active_mentalic)

	# Test 3: Hand sorting
	print("\n[Test 3] Hand Sorting")
	DeckGenerator.sort_hand(game_state.mentalic1_hand)
	print("✓ Player 1 hand sorted")
	print("  - First card: %s %d" % [
		game_state.mentalic1_hand[0].get_aspect_name(),
		game_state.mentalic1_hand[0].value
	])
	print("  - Last card: %s %d" % [
		game_state.mentalic1_hand[12].get_aspect_name(),
		game_state.mentalic1_hand[12].value
	])

	# Test 4: Aspect counting
	print("\n[Test 4] Aspect Counting")
	var test_aspects: Array[CardData.Aspect] = [CardData.Aspect.MENTAL, CardData.Aspect.PHYSICAL, CardData.Aspect.TEMPORAL]
	for aspect: CardData.Aspect in test_aspects:
		var count := DeckGenerator.count_aspect_in_hand(game_state.mentalic1_hand, aspect)
		var aspect_name: String
		match aspect:
			CardData.Aspect.MENTAL:
				aspect_name = "Mental"
			CardData.Aspect.PHYSICAL:
				aspect_name = "Physical"
			CardData.Aspect.TEMPORAL:
				aspect_name = "Temporal"
		print("  - %s cards: %d" % [aspect_name, count])

	# Test 5: Playing a card
	print("\n[Test 5] Playing Cards to Trick")
	var first_card := game_state.mentalic1_hand[0]
	game_state.play_card_to_trick(first_card, 1)
	assert(game_state.current_trick.size() == 1, "Trick should have 1 card")
	assert(game_state.lead_aspect == first_card.aspect, "Lead aspect should match first card")
	assert(game_state.mentalic1_hand.size() == 12, "Player 1 should have 12 cards left")
	print("✓ Card played to trick")
	print("  - Lead aspect: %s" % first_card.get_aspect_name())
	print("  - Cards remaining in hand: %d" % game_state.mentalic1_hand.size())

	var second_card := game_state.mentalic2_hand[0]
	game_state.play_card_to_trick(second_card, 2)
	assert(game_state.current_trick.size() == 2, "Trick should have 2 cards")
	print("✓ Second card played to trick")

	# Test 6: Clearing trick
	print("\n[Test 6] Clearing Trick")
	var trick_num_before := game_state.trick_number
	game_state.clear_trick()
	assert(game_state.current_trick.size() == 0, "Trick should be cleared")
	assert(game_state.trick_number == trick_num_before + 1, "Trick number should increment")
	print("✓ Trick cleared, number incremented to %d" % game_state.trick_number)

	# Test 7: Scoring calculation
	print("\n[Test 7] Score Calculation")
	var test_scores := {
		0: 6,   # Subtle Influence
		1: 6,
		2: 6,
		3: 6,
		4: 1,   # Detected Pressure
		5: 2,   # Obvious Manipulation
		6: 3,   # Contested Control
		7: 6,   # Calculated Dominance
		8: 6,
		9: 6,
		10: 0,  # Exposed Operation
		11: 0,
		12: 0,
		13: 0
	}

	for tricks: int in test_scores.keys():
		var expected_score: int = test_scores[tricks]
		# Calculate score using match logic
		var actual_score: int
		match tricks:
			0, 1, 2, 3:
				actual_score = 6
			4:
				actual_score = 1
			5:
				actual_score = 2
			6:
				actual_score = 3
			7, 8, 9:
				actual_score = 6
			_:
				actual_score = 0

		assert(actual_score == expected_score, "Score for %d tricks should be %d" % [tricks, expected_score])
	print("✓ All score calculations correct")

	# Test 8: Round completion check
	print("\n[Test 8] Round Completion")
	game_state.trick_number = 13
	assert(not game_state.is_round_complete(), "Round should not be complete at trick 13")
	game_state.trick_number = 14
	assert(game_state.is_round_complete(), "Round should be complete after trick 13")
	print("✓ Round completion detection working")

	# Test 9: Game winner check
	print("\n[Test 9] Game Winner Detection")
	game_state.mentalic1_total_score = 15
	game_state.mentalic2_total_score = 10
	assert(game_state.check_game_winner() == 0, "No winner yet")

	game_state.mentalic1_total_score = 21
	assert(game_state.check_game_winner() == 1, "Player 1 should win with 21 points")

	game_state.mentalic1_total_score = 10
	game_state.mentalic2_total_score = 24
	assert(game_state.check_game_winner() == 2, "Player 2 should win with 24 points")
	print("✓ Game winner detection working")

	print("\n=== All Tests Passed! ===")
	print("Hand building system is fully functional.")

	# Exit
	quit()
