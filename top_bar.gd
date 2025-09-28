
extends Control
@export var wallet_path: NodePath = ^"../..//Wallet"   # Main/Wallet
@onready var wallet = get_node(wallet_path)
@onready var coins_label: Label = $CoinsLabel
@onready var build_btn: Button = $BuildBtn

func _ready():
    coins_label.text = "Coins: %d" % wallet.coins
    wallet.coins_changed.connect(func(v:int): coins_label.text = "Coins: %d" % v)
