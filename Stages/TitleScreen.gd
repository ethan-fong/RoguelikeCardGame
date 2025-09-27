extends Control

@onready var play_button = $%PlayButton
@onready var main_game_scene_path = "res://Stages/CardGame/CardGame.tscn"

func _ready():
    play_button.pressed.connect(_on_start)

func _on_start():
    if ResourceLoader.exists(main_game_scene_path):
        get_tree().change_scene_to_file(main_game_scene_path)
