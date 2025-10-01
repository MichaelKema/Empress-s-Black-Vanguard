# RangeViz.gd (attach to RangeViz node)
extends Node2D
@export var line_color := Color(0, 1, 0, 0.35)
@export var fill_color := Color(0, 1, 0, 0.10)
var r: float = 100.0

func set_radius(new_r: float) -> void:
    r = new_r; update()

func _draw():
    if r <= 0: return
    draw_circle(Vector2.ZERO, r, fill_color)
    draw_circle_lines(Vector2.ZERO, r, line_color, 64)
