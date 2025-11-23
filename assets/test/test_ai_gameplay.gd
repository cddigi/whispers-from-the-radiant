extends SceneTree

## Quick test to verify AI gameplay works correctly
## Run with: /Applications/Godot.app/Contents/MacOS/Godot -s res://assets/test/test_ai_gameplay.gd

# Preload required classes
const AIStrategyScript = preload("res://assets/game/ai/ai_strategy.gd")
const CardDataScript = preload("res://assets/cards/card_data.gd")
const GameStateScript = preload("res://assets/game/game_state.gd")
const DeckGeneratorScript = preload("res://assets/game/managers/deck_generator.gd")

func _init() -> void:
	print("\n=== AI Gameplay Test ===\n")

	# Create game state
	var game_state := GameState.new()
	game_state.local_player_id = 1

	# Generate deck
	var deck := DeckGenerator.generate_full_deck()
	DeckGenerator.shuffle_deck(deck)

	# Deal cards
	var deal := DeckGenerator.deal_cards(deck)
	game_state.mentalic1_hand = deal.player1
	game_state.mentalic2_hand = deal.player2
	game_state.radiant_display_card = deal.decree
	game_state.dominant_aspect = deal.decree.aspect

	print("Protagonist (Player 1) hand:")
	for card in game_state.mentalic1_hand:
		print("  %s %d%s" % [
			card.get_aspect_name(),
			card.value,
			" (ability)" if card.has_ability else ""
		])

	print("\nAntagonist (Player 2/AI) hand:")
	for card in game_state.mentalic2_hand:
		print("  %s %d%s" % [
			card.get_aspect_name(),
			card.value,
			" (ability)" if card.has_ability else ""
		])

	print("\nDominant Aspect (Trump): %s" % game_state.radiant_display_card.get_aspect_name())

	# Test AI at each difficulty
	_test_difficulty(AIStrategy.Difficulty.EASY, game_state)
	_test_difficulty(AIStrategy.Difficulty.MEDIUM, game_state)
	_test_difficulty(AIStrategy.Difficulty.HARD, game_state)

	print("\n=== All AI Tests Passed! ===\n")
	quit()


func _test_difficulty(difficulty: AIStrategy.Difficulty, game_state: GameState) -> void:
	var difficulty_name := ""
	match difficulty:
		AIStrategy.Difficulty.EASY: difficulty_name = "EASY"
		AIStrategy.Difficulty.MEDIUM: difficulty_name = "MEDIUM"
		AIStrategy.Difficulty.HARD: difficulty_name = "HARD"

	print("\n--- Testing %s Difficulty ---" % difficulty_name)

	var ai := AIStrategy.new()
	ai.difficulty = difficulty

	# Test AI choosing a card to lead
	game_state.current_trick.clear()
	game_state.trick_number = 1
	game_state.active_mentalic = 2

	var card := ai.choose_card_to_play(
		game_state.mentalic2_hand.duplicate(),
		game_state,
		0,  # antagonist tricks
		0   # protagonist tricks
	)

	print("AI chose to lead with: %s %d (strategy: %s)" % [
		card.get_aspect_name(),
		card.value,
		ai.current_target_strategy
	])

	# Simulate protagonist playing first
	game_state.current_trick.append(game_state.mentalic1_hand[0])
	game_state.lead_aspect = game_state.mentalic1_hand[0].aspect

	# Test AI following
	var follow_card := ai.choose_card_to_play(
		game_state.mentalic2_hand.duplicate(),
		game_state,
		0,
		0
	)

	print("AI chose to follow with: %s %d (following %s)" % [
		follow_card.get_aspect_name(),
		follow_card.value,
		game_state.lead_aspect
	])

	# Verify card is valid
	var is_valid := _is_valid_play(follow_card, game_state.mentalic2_hand, game_state)
	if is_valid:
		print("✓ AI choice is valid")
	else:
		print("✗ ERROR: AI choice is INVALID!")
		quit(1)


func _is_valid_play(card: CardData, hand: Array[CardData], game_state: GameState) -> bool:
	if game_state.current_trick.is_empty():
		return true

	var lead_aspect := game_state.current_trick[0].aspect

	# Check if hand has cards of lead aspect
	var has_lead := false
	for c in hand:
		if c.aspect == lead_aspect:
			has_lead = true
			break

	if has_lead:
		# Must follow suit
		return card.aspect == lead_aspect

	# Can play anything if can't follow
	return true
