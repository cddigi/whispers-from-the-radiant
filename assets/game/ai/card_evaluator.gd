## Card Evaluator for AI Opponent
## Assesses the strategic value of cards in various game contexts
class_name CardEvaluator
extends Object

## Evaluates a card's value in the current game context
## Returns a score from 0.0 (worst) to 1.0 (best)
static func evaluate_card(
	card: CardData,
	hand: Array[CardData],
	game_state: GameState,
	current_tricks_won: int,
	target_trick_range: String  # "low" (0-3) or "high" (7-9)
) -> float:
	var score := 0.0

	# Base value component (normalized 0-1)
	var value_score := float(card.value) / 11.0

	# Adjust based on current strategy
	if target_trick_range == "low":
		# For low tricks, prefer low value cards to avoid winning
		score += (1.0 - value_score) * 0.3
	else:
		# For high tricks, prefer high value cards to win
		score += value_score * 0.3

	# Trump/dominant aspect bonus
	if card.aspect == game_state.dominant_aspect:
		score += 0.2

	# Special ability bonus
	if card.has_ability:
		score += evaluate_ability_value(card, game_state, current_tricks_won) * 0.3

	# Context: if following suit required, prioritize valid cards
	if not game_state.current_trick.is_empty():
		var lead_aspect := game_state.current_trick[0].aspect
		if card.aspect == lead_aspect:
			score += 0.2  # Bonus for being playable

	return clamp(score, 0.0, 1.0)


## Evaluates the strategic value of a card's special ability
static func evaluate_ability_value(
	card: CardData,
	game_state: GameState,
	current_tricks: int
) -> float:
	match card.value:
		1:  # Whispered Redirection - gain lead on loss
			# More valuable early in round when positioning matters
			return 0.7 if game_state.trick_number <= 5 else 0.4

		3:  # Mental Static - exchange with Prime Radiant
			# Valuable if radiant card is better than average hand
			if game_state.radiant_display_card:
				return 0.6  # Always some value in card exchange
			return 0.3

		5:  # Intuitive Leap - draw and discard
			# Valuable mid-game for hand optimization
			return 0.7 if game_state.trick_number >= 4 and game_state.trick_number <= 10 else 0.4

		7:  # Conversion Point - bonus points on win
			# Valuable if aiming for high score
			return 0.8 if current_tricks >= 4 and current_tricks <= 8 else 0.5

		9:  # Mentalic Resonance - wild aspect
			# Very valuable for flexibility
			return 0.9

		11:  # Speaker's Command - force opponent play
			# Valuable late game to control opponent
			return 0.8 if game_state.trick_number >= 8 else 0.5

		_:
			return 0.0


## Predicts if playing this card will win the current trick
static func will_win_trick(
	card: CardData,
	game_state: GameState
) -> bool:
	# If leading, assume we'll win with high cards of trump
	if game_state.current_trick.is_empty():
		return card.aspect == game_state.dominant_aspect and card.value >= 7

	var opponent_card := game_state.current_trick[0]
	var lead_aspect := opponent_card.aspect
	var trump := game_state.dominant_aspect

	# Handle card 9 special case
	var opponent_is_wild := opponent_card.value == 9
	var we_are_wild := card.value == 9

	# Both wild - higher value wins
	if opponent_is_wild and we_are_wild:
		return card.value > opponent_card.value

	# We're wild, opponent isn't - we're trump
	if we_are_wild:
		return true

	# Opponent is wild, we're not - they're trump
	if opponent_is_wild:
		return false

	# Trump beats non-trump
	var opponent_is_trump := opponent_card.aspect == trump
	var we_are_trump := card.aspect == trump

	if we_are_trump and not opponent_is_trump:
		return true
	if opponent_is_trump and not we_are_trump:
		return false

	# Following lead aspect beats off-aspect
	var opponent_follows := opponent_card.aspect == lead_aspect
	var we_follow := card.aspect == lead_aspect

	if we_follow and not opponent_follows:
		return true
	if opponent_follows and not we_follow:
		return false

	# Both same category - higher value wins
	return card.value > opponent_card.value


## Determines optimal scoring strategy based on current game state
## Returns "low" (aim for 0-3 tricks) or "high" (aim for 7-9 tricks)
static func determine_target_strategy(
	current_tricks: int,
	tricks_remaining: int,
	opponent_tricks: int
) -> String:
	# If we're in danger zone (4-6 or 10+), try to move out
	if current_tricks >= 10:
		# Already exposed - minimize damage, aim low
		return "low"

	if current_tricks >= 7 and current_tricks <= 9:
		# In high scoring zone - stay here if possible
		if current_tricks + tricks_remaining >= 10:
			# Risk of going over - be cautious
			return "low"
		return "high"

	if current_tricks >= 4 and current_tricks <= 6:
		# In poor scoring zone - decide which way to go
		if tricks_remaining >= 3:
			# Enough tricks to reach high zone
			return "high"
		else:
			# Not enough tricks, drop to low zone
			return "low"

	# In low zone (0-3)
	if current_tricks <= 3:
		if tricks_remaining <= (3 - current_tricks):
			# Can stay in low zone
			return "low"
		else:
			# Will likely exceed low zone, aim for high
			return "high"

	# Default to high scoring strategy
	return "high"


## Counts how many cards of a specific aspect are in hand
static func count_aspect_in_hand(hand: Array[CardData], aspect: CardData.Aspect) -> int:
	var count := 0
	for card in hand:
		if card.aspect == aspect:
			count += 1
	return count


## Gets the highest card of a specific aspect in hand
static func get_highest_of_aspect(hand: Array[CardData], aspect: CardData.Aspect) -> CardData:
	var highest: CardData = null
	for card in hand:
		if card.aspect == aspect:
			if highest == null or card.value > highest.value:
				highest = card
	return highest


## Gets the lowest card of a specific aspect in hand
static func get_lowest_of_aspect(hand: Array[CardData], aspect: CardData.Aspect) -> CardData:
	var lowest: CardData = null
	for card in hand:
		if card.aspect == aspect:
			if lowest == null or card.value < lowest.value:
				lowest = card
	return lowest
