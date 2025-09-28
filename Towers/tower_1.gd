extends StaticBody2D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 0.5
@export var end_marker: NodePath
@export var bullet_damage: int = 5

# 👇 match your actual node paths
@onready var range: Area2D = $Tower/TowerRange
@onready var aim: Node2D   = $Marker2D
@onready var bullet_container: Node = $Tower/BulletContainer

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

func shoot(target: Node):
    var bullet = projectile_scene.instantiate()
    bullet.global_position = aim.global_position
    bullet.target = target
    bullet.bulletDamage = bullet_damage
    get_tree().current_scene.add_child(bullet)  # <- add to scene root
  # keep bullets grouped under the tower
