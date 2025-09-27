# ConsumablesDatabase.gd
extends Resource
class_name ConsumablesDatabase

# ---------------- ARRAYS ----------------
var consumables: Array[Consumable] = []

func _init():
    # ---------------- Common Consumables ----------------
    var double_coins := Consumable.new()
    double_coins.name = "Double Money"
    double_coins.description = "Doubles coins you currently have"
    double_coins.icon = preload("res://Components/Card/Art/yellow_backing.png")
    double_coins.rarity = 1
    consumables.append(double_coins)

    var peek_top := Consumable.new()
    peek_top.name = "Peek Top Card"
    peek_top.description = "Peeks at the top card"
    peek_top.icon = preload("res://Components/Card/Art/joker.png")
    peek_top.rarity = 1
    consumables.append(peek_top)
    
    var ten_coins := Consumable.new()
    ten_coins.name = "Ten Coins"
    ten_coins.description = "Instantly Gives 10 Coins"
    ten_coins.icon = preload("res://Components/Card/Art/purple_backing.png")
    ten_coins.rarity = 1
    consumables.append(ten_coins)
    
    # ---------------- Uncommon Consumables ----------------
    var peek_three := Consumable.new()
    peek_three.name = "Peek Top Three Cards"
    peek_three.description = "Peeks at the top three cards"
    peek_three.icon = preload("res://Components/Card/Art/green_backing.png")
    peek_three.rarity = 2
    consumables.append(peek_three)
    
    var eighty_coins := Consumable.new()
    eighty_coins.name = "Eighty Coins"
    eighty_coins.description = "Instantly Gives 80 Coi"
    eighty_coins.icon = preload("res://Components/Card/Art/pink_backing.png")
    eighty_coins.rarity = 2
    consumables.append(eighty_coins)
