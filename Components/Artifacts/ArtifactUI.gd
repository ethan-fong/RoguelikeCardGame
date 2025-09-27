extends Control
class_name ArtifactUI

@export var artifact_data: Artifact

@onready var button: TextureButton = $%ArtifactIcon
@onready var detail_popup: Control = $ArtifactDetailPopup

func _ready() -> void:
    # Setup button
    button.texture_normal = artifact_data.icon if artifact_data.icon else null
    button.pressed.connect(_on_pressed)

    # Initialize popup
    if detail_popup.has_method("init"):
        detail_popup.init(artifact_data)
    detail_popup.visible = false

func _on_pressed() -> void:
    detail_popup.visible = not detail_popup.visible

func set_texture(texture: Texture2D) -> void:
    button.texture_normal = texture
