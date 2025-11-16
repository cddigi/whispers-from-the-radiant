extends Control

## Main game controller for Whispers from the Radiant.
## Manages game flow, hand display, trick resolution, and scoring.
## This is the primary gameplay scene.

const CardScene := preload("res://assets/cards/card.tscn")
const RoundSummaryScene := preload("res://assets/ui/round_summary.tscn")
const GameOverScene := preload("res://assets/ui/game_over.tscn")

## Scene-unique node references
@onready var player1_hand_container := %Player1HandContainer as HBoxContainer
@onready var player2_hand_container := %Player2HandContainer as HBoxContainer
@onready var trick_area := %TrickArea as Control
@onready var decree_display := %DecreeDisplay as Control
@onready var score_label := %ScoreLabel as Label
@onready var turn_indicator := %TurnIndicator as Label

## Game state resource
var game_state: GameState = null

## Card instances in each player's hand UI
var player1_hand_cards: Array[Card] = []
var player2_hand_cards: Array[Card] = []

## Cards played in current trick
var player1_trick_card: Card = null
var player2_trick_card: Card = null

## AI Strategy instance for opponent
var ai_strategy: AIStrategy = null
var ai_difficulty: AIStrategy.Difficulty = AIStrategy.Difficulty.MEDIUM

## UI overlays
var round_summary: RoundSummary = null
var game_over_screen: GameOver = null


func _ready() -> void:
	print("=== Whispers from the Radiant - Game Start ===")

	# Initialize AI strategy
	ai_strategy = AIStrategy.new()
	ai_strategy.difficulty = ai_difficulty

	# Initialize UI overlays
	round_summary = RoundSummaryScene.instantiate() as RoundSummary
	round_summary.hide()
	round_summary.continue_pressed.connect(_on_round_summary_continue)
	add_child(round_summary)

	game_over_screen = GameOverScene.instantiate() as GameOver
	game_over_screen.hide()
	game_over_screen.new_game_pressed.connect(_on_new_game)
	game_over_screen.main_menu_pressed.connect(_on_main_menu)
	add_child(game_over_screen)

	initialize_new_round()


## Initializes a new round: creates deck, shuffles, deals, displays
func initialize_new_round() -> void:
	# Create fresh game state
	game_state = GameState.new()
	game_state.local_player_id = 1  # For now, always player 1 is local

	# Generate and shuffle deck
	var deck := DeckGenerator.generate_full_deck()
	DeckGenerator.shuffle_deck(deck)
	print("Deck generated and shuffled: %d cards" % deck.size())

	# Deal cards to both players
	var deal_result := DeckGenerator.deal_cards(deck)
	game_state.mentalic1_hand = deal_result.player1
	game_state.mentalic2_hand = deal_result.player2
	game_state.radiant_display_card = deal_result.decree

	# Set dominant aspect based on decree card
	game_state.dominant_aspect = deal_result.decree.aspect

	print("Player 1 dealt %d cards" % game_state.mentalic1_hand.size())
	print("Player 2 dealt %d cards" % game_state.mentalic2_hand.size())
	print("Prime Radiant decree: %s %d" % [
		game_state.radiant_display_card.get_aspect_name(),
		game_state.radiant_display_card.value
	])

	# Sort hands for better display
	DeckGenerator.sort_hand(game_state.mentalic1_hand)
	DeckGenerator.sort_hand(game_state.mentalic2_hand)

	# Display hands
	display_player_hand(1)
	display_player_hand(2)

	# Display decree card
	display_decree_card()

	# Update UI
	update_score_display()
	update_turn_indicator()

	# If AI goes first, have them play after short delay
	if not game_state.is_local_players_turn():
		await get_tree().create_timer(1.5).timeout
		ai_play_card()


