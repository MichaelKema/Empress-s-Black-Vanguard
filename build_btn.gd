extends Button

@export var tower_scene: PackedScene
@export var tower_cost: int = 20
@export var snap_pixels: int = 48
@export var drop_parent_path: NodePath = ^"../../Towers"
@export var wallet_path: NodePath = ^"../../../Wallet"

var ghost: Node2D
var dragging := false
@onready var drop_parent: Node = get_node(drop_parent_path)
var wallet: Node = null

func _ready():
    # resolve wallet robustly
    if wallet_path.is_empty():
        wallet = get_tree().current_scene.get_node_or_null("Wallet")
        if wallet == null:
            wallet = get_tree().get_first_node_in_group("wallet")
    else:
        wallet = get_node_or_null(wallet_path)

    if wallet == null:
        push_error("BuildBtn: Wallet not found. Set wallet_path or Autoload Wallet.")
        disabled = true
        return

    _refresh_text()
    if wallet.has_signal("coins_changed"):
        wallet.coins_changed.connect(_on_coins_changed)
    _update_disabled()

func _on_coins_changed(_v:int) -> void:
    _update_disabled()
    _refresh_text()

func _update_disabled():
    disabled = wallet.coins < tower_cost

func _refresh_text():
    if self is Button:
        text = "Tower (%d)" % tower_cost
    var lbl := get_node_or_null("Label") as Label
    if lbl: lbl.text = "Tower (%d)" % tower_cost

func _pressed():
    # must have valid scene and parent
    if tower_scene == null:
        push_error("BuildBtn: tower_scene not set.")
        return
    if drop_parent == null:
        push_error("BuildBtn: drop_parent is null.")
        return

    # must have money
    if wallet == null or !wallet.spend(tower_cost):
        return

    dragging = true

    # make the ghost
    ghost = tower_scene.instantiate()
    if ghost == null:
        push_error("BuildBtn: instantiate() returned null (bad scene?).")
        dragging = false
        return

    ghost.modulate = Color(1,1,1,0.6)
    drop_parent.add_child(ghost)
    _move_ghost_to_mouse()


func _process(_dt):
    if dragging and ghost:
        _move_ghost_to_mouse()

func _input(event):
    if !dragging or ghost == null: return
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
            ghost.modulate = Color(1,1,1,1)   # place
            ghost = null
            dragging = false
        elif event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed:
            wallet.add(tower_cost)            # cancel → refund
            ghost.queue_free()
            ghost = null
            dragging = false

func _move_ghost_to_mouse():
    var pos := get_viewport().get_mouse_position()
    var cam := get_viewport().get_camera_2d()
    if cam: pos = cam.screen_to_world(pos)
    if snap_pixels > 0:
        pos = Vector2(round(pos.x / snap_pixels) * snap_pixels,
                      round(pos.y / snap_pixels) * snap_pixels)
    ghost.global_position = pos
