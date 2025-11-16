extends Control

## Main menu for Whispers from the Radiant.
## Provides options to start a new calculation, view instructions, or exit.

## Scenes to load
const INTRO_SCENE := "res://assets/intro/intro_animation.tscn"

## UI nodes
@onready var start_button: Button = $MenuPanel/VBoxContainer/StartButton
@onready var instructions_button: Button = $MenuPanel/VBoxContainer/InstructionsButton
@onready var quit_button: Button = $MenuPanel/VBoxContainer/QuitButton
@onready var instructions_panel: Panel = $InstructionsPanel
@onready var close_instructions_button: Button = $InstructionsPanel/MarginContainer/VBoxContainer/CloseButton


func _ready() -> void:
	print("=== Whispers from the Radiant - Main Menu ===")

	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	instructions_button.pressed.connect(_on_instructions_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	close_instructions_button.pressed.connect(_on_close_instructions_pressed)

	# Hide instructions panel initially
	instructions_panel.visible = false

	# Focus the start button
	start_button.grab_focus()


func _on_start_pressed() -> void:
	print("Starting new calculation...")
	# Play intro animation first, which then loads the game
	get_tree().change_scene_to_file(INTRO_SCENE)


func _on_instructions_pressed() -> void:
	print("Showing instructions...")
	instructions_panel.visible = true
	close_instructions_button.grab_focus()


func _on_close_instructions_pressed() -> void:
	instructions_panel.visible = false
	instructions_button.grab_focus()


func _on_quit_pressed() -> void:
	print("Exiting to consensus reality...")
	get_tree().quit()
