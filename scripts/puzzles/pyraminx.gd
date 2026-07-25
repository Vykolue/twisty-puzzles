extends Puzzle

# tetrahedron helper values
const VAL1 = (sqrt(6.0)) / 3.0 # approx 0.82
const VAL2 = (sqrt(2.0)) / 3.0 # approx 0.47
const VAL3 = 2.0 * VAL2 # approx 0.94
const VAL4 = 1.0 / 3.0 # approx 0.33

const FRONT_NORMAL = Vector3(0.00, VAL4, VAL3)
const LEFT_NORMAL = Vector3(-1 * VAL1, VAL4, -1 * VAL2)
const RIGHT_NORMAL = Vector3(VAL1, VAL4, -1 * VAL2)
const DOWN_NORMAL = Vector3(0.0, -1.0, 0.0)

const BACK_POINT = -FRONT_NORMAL
const RIGHT_POINT = -LEFT_NORMAL
const LEFT_POINT = -RIGHT_NORMAL
const UP_POINT = -DOWN_NORMAL


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# define variables
	operations = ["up", "left", "right", "back"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### MAIN FUNCTIONS ###

### INSTANTIATION FUNCTIONS ###

# randomizes the color layout
func randomize_colors():
	var new_colors = color_map.duplicate(true)
	var options = ["red", "blue", "green", "yellow"]
	
	var colors_to_place = ["red", "blue", "green", "yellow"]
	for color in colors_to_place:
		var rand_index = randi() % len(options)
		new_colors[color] = options.pop_at(rand_index)
	color_map = new_colors

### HELPER FUNCTIONS ###

# assigns a dictionary to faces
func assign_faces():
	var face_names = ["front", "left", "right", "down"]
	var color_names = ["green", "red", "blue", "yellow"]
	
	var normals = [FRONT_NORMAL, LEFT_NORMAL, RIGHT_NORMAL, DOWN_NORMAL]
	
	for i in len(face_names):
		faces[face_names[i]] = {"color": color_names[i], "normal": normals[i]}

# gets the piece id of all triangles
# based on where it traveled on the given face
func get_piece_ids(ids):
	var new_ids = []
	for id in ids:
		var piece_faces = [id[0], id[2], id[4]]
		var vals = [int(id[1]), int(id[3]), int(id[5])]
		var inds = [piece_faces.find("f"), piece_faces.find("l"), piece_faces.find("r"), piece_faces.find("d")]
		var dirs = [piece_faces[inds[0]], piece_faces[inds[1]], piece_faces[inds[2]]]
		var new_vals = [0, 0, 0]
		var change_dirs = [["l", "m", "r"], ["u", "e", "d"], ["f", "s", "b"]]
		#print(faces[inds[0]] + " " + faces[inds[1]] + " " + faces[inds[2]])
		#print(str(vals[inds[0]]) + " " + str(vals[inds[1]]) + " " + str(vals[inds[2]]))
		
		for i in range(len(inds)):
			if vals[inds[i]] < (0.5 * size) - 0.5:
				if size % 2 == 0:
					new_vals[i] = abs(vals[inds[i]] - ((0.5 * size) - 1.0))
				else:
					new_vals[i] = abs(vals[inds[i]] - ((0.5 * size) - 1.5))
			elif vals[inds[i]] == (0.5 * size) - 0.5:
				dirs[i] = change_dirs[i][1]
				new_vals[i] = 0
			elif vals[inds[i]] > (0.5 * size) - 0.5:
				if dirs[i] == change_dirs[i][0]: dirs[i] = change_dirs[i][2]
				elif dirs[i] == change_dirs[i][2]: dirs[i] = change_dirs[i][0]
				
				if size % 2 == 0:
					new_vals[i] = abs(vals[inds[i]] - ((0.5 * size) + 0.0))
				else:
					new_vals[i] = abs(vals[inds[i]] - ((0.5 * size) + 0.5))
		
		var new_id = dirs[0] + str(int(new_vals[0])) + dirs[1] + str(int(new_vals[1])) + dirs[2] + str(int(new_vals[2]))
		
		# appends the id, and the face value that the current sticker is on
		new_ids.append([new_id, id[0]])
	return new_ids

# switches the vectors based on the current face being constructed
func match_vectors_by_face(face):
	match face:
		"front":
			return [FRONT_NORMAL, LEFT_NORMAL, RIGHT_NORMAL, DOWN_NORMAL, "d", "r"]
		"left":
			return [LEFT_NORMAL, RIGHT_NORMAL, FRONT_NORMAL, DOWN_NORMAL, "d", "f"]
		"right":
			return [RIGHT_NORMAL, FRONT_NORMAL, LEFT_NORMAL, DOWN_NORMAL, "d", "l"]
		"down":
			return [DOWN_NORMAL, LEFT_NORMAL, FRONT_NORMAL, RIGHT_NORMAL, "r", "f"]
