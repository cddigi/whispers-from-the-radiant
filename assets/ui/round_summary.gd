extends ColorRect

## Round summary overlay showing tricks won and points scored

signal continue_pressed

@onready var title := %Title as Label
@onready var player1_summary := %Player1Summary as Label
@onready var player2_summary := %Player2Summary as Label
@onready var continue_button := %ContinueButton as Button


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)


## Display round results
func show_round_results(
	p1_tricks: int,
	p1_score: int,
	p1_total: int,
	p2_tricks: int,
	p2_score: int,
	p2_total: int
) -> void:
	player1_summary.text = "Protagonist: %d tricks → %d points (Total: %d)" % [
		p1_tricks, p1_score, p1_total
	]

	player2_summary.text = "Antagonist: %d tricks → %d points (Total: %d)" % [
		p2_tricks, p2_score, p2_total
	]

	show()


func _on_continue_pressed() -> void:
	hide()
	continue_pressed.emit()
