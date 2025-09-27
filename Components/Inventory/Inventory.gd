extends Node
class_name Inventory

# ---------------- SIGNALS ----------------
signal coins_changed(new_amount: int)
signal consumable_added(_c)
signal consumable_removed(_c)

# ---------------- STATE ----------------
@export var coins: int = 0
@export var artifacts: Array[Artifact] = []         # Player-owned artifacts
@export var boss_modifiers: Array[Artifact] = []    # Boss/run modifiers added individually
@export var persistent_deck: Array[CardData] = []   # Player's starting deck, persistent across runs
@export var consumables: Array[Consumable] = []

const ConsumableDatabase = preload("res://Components/Consumables/Data/ConsumableDatabase.gd")
var consumable_db

# ---------------- INITIALIZATION ----------------
func _ready() -> void:
    consumable_db = ConsumableDatabase.new()
    # Initialize the persistent deck if empty
    if persistent_deck.is_empty():
        _init_base_deck()
    
    # Add starting consumables
    _init_starting_consumables()

func _init_starting_consumables():
    # Add "Peek Top Card"
    for c in consumable_db.consumables:
        if c.name == "Peek Top Card":
            add_consumable(c)
            break   
    var common_consumables = []
    for c in consumable_db.consumables:
        if c.rarity == 1:
            common_consumables.append(c)

    if common_consumables.is_empty():
        return

    for i in range(2):
        add_consumable(common_consumables.pick_random())

# ---------------- DECK API ----------------
func _init_base_deck() -> void:
    persistent_deck.clear()
    for suit in ["hearts", "diamonds", "clubs", "spades"]:
        for rank in range(1, 14):
            persistent_deck.append(CardData.new(rank, suit))

func get_persistent_deck() -> Array:
    return persistent_deck.duplicate()

func remove_card(card: CardData) -> void:
    for i in range(persistent_deck.size()):
        var c = persistent_deck[i]
        if c.rank == card.rank and c.suit == card.suit:
            persistent_deck.remove_at(i)
            return

func add_card(card: CardData) -> void:
    persistent_deck.append(CardData.new(card.rank, card.suit))

# ---------------- COINS API ----------------
func set_coins(value: int) -> void:
    coins = value
    emit_signal("coins_changed", coins)

func add_coins(amount: int) -> void:
    set_coins(coins + amount)

func subtract_coins(amount: int) -> void:
    set_coins(max(coins - amount, 0))

func check_can_afford(amount: int) -> bool:
    return coins >= amount

func check_current_coins() -> int:
    return coins

func reset_coins() -> void:
    set_coins(0)

# ---------------- ARTIFACT API ----------------
func add_artifact(artifact: Artifact) -> void:
    artifacts.append(artifact)

func remove_artifact(artifact: Artifact) -> void:
    artifacts.erase(artifact)

func add_boss_modifier(artifact: Artifact) -> void:
    boss_modifiers.append(artifact)

func remove_boss_modifier(artifact: Artifact) -> void:
    boss_modifiers.erase(artifact)

func get_all_strategies() -> Array[Artifact]:
    return artifacts + boss_modifiers

func clear_inventory() -> void:
    artifacts.clear()
    boss_modifiers.clear()
    reset_coins()
    _init_base_deck()

# ---------------- CONSUMABLE API ----------------
func add_consumable(c: Consumable) -> void:
    consumables.append(c)
    consumable_added.emit(c)

func remove_consumable(c: Consumable) -> void:
    consumables.erase(c)
    consumable_removed.emit(c)

func use_consumable(c: Consumable) -> void:
    if c in consumables:
        c.use()
        remove_consumable(c)
