# consumable.gd
extends Resource

class_name Consumable

@export var name: String
@export var description: String
@export var icon: Texture2D
@export var rarity: int

signal used(consumable: Consumable)

func use() -> void:
    emit_signal("used", self)
