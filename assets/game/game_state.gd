class_name GameState
extends Resource

## Central game state resource managing all data for a Whispers from the Radiant match.
## Tracks player hands, trick state, scores, and Prime Radiant configuration.
## This resource is synchronized between networked clients via RPC calls.

# Player hands (private information - only visible to owning player)
var mentalic1_hand: Array[CardData] = []
var mentalic2_hand: Array[CardData] = []

# Prime Radiant state (the dominant psychohistorical variable)
var dominant_aspect: CardData.Aspect = CardData.Aspect.MENTAL
var radiant_display_card: CardData = null  # Face-up decree card

# Current trick state
var active_mentalic: int = 1  # 1 or 2 - whose turn to manipulate
var current_trick: Array[CardData] = []  # Cards played in current trick
var trick_number: int = 1  # Which probability node (1-13)
var lead_aspect: CardData.Aspect = CardData.Aspect.MENTAL  # First card's aspect

# Score tracking - tricks won this round
var mentalic1_tricks: int = 0
var mentalic2_tricks: int = 0

# Score tracking - round points (including card 7 bonuses)
var mentalic1_round_score: int = 0
var mentalic2_round_score: int = 0

# Score tracking - total game influence
var mentalic1_total_score: int = 0
var mentalic2_total_score: int = 0

# Deck management
var draw_pile: Array[CardData] = []

# Mental shield state (local only, not synced - UI state)
var mentalic1_piercing: bool = false
var mentalic2_piercing: bool = false

# Network identity (which player this client represents)
var local_player_id: int = 1


## Returns true if it's the local player's turn
func is_local_players_turn() -> bool:
	return active_mentalic == local_player_id


## Gets the opponent's hand (the one that should be shielded)
func get_opponent_hand() -> Array[CardData]:
	if local_player_id == 1:
		return mentalic2_hand
	else:
		return mentalic1_hand


## Gets the local player's hand
func get_local_hand() -> Array[CardData]:
	if local_player_id == 1:
		return mentalic1_hand
	else:
		return mentalic2_hand


## Adds a card to the current trick
func play_card_to_trick(card: CardData, player_id: int) -> void:
	current_trick.append(card)

	# Set lead aspect from first card
	if current_trick.size() == 1:
		lead_aspect = card.aspect

	# Remove card from player's hand
	var hand := mentalic1_hand if player_id == 1 else mentalic2_hand
	var card_index := hand.find(card)
	if card_index >= 0:
		hand.remove_at(card_index)


## Clears the current trick after resolution
func clear_trick() -> void:
	current_trick.clear()
	trick_number += 1


## Resets state for a new round
func reset_for_new_round() -> void:
	mentalic1_hand.clear()
	mentalic2_hand.clear()
	current_trick.clear()
	trick_number = 1
	mentalic1_tricks = 0
	mentalic2_tricks = 0
	mentalic1_round_score = 0
	mentalic2_round_score = 0
	draw_pile.clear()
	radiant_display_card = null


## Checks if the round is over (all 13 tricks played)
func is_round_complete() -> bool:
	return trick_number > 13


## Checks if either player has won the game (21+ points)
func check_game_winner() -> int:
	if mentalic1_total_score >= 21:
		return 1
	elif mentalic2_total_score >= 21:
		return 2
	return 0  # No winner yet


## Serializes state to dictionary for network sync
func to_dict() -> Dictionary:
	return {
		"dominant_aspect": dominant_aspect,
		"active_mentalic": active_mentalic,
		"trick_number": trick_number,
		"mentalic1_tricks": mentalic1_tricks,
		"mentalic2_tricks": mentalic2_tricks,
		"mentalic1_round_score": mentalic1_round_score,
		"mentalic2_round_score": mentalic2_round_score,
		"mentalic1_total_score": mentalic1_total_score,
		"mentalic2_total_score": mentalic2_total_score,
	}


## Deserializes state from dictionary after network sync
func from_dict(data: Dictionary) -> void:
	if data.has("dominant_aspect"):
		dominant_aspect = data.dominant_aspect
	if data.has("active_mentalic"):
		active_mentalic = data.active_mentalic
	if data.has("trick_number"):
		trick_number = data.trick_number
	if data.has("mentalic1_tricks"):
		mentalic1_tricks = data.mentalic1_tricks
	if data.has("mentalic2_tricks"):
		mentalic2_tricks = data.mentalic2_tricks
	if data.has("mentalic1_round_score"):
		mentalic1_round_score = data.mentalic1_round_score
	if data.has("mentalic2_round_score"):
		mentalic2_round_score = data.mentalic2_round_score
	if data.has("mentalic1_total_score"):
		mentalic1_total_score = data.mentalic1_total_score
	if data.has("mentalic2_total_score"):
		mentalic2_total_score = data.mentalic2_total_score
