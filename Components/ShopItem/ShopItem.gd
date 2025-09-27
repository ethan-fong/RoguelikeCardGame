extends PanelContainer

#---------------- SIGNALS ----------------
signal purchase_pressed(item, price)

#---------------- NODES ----------------
@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var description_label: Label = %DescriptionLabel
@onready var price_label: Label = %PriceLabel
@onready var purchase_button: Button = %PurchaseButton

#---------------- STATE ----------------
var current_item
var current_price: int

#---------------- INITIALIZATION ----------------
func _ready() -> void:
    assert(icon != null, "The 'Icon' node is not assigned. Did you set its unique name ('%') in ShopItemCard.tscn?")
    assert(name_label != null, "The 'NameLabel' node is not assigned. Did you set its unique name ('%') in ShopItemCard.tscn?")
    assert(description_label != null, "The 'DescriptionLabel' node is not assigned. Did you set its unique name ('%') in ShopItemCard.tscn?")
    assert(price_label != null, "The 'PriceLabel' node is not assigned. Did you set its unique name ('%') in ShopItemCard.tscn?")
    assert(purchase_button != null, "The 'PurchaseButton' node is not assigned. Did you set its unique name ('%') in ShopItemCard.tscn?")
    purchase_button.pressed.connect(_on_purchase_button_pressed)

#---------------- PUBLIC API ----------------
func update_card(item, price: int) -> void:
    current_item = item
    current_price = price

    # Set the visual details of the card
    if "icon" in item and item.icon != null:
        icon.texture = item.icon
    else:
        icon.texture = null # Clear the texture if the item has no icon
    name_label.text = item.name
    description_label.text = item.description
    
    price_label.text = "Price: %d coins" % price

    # Disable button if player can't afford it
    purchase_button.disabled = not PlayerInventory.check_can_afford(price)

#---------------- HANDLERS ----------------
func _on_purchase_button_pressed() -> void:
    emit_signal("purchase_pressed", current_item, current_price)
    # After purchase, the shop script will likely remove this card,
    # so we don't need to do much more here.
