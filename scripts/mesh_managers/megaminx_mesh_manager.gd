extends MeshManager
class_name MegaminxMeshManager

### DEFAULT FUNCTIONS ###

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### MAIN FUNCTIONS ###

func retrieve_mesh_data(mesh_type):
	return {}

### HELPER FUNCTIONS ###

func get_piece_ids(ids):
	return ids

# Sets the scale_by_size and scale_by_piece_type
func set_scales():
	scale_by_size = size
	scale_by_piece_type = [1]
