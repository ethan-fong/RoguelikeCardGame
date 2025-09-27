extends Control
# ---------------- NODES ----------------
@onready var coin_label: Label = $CoinsContainer/CoinLabel
@onready var coin_icon: TextureRect = $CoinsContainer/CoinIcon
@onready var artifacts_hbox: HBoxContainer = $ArtifactsContainer/HBoxContainer
@onready var consumables_bar: HBoxContainer = $%ConsumablesBar
@onready var card_reveals_left_label: Label = $%CardRevealsLeft

var consumable_tooltip_scene = preload("res://Components/Consumables/ConsumableTooltip.tscn")
var consumable_tooltip: PanelContainer = null

# ---------------- CHIP SETTINGS ----------------
@export var chip_spritesheet: Texture2D
@export var chip_cols: int = 8
@export var chip_rows: int = 4
@export var chip_size: Vector2 = Vector2(46, 62)
@export var chip_color_index: int = 0  # row/color in spritesheet

# ---------------- SIGNALS ----------------
signal artifact_selected(artifact)

# ---------------- INITIALIZATION ----------------
func _ready() -> void:
    PlayerInventory.connect("coins_changed", Callable(self, "_on_coins_changed"))
    _refresh_consumables()
    PlayerInventory.consumable_added.connect(_on_consumable_added)
    PlayerInventory.consumable_removed.connect(_on_consumable_removed)
    _refresh_artifacts()
    _on_coins_changed(PlayerInventory.coins)

# ---------------- COINS DISPLAY ----------------
func _on_coins_changed(new_amount: int) -> void:
    # Update label
    coin_label.text = str(new_amount)
    # Update single chip icon
    display_chip(new_amount)

func display_chip(amount: int) -> void:
    coin_icon.texture = null
    if amount <= 0:
        return

    # Generate powers-of-two array up to max spritesheet capacity
    var max_sprites = chip_cols * chip_rows  # 8 * 4 = 32
    var chip_values = []
    for i in range(max_sprites):
        chip_values.append(1 << i)  # 2^i

    # Find nearest power-of-two ≤ amount
    var nearest_value = chip_values[0]
    for val in chip_values:
        if val <= amount:
            nearest_value = val
        else:
            break

    var index = chip_values.find(nearest_value)
    var col = index % chip_cols
    var row = index / chip_cols  # integer division

    # Set atlas texture
    var atlas_tex = AtlasTexture.new()
    atlas_tex.atlas = chip_spritesheet
    atlas_tex.region = Rect2(
        col * chip_size.x,
        row * chip_size.y,
        chip_size.x,
        chip_size.y
    )

    coin_icon.texture = atlas_tex
    coin_icon.expand = true
    coin_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    coin_icon.custom_minimum_size = chip_size


# ---------------- ARTIFACT DISPLAY ----------------
func _refresh_artifacts() -> void:
    for child in artifacts_hbox.get_children():
        child.queue_free()

    for artifact in PlayerInventory.artifacts:
        var artifact_button = preload("res://Components/Artifacts/UserArtifact.tscn").instantiate()
        # Set the data property. The ArtifactUI's _ready() function will handle the rest.
        artifact_button.artifact_data = artifact
        # Add the button to the scene tree, which will trigger its _ready() function.
        artifacts_hbox.add_child(artifact_button)
        # Connect the signal after the node is in the tree.

# ---------------- ARTIFACT CLICK ----------------
func _on_artifact_pressed(artifact) -> void:
    emit_signal("artifact_selected", artifact)

# ---------------- CONSUMABLES DISPLAY ----------------
# Remove all children and recreate buttons from inventory
func _refresh_consumables() -> void:
    # Safely free existing children
    for child in consumables_bar.get_children():
        child.queue_free()

    # If there are no consumables, nothing to do
    if PlayerInventory.consumables.is_empty():
        return

    # Create a button for each consumable
    for consumable in PlayerInventory.consumables:
        var btn: TextureButton = TextureButton.new()
        # set the icon (assumes consumable.icon is a Texture)
        if consumable.icon:
            btn.texture_normal = consumable.icon
        # helpful tooltip/name
        # layout behaviour
        btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        btn.size_flags_vertical = Control.SIZE_FILL
        btn.custom_minimum_size = Vector2(64, 64)  # tweak as needed

        # connect pressed → pass the consumable instance using Callable.bind
        btn.pressed.connect(Callable(self, "_on_consumable_pressed").bind(consumable))
        btn.mouse_entered.connect(Callable(self, "_on_consumable_mouse_entered").bind(consumable))
        btn.mouse_exited.connect(Callable(self, "_on_consumable_mouse_exited"))

        consumables_bar.add_child(btn)

func _on_consumable_mouse_entered(consumable: Consumable):
    if consumable_tooltip == null:
        consumable_tooltip = consumable_tooltip_scene.instantiate()
        add_child(consumable_tooltip)
    consumable_tooltip.update_tooltip(consumable)
    consumable_tooltip.show()

func _on_consumable_mouse_exited():
    if consumable_tooltip:
        consumable_tooltip.hide()

# Handlers for Inventory signals (just refresh - inexpensive)
func _on_consumable_added(consumable) -> void:
    _refresh_consumables()

func _on_consumable_removed(consumable) -> void:
    _refresh_consumables()

# When a consumable button is pressed
func _on_consumable_pressed(consumable) -> void:
    # Let inventory handle the use / effects
    PlayerInventory.use_consumable(consumable)

# ---------------- REVEALS DISPLAY ----------------
func _on_reveals_updated(reveals_left: int) -> void:
    if card_reveals_left_label:
        card_reveals_left_label.text = "Reveals Left: %d" % reveals_left
