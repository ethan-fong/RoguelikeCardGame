extends Resource
class_name CardData

var rank: int
var suit: String
var card_type: String
var color: String

func _init(_rank: int, _suit: String, _card_type: String = "normal") -> void:
    rank = _rank
    suit = _suit
    card_type = _card_type
    color = determine_color(_suit)

func determine_color(suit_str: String) -> String:
    match suit_str.to_lower():
        "hearts", "diamonds":
            return "Red"
        "clubs", "spades":
            return "Black"
        _:
            return "none"
