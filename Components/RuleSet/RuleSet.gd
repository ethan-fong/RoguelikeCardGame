extends Resource
class_name RuleSet

# ---------------- BASE SETTINGS ----------------
@export var cards_to_reveal: int = 10
@export var allow_equal_rank_win: bool = false   # if true, 7==7 counts as win

var deck: Array[CardData] = []           # Base deck for current run
var stage_order: Array[Stage] = []       # Base stages (Stage objects)

# ---------------- ACTIVE SETTINGS ----------------
var effective_cards_to_reveal: int
var effective_allow_equal_rank_win: bool
var effective_stage_order: Array[Stage]
var effective_deck: Array[CardData]

# ---------------- PRELOAD STAGE DATABASE ----------------
var StageDB = preload("res://Components/GuessStages/Data/GuessStageDatabase.gd")

# ---------------- BASE INITIALIZATION ----------------
func init_base_rules():
    # Use the player's persistent deck from Inventory
    if PlayerInventory.persistent_deck.is_empty():
        PlayerInventory._init_base_deck()
    deck = PlayerInventory.get_persistent_deck()
    
    # Create base stages
    stage_order = [
        StageDB.RedBlackStage.new(),
        StageDB.HigherLowerStage.new(),
        StageDB.InsideOutsideStage.new(),
        StageDB.SuitStage.new(),
        StageDB.BusCompletionStage.new()
    ]

# ---------------- APPLY STRATEGIES ----------------
func apply_strategies(strategies: Array) -> void:
    # Reset effective values to base
    effective_cards_to_reveal = cards_to_reveal
    effective_allow_equal_rank_win = allow_equal_rank_win

    # Copy stages and deck
    effective_stage_order = []
    for s in stage_order:
        effective_stage_order.append(s) # Keep Stage objects

    effective_deck = deck.duplicate()

    print("=== Applying Strategies ===")

    for i in range(strategies.size()):
        var strategy = strategies[i]
        if strategy and strategy.has_method("apply_to_ruleset"):
            # Snapshot before applying
            var before_cards_to_reveal = effective_cards_to_reveal
            var before_allow_equal = effective_allow_equal_rank_win
            var before_stage_names: Array = []
            for s in effective_stage_order:
                before_stage_names.append(s.name)

            var before_deck_size = effective_deck.size()

            # Apply the strategy
            strategy.apply_to_ruleset(self)

            # Compare and log only changes
            var changes: Array = []
            if before_cards_to_reveal != effective_cards_to_reveal:
                changes.append("cards_to_win: %d -> %d" % [before_cards_to_reveal, effective_cards_to_reveal])
            if before_allow_equal != effective_allow_equal_rank_win:
                changes.append("allow_equal_rank_win: %s -> %s" % [str(before_allow_equal), str(effective_allow_equal_rank_win)])

            var after_stage_names: Array = []
            for s in effective_stage_order:
                after_stage_names.append(s.name)
            if before_stage_names != after_stage_names:
                changes.append("stage_order: %s -> %s" % [before_stage_names, after_stage_names])

            if before_deck_size != effective_deck.size():
                changes.append("deck_size: %d -> %d" % [before_deck_size, effective_deck.size()])

            if changes.size() > 0:
                print("-> Applied strategy %d: %s" % [i, strategy.name])
                for c in changes:
                    print("   ", c)

    print("=== Finished Applying Strategies ===\n")
