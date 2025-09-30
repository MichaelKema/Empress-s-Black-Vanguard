extends CharacterBody2D

@export var speed=100
@export var coin_reward: int = 5
# Called when the node enters the scene tree for the first time.


@export var max_hp: int = 20
var hp: int

@onready var health_bar = $HealthBar

func _ready():
    hp = max_hp
    health_bar.max_value = max_hp
    health_bar.value = max_hp

func take_damage(amount: int):
    hp -= amount
    health_bar.value = hp  # update bar
    if hp <= 0:
        die()

func die():
    # simplest: hit the Wallet node in the current scene
    var wallet = get_tree().current_scene.get_node_or_null("Wallet")
    if wallet:
        wallet.add(coin_reward)
    queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    get_parent().set_progress(get_parent().get_progress() + speed*delta)
