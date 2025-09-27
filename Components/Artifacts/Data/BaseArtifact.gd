# Artifact.gd
extends Resource
class_name Artifact

var name: String
var description: String
var icon: Texture2D
var rarity: int

# Strategy logic directly inside artifact
var modify_ruleset_func: Callable

func apply_to_ruleset(ruleset: RuleSet) -> void:
    if modify_ruleset_func:
        modify_ruleset_func.call(ruleset)
