## AI Strategy Manager for Antagonist
## Makes intelligent decisions for the AI opponent
class_name AIStrategy
extends Object

enum Difficulty {
	EASY,     ## Random valid plays
	MEDIUM,   ## Strategic card evaluation
	HARD      ## Advanced prediction and optimization
}

var difficulty: Difficulty = Difficulty.MEDIUM
var current_target_strategy: String = "high"  # "low" or "high"


## Selects the best card to play from the AI's hand
func choose_card_to_play(
	hand: Array[CardData],
	game_state: GameState,
	antagonist_tricks: int,
	protagonist_tricks: int
) -> CardData:
	match difficulty:
		Difficulty.EASY:
			return _choose_random_valid_card(hand, game_state)
		Difficulty.MEDIUM:
			return _choose_strategic_card(hand, game_state, antagonist_tricks, protagonist_tricks)
		Difficulty.HARD:
			return _choose_optimal_card(hand, game_state, antagonist_tricks, protagonist_tricks)
		_:
			return _choose_random_valid_card(hand, game_state)


## Easy difficulty: Play random valid card
func _choose_random_valid_card(hand: Array[CardData], game_state: GameState) -> CardData:
	var valid_cards := _get_valid_cards(hand, game_state)

	if valid_cards.is_empty():
		push_error("AI has no valid cards to play!")
		return hand[0] if not hand.is_empty() else null

	# Return random valid card
	return valid_cards[randi() % valid_cards.size()]


## Medium difficulty: Strategic card selection with basic evaluation
func _choose_strategic_card(
	hand: Array[CardData],
	game_state: GameState,
	antagonist_tricks: int,
	protagonist_tricks: int
) -> CardData:
	var valid_cards := _get_valid_cards(hand, game_state)

	if valid_cards.is_empty():
		return hand[0] if not hand.is_empty() else null

	# Determine target strategy
	var tricks_remaining := 13 - game_state.trick_number + 1
	current_target_strategy = CardEvaluator.determine_target_strategy(
		antagonist_tricks,
		tricks_remaining,
		protagonist_tricks
	)

	# Evaluate all valid cards
	var best_card: CardData = null
	var best_score := -1.0

	for card in valid_cards:
		var score := CardEvaluator.evaluate_card(
			card,
			hand,
			game_state,
			antagonist_tricks,
			current_target_strategy
		)

		if score > best_score:
			best_score = score
			best_card = card

	return best_card if best_card else valid_cards[0]


## Hard difficulty: Optimal play with advanced prediction
func _choose_optimal_card(
	hand: Array[CardData],
	game_state: GameState,
	antagonist_tricks: int,
	protagonist_tricks: int
) -> CardData:
	var valid_cards := _get_valid_cards(hand, game_state)

	if valid_cards.is_empty():
		return hand[0] if not hand.is_empty() else null

	# Determine target strategy with more sophisticated logic
	var tricks_remaining := 13 - game_state.trick_number + 1
	current_target_strategy = _determine_advanced_strategy(
		antagonist_tricks,
		protagonist_tricks,
		tricks_remaining,
		game_state
	)

	# If we're leading the trick, choose strategically
	if game_state.current_trick.is_empty():
		return _choose_lead_card(valid_cards, hand, game_state, antagonist_tricks)

	# If we're following, choose based on what opponent played
	return _choose_follow_card(valid_cards, hand, game_state, antagonist_tricks)


## Determines advanced strategy considering opponent's position
func _determine_advanced_strategy(
	our_tricks: int,
	their_tricks: int,
	tricks_remaining: int,
	game_state: GameState
) -> String:
	# If opponent is in high scoring zone, try to push them over
	if their_tricks >= 7 and their_tricks <= 9:
		if their_tricks + tricks_remaining >= 10:
			# Try to force them over 9 tricks
			return "high"  # Win tricks to deny them

	# If we're in optimal zones, protect it
	if our_tricks >= 7 and our_tricks <= 9:
		if our_tricks + tricks_remaining < 10:
			return "high"  # Stay in high zone
		else:
			return "low"  # Don't go over 9

	if our_tricks <= 3:
		if our_tricks + tricks_remaining <= 3:
			return "low"  # Stay in low zone
		else:
			return "high"  # Move to high zone

	# Default strategy based on position
	return CardEvaluator.determine_target_strategy(our_tricks, tricks_remaining, their_tricks)