## Displays a player's hand in their container
func display_player_hand(player_id: int) -> void:
	var hand_data: Array[CardData]
	var hand_container: HBoxContainer
	var hand_cards_array: Array[Card]
	var is_local_player := (player_id == game_state.local_player_id)

	if player_id == 1:
		hand_data = game_state.mentalic1_hand
		hand_container = player1_hand_container
		hand_cards_array = player1_hand_cards
	else:
		hand_data = game_state.mentalic2_hand
		hand_container = player2_hand_container
		hand_cards_array = player2_hand_cards

	# Clear existing cards
	for card in hand_cards_array:
		card.queue_free()
	hand_cards_array.clear()

	# Create card instances for each card in hand
	for card_data in hand_data:
		var card_instance := CardScene.instantiate() as Card
		hand_container.add_child(card_instance)
		card_instance.set_card_data(card_data)

		# Set face-up for local player, face-down for opponent
		card_instance.set_face_up(is_local_player)

		# Connect signals only for local player's cards
		if is_local_player:
			card_instance.card_selected.connect(_on_player_card_selected.bind(card_instance))
			card_instance.card_hovered.connect(_on_player_card_hovered.bind(card_instance))

		hand_cards_array.append(card_instance)

	# Update card playability states if it's the local player
	if is_local_player:
		update_hand_playability()

	print("Displayed %d cards for Player %d (face-%s)" % [
		hand_cards_array.size(),
		player_id,
		"up" if is_local_player else "down"
	])


## Displays the Prime Radiant decree card (trump indicator) with clear labeling
func display_decree_card() -> void:
	if not game_state.radiant_display_card:
		return

	# Clear existing decree display
	for child in decree_display.get_children():
		child.queue_free()

	# Create decree card instance
	var decree_card := CardScene.instantiate() as Card
	decree_display.add_child(decree_card)
	decree_card.set_card_data(game_state.radiant_display_card)
	decree_card.set_face_up(true)

	# Update decree label to show the dominant aspect clearly
	update_decree_label()

	print("Decree card displayed: %s %d (dominant aspect)" % [
		game_state.radiant_display_card.get_aspect_name(),
		game_state.radiant_display_card.value
	])


## Updates the score display with clear, readable formatting
func update_score_display() -> void:
	var p1_influence = game_state.mentalic1_total_score
	var p2_influence = game_state.mentalic2_total_score

	score_label.text = "Player 1: %d nodes won | %d round points | %d total | Player 2: %d nodes won | %d round points | %d total" % [
		game_state.mentalic1_tricks,
		game_state.mentalic1_round_score,
		p1_influence,
		game_state.mentalic2_tricks,
		game_state.mentalic2_round_score,
		p2_influence
	]


## Updates the turn indicator with clear player identification and context
func update_turn_indicator() -> void:
	var is_local_turn := game_state.is_local_players_turn()
	var trick_num = game_state.trick_number
	var player_name = "Player 1 (You)" if game_state.active_mentalic == game_state.local_player_id else "Opponent (Player %d)" % game_state.active_mentalic

	# Add urgency indicator based on tricks played
	var urgency_text = ""
	if game_state.trick_number > 10:
		urgency_text = " - CRITICAL NODE"
	elif game_state.trick_number > 6:
		urgency_text = " - CONVERGENCE POINT"

	if is_local_turn:
		turn_indicator.text = "YOUR TURN - %s [Node %d/13]%s" % [player_name, trick_num, urgency_text]
		turn_indicator.add_theme_color_override("font_color", Color.LIGHT_GREEN)
	else:
		turn_indicator.text = "%s is calculating... [Node %d/13]%s" % [player_name, trick_num, urgency_text]
		turn_indicator.add_theme_color_override("font_color", Color.LIGHT_BLUE)


## Updates the decree display label with dominant aspect information
func update_decree_label() -> void:
	if not game_state.radiant_display_card or not decree_display.is_node_ready():
		return

	# Find the label node in DecreeArea (parent of DecreeDisplay)
	var decree_area = decree_display.get_parent()
	if not decree_area:
		return

	# Look for existing label to update
	for child in decree_area.get_children():
		if child is Label and child.text.contains("Prime Radiant"):
			var aspect_name = game_state.radiant_display_card.get_aspect_name()
			child.text = "Prime Radiant Decree\n[%s Trump]" % aspect_name
			child.add_theme_font_size_override("font_size", 16)
			break


## Updates visual indicators in the trick area showing cards that have been played
func update_trick_area_display() -> void:
	if trick_area.is_node_ready():
		# Cards are displayed via play_card_to_trick() - this function
		# is called to ensure visual state is consistent
		# Add visual feedback for which player played which card
		if player1_trick_card:
			player1_trick_card.modulate = Color.WHITE

		if player2_trick_card:
			player2_trick_card.modulate = Color.WHITE


## Updates which cards in the local player's hand can be played
func update_hand_playability() -> void:
	var player_id := game_state.local_player_id
	var hand_cards := player1_hand_cards if player_id == 1 else player2_hand_cards
	var is_players_turn := game_state.is_local_players_turn()

	for card in hand_cards:
		var card_data := card.get_card_data()

		# Cards are selectable only on player's turn
		card.set_selectable(is_players_turn)

		# Check if card is playable based on game rules
		if is_players_turn:
			var playable := can_play_card(card_data, player_id)
			card.set_playable(playable)
		else:
			card.set_playable(false)


