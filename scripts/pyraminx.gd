extends Puzzle

const height = 4.0 / 3.0
const dist_to_vertex = 1.0
const dist_to_face = 1.0 / 3.0

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
	type = "pyraminx"
	operations = ["up", "left", "right", "back"]
	assign_faces()
	
	send_mesh_data(style)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

### MAIN FUNCTIONS ###

# rotates the puzzle
func rotate_puzzle(dir):
	pass

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

# generates mesh data for pieces and stickers and sends to generate_meshes()
func send_mesh_data(style):
	# mesh data
	var outer_plastic_data = faces.duplicate(true)
	var inner_plastic_data = faces.duplicate(true)
	var sticker_data = faces.duplicate(true)
	
	# piece ids
	var outer_plastic_ids = []
	var inner_plastic_ids = []
	var sticker_ids = []
	
	# scales the puzzle based on size while remaining centered on the origin
	#var scale_by_size = size * 2 * VAL4
	#var scale_by_size = size
	var idk_scale_tetra = 1.635
	var idk_scale_octa = 1.88
	
	# scale the pieces so there is a gap between
	#var piece_scale = 0.95
	var adjustment = (1.0 - piece_scale) / 2.0
	var adj_scaled_back = adjustment / (tan(acos(sqrt(3.0) / 3.0)))
	var adj_scaled_down = adjustment / (sin(acos(sqrt(3.0) / 3.0)))
	#var adj_vector = Vector3(0.0, -adjustment, 0.0)
	#var corner_scale = (size - adjustment) / size
	
	# scale the stickers to not take up the entire surface
	# value should be less than piece_scale
	#var sticker_scale = 0.90
	var s_adjustment = (1.0 - sticker_scale) / 2.0
	var s_adj_scaled_back = s_adjustment / (tan(acos(sqrt(3.0) / 3.0)))
	var s_adj_scaled_down = s_adjustment / (sin(acos(sqrt(3.0) / 3.0)))
	#var s_adj_vector = Vector3(0.0, -s_adjustment, 0.0)
	#var s_corner_scale = (size - s_adjustment) / size
	
	# how far the sticker floats in front of the face
	# setting this to 0 will cause issues with rendering both sticker and face 
	# in the same location
	var s_float = 0.01
	
	# builds the data face by face
	for face in faces:
		outer_plastic_data[face]["triangles"] = []
		inner_plastic_data[face]["triangles"] = []
		sticker_data[face]["triangles"] = []
		
		# changes the plastic to default plastic color, rather than face color
		if style != "stickerless":
			outer_plastic_data[face]["color"] = "plastic"
		inner_plastic_data[face]["color"] = "plastic"
		
		# defines helper vectors based on face
		# naming is based on looking directly at the face
		var rotated_vectors = match_vectors_by_face(face)
		
		var f_norm = rotated_vectors[0]
		var l_norm = rotated_vectors[1]
		var r_norm = rotated_vectors[2]
		var d_norm = rotated_vectors[3]
		
		var d1 = rotated_vectors[4]
		var d2 = rotated_vectors[5]
		
		var b_pt = -f_norm
		var r_pt = -l_norm
		var l_pt = -r_norm
		var u_pt = -d_norm
		
		var u_to_l = d_norm + l_pt
		var u_to_r = d_norm + r_pt
		var u_to_b = d_norm + b_pt
		var l_to_r = r_norm + r_pt
		var r_to_b = l_norm + b_pt
		
		var oct_norm = (l_to_r + r_to_b + u_to_r).normalized()
		
		#var fd_edge = (l_pt + r_pt) / 2.0
		#const fd_scale = 2.0
		
		# scale the puzzle based on size
		var top = (u_pt * size)
		
		# creates a list of starting points for each piece and sticker on the current face
		# also keeps track of where on the face each starting point corresponds to
		var start_points_tetra = []
		var sticker_start_points_tetra = []
		var indices_tetra = []
		for i in size:
			for j in range(0, i+1):
				var start_point = (top) + (u_to_l * i) + (l_to_r * j) + (d_norm * adj_scaled_down * idk_scale_tetra)
				start_points_tetra.append(start_point)
				
				var s_start_point = (top) + (u_to_l * i) + (l_to_r * j) + (d_norm * s_adj_scaled_down * idk_scale_tetra) + (f_norm * (s_adj_scaled_back + s_float - adj_scaled_back))
				sticker_start_points_tetra.append(s_start_point)
				
				indices_tetra.append([i, j])
		
		var start_points_octa = []
		var sticker_start_points_octa = []
		var indices_octa = []
		for i in range(1, size):
			for j in range(0, i):
				var start_point = (top) + (u_to_l * i) + (l_to_r * j) + (oct_norm * adj_scaled_down * idk_scale_octa)
				start_points_octa.append(start_point)
				
				var s_start_point = (top) + (u_to_l * i) + (l_to_r * j) + (oct_norm * s_adj_scaled_down * idk_scale_octa) + (f_norm * idk_scale_octa * (s_adj_scaled_back + s_float - adj_scaled_back))
				sticker_start_points_octa.append(s_start_point)
				
				indices_octa.append([i, j])
		
		# creates a separate face for the inside of the stickers
		sticker_data[face + " inside"] = {
			"color": sticker_data[face]["color"],
			"normal": -sticker_data[face]["normal"],
			"triangles": []
		}
		
		# loops through starting points to add triangles to the mesh data
		for i in range(0, len(start_points_tetra)):
			var point = start_points_tetra[i]
			var s_point = sticker_start_points_tetra[i]
			
			# creates a triangle for the outer plastic of each piece
			outer_plastic_data[face]["triangles"].append([point, point + (u_to_r * piece_scale), point + (u_to_l * piece_scale)])
			
			outer_plastic_ids.append(face[0] + str(0) + d1 + str(indices_tetra[i][0]) + d2 + str(indices_tetra[i][1]))
			
			# creates a triangle for each sticker
			sticker_data[face]["triangles"].append([s_point, s_point + (u_to_r * sticker_scale), s_point + (u_to_l * sticker_scale)])
			
			sticker_ids.append(face[0] + str(0) + d1 + str(indices_tetra[i][0]) + d2 + str(indices_tetra[i][1]))
			
			# creates a triangle for the inside of each sticker (so stickers are visible from both sides)
			sticker_data[face + " inside"]["triangles"].append([s_point, s_point + (u_to_l * sticker_scale), s_point + (u_to_r * sticker_scale)])
			
			sticker_ids.append(face[0] + str(0) + d1 + str(indices_tetra[i][0]) + d2 + str(indices_tetra[i][1]))
			
			# creates all of the faces inside the piece (since there is some separation between pieces)
			for j in range(1, size):
				if indices_tetra[i][0] + j < size:
					var c1 = indices_tetra[i][0] + j == 0
					var c2 = indices_tetra[i][0] + j == size-1
					var c3 = indices_tetra[i][1] + j == 0
					var c4 = indices_tetra[i][1] + j == size-1
					var c5 = indices_tetra[i][1] == 0
					var c6 = indices_tetra[i][0] == indices_tetra[i][1] and indices_tetra[i][0] < size
					if c1 or c2 or c3 or c4 or c5 or c6:
						inner_plastic_data[face]["triangles"].append([point + (j * u_to_b), point + (u_to_r * piece_scale) + (j * u_to_b), point + (u_to_l * piece_scale) + (j * u_to_b)])
						
						inner_plastic_ids.append(face[0] + str(j) + d1 + str(indices_tetra[i][0]) + d2 + str(indices_tetra[i][1]))
		
		for i in range(0, len(start_points_octa)):
			var point = start_points_octa[i]
			var b_point = point + (l_to_r * piece_scale) + (r_to_b * piece_scale)
			var s_point = sticker_start_points_octa[i]
			
			# creates a triangle for the outer plastic of each piece
			outer_plastic_data[face]["triangles"].append([point, point + (l_to_r * piece_scale), point + (u_to_r * piece_scale)])
			
			outer_plastic_ids.append(face[0] + str(0) + d1 + str(indices_octa[i][0]) + d2 + str(indices_octa[i][1]))
			
			# creates a triangle for each sticker
			sticker_data[face]["triangles"].append([s_point, s_point + (l_to_r * sticker_scale), s_point + (u_to_r * sticker_scale)])
			
			sticker_ids.append(face[0] + str(0) + d1 + str(indices_octa[i][0]) + d2 + str(indices_octa[i][1]))
			
			# creates a triangle for the inside of each sticker (so stickers are visible from both sides)
			sticker_data[face + " inside"]["triangles"].append([s_point, s_point + (u_to_r * sticker_scale), s_point + (l_to_r * sticker_scale)])
			
			sticker_ids.append(face[0] + str(0) + d1 + str(indices_octa[i][0]) + d2 + str(indices_octa[i][1]))
			
			# creates a triangle for the inner plastic opposite the current face
			# since there is no face for it
			inner_plastic_data[face]["triangles"].append([b_point, b_point + (u_to_l * piece_scale), b_point + (u_to_r * piece_scale)])
			
			inner_plastic_ids.append(face[0] + str(0) + d1 + str(indices_octa[i][0]) + d2 + str(indices_octa[i][1]))
			
			# creates all of the faces inside the piece (since there is some separation between pieces)
			for depth in range(1, size):
				var layer = indices_octa[i][0]
				var spot = indices_octa[i][1]
				if layer + depth < size:
					var c1 = layer + depth == 0
					var c2 = layer + depth == size-1
					var c3 = spot + depth == 0
					var c4 = spot + depth == size-1
					var c5 = spot == 0
					var c6 = layer == spot and layer < size
					var c7 = layer == spot + 1
					if c1 or c2 or c3 or c4 or c5 or c6 or c7:
						inner_plastic_data[face]["triangles"].append([point + (depth * u_to_b), point + (l_to_r * piece_scale) + (depth * u_to_b), point + (u_to_r * piece_scale) + (depth * u_to_b)])
						inner_plastic_data[face]["triangles"].append([b_point + (depth * u_to_b), b_point + (u_to_l * piece_scale) + (depth * u_to_b), b_point + (u_to_r * piece_scale) + (depth * u_to_b)])
						
						inner_plastic_ids.append(face[0] + str(depth) + d1 + str(indices_octa[i][0]) + d2 + str(indices_octa[i][1]))
						inner_plastic_ids.append(face[0] + str(depth) + d1 + str(indices_octa[i][0]) + d2 + str(indices_octa[i][1]))
	
	'''
	outer_plastic_ids = get_piece_ids(outer_plastic_ids)
	inner_plastic_ids = get_piece_ids(inner_plastic_ids)
	sticker_ids = get_piece_ids(sticker_ids)
	'''
	
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
	
	'''
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
	
	id_dict_plastic = reformat_ids(plastic_ids)
	id_dict_stickers = reformat_ids(sticker_ids)
	'''
	
	# generates the meshes
	# can also specify whether the mesh is hidden
	generate_meshes(plastic_data, "plastic", (style == "transparent"))
	generate_meshes(sticker_data, "stickers", (style == "stickerless"))

### HELPER FUNCTIONS ###

# assigns a dictionary to faces
func assign_faces():
	var face_names = ["front", "left", "right", "down"]
	var colors = ["green", "red", "blue", "yellow"]
	
	var normals = [FRONT_NORMAL, LEFT_NORMAL, RIGHT_NORMAL, DOWN_NORMAL]
	
	for i in len(face_names):
		faces[face_names[i]] = {"color": colors[i], "normal": normals[i]}

# gets the piece id of all triangles
# based on where it traveled on the given face
func get_piece_ids(ids):
	var new_ids = []
	for id in ids:
		var faces = [id[0], id[2], id[4]]
		var vals = [int(id[1]), int(id[3]), int(id[5])]
		var inds = [faces.find("f"), faces.find("l"), faces.find("r"), faces.find("d")]
		var dirs = [faces[inds[0]], faces[inds[1]], faces[inds[2]]]
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

func triangle_to_readable(triangle):
	pass

func vertex_to_readable(vertex: Vector3):
	pass
