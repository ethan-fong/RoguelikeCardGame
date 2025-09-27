extends Control
class_name Card

# ---------------- CONFIG ----------------
@export var card_scale: float = 1.0
@export var hover_scale: float = 1.05  # bounce multiplier
@export var hover_duration: float = 0.15

# ---------------- NODES ----------------
@onready var front: TextureRect = $Sprite/Front
@onready var back: TextureRect = $Sprite/Back
@onready var flip_up_sound: AudioStreamPlayer = $SFX/FlipUpSound
@onready var flip_down_sound: AudioStreamPlayer = $SFX/FlipDownSound

# ---------------- CARD DATA ----------------
var card_data: CardData:
    set(value):
        card_data = value
        if card_data and is_inside_tree():
            _apply_card_texture()

# ---------------- STATE ----------------
var is_face_up := false:
    set(value):
        is_face_up = value
        if not is_node_ready():
            return
        front.visible = is_face_up
        back.visible = not is_face_up

# ---------------- READY ----------------
func _ready() -> void:
    if card_data:
        _apply_card_texture()

    if front.texture:
        front.custom_minimum_size = front.texture.get_size() * card_scale
    if back.texture:
        back.custom_minimum_size = back.texture.get_size() * card_scale

    self.is_face_up = false # Set initial state through the setter
    pivot_offset = size / 2

    # connect hover signals
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

# ---------------- API ----------------
func flip() -> Tween:
    if not is_face_up and flip_up_sound.stream:
        flip_up_sound.play()
    elif is_face_up and flip_down_sound.stream:
        flip_down_sound.play()

    var tween = create_tween()
    tween.tween_property(self, "scale:x", 0.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
    tween.tween_callback(Callable(self, "_toggle_face"))
    tween.tween_property(self, "scale:x", 1.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
    return tween

# ---------------- INTERNAL ----------------
func _on_mouse_entered() -> void:
    var tween = create_tween()
    tween.tween_property(self, "scale", Vector2.ONE * hover_scale, hover_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
    var tween = create_tween()
    tween.tween_property(self, "scale", Vector2.ONE, hover_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _apply_card_texture() -> void:
    match card_data.card_type:
        "normal": _update_normal_card_texture()
        "joker": _update_joker_texture()
        "special": _update_special_card_texture()
        _: _update_placeholder_texture()

    if front.texture:
        custom_minimum_size = front.custom_minimum_size

func _update_normal_card_texture() -> void:
    var path = "res://Components/Card/Art/%d_%s.png" % [card_data.rank, card_data.suit]
    front.texture = load(path)
    back.texture = load("res://Components/Card/Art/red_backing.png")
    front.custom_minimum_size = front.texture.get_size() * card_scale
    back.custom_minimum_size = back.texture.get_size() * card_scale

func _update_joker_texture() -> void:
    front.texture = load("res://Components/Card/Art/joker.png")
    back.texture = load("res://Components/Card/Art/red_backing.png")
    front.custom_minimum_size = front.texture.get_size() * card_scale
    back.custom_minimum_size = back.texture.get_size() * card_scale

func _update_special_card_texture() -> void:
    front.texture = load("res://Components/Card/Art/red_backing.png")
    back.texture = load("res://Components/Card/Art/red_backing.png")
    front.custom_minimum_size = front.texture.get_size() * card_scale
    back.custom_minimum_size = back.texture.get_size() * card_scale

func _update_placeholder_texture() -> void:
    front.texture = load("res://Components/Card/Art/grey_backing.png")
    back.texture = load("res://Components/Card/Art/grey_backing.png")
    front.custom_minimum_size = front.texture.get_size() * card_scale
    back.custom_minimum_size = back.texture.get_size() * card_scale

func _toggle_face() -> void:
    self.is_face_up = not is_face_up
