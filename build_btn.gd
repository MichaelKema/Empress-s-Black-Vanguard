# build_button.gd (attach to UI/TopBar/BuildBtn)
extends Button

@export var tower_scene: PackedScene
@export var snap_pixels: int = 48
@export var tower_cost: int = 25
@export var drop_parent_path: NodePath = ^"../../Towers"  # Main/Towers
@export var wallet_path: NodePath = ^"../../Wallet"

var ghost: Node2D
var dragging := false
@onready var drop_parent = get_node(drop_parent_path)
@onready var wallet = get_node(wallet_path)

func _pressed():
    if dragging or tower_scene == null: return
    if !wallet.spend(tower_cost): return  # not enough coins
    dragging = true
    ghost = tower_scene.instantiate()
    ghost.modulate = Color(1,1,1,0.6)
    drop_parent.add_child(ghost)
    _move_ghost_to_mouse()

func _process(_dt):
    if dragging and ghost:
        _move_ghost_to_mouse()

func _input(event):
    if !dragging or ghost == null: return
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
        # place
        ghost.modulate = Color(1,1,1,1)
        ghost = null
        dragging = false
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed:
        # cancel (refund)
        wallet.add(tower_cost)
        ghost.queue_free()
        ghost = null
        dragging = false

func _move_ghost_to_mouse():
    var pos = get_viewport().get_mouse_position()
    var cam := get_viewport().get_camera_2d()
    if cam: pos = cam.screen_to_world(pos)
    if snap_pixels > 0:
        pos = Vector2(round(pos.x / snap_pixels) * snap_pixels,
                      round(pos.y / snap_pixels) * snap_pixels)
    ghost.global_position = pos
