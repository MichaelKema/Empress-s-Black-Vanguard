extends Node2D
@onready var path: Path2D = $Path2D
@onready var road: Line2D = $Road

func _ready():
	road.points = path.curve.get_baked_points()
	road.width = 28                       # thickness of the road
	road.default_color = Color("#30313a") # spooky asphalt
	road.joint_mode = Line2D.LINE_JOINT_ROUND
	road.end_cap_mode = Line2D.LINE_CAP_ROUND
