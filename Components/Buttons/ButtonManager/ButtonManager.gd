extends Control

@onready var buttons_container: HBoxContainer = $ButtonsContainer
@export var button_scene: PackedScene

signal choice_made(choice: ChoiceOption)

func _on_animations_started() -> void:
    for btn_node in buttons_container.get_children():
        var btn = btn_node.get_node_or_null("Button")
        if btn:
            btn.disabled = true

func _on_animations_finished() -> void:
    for btn_node in buttons_container.get_children():
        var btn = btn_node.get_node_or_null("Button")
        if btn:
            btn.disabled = false

# ---------------- PUBLIC API ----------------
func set_options(options: Array[ChoiceOption]) -> void:
    # Clear old buttons
    for child in buttons_container.get_children():
        child.queue_free()
    
    if options.is_empty():
        return

    for option_data in options:
        if not button_scene:
            push_error("Button scene not assigned!")
            continue
        
        var btn_node = button_scene.instantiate()
        buttons_container.add_child(btn_node)

        if btn_node.has_method("set_choice_option"):
            btn_node.set_choice_option(option_data)
        else:
            push_error("Instantiated button scene has no set_choice_option() method!")

        btn_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        btn_node.size_flags_vertical = Control.SIZE_EXPAND_FILL

        if btn_node.has_signal("choice_made"):
            btn_node.choice_made.connect(_emit_choice_made)
        else:
            push_error("Instantiated button scene has no 'choice_made' signal!")

func _emit_choice_made(choice: ChoiceOption) -> void:
    emit_signal("choice_made", choice)
