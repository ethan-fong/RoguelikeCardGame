extends Node

# ---------------- CONFIG ----------------
@export var card_scene: PackedScene = preload("res://Components/Card/Card.tscn") # your Card scene
@onready var card_line: HBoxContainer = $%CardLine
@onready var scroll_container: ScrollContainer = $%InPlay
@onready var deck_stack: Node = $%DeckStack

# ---------------- DECK DATA ----------------
var deck: Array = []           # Array of CardData instances
var deck_indices: Array[int] = []

# ---------------- SIGNALS ----------------
signal hide_animation_finished

# ---------------- INITIALIZATION ----------------
func init_deck(prebuilt_deck: Array) -> void:
    assert(prebuilt_deck != null, "DeckManager.init_deck requires a prebuilt deck!")
    deck = prebuilt_deck.duplicate()
    shuffle_deck()
    deck_stack.update_stack(deck_indices.size(), deck[deck_indices[-1]])

# ---------------- SHUFFLE ----------------
func shuffle_deck() -> void:
    deck_indices.clear()
    for i in range(deck.size()):
        deck_indices.append(i)
    deck_indices.shuffle()

# ---------------- DEAL CARD ----------------
func deal_card() -> CardData:
    if deck_indices.is_empty():
        return null
    var idx = deck_indices.pop_back()
    var card_data = deck[idx]        
    _show_card(card_data)
    if len(deck_indices) > 1:
        deck_stack.update_stack(deck_indices.size(), deck[deck_indices[-1]])
    else:
        deck_stack.update_stack(deck_indices.size())
    return card_data

# ---------------- CHECK IF EMPTY ----------------
func is_empty() -> bool:
    return deck_indices.is_empty()

# ---------------- SHOW CARD ----------------
func _show_card(card_data: CardData) -> void:
    var card = card_scene.instantiate()
    card.card_data = card_data
    card_line.add_child(card)
    # Snap scroll to right after layout
    await get_tree().process_frame
    if scroll_container.get_h_scroll_bar():
        scroll_container.scroll_horizontal = roundi(scroll_container.get_h_scroll_bar().max_value)
    # Flip animation
    await card.flip().finished

func hide_last_cards(count: int) -> Signal:
    _animate_and_hide(count)
    return hide_animation_finished

func _animate_and_hide(count: int) -> void:
    var all_cards = card_line.get_children()
    if all_cards.is_empty() or count <= 0:
        emit_signal("hide_animation_finished")
        return

    var start_index = max(0, all_cards.size() - count)
    var cards_to_hide = all_cards.slice(start_index)

    if cards_to_hide.is_empty():
        emit_signal("hide_animation_finished")
        return

    await get_tree().create_timer(0.7).timeout
    
    # ---- PHASE 1: flip each card one-by-one ----
    for card in cards_to_hide:
        if card and card.is_inside_tree():
            await card.flip().finished
            
    # ---- PHASE 2: slide + fade all at once ----
    var base_target = Vector2(-50, 0)
    var offset = Vector2(15, 0)
    var tweens: Array[Tween] = []
    for i in range(cards_to_hide.size()):
        var card = cards_to_hide[i]
        if card and card.is_inside_tree():
            var target = base_target + offset * i
            var tween = create_tween()
            tween.tween_property(card, "position", target, 0.5)
            tween.tween_property(card, "modulate:a", 0.0, 0.5)
            tween.tween_callback(card.queue_free)
            tweens.append(tween)
            
    if tweens.is_empty():
        emit_signal("hide_animation_finished")
        return

    await tweens[-1].finished
    emit_signal("hide_animation_finished")

    emit_signal("hide_animation_finished")
