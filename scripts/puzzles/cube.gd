extends Puzzle

# face normals
const UP_NORMAL = Vector3(0.0, 1.0, 0.0)
const DOWN_NORMAL = Vector3(0.0, -1.0, 0.0)
const LEFT_NORMAL = Vector3(-1.0, 0.0, 0.0)
const RIGHT_NORMAL = Vector3(1.0, 0.0, 0.0)
const FRONT_NORMAL = Vector3(0.0, 0.0, 1.0)
const BACK_NORMAL = Vector3(0.0, 0.0, -1.0)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# define variables
	operations = ["up", "down", "left", "right", "front", "back"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### MAIN FUNCTIONS ###

### INSTANTIATION FUNCTIONS ###

# randomizes the color layout
func randomize_colors():
	var new_colors = color_map.duplicate(true)
	var options = ["red", "orange", "blue", "green", "white", "yellow"]
	
	var colors_to_place = ["red", "orange", "blue", "green", "white", "yellow"]
	for color in colors_to_place:
		var rand_index = randi() % len(options)
		new_colors[color] = options.pop_at(rand_index)
	color_map = new_colors

### HELPER FUNCTIONS ###

# assigns a dictionary to faces
func assign_faces():
	var face_names = ["up", "down", "left", "right", "front", "back"]
	var color_names = ["white", "yellow", "orange", "red", "green", "blue"]
	
	var normals = [UP_NORMAL, DOWN_NORMAL, LEFT_NORMAL, RIGHT_NORMAL, FRONT_NORMAL, BACK_NORMAL]
	
	for i in len(face_names):
		faces[face_names[i]] = {"color": color_names[i], "normal": normals[i]}

# gets the piece id of all triangles
# based on how far away it traveled from the given faces
func get_piece_ids(ids):
	var new_ids = []
	#var index = 0
	#var face = "none"
	for id in ids:
		var piece_faces = [id[0], id[2], id[4]]
		var vals = [int(id[1]), int(id[3]), int(id[5])]
		var inds = [max(piece_faces.find("l"), piece_faces.find("r")), max(piece_faces.find("u"), piece_faces.find("d")), max(piece_faces.find("f"), piece_faces.find("b"))]
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

func guess_id(arr):
	var id = []
	for c in len(arr[0]):
		var s1 = arr[0][c][0]
		var s2 = arr[1][c][0]
		var s3 = arr[2][c][0]
		if s1 == s2 and s1 == s3:
			id.append(s1)
		elif s1 == s2:
			id.append(s1 + "?(" + s3 + ")")
		elif s1 == s3:
			id.append(s1 + "?(" + s2 + ")")
		elif s2 == s3:
			id.append(s2 + "?(" + s1 + ")")
		else:
			id.append("idk")
	return id
