extends Camera3D

@onready var game: Node3D = $"../.."
@onready var camera_pivot: Node3D = $".."

const CAMERA_PAN_MARGIN:float = 5.0

@export var sensitivity = 300

var is_clicking = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.back.connect(back)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Pivots the camera around the origin when the player clicks and drags
func _input(event):
	if (game.page == "in_solo_game" or game.page == "in_ap_game") and event is InputEventMouseMotion and is_clicking:
		camera_pivot.transform = camera_pivot.transform.rotated_local(Vector3.UP, -1 * event.relative.x / sensitivity)
		camera_pivot.transform = camera_pivot.transform.rotated_local(Vector3.RIGHT, -1 * event.relative.y / sensitivity)

		camera_pivot.transform = camera_pivot.transform.orthonormalized()
			
	if event is InputEventMouseButton:
		if event.is_action_pressed("Click"):
			is_clicking = true
		elif event.is_action_released("Click"):
			is_clicking = false

# Resets camera position when the game is exited
func back():
	camera_pivot.rotation = Vector3(deg_to_rad(-45.0), deg_to_rad(45.0), 0.0)
