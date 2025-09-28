# projectile_1.gd
extends Area2D

@export var speed: float = 400
@export var bulletDamage: int = 8
var target: Node = null

func _process(delta):
    if not target or !target.is_inside_tree():
        queue_free()
        return


    var dir = (target.global_position - global_position).normalized()
    global_position += dir * speed * delta

    # check distance to target (simple collision)
    if global_position.distance_to(target.global_position) < 8.0:
        if target.has_method("take_damage"):
            target.take_damage(bulletDamage)
        queue_free()
