class_name DeckGenerator
extends Object

## Utility class for generating and managing the Seldon Plan card deck.
## Creates exactly 33 cards: 11 Mental, 11 Physical, 11 Temporal.
## Provides shuffling and dealing functionality.


## Generates a complete deck of 33 cards
static func generate_full_deck() -> Array[CardData]:
	var deck: Array[CardData] = []

	# Create 11 cards for each of the 3 aspects
	for aspect: int in CardData.Aspect.values():
		for value: int in range(1, 12):  # 1 through 11
			var card := CardData.new(value, aspect)
			deck.append(card)

	return deck


## Shuffles a deck using Fisher-Yates algorithm
static func shuffle_deck(deck: Array[CardData]) -> void:
	var n := deck.size()
	for i: int in range(n - 1, 0, -1):
		var j := randi() % (i + 1)
		var temp := deck[i]
		deck[i] = deck[j]
		deck[j] = temp


## Deals cards from deck to two players
## Returns dictionary with "player1", "player2", and "decree" (remaining card)
static func deal_cards(deck: Array[CardData]) -> Dictionary:
	if deck.size() != 33:
		push_error("Deck must contain exactly 33 cards to deal")
		return {}

	var player1_hand: Array[CardData] = []
	var player2_hand: Array[CardData] = []

	# Deal 13 cards to each player alternately
	for i: int in range(26):
		if i % 2 == 0:
			player1_hand.append(deck[i])
		else:
			player2_hand.append(deck[i])

	# Last card becomes the Prime Radiant decree (face-up trump indicator)
	var decree_card := deck[26]

	return {
		"player1": player1_hand,
		"player2": player2_hand,
		"decree": decree_card
	}


## Sorts a hand by aspect and value for display
static func sort_hand(hand: Array[CardData]) -> void:
	hand.sort_custom(func(a: CardData, b: CardData) -> bool:
		if a.aspect != b.aspect:
			return a.aspect < b.aspect
		return a.value < b.value
	)


## Counts cards of a specific aspect in a hand
static func count_aspect_in_hand(hand: Array[CardData], aspect: CardData.Aspect) -> int:
	var count := 0
	for card: CardData in hand:
		if card.aspect == aspect:
			count += 1
	return count


## Finds all cards of a specific aspect in a hand
static func get_cards_of_aspect(hand: Array[CardData], aspect: CardData.Aspect) -> Array[CardData]:
	var cards: Array[CardData] = []
	for card: CardData in hand:
		if card.aspect == aspect:
			cards.append(card)
	return cards


## Gets the highest value card of a specific aspect from a hand
static func get_highest_of_aspect(hand: Array[CardData], aspect: CardData.Aspect) -> CardData:
	var cards := get_cards_of_aspect(hand, aspect)
	if cards.is_empty():
		return null

	var highest := cards[0]
	for card: CardData in cards:
		if card.value > highest.value:
			highest = card

	return highest


## Gets the card with value 1 from a hand (for Speaker's Command ability)
static func get_card_with_value(hand: Array[CardData], value: int) -> CardData:
	for card: CardData in hand:
		if card.value == value:
			return card
	return null
