extends Node

# ---------------- DEPENDENCIES ----------------
@onready var deck_manager: Control = $%DeckManager
@onready var deck_stack: Control = $%DeckStack

# ---------------- GAME DATA ----------------
var ruleset: RuleSet                     # active ruleset for this round
var current_stage_index: int = 0         # index in ruleset.effective_stage_order
var revealed_cards: Array[CardData] = [] # history of cards dealt

# ---------------- SIGNALS ----------------
signal options_updated(options: Array[ChoiceOption])
signal game_over(is_win: bool)
signal animations_started
signal animations_finished
signal reveals_updated(reveals_left: int)

# ---------------- PRELOAD ----------------
var RuleSetClass = preload("res://Components/RuleSet/RuleSet.gd")

# ---------------- INITIALIZATION ----------------
func _ready():
    for c in PlayerInventory.consumables:
        if not c.used.is_connected(_on_consumable_used):
            c.used.connect(_on_consumable_used)

func _exit_tree():
    for c in PlayerInventory.consumables:
        if c.used.is_connected(_on_consumable_used):
            c.used.disconnect(_on_consumable_used)

func start_new_round() -> void:
    ruleset = RuleSetClass.new()
    ruleset.init_base_rules()
    ruleset.apply_strategies(PlayerInventory.get_all_strategies())
    current_stage_index = 0
    revealed_cards.clear()
    _update_buttons()
    deck_manager.init_deck(ruleset.effective_deck)
    emit_signal("reveals_updated", ruleset.effective_cards_to_reveal - revealed_cards.size())

# ---------------- SUBMIT CHOICE ----------------
func submit_choice(choice: ChoiceOption) -> void:
    var stage = ruleset.effective_stage_order[current_stage_index]

    # If the top card is being shown, hide it after dealing.
    if deck_stack.peek_count > 0:
        deck_stack.peek_count -= 1

    var new_card: CardData = deck_manager.deal_card()
    if new_card == null:
        emit_signal("game_over", false)
        current_stage_index = -1
        _update_buttons()
        return
        
    var result_success = stage.evaluate_choice(choice, revealed_cards, new_card, ruleset)

    revealed_cards.append(new_card)
    emit_signal("reveals_updated", ruleset.effective_cards_to_reveal - revealed_cards.size())

    if result_success:
        # Grant the specific reward for the choice
        if choice.reward_callable:
            choice.reward_callable.call()

        # Check for win condition
        if revealed_cards.size() >= ruleset.effective_cards_to_reveal:
            await deck_manager.hide_last_cards(current_stage_index + 1)
            emit_signal("game_over", true)
            return
        else:
            if current_stage_index == ruleset.effective_stage_order.size() -1:
                current_stage_index = 0
                emit_signal("animations_started")
                await deck_manager.hide_last_cards(ruleset.effective_stage_order.size())
                _update_buttons()
                emit_signal("animations_finished")
            else:
                current_stage_index += 1
                _update_buttons()
    else:
        # Incorrect guess, reset to first stage
        var cards_to_clear = current_stage_index + 1
        current_stage_index = 0
        emit_signal("animations_started")
        await deck_manager.hide_last_cards(cards_to_clear)
        _update_buttons()
        emit_signal("animations_finished")
        
# ---------------- BUTTON OPTIONS ----------------
func _update_buttons() -> void:
    if current_stage_index < 0 or not ruleset or current_stage_index >= ruleset.effective_stage_order.size():
        emit_signal("options_updated", [] as Array[ChoiceOption])
        return
    var stage = ruleset.effective_stage_order[current_stage_index]
    emit_signal("options_updated", stage.get_options())

# ---------------- CONSUMABLES ----------------
func _on_consumable_used(c: Consumable) -> void:
    match c.name:
        "Peek Top Card":
            deck_stack.peek_count = 1
        "Double Money":
            PlayerInventory.set_coins(PlayerInventory.check_current_coins() * 2)
        "Ten Coins":
            PlayerInventory.set_coins(PlayerInventory.check_current_coins() + 10)
        "Peek Top Three Cards":
            deck_stack.peek_count = 3
        "Eighty Coins":
            PlayerInventory.set_coins(PlayerInventory.check_current_coins() + 80)
