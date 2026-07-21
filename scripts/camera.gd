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
func _process(delta: float) -> void:
	pass

func camera_pan(delta: float) -> void:
	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	'''
	if mouse_pos.x < CAMERA_PAN_MARGIN: cam_movement_velocity.x = -1 * delta
	if mouse_pos.y < CAMERA_PAN_MARGIN: cam_movement_velocity.z = -1 * delta
	if mouse_pos.x > CAMERA_PAN_MARGIN: cam_movement_velocity.x = delta
	if mouse_pos.y > CAMERA_PAN_MARGIN: cam_movement_velocity.z = delta
	'''

func _input(event):
	if (game.page == "in game" or game.page == "in ap game") and event is InputEventMouseMotion and is_clicking:
		camera_pivot.rotate(Vector3.UP, -1 * event.relative.x / sensitivity)
		'''
		camera_pivot.rotate(Vector3.RIGHT, -1 * event.relative.y / sensitivity)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(-45), deg_to_rad(90))
		'''
	if event is InputEventMouseButton:
		if event.is_action_pressed("Click"):
			is_clicking = true
		elif event.is_action_released("Click"):
			is_clicking = false

func back():
	camera_pivot.rotation = Vector3.ZERO
