# ArtifactsDatabase.gd
extends Resource
class_name ArtifactsDatabase

# ---------------- ARRAYS ----------------
var user_artifacts: Array[Artifact] = []
var boss_artifacts: Array[Artifact] = []

# ---------------- INITIALIZATION ----------------
func _init():
    # ---------------- User Artifacts ----------------
    var double_cards := Artifact.new()
    double_cards.name = "Double Cards"
    double_cards.description = "Doubles amount of cards you can reveal per round."
    double_cards.modify_ruleset_func = Callable(ArtifactsDatabase, "_double_cards")
    double_cards.icon = preload("res://Components/Card/Art/1_clubs.png")
    double_cards.rarity = 1
    user_artifacts.append(double_cards)

    var extra_cards := Artifact.new()
    extra_cards.name = "Extra Cards"
    extra_cards.description = "Increases max cards by 10."
    extra_cards.modify_ruleset_func = Callable(ArtifactsDatabase, "_extra_cards")
    extra_cards.icon = preload("res://Components/Card/Art/1_spades.png")
    extra_cards.rarity = 1
    user_artifacts.append(extra_cards)

    # ---------------- Boss Artifacts ----------------
    var tougher_guesses := Artifact.new()
    tougher_guesses.name = "Tougher Guesses"
    tougher_guesses.description = "Reduces max coin guesses by 2."
    tougher_guesses.modify_ruleset_func = Callable(ArtifactsDatabase, "_reduce_max_guess")
    boss_artifacts.append(tougher_guesses)

    var halve_deck := Artifact.new()
    halve_deck.name = "Halve Deck"
    halve_deck.description = "Reduces deck size"
    halve_deck.modify_ruleset_func = Callable(ArtifactsDatabase, "_halve_deck")
    boss_artifacts.append(halve_deck)

# ---------------- STRATEGY LOGIC ----------------
static func _double_cards(ruleset: RuleSet) -> void:
    ruleset.effective_cards_to_reveal *= 2

static func _extra_cards(ruleset: RuleSet) -> void:
    ruleset.effective_cards_to_reveal += 10

static func _reduce_max_guess(ruleset: RuleSet) -> void:
    ruleset.effective_max_coin_guesses = max(1, ruleset.effective_max_coin_guesses - 2)

static func _halve_deck(ruleset: RuleSet) -> void:
    ruleset.deck = []
