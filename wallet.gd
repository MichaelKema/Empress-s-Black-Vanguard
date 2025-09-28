
extends Node
@export var coins := 100
signal coins_changed(value:int)
func add(v:int): coins += v; coins_changed.emit(coins)
func spend(v:int) -> bool:
    if coins >= v: coins -= v; coins_changed.emit(coins); return true
    return false
