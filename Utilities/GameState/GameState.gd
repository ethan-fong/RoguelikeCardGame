extends Node
class_name GameState

# ---------------- STATE ----------------
@export var stage: int = 1
@export var boss_list: Array[Artifact] = []         # Boss/run modifiers added individually

func next_stage() -> void:
    stage = stage + 1

func check_current_stage() -> int:
    return stage
