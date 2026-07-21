extends Node3D

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

const SQUARE_STICKER = preload("res://assets/stickers/square_sticker.tres")
const EQUILATERAL_TRIANGLE_STICKER = preload("res://assets/stickers/equilateral_triangle_sticker.tres")

const colors = {
	"red": Color(1.0, 0.0, 0.0, 1.0), 
	"orange": Color(1.0, 0.5, 0.0, 1.0), 
	"blue": Color(0.0, 0.0, 1.0, 1.0), 
	"green": Color(0.0, 1.0, 0.0, 1.0), 
	"white": Color(1.0, 1.0, 1.0, 1.0), 
	"yellow": Color(1.0, 1.0, 0.0, 1.0)
}

var override = StandardMaterial3D.new()

@export var shape = ""
@export var color = ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh_instance["surface_material_override/0"] = override


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

### CONSTRUCTOR ###

func construct(pos : Vector3, shape : String, rotate : Dictionary, color : String):
	update_mesh(shape)
	update_color(color)
	scale = Vector3(0.9, 0.9, 0.09)
	position = pos
	#rotation = rotate
	
	for vector in rotate:
		transform.basis = transform.basis.rotated(vector, rotate[vector])

### METHODS ###

# Updates the mesh to the given shape
func update_mesh(shape):
	self.shape = shape
	match shape:
		"square":
			mesh_instance.mesh = SQUARE_STICKER
		"triangle":
			mesh_instance.mesh = EQUILATERAL_TRIANGLE_STICKER
			mesh_instance.position.y += 0.15
			mesh_instance.scale.x += 0.25

func update_color(color):
	self.color = color
	
	override["albedo_color"] = colors[color]

# Show/Hide the mesh for this sticker
func show_mesh():
	mesh_instance.visible = true

func hide_mesh():
	mesh_instance.visible = false
