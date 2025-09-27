extends Control

#---------------- EXPORTS ----------------
@export var main_game_scene: PackedScene

#---------------- NODES ----------------
@onready var artifacts_container: HBoxContainer = %ArtifactsContainer
@onready var consumables_container: HBoxContainer = %ConsumablesContainer
@onready var player_consumables_container: VBoxContainer = %PlayerConsumablesContainer
@onready var combine_slot_1: TextureButton = %CombineSlot1
@onready var combine_slot_2: TextureButton = %CombineSlot2
@onready var combine_button: Button = %CombineButton
@onready var back_button: Button = %BackButton
@onready var player_coins_label: Label = %PlayerCoinsLabel

#---------------- PRELOADS ----------------
const ArtifactDatabase = preload("res://scripts/databases/ArtifactDatabase.gd")
const ConsumableDatabase = preload("res://scripts/databases/ConsumableDatabase.gd")
const ShopItemCard = preload("res://scenes/components/shop_item_card.tscn")

#---------------- STATE ----------------
var artifact_db
var consumable_db
var combine_consumable_1: Consumable = null
var combine_consumable_2: Consumable = null

#---------------- INITIALIZATION ----------------
func _ready() -> void:
    artifact_db = ArtifactDatabase.new()
    consumable_db = ConsumableDatabase.new()

    # Connect signals
    back_button.pressed.connect(_on_back_button_pressed)
    combine_button.pressed.connect(_on_combine_button_pressed)
    PlayerInventory.coins_changed.connect(_update_player_coins)

    # Initial UI setup
    _update_player_coins(PlayerInventory.check_current_coins())
    generate_shop_items()
    populate_player_consumables()

#---------------- SHOP GENERATION ----------------
func generate_shop_items() -> void:
    # Clear previous items
    for child in artifacts_container.get_children():
        child.queue_free()
    for child in consumables_container.get_children():
        child.queue_free()

    # Generate 3 random artifacts
    var available_artifacts = artifact_db.user_artifacts.duplicate()
    available_artifacts.shuffle()
    for i in range(min(3, available_artifacts.size())):
        var artifact = available_artifacts[i]
        var price = 20 * artifact.rarity # Example pricing
        _create_shop_item_card(artifacts_container, artifact, price)

    # Generate 3 random consumables
    var available_consumables = consumable_db.consumables.duplicate()
    available_consumables.shuffle()
    for i in range(min(3, available_consumables.size())):
        var consumable = available_consumables[i]
        var price = 10 * consumable.rarity # Example pricing
        _create_shop_item_card(consumables_container, consumable, price)

func _create_shop_item_card(container: HBoxContainer, item, price: int) -> void:
    var card = ShopItemCard.instantiate()
    # Add the card to the scene tree FIRST to ensure its @onready vars are initialized.
    container.add_child(card) 
    # Now it's safe to call update_card.
    card.update_card(item, price)
    card.purchase_pressed.connect(_on_purchase_pressed)

#---------------- PLAYER CONSUMABLE DISPLAY ----------------
func populate_player_consumables() -> void:
    for child in player_consumables_container.get_children():
        child.queue_free()
    
    for consumable in PlayerInventory.consumables:
        var btn = TextureButton.new()
        btn.texture_normal = consumable.icon
        btn.custom_minimum_size = Vector2(64, 64)
        btn.gui_input.connect(Callable(self, "_on_player_consumable_gui_input").bind(btn, consumable))
        player_consumables_container.add_child(btn)

func _on_player_consumable_gui_input(event: InputEvent, button: TextureButton, consumable: Consumable) -> void:
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        var preview = TextureRect.new()
        preview.texture = button.texture_normal
        preview.size = button.size
        set_drag_preview(preview)
        # The data sent with the drag operation is the consumable itself
        get_viewport().set_drag_data(consumable)

#---------------- DROP HANDLING ----------------
func _can_drop_data(_pos, data) -> bool:
    return data is Consumable

func _drop_data(pos, data) -> void:
    # Check if the drop position is within the bounds of combine_slot_1
    if combine_slot_1.get_global_rect().has_point(get_global_mouse_position()):
        _handle_consumable_drop(data, 1)
    # Check if the drop position is within the bounds of combine_slot_2
    elif combine_slot_2.get_global_rect().has_point(get_global_mouse_position()):
        _handle_consumable_drop(data, 2)

func _handle_consumable_drop(consumable: Consumable, slot_index: int) -> void:
    if slot_index == 1:
        combine_consumable_1 = consumable
        combine_slot_1.texture_normal = consumable.icon
    elif slot_index == 2:
        combine_consumable_2 = consumable
        combine_slot_2.texture_normal = consumable.icon
    
    combine_button.disabled = not (combine_consumable_1 and combine_consumable_2)

#---------------- ACTIONS & HANDLERS ----------------
func _on_purchase_pressed(item, price: int) -> void:
    if PlayerInventory.check_can_afford(price):
        PlayerInventory.subtract_coins(price)
        if item is Artifact:
            PlayerInventory.add_artifact(item)
        elif item is Consumable:
            PlayerInventory.add_consumable(item)
        
        # Refresh shop to remove purchased item (optional)
        generate_shop_items()
        populate_player_consumables()
    else:
        print("Not enough coins!")

func _on_player_consumable_selected(consumable: Consumable) -> void:
    if combine_consumable_1 == null:
        combine_consumable_1 = consumable
        combine_slot_1.texture_normal = consumable.icon
    elif combine_consumable_2 == null and consumable != combine_consumable_1:
        combine_consumable_2 = consumable
        combine_slot_2.texture_normal = consumable.icon
    
    # Enable combine button when both slots are filled
    combine_button.disabled = not (combine_consumable_1 and combine_consumable_2)

func _on_combine_button_pressed() -> void:
    if not (combine_consumable_1 and combine_consumable_2):
        return

    # 1. Remove combined consumables from inventory
    PlayerInventory.remove_consumable(combine_consumable_1)
    PlayerInventory.remove_consumable(combine_consumable_2)

    # 2. Calculate new rarity
    var new_rarity = combine_consumable_1.rarity + combine_consumable_2.rarity

    # 3. Find a consumable with the new rarity
    var potential_new_consumables = []
    for c in consumable_db.consumables:
        if c.rarity == new_rarity:
            potential_new_consumables.append(c)

    if not potential_new_consumables.is_empty():
        potential_new_consumables.shuffle()
        var new_consumable = potential_new_consumables[0]
        PlayerInventory.add_consumable(new_consumable)

    # 4. Reset state and UI
    combine_consumable_1 = null
    combine_consumable_2 = null
    combine_slot_1.texture_normal = null
    combine_slot_2.texture_normal = null
    combine_button.disabled = true
    populate_player_consumables()

func _on_back_button_pressed() -> void:
    if main_game_scene:
        get_tree().change_scene_to_packed(main_game_scene)
    else:
        print("Main game scene not set!")

func _update_player_coins(new_amount: int) -> void:
    player_coins_label.text = "Coins: " + str(new_amount)