## Handles when a player hovers over a card
func _on_player_card_hovered(_card: Card) -> void:
	# Could add tooltip or info display here in future
	pass


## Handles when a player selects a card from their hand
func _on_player_card_selected(card: Card) -> void:
	if not game_state.is_local_players_turn():
		print("Not your turn!")
		return

	var card_data := card.get_card_data()
	var player_id := game_state.local_player_id

	# Validate card can be played
	if not can_play_card(card_data, player_id):
		print("Cannot play that card - must follow lead aspect!")
		return

	print("Player %d selected card: %s %d" % [player_id, card_data.get_aspect_name(), card_data.value])

	# Play the card to the trick area
	play_card_to_trick(card, player_id)


## Validates if a card can be legally played
func can_play_card(card_data: CardData, player_id: int) -> bool:
	# First card of trick can always be played
	if game_state.current_trick.is_empty():
		return true

	# Get player's hand
	var hand := game_state.mentalic1_hand if player_id == 1 else game_state.mentalic2_hand

	# Must follow lead aspect if possible
	var has_lead_aspect := DeckGenerator.count_aspect_in_hand(hand, game_state.lead_aspect) > 0

	if has_lead_aspect:
		# Player has cards of lead aspect, must play one
		return card_data.aspect == game_state.lead_aspect
	else:
		# Player doesn't have lead aspect, can play anything
		return true


## Plays a card to the trick area
func play_card_to_trick(card: Card, player_id: int) -> void:
	var card_data := card.get_card_data()

	# Add to game state
	game_state.play_card_to_trick(card_data, player_id)

	# Remove from hand display
	if player_id == 1:
		player1_hand_cards.erase(card)
	else:
		player2_hand_cards.erase(card)

	# Store original position for animation
	var start_pos := card.global_position

	# Move card to trick area (visual)
	card.reparent(trick_area)

	# Set starting position (maintain visual continuity)
	card.global_position = start_pos

	# Determine target position in trick area
	var target_position: Vector2
	if player_id == 1:
		player1_trick_card = card
		target_position = Vector2(100, 0)
	else:
		player2_trick_card = card
		target_position = Vector2(300, 0)

	# Animate card to trick area
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel(true)
	tween.tween_property(card, "position", target_position, 0.4)
	tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.4)
	tween.set_parallel(false)

	# Ensure card is face-up when played
	card.set_face_up(true)

	# Update trick area visuals
	update_trick_area_display()

	print("Player %d played %s %d to trick" % [
		player_id,
		card_data.get_aspect_name(),
		card_data.value
	])

	# Check if trick is complete
	if game_state.current_trick.size() == 2:
		# Both players have played - resolve trick
		resolve_trick()
	else:
		# Switch turns
		game_state.active_mentalic = 3 - game_state.active_mentalic
		update_turn_indicator()
		update_hand_playability()

		# If it's now AI opponent's turn, have them play after short delay
		if not game_state.is_local_players_turn():
			await get_tree().create_timer(1.0).timeout
			ai_play_card()


## Resolves the current trick and determines winner
func resolve_trick() -> void:
	if game_state.current_trick.size() != 2:
		return

	var card1 := game_state.current_trick[0]
	var card2 := game_state.current_trick[1]

	var winner_id := determine_trick_winner(card1, card2)

	print("Trick %d resolved - Winner: Player %d" % [game_state.trick_number, winner_id])

	# Award trick to winner
	if winner_id == 1:
		game_state.mentalic1_tricks += 1
	else:
		game_state.mentalic2_tricks += 1

	# TODO: Handle special abilities (7s, etc.)
	# TODO: Update round score

	update_score_display()

	# Clear trick area after delay
	await get_tree().create_timer(2.0).timeout
	clear_trick_area()

	# Start next trick with winner leading
	game_state.active_mentalic = winner_id
	game_state.clear_trick()
	update_turn_indicator()
	update_hand_playability()

	# Check if round is over
	if game_state.is_round_complete():
		end_round()
	else:
		# If it's AI turn, have them play
		if not game_state.is_local_players_turn():
			await get_tree().create_timer(1.0).timeout
			ai_play_card()


