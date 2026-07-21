extends Node3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

const CUBE_PIECE = preload("res://assets/pieces/cube_piece.tres")
const PYRAMID_PIECE = preload("res://assets/pieces/pyramid_piece.obj")
const OCTOHEDRON_PIECE = preload("res://assets/pieces/octohedron.obj")

@export var shape = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

### CONSTRUCTOR ###

func construct(pos : Vector3, shape : String):
	update_mesh(shape)
	position = pos
	scale = Vector3(0.9, 0.9, 0.9)

### METHODS ###

# Updates the mesh to the given shape
func update_mesh(shape : String):
	self.shape = shape
	match shape:
		"cube":
			mesh_instance.mesh = CUBE_PIECE
		"tetrahedron":
			mesh_instance.mesh = PYRAMID_PIECE
		"octohedron":
			mesh_instance.mesh = OCTOHEDRON_PIECE

# Show/Hide the mesh for this piece
# Note, this will not show/hide stickers
func show_mesh():
	mesh_instance.visible = true

func hide_mesh():
	mesh_instance.visible = false
