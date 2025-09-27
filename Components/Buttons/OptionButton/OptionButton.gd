# ChoiceButton.gd
extends Control

signal choice_made(choice: ChoiceOption)

@export var click_sound: AudioStream

@onready var button: TextureButton = $Button
@onready var label: Label = $Button/Label
@onready var reward_label: Label = $Button/RewardLabel
@onready var audio_player: AudioStreamPlayer = $Button/ClickSound

var choice_option: ChoiceOption

func _ready() -> void:
    if click_sound:
        audio_player.stream = click_sound
    button.pressed.connect(_on_pressed)

func set_choice_option(option: ChoiceOption) -> void:
    choice_option = option
    if label:
        label.text = option.text
    if reward_label:
        reward_label.text = option.reward_description

func _on_pressed() -> void:
    if audio_player.stream:
        audio_player.play()
    if choice_option:
        emit_signal("choice_made", choice_option)
