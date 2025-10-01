extends CanvasLayer

@export var tower_scene: PackedScene
@export var tower_cost: int = 20
@export var snap_pixels: int = 48

@export var wallet_path: NodePath = ^"../Wallet"
@export var placement_parent_path: NodePath = ^"../Towers"

@onready var build_btn: BaseButton = $TopBar/BuildBtn
@onready var coins_label: Label = $TopBar/CoinsLabel
@onready var wallet := get_node_or_null(wallet_path)

var _building := false
var _ghost: Node2D

func _ready():
    
    print("[UI] ready from ", get_path())

    set_process(true)
    set_process_unhandled_input(true)

    # If your node is a plain Button, use BaseButton here:


    build_btn.pressed.connect(func ():
        print("[UI] BuildBtn pressed")   # ← prove the click fires
        _on_build_btn_pressed()
    )

    if wallet and wallet.has_signal("coins_changed"):
        wallet.coins_changed.connect(_on_coins_changed)
        if "coins" in wallet:
            _on_coins_changed(wallet.coins)

func _on_coins_changed(v:int) -> void:
    coins_label.text = str(v)
    build_btn.disabled = (v < tower_cost)

func _on_build_btn_pressed() -> void:
    print("[UI] click in; disabled=", build_btn.disabled)

    if tower_scene == null:
        push_error("[UI] Assign 'tower_scene' on the UI node.")
        return

    var parent := get_node_or_null(^"../Towers") # <- your actual tree
    if parent == null:
        push_error("[UI] Can't find ../Towers from UI");
        return

    var t := tower_scene.instantiate()
    t.global_position = Vector2(600, 300) # obvious spot
    if t.has_method("set_preview"):
        t.set_preview(false)
    parent.add_child(t)
    print("[UI] DROPPED tower under ", parent.get_path())



func _process(_dt):
    if _building and is_instance_valid(_ghost):
        _move_ghost()

func _unhandled_input(event):
    if !_building: return
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_LEFT:
            # ignore if clicking over UI
            if get_viewport().gui_pick(event.position) != null:
                return

            if wallet == null or !wallet.spend(tower_cost):
                coins_label.modulate = Color(1,0.4,0.4)
                await get_tree().create_timer(0.15).timeout
                coins_label.modulate = Color(1,1,1)
                return

            var parent := _get_parent(); if parent == null: return
            var final_pos := _ghost.global_position
            _ghost.queue_free(); _ghost = null

            var tower := tower_scene.instantiate()
            tower.global_position = final_pos
            if tower.has_method("set_preview"): tower.set_preview(false)
            parent.add_child(tower)

            _building = false
            build_btn.modulate = Color(1,1,1,1)

        elif event.button_index == MOUSE_BUTTON_RIGHT:
            _cancel_build()

func _move_ghost():
    if !is_instance_valid(_ghost): return
    var vp := get_viewport()
    var pos := vp.get_mouse_position()
    var cam := vp.get_camera_2d()
    # convert screen -> world if you have a Camera2D
    pos = cam.screen_to_world(pos) if cam else pos
    if snap_pixels > 0:
        pos = Vector2(round(pos.x / snap_pixels) * snap_pixels,
                      round(pos.y / snap_pixels) * snap_pixels)
    _ghost.global_position = pos

func _cancel_build():
    _building = false
    if is_instance_valid(_ghost): _ghost.queue_free()
    _ghost = null
    build_btn.modulate = Color(1,1,1,1)

func _get_parent() -> Node:
    if placement_parent_path.is_empty():
        return get_tree().current_scene
    return get_node_or_null(placement_parent_path)
