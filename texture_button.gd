extends TextureButton

@export var tower_scene: PackedScene           # e.g. res://Towers/tower_1.tscn
@export var snap_pixels: int = 48              # 0 = no snap; 48 if your tiles are 48px
@export var drop_parent_path: NodePath         # optional: where to put towers (e.g. ../Towers)

var ghost: Node2D = null
var dragging: bool = false
var drop_parent: Node = null

func _ready():
    # Let mouse events bubble up; the button still works
    mouse_filter = Control.MOUSE_FILTER_PASS

    # Where do we put the ghost/placed tower?
    if drop_parent_path.is_empty():
        drop_parent = get_tree().current_scene.get_node_or_null("Towers")
        if drop_parent == null:
            drop_parent = get_tree().current_scene
    else:
        drop_parent = get_node(drop_parent_path)

func _pressed():
    if dragging or tower_scene == null:
        return
    dragging = true
    ghost = tower_scene.instantiate()
    ghost.modulate = Color(1, 1, 1, 0.6)   # translucent preview
    drop_parent.add_child(ghost)
    _move_ghost_to_mouse()

func _process(_dt):
    if dragging and ghost:
        _move_ghost_to_mouse()

func _input(event):
    if !dragging or ghost == null:
        return
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.pressed:
        # place
        ghost.modulate = Color(1, 1, 1, 1)
        ghost = null
        dragging = false
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed:
        # cancel
        ghost.queue_free()
        ghost = null
        dragging = false

func _move_ghost_to_mouse():
    var pos = get_viewport().get_mouse_position()      # screen coords
    var cam := get_viewport().get_camera_2d()
    if cam:
        pos = cam.screen_to_world(pos)                 # convert to world coords
    if snap_pixels > 0:
        pos = Vector2(
            round(pos.x / snap_pixels) * snap_pixels,
            round(pos.y / snap_pixels) * snap_pixels
        )
    ghost.global_position = pos
