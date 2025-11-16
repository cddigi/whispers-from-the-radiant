extends ColorRect

## Game over screen showing final winner and scores

signal new_game_pressed
signal main_menu_pressed

@onready var title := %Title as Label
@onready var winner_label := %WinnerLabel as Label
@onready var score_label := %ScoreLabel as Label
@onready var new_game_button := %NewGameButton as Button
@onready var main_menu_button := %MainMenuButton as Button


func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	hide()


## Show game over screen with winner information
func show_game_over(winner_id: int, p1_score: int, p2_score: int) -> void:
	if winner_id == 1:
		winner_label.text = "Protagonist Prevails!"
		winner_label.add_theme_color_override("font_color", Color.CYAN)
	else:
		winner_label.text = "Antagonist Triumphs!"
		winner_label.add_theme_color_override("font_color", Color.ORANGE_RED)

	score_label.text = "Final Score: %d - %d" % [p1_score, p2_score]

	show()


func _on_new_game_pressed() -> void:
	hide()
	new_game_pressed.emit()


func _on_main_menu_pressed() -> void:
	hide()
	main_menu_pressed.emit()