## Choose best card when leading the trick
func _choose_lead_card(
	valid_cards: Array[CardData],
	hand: Array[CardData],
	game_state: GameState,
	current_tricks: int
) -> CardData:
	var target := current_target_strategy

	# Lead with trump to apply pressure
	var trump_cards := valid_cards.filter(func(c): return c.aspect == game_state.dominant_aspect)

	if target == "low":
		# Want to lose - lead low value card of weak aspect
		var non_trump := valid_cards.filter(func(c): return c.aspect != game_state.dominant_aspect)
		if not non_trump.is_empty():
			return CardEvaluator.get_lowest_of_aspect(non_trump, non_trump[0].aspect)
		return CardEvaluator.get_lowest_of_aspect(valid_cards, valid_cards[0].aspect)

	else:  # target == "high"
		# Want to win - lead high trump or high value
		if not trump_cards.is_empty() and trump_cards[0].value >= 7:
			return CardEvaluator.get_highest_of_aspect(trump_cards, game_state.dominant_aspect)

		# Otherwise lead highest card
		var highest: CardData = valid_cards[0]
		for card in valid_cards:
			if card.value > highest.value:
				highest = card
		return highest


## Choose best card when following opponent's lead
func _choose_follow_card(
	valid_cards: Array[CardData],
	hand: Array[CardData],
	game_state: GameState,
	current_tricks: int
) -> CardData:
	var opponent_card := game_state.current_trick[0]
	var target := current_target_strategy

	# Find cards that would win/lose
	var winning_cards: Array[CardData] = []
	var losing_cards: Array[CardData] = []

	for card in valid_cards:
		if CardEvaluator.will_win_trick(card, game_state):
			winning_cards.append(card)
		else:
			losing_cards.append(card)

	if target == "low":
		# Want to lose tricks
		if not losing_cards.is_empty():
			# Play highest losing card (keep low cards for later)
			return _get_highest_card(losing_cards)
		else:
			# Must win - play lowest winning card
			return _get_lowest_card(winning_cards) if not winning_cards.is_empty() else valid_cards[0]

	else:  # target == "high"
		# Want to win tricks
		if not winning_cards.is_empty():
			# Play lowest winning card (conserve high cards)
			return _get_lowest_card(winning_cards)
		else:
			# Can't win - play lowest losing card
			return _get_lowest_card(losing_cards) if not losing_cards.is_empty() else valid_cards[0]


## Gets all cards that can legally be played
func _get_valid_cards(hand: Array[CardData], game_state: GameState) -> Array[CardData]:
	# If leading, all cards are valid
	if game_state.current_trick.is_empty():
		return hand.duplicate()

	# If following, must follow suit if possible
	var lead_aspect := game_state.current_trick[0].aspect
	var same_aspect_cards: Array[CardData] = []

	for card in hand:
		if card.aspect == lead_aspect:
			same_aspect_cards.append(card)

	# Must follow suit if we have it
	if not same_aspect_cards.is_empty():
		return same_aspect_cards

	# Can play any card if we don't have lead aspect
	return hand.duplicate()


## Helper: Get highest value card from array
func _get_highest_card(cards: Array[CardData]) -> CardData:
	if cards.is_empty():
		return null

	var highest := cards[0]
	for card in cards:
		if card.value > highest.value:
			highest = card
	return highest


## Helper: Get lowest value card from array
func _get_lowest_card(cards: Array[CardData]) -> CardData:
	if cards.is_empty():
		return null

	var lowest := cards[0]
	for card in cards:
		if card.value < lowest.value:
			lowest = card
	return lowest


## Makes a choice for card 3 ability (Mental Static) - which card to exchange
func choose_card_for_mental_static(hand: Array[CardData], radiant_card: CardData, game_state: GameState) -> int:
	if difficulty == Difficulty.EASY:
		return randi() % hand.size()

	# Strategic choice: exchange our worst card for radiant card if radiant is better
	var worst_index := 0
	var worst_score := 999.0

	for i in range(hand.size()):
		var score := CardEvaluator.evaluate_card(
			hand[i],
			hand,
			game_state,
			0,  # Tricks don't matter for exchange decision
			current_target_strategy
		)

		if score < worst_score:
			worst_score = score
			worst_index = i

	return worst_index


## Makes a choice for card 5 ability (Intuitive Leap) - which card to discard after draw
func choose_card_to_discard(hand: Array[CardData], game_state: GameState) -> int:
	if difficulty == Difficulty.EASY:
		return randi() % hand.size()

	# Discard the lowest value card
	var worst_index := 0
	var worst_score := 999.0

	for i in range(hand.size()):
		var score := CardEvaluator.evaluate_card(
			hand[i],
			hand,
			game_state,
			0,
			current_target_strategy
		)

		if score < worst_score:
			worst_score = score
			worst_index = i

	return worst_index
