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

# generates mesh data for pieces and stickers and sends to generate_meshes()
func send_mesh_data():
	# mesh data
	var outer_plastic_data = faces.duplicate(true)
	var inner_plastic_data = faces.duplicate(true)
	var sticker_data = faces.duplicate(true)
	
	# piece ids
	var outer_plastic_ids = []
	var inner_plastic_ids = []
	var sticker_ids = []
	
	# scales the puzzle based on size while remaining centered on the origin
	var scale_by_size = 0.5 * size
	
	# scale the pieces so there is a gap between
	#var piece_scale = 0.95
	var adjustment = (1.0 - piece_scale) / 2.0
	var corner_scale = (scale_by_size - adjustment) / scale_by_size
	
	# scale the stickers to not take up the entire surface
	# value should be less than piece_scale
	#var sticker_scale = 0.90
	var s_adjustment = (1.0 - sticker_scale) / 2.0
	var s_corner_scale = (scale_by_size - s_adjustment) / scale_by_size
	
	# how far the sticker floats in front of the face
	# setting this to 0 will cause issues with rendering both sticker and face 
	# in the same location
	var s_float = 0.01
	
	# builds the data face by face
	for face in faces:
		outer_plastic_data[face]["triangles"] = []
		inner_plastic_data[face]["triangles"] = []
		sticker_data[face]["triangles"] = []
		
		# helper points and vectors
		var p = Vector3()
		var d1 = ""
		var v1 = Vector3()
		var d2 = ""
		var v2 = Vector3()
		var v3 = Vector3()
		
		# changes the plastic to default plastic color, rather than face color
		if style != "stickerless":
			outer_plastic_data[face]["color"] = "plastic"
		inner_plastic_data[face]["color"] = "plastic"
		
		# defines helper points and vectors based on face
		match face:
			"up":
				p = (LEFT_NORMAL + UP_NORMAL + BACK_NORMAL)
				v1 = RIGHT_NORMAL
				d1 = "l"
				v2 = FRONT_NORMAL
				d2 = "b"
				v3 = -UP_NORMAL
			"front":
				p = (LEFT_NORMAL + UP_NORMAL + FRONT_NORMAL)
				v1 = RIGHT_NORMAL
				d1 = "l"
				v2 = DOWN_NORMAL
				d2 = "u"
				v3 = -FRONT_NORMAL
			"right":
				p = (RIGHT_NORMAL + UP_NORMAL + FRONT_NORMAL)
				v1 = BACK_NORMAL
				d1 = "f"
				v2 = DOWN_NORMAL
				d2 = "u"
				v3 = -RIGHT_NORMAL
			"back":
				p = (RIGHT_NORMAL + UP_NORMAL + BACK_NORMAL)
				v1 = LEFT_NORMAL
				d1 = "r"
				v2 = DOWN_NORMAL
				d2 = "u"
				v3 = -BACK_NORMAL
			"left":
				p = (LEFT_NORMAL + UP_NORMAL + BACK_NORMAL)
				v1 = FRONT_NORMAL
				d1 = "b"
				v2 = DOWN_NORMAL
				d2 = "u"
				v3 = -LEFT_NORMAL
			"down":
				p = (LEFT_NORMAL + DOWN_NORMAL + FRONT_NORMAL)
				v1 = RIGHT_NORMAL
				d1 = "l"
				v2 = BACK_NORMAL
				d2 = "f"
				v3 = -DOWN_NORMAL
		
		# scale the puzzle based on size
		p = p * scale_by_size
		
		# more helper vectors for scaling
		var v1a = v1 * piece_scale
		var v2a = v2 * piece_scale
		var v1b = v1 * sticker_scale
		var v2b = v2 * sticker_scale
		
		# creates a list of starting points for each piece and sticker on the current face
		# also keeps track of where on the face each starting point corresponds to
		var start_points = []
		var sticker_start_points = []
		var indices = []
		for i in size:
			for j in size:
				var start_point = (p * corner_scale) + (v1 * i) + (v2 * j)
				start_points.append(start_point)
				
				var s_start_point = (p * s_corner_scale) + (v1 * i) + (v2 * j) + ((s_adjustment + s_float - adjustment) * -v3)
				sticker_start_points.append(s_start_point)
				
				indices.append([i, j])
		
		# creates a separate face for the inside of the stickers
		sticker_data[face + " inside"] = {
			"color": sticker_data[face]["color"],
			"normal": -sticker_data[face]["normal"],
			"triangles": []
		}
		
		# loops through starting points to add triangles to the mesh data
		for i in range(0, len(start_points)):
			var point = start_points[i]
			var s_point = sticker_start_points[i]
			
			
			# creates two triangles (forming a square) for the outer plastic of each piece
			outer_plastic_data[face]["triangles"].append([point, point+v1a, point+v1a+v2a])
			outer_plastic_data[face]["triangles"].append([point, point+v1a+v2a, point+v2a])
			
			outer_plastic_ids.append(face[0] + str(0) + d1 + str(indices[i][0]) + d2 + str(indices[i][1]))
			outer_plastic_ids.append(face[0] + str(0) + d1 + str(indices[i][0]) + d2 + str(indices[i][1]))
			
			# creates two triangles for each sticker
			sticker_data[face]["triangles"].append([s_point, s_point+v1b, s_point+v1b+v2b])
			sticker_data[face]["triangles"].append([s_point, s_point+v1b+v2b, s_point+v2b])
			
			sticker_ids.append(face[0] + str(0) + d1 + str(indices[i][0]) + d2 + str(indices[i][1]))
			sticker_ids.append(face[0] + str(0) + d1 + str(indices[i][0]) + d2 + str(indices[i][1]))
			
			# creates two triangles for the inside of each sticker (so stickers are visible from both sides)
			sticker_data[face + " inside"]["triangles"].append([s_point, s_point+v1b+v2b, s_point+v1b])
			sticker_data[face + " inside"]["triangles"].append([s_point, s_point+v2b, s_point+v1b+v2b])
			
			sticker_ids.append(face[0] + str(0) + d1 + str(indices[i][0]) + d2 + str(indices[i][1]))
			sticker_ids.append(face[0] + str(0) + d1 + str(indices[i][0]) + d2 + str(indices[i][1]))
			
			# creates all of the faces inside the piece (since there is some separation between pieces)
			for j in range(1, size):
				if indices[i][0] == 0 or indices[i][0] == size-1 or indices[i][1] == 0 or indices[i][1] == size-1 or j == size-1:
					inner_plastic_data[face]["triangles"].append([point + (j*v3), point+v1a + (j*v3), point+v1a+v2a + (j*v3)])
					inner_plastic_data[face]["triangles"].append([point + (j*v3), point+v1a+v2a + (j*v3), point+v2a + (j*v3)])
					
					inner_plastic_ids.append(face[0] + str(j) + d1 + str(indices[i][0]) + d2 + str(indices[i][1]))
					inner_plastic_ids.append(face[0] + str(j) + d1 + str(indices[i][0]) + d2 + str(indices[i][1]))
	
	#var outer_i = outer_plastic_ids.duplicate(true)
	outer_plastic_ids = get_piece_ids(outer_plastic_ids)
	#var inner_i = inner_plastic_ids.duplicate(true)
	inner_plastic_ids = get_piece_ids(inner_plastic_ids)
	#var sticker_i = sticker_ids.duplicate(true)
	sticker_ids = get_piece_ids(sticker_ids)
	
	# merges outer_plastic_data and inner_plastic_data into a single dataset
	# preserves color values for outer plastic
	var plastic_data = outer_plastic_data
	for face in inner_plastic_data:
		plastic_data["inner " + face] = {
			"color": "plastic",
			"normal": plastic_data[face]["normal"],
			"triangles": []
		}
		
		for triangle in inner_plastic_data[face]["triangles"]:
			plastic_data["inner " + face]["triangles"].append(triangle)
	
	# merges outer_plastic_ids with inner_plastic_ids
	# to match the new plastic_data
	# sets the face value of inner plastic to "p" for plastic 
	# as this color will never need to be changed
	var plastic_ids = []
	for arr in outer_plastic_ids:
		plastic_ids.append(arr)
	
	for arr in inner_plastic_ids:
		var id = arr[0]
		var face = "p"
		var new_arr = [id, face]
		plastic_ids.append(new_arr)
	
	'''
	# debugging
	var c = 0
	for face in plastic_data:
		var inn = "inner" in face
		for triangle in plastic_data[face]["triangles"]:
			if c < 50:
				#print(triangle)
				var readable = triangle_to_readable(triangle)
				#print(readable)
				var new_id = guess_id(readable)
				print(str(new_id))
				#if inn: print(inner_i[c-len(outer_i)])
				#else: print(outer_i[c])
				print(plastic_ids[c])
				print()
			c += 1
	
	print_directional_consts()
	'''
	
	id_dict_plastic = reformat_ids(plastic_ids)
	id_dict_stickers = reformat_ids(sticker_ids)
	
	# generates the meshes
	# can also specify whether the mesh is hidden
	generate_meshes(plastic_data, "plastic", (style == "transparent"))
	generate_meshes(sticker_data, "stickers", (style == "stickerless"))

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
