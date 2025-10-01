extends StaticBody2D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 0.5
@export var end_marker: NodePath
@export var bullet_damage: int = 5

@export var draggable: bool = true
@export var snap_pixels: int = 48   # 0 = no snap


# 👇 match your actual node paths
@onready var range: Area2D = $Tower/TowerRange
@onready var aim: Node2D   = $Marker2D
@onready var bullet_container: Node = $Tower/BulletContainer

var _dragging := false
var _drag_offset := Vector2.ZERO

var end_pos: Vector2
var cd := 0.0

func _ready():
    if range == null: push_error("Missing Area2D at Tower/TowerRange")
    if aim == null: push_error("Missing Node2D at Marker2D")
    if bullet_container == null: push_error("Missing Node at Tower/BulletContainer")

    var end_node: Node2D = null
    if end_marker.is_empty():
        # try to find EndMarker in the running scene
        end_node = get_tree().current_scene.get_node_or_null("EndMarker")
    else:
        end_node = get_node_or_null(end_marker) as Node2D

    if end_node:
        end_pos = end_node.global_position
    else:
        push_error("EndMarker not set/found. Assign it on the Tower instance.")
        return
func _input_event(_viewport, event, _shape_idx):
    # called by StaticBody2D when clicked on one of its shapes
    if !draggable:
        return
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            _dragging = true
            _drag_offset = global_position - get_global_mouse_position()
            # optional: show range/ghost style while dragging
            if has_method("set_preview"): set_preview(true)
        else:
            _dragging = false
            if has_method("set_preview"): set_preview(false)

func _unhandled_input(event):
    # allow cancel with right click while dragging
    if _dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and !event.pressed:
        _dragging = false
        if has_method("set_preview"): set_preview(false)

func _process(delta):
    cd -= delta
    if cd > 0.0:
        return

    var bodies := range.get_overlapping_bodies()
    if bodies.is_empty():
        return

    # pick the enemy closest to EndMarker
    var target: Node2D = null
    var best_d2 := INF
    for b in bodies:
        if "Zombie" in b.name: # or b.is_in_group("enemies")
            var d2 := b.global_position.distance_squared_to(end_pos)
            if d2 < best_d2:
                best_d2 = d2
                target = b

    if target:
        shoot(target)
        cd = fire_rate

    if _dragging:
        var pos := get_global_mouse_position() + _drag_offset
        if snap_pixels > 0:
            pos = Vector2(round(pos.x / snap_pixels) * snap_pixels,
                          round(pos.y / snap_pixels) * snap_pixels)
        global_position = pos    

func shoot(target: Node):
    var bullet = projectile_scene.instantiate()
    bullet.global_position = aim.global_position
    bullet.target = target
    bullet.bulletDamage = bullet_damage
    get_tree().current_scene.add_child(bullet)  # <- add to scene root
  # keep bullets grouped under the tower

func set_preview(on:bool) -> void:
    modulate.a = 0.6 if on else 1.0

    
