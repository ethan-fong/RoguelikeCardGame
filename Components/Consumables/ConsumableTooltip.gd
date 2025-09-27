extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel

func update_tooltip(consumable: Consumable):
    name_label.text = consumable.name
    description_label.text = consumable.description

func _process(_delta):
    global_position = get_global_mouse_position() + Vector2(10, 10)
