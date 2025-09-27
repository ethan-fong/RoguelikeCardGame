extends Control

# ---------------- NODES ----------------
@onready var button_manager: Node = $CardGame/ButtonManager
@onready var ride_the_bus: Control = $CardGame/RideTheBus
@onready var shop_scene_path = "res://scenes/Shop.tscn"  # path to your shop scene

func _ready() -> void:
    # Instantiate RideTheBus
    ride_the_bus.connect("options_updated", Callable(self, "_on_options_updated"))
    ride_the_bus.connect("game_over", Callable(self, "_on_game_end"))
    button_manager.connect("choice_made", Callable(self, "_on_choice_made"))
    # Connect animations signals to ButtonManager
    if button_manager and ride_the_bus.has_signal("animations_started"):
        ride_the_bus.connect("animations_started", Callable(button_manager, "_on_animations_started"))
    if button_manager and ride_the_bus.has_signal("animations_finished"):
        ride_the_bus.connect("animations_finished", Callable(button_manager, "_on_animations_finished"))
    ride_the_bus.connect("reveals_updated", Callable($CardGame/CardGameOverlay, "_on_reveals_updated"))

    # Start first round
    ride_the_bus.start_new_round()

# ---------------- BUTTON CALLBACK ----------------
func _on_options_updated(options: Array[ChoiceOption]) -> void:
    button_manager.set_options(options)

func _on_choice_made(choice: ChoiceOption) -> void:
    ride_the_bus.submit_choice(choice)

# ---------------- GAME END ----------------
func _on_game_end(is_win: bool) -> void:
    if is_win:
        print("Player won the game!")
        # Optionally, transition to a victory screen or back to the main menu
        if ResourceLoader.exists(shop_scene_path):
            get_tree().call_deferred("change_scene_to_file", shop_scene_path)
        else:
            push_error("Shop scene not found at: " + shop_scene_path)
    else:
        print("Player lost the game!")
        # Optionally, show a game over screen and offer to restart
        ride_the_bus.start_new_round() # For now, just restart the game
