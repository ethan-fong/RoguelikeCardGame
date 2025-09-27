extends Control

# ---------------- CONFIG ----------------
@export var textures: Array[Texture2D] = []  # list of textures from deck-1 to deck-6
@export var max_cards: int = 52              # total number of cards in deck
@export var peek_count: int = 0: set = _set_peek_count

# ---------------- NODES ----------------
@onready var stack_sprite: TextureRect = $%Sprite
@onready var label: Label = $Label
@onready var top_card: Card = $%TopCard
@onready var next_label: Label = %NextLabel
@onready var card_preview: Node2D = $%CardPreview

var stored_top_card: CardData = null

# ---------------- UPDATE FUNCTION ----------------
func update_stack(remaining_cards: int, _top_card: CardData = null) -> void:
    if _top_card == null:
        top_card.visible = false
    else:
        stored_top_card = _top_card
        top_card.card_data = _top_card
    if textures.is_empty():
        return
    if remaining_cards <= 0:
        label.text = "Remaining in deck: 0"
        stack_sprite.texture = null
        return
    var ratio = float(remaining_cards) / max_cards
    var tex_index = clamp(floor((textures.size() - 1) * (1.0 - ratio)), 0, textures.size() - 1)
    stack_sprite.texture = textures[tex_index]
    label.text = "Remaining in deck: %d" % remaining_cards

# ---------------- PROPERTY SETTER ----------------
func _set_peek_count(value: int) -> void:
    peek_count = value
    var should_show = peek_count > 0
    if card_preview:
        card_preview.visible = should_show
    if should_show and stored_top_card:
        top_card.card_data = stored_top_card
        top_card.is_face_up = true
