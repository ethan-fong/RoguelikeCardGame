extends Resource
class_name Stage

@export var name: String = "Unnamed"
@export var options: Array[ChoiceOption] = []  # Options for this stage

# Evaluate the player's choice
# revealed_cards: Array of all CardData dealt so far
# new_card: the newly drawn CardData
# ruleset: the current effective ruleset
func evaluate_choice(
    _choice: ChoiceOption,
    _revealed_cards: Array,
    _new_card: CardData,
    _ruleset: RuleSet
) -> bool:
    # Base class does nothing; override in subclasses
    return false

# Expose options for the UI
func get_options() -> Array[ChoiceOption]:
    return options
