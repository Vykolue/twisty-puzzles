extends Puzzle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# define variables
	operations = ["up", "right", "left", "front", "rdown", "ldown"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### MAIN FUNCTIONS ###

### INSTANTIATION FUNCTIONS ###

# randomizes the color layout
func randomize_colors():
	pass

### HELPER FUNCTIONS ###

# assigns a dictionary to faces
func assign_faces():
	var face_names = ["up", "down", "left", "right", "front", "back"]
	var color_names = ["white", "yellow", "orange", "red", "green", "blue"]
	
	var up_normal = Vector3(0.0, 1.0, 0.0)
	var down_normal = Vector3(0.0, -1.0, 0.0)
	var left_normal = Vector3(-1.0, 0.0, 0.0)
	var right_normal = Vector3(1.0, 0.0, 0.0)
	var front_normal = Vector3(0.0, 0.0, 1.0)
	var back_normal = Vector3(0.0, 0.0, -1.0)
	
	var normals = [up_normal, down_normal, left_normal, right_normal, front_normal, back_normal]
	
	for i in len(face_names):
		faces[face_names[i]] = {"color": color_names[i], "normal": normals[i]}

func get_piece_ids(ids):
	return ids