## Determines which player won the trick
func determine_trick_winner(card1: CardData, card2: CardData) -> int:
	# If aspects are the same, higher value wins
	if card1.aspect == card2.aspect:
		return 1 if card1.value > card2.value else 2

	# If first card is lead aspect, it wins (second card didn't follow)
	if card1.aspect == game_state.lead_aspect:
		return 1

	# If second card is lead aspect, it wins
	if card2.aspect == game_state.lead_aspect:
		return 2

	# If first card is dominant aspect (trump), it wins
	if card1.aspect == game_state.dominant_aspect:
		return 1

	# If second card is dominant aspect (trump), it wins
	if card2.aspect == game_state.dominant_aspect:
		return 2

	# Neither followed suit or played trump - first player wins by default
	return 1


## Clears the trick area
func clear_trick_area() -> void:
	if player1_trick_card:
		player1_trick_card.queue_free()
		player1_trick_card = null

	if player2_trick_card:
		player2_trick_card.queue_free()
		player2_trick_card = null


## Ends the current round and calculates scores
func end_round() -> void:
	print("=== Round Complete ===")
	print("Player 1 tricks: %d" % game_state.mentalic1_tricks)
	print("Player 2 tricks: %d" % game_state.mentalic2_tricks)

	# Calculate round scores based on trick count
	game_state.mentalic1_round_score = calculate_round_score(game_state.mentalic1_tricks)
	game_state.mentalic2_round_score = calculate_round_score(game_state.mentalic2_tricks)

	# Add to total scores
	game_state.mentalic1_total_score += game_state.mentalic1_round_score
	game_state.mentalic2_total_score += game_state.mentalic2_round_score

	print("Player 1 score: %d (total: %d)" % [
		game_state.mentalic1_round_score,
		game_state.mentalic1_total_score
	])
	print("Player 2 score: %d (total: %d)" % [
		game_state.mentalic2_round_score,
		game_state.mentalic2_total_score
	])

	# Check for game winner
	var winner := game_state.check_game_winner()
	if winner > 0:
		print("=== GAME OVER - Player %d Wins! ===" % winner)
		# Show game over screen
		game_over_screen.show_game_over(
			winner,
			game_state.mentalic1_total_score,
			game_state.mentalic2_total_score
		)
	else:
		print("=== Starting Next Round ===")
		# Show round summary
		round_summary.show_round_results(
			game_state.mentalic1_tricks,
			game_state.mentalic1_round_score,
			game_state.mentalic1_total_score,
			game_state.mentalic2_tricks,
			game_state.mentalic2_round_score,
			game_state.mentalic2_total_score
		)


## Calculates points based on tricks won
func calculate_round_score(tricks_won: int) -> int:
	match tricks_won:
		0, 1, 2, 3:
			return 6  # Subtle Influence
		4:
			return 1  # Detected Pressure
		5:
			return 2  # Obvious Manipulation
		6:
			return 3  # Contested Control
		7, 8, 9:
			return 6  # Calculated Dominance
		_:
			return 0  # Exposed Operation (10-13 tricks)


## AI logic for antagonist's card play
func ai_play_card() -> void:
	var ai_player_id := 3 - game_state.local_player_id
	var ai_hand := game_state.mentalic2_hand if ai_player_id == 2 else game_state.mentalic1_hand

	if ai_hand.is_empty():
		print("AI has no cards to play!")
		return

	# Get AI's current trick count
	var ai_tricks := game_state.mentalic2_tricks if ai_player_id == 2 else game_state.mentalic1_tricks
	var protagonist_tricks := game_state.mentalic1_tricks if ai_player_id == 2 else game_state.mentalic2_tricks

	# Use AI strategy to choose best card
	var card_to_play: CardData = ai_strategy.choose_card_to_play(
		ai_hand,
		game_state,
		ai_tricks,
		protagonist_tricks
	)

	if not card_to_play:
		print("AI strategy failed to choose a card! Falling back to first card.")
		card_to_play = ai_hand[0]

	print("AI (Player %d) [%s] choosing to play %s %d (strategy: %s)" % [
		ai_player_id,
		_get_difficulty_name(),
		card_to_play.get_aspect_name(),
		card_to_play.value,
		ai_strategy.current_target_strategy
	])

	# Find the card instance in the UI
	var ai_hand_cards := player2_hand_cards if ai_player_id == 2 else player1_hand_cards
	for card_instance in ai_hand_cards:
		if card_instance.get_card_data() == card_to_play:
			play_card_to_trick(card_instance, ai_player_id)
			break
