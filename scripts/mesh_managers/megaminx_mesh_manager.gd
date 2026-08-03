extends MeshManager
class_name MegaminxMeshManager

### MAIN FUNCTIONS ###

# Builds one face of the mesh
func build_face(mesh_type: String, vectors: Array[Vector3], relative_faces: Array[String], mesh_data: Array[Variant]) -> void:
	# vectors
	var v1 = vectors[0] # up when working on the front side
	var v2 = vectors[1] # down when working on the front side
	var v3 = vectors[2] # left when working on the front side
	var v4 = vectors[3] # back_right when working on the front side
	var v5 = vectors[4] # right when working on the front side
	var v6 = vectors[5] # back_left when working on the front side
	var v7 = vectors[6] # front when working on the front side
	var v8 = vectors[7] # back when working on the front side
	var v9 = vectors[8] # left_down when working on the front side
	var v10 = vectors[9] # back_up_right when working on the front side
	var v11 = vectors[10] # right_down when working on the front side
	var v12 = vectors[11] # back_up_left when working on the front side
	
	# the name of the face currently being built
	var face = relative_faces[6]
	
	# define vertices on the current face
	var scale_vertices = 0.5
	
	var vertex_1 = (v1 + v7 + v3) * scale_vertices # up left when working on the front side
	var vertex_2 = (v1 + v7 + v5) * scale_vertices # up right when working on the front side
	var vertex_3 = (v7 + v5 + v11) * scale_vertices # right when working on the front side
	var vertex_4 = (v7 + v9 + v11) * scale_vertices # down when working on the front side
	var vertex_5 = (v7 + v3 + v9) * scale_vertices # left when working on the front side
	
	# define variables for mesh building
	var color = colors[color_map[faces[face]["color"]]]
	var plastic_color = colors[color_map["plastic"]]
	var normal = v7
	
	# define which scale to use
	var scale: float
	if mesh_type == "plastic":
		scale = p_scale
	elif mesh_type == "stickers":
		scale = s_scale
	else:
		print("Unexpected mesh type. The supported types are 'plastic' and 'stickers'")
	
	# define adjustment variables
	var p_adjustment = (1.0 - p_scale) / 2.0
	var s_adjustment = (1.0 - s_scale) / 2.0
	
	var sticker_shift = Vector3(0.0, 0.0, 0.0)
	if mesh_type == "stickers":
		sticker_shift = (s_adjustment - p_adjustment + sticker_float) * v7
	
	# find the starting index in the mesh array for this face
	var index
	if mesh_data[Mesh.ARRAY_VERTEX] == null:
		index = 0
		mesh_data[Mesh.ARRAY_VERTEX] = PackedVector3Array()
		mesh_data[Mesh.ARRAY_NORMAL] = PackedVector3Array()
		mesh_data[Mesh.ARRAY_COLOR] = PackedColorArray()
	else:
		index = len(mesh_data[Mesh.ARRAY_VERTEX])
	
	# define corner vertex
	var corner = (vertex_1) * 0.5 * (size - (size % 2))
	
	var corner_adjustment = (vertex_1) * (1.0 - scale) / 2.0
	var scaled_corner = corner - corner_adjustment
	
	var vertices_arr = [
		[vertex_1, vertex_2, vertex_3, vertex_4, vertex_5],
		[vertex_2, vertex_3, vertex_4, vertex_5, vertex_1],
		[vertex_3, vertex_4, vertex_5, vertex_1, vertex_2],
		[vertex_4, vertex_5, vertex_1, vertex_2, vertex_3],
		[vertex_5, vertex_1, vertex_2, vertex_3, vertex_4]
	]
	
	var is_odd_size = size % 2 == 1
	var show_center_color = is_odd_size
	
	# make the pentagon
	var points = []
	var new_size = ceil((size - 1) / 2.0)
	for vertices in vertices_arr:
		var new_corner = (vertices[0]) * 0.5 * (size - (size % 2)) - (vertices[0]) * (1.0 - scale) / 2.0
		var pt = new_corner + ((-vertices[0] + vertices[4]) * new_size / 2.0) + ((-vertices[0] + vertices[1]) * new_size / 2.0) + sticker_shift
		points.append(pt)
	
	
	var indices_to_add = []
	if mesh_type == "plastic":
		indices_to_add = [points[0], points[1], points[2], points[0], points[2], points[3], points[0], points[3], points[4]]
	elif mesh_type == "stickers" and show_center_color:
		indices_to_add = [points[0], points[1], points[2], points[0], points[2], points[3], points[0], points[3], points[4], points[0], points[2], points[1], points[0], points[3], points[2], points[0], points[4], points[3]]
	
	# gets the id of the current piece
	var id = get_id(points[0])
	if not id in id_dict:
		id_dict[id] = {
			"plastic": [],
			"stickers": []
		}
	
	for c in range(0, len(indices_to_add)):
		var i = indices_to_add[c]
		mesh_data[Mesh.ARRAY_VERTEX].append(i)
		mesh_data[Mesh.ARRAY_NORMAL].append(normal)
		if (mesh_type == "plastic" and (not style == "stickerless" or c > 8)) or not show_center_color:
			mesh_data[Mesh.ARRAY_COLOR].append(plastic_color)
		else:
			mesh_data[Mesh.ARRAY_COLOR].append(color)
		id_dict[id][mesh_type].append(index)
		index += 1
	
	# iterate through the five corners of each face to make the rhombuses, triangles, and trapezoids
	for vertices in vertices_arr:
		# starting point
		corner = (vertices[0]) * 0.5 * (size - (size % 2))
		
		corner_adjustment = (vertices[0]) * (1.0 - scale) / 2.0
		scaled_corner = corner - corner_adjustment
		
		for row in new_size:
			var new_corner = (vertices[1]) * 0.5 * (size - (size % 2)) - (vertices[1]) * (1.0 - scale) / 2.0
			var p1 = scaled_corner + (row * (-vertices[0] + vertices[4])) / 2.0 + (new_size * (-vertices[0] + vertices[1])) / 2.0 + sticker_shift
			var p2 = new_corner + (row * (-vertices[1] + vertices[2])) / 2.0 + (new_size * (-vertices[1] + vertices[0])) / 2.0 + sticker_shift
			
			if row == 0:
				p1 = (p1 + p2) / 2
				p2 = p1
			
			var p3 = p1 + ((-vertices[0] + vertices[4]) * scale) / 2.0
			var p4 = p2 + ((-vertices[1] + vertices[2]) * scale) / 2.0
			
			id = get_id(p1)
			if not id in id_dict:
				id_dict[id] = {
					"plastic": [],
					"stickers": []
				}
			
			indices_to_add = []
			if mesh_type == "plastic":
				indices_to_add = [p1, p2, p3, p2, p4, p3, p1, p3, p2, p2, p3, p4]
			elif mesh_type == "stickers" and is_odd_size:
				indices_to_add = [p1, p2, p3, p2, p4, p3, p1, p3, p2, p2, p3, p4]
			
			for c in range(0, len(indices_to_add)):
				var i = indices_to_add[c]
				mesh_data[Mesh.ARRAY_VERTEX].append(i)
				mesh_data[Mesh.ARRAY_NORMAL].append(normal)
				if (mesh_type == "plastic" and (not style == "stickerless" or c > 5)) or not is_odd_size:
					mesh_data[Mesh.ARRAY_COLOR].append(plastic_color)
				else:
					mesh_data[Mesh.ARRAY_COLOR].append(color)
				id_dict[id][mesh_type].append(index)
				index += 1
			
			for col in new_size:
				p1 = scaled_corner + (row * (-vertices[0] + vertices[4])) / 2.0 + (col * (-vertices[0] + vertices[1])) / 2.0 + sticker_shift
				p2 = p1 + ((-vertices[0] + vertices[1]) * scale) / 2.0
				p3 = p1 + ((-vertices[0] + vertices[4]) * scale) / 2.0
				p4 = p1 + ((-vertices[0] + vertices[1]) * scale) / 2.0 + ((-vertices[0] + vertices[4]) * scale) / 2.0
				
				id = get_id(p1)
				if not id in id_dict:
					id_dict[id] = {
						"plastic": [],
						"stickers": []
					}
				
				indices_to_add = []
				if mesh_type == "plastic":
					indices_to_add = [p1, p2, p3, p2, p4, p3]
				elif mesh_type == "stickers":
					indices_to_add = [p1, p2, p3, p2, p4, p3, p1, p3, p2, p2, p3, p4]
				
				for c in range(0, len(indices_to_add)):
					var i = indices_to_add[c]
					mesh_data[Mesh.ARRAY_VERTEX].append(i)
					mesh_data[Mesh.ARRAY_NORMAL].append(normal)
					if mesh_type == "plastic" and (not style == "stickerless" or c > 5):
						mesh_data[Mesh.ARRAY_COLOR].append(plastic_color)
					else:
						mesh_data[Mesh.ARRAY_COLOR].append(color)
					id_dict[id][mesh_type].append(index)
					index += 1

### HELPER FUNCTIONS ###

# Defines all variables specific to the puzzle type
func define_variables() -> void:
	piece_shapes = []

# Gets a list of helper vectors for building the given face
func get_helper_vectors(face: String) -> Array[Vector3]:
	var arr: Array[Vector3] = []
	var new_arr: Array[Vector3] = []
	
	for key in faces:
		arr.append(faces[key]["normal"])
	
	for vector in arr:
		match face:
			"up":
				new_arr.append(vector.rotated(faces["left"]["normal"], deg_to_rad(72)))
			"down":
				new_arr.append(vector.rotated(faces["left_down"]["normal"], deg_to_rad(-144)))
			"left":
				new_arr.append(vector.rotated(faces["up"]["normal"], deg_to_rad(-72)))
			"back_right":
				new_arr.append(vector.rotated(faces["right"]["normal"], deg_to_rad(144)))
			"right":
				new_arr.append(vector.rotated(faces["up"]["normal"], deg_to_rad(72)))
			"back_left":
				new_arr.append(vector.rotated(faces["left"]["normal"], deg_to_rad(-144)))
			"front":
				new_arr.append(vector)
			"back":
				var new_vector = vector.rotated(faces["left_down"]["normal"], deg_to_rad(-72))
				new_arr.append(new_vector.rotated(faces["down"]["normal"], deg_to_rad(-144)))
			"left_down":
				new_arr.append(vector.rotated(faces["left"]["normal"], deg_to_rad(-72)))
			"back_up_right":
				new_arr.append(vector.rotated(faces["up"]["normal"], deg_to_rad(144)))
			"right_down":
				new_arr.append(vector.rotated(faces["right"]["normal"], deg_to_rad(72)))
			"back_up_left":
				new_arr.append(vector.rotated(faces["up"]["normal"], deg_to_rad(-144)))
	
	return new_arr

# Gets a list of where each face is relative to the current face
func switch_faces(face: String) -> Array[String]:
	var relative_faces = [
		"up", "down", "left", "back_right", "right", "back_left", 
		"front", "back", "left_down", "back_up_right", "right_down", "back_up_left"
	]
	match face:
		"up":
			relative_faces = [
				"back_up_left", "right_down", "left", "back_right", "back_up_right", "left_down", 
				"up", "down", "front", "back", "right", "back_left"
			]
		"down":
			relative_faces = [
				"back_right", "left", "right_down", "back_up_left", "back", "front", 
				"down", "up", "left_down", "back_up_right", "back_left", "right"
			]
		"left":
			relative_faces = [
				"up", "down", "back_up_left", "right_down", "front", "back", 
				"left", "back_right", "back_left", "right", "left_down", "back_up_right"
			]
		"back_right":
			relative_faces = [
				"right_down", "back_up_left", "down", "up", "right", "back_left", 
				"back_right", "left", "back", "front", "back_up_right", "left_down"
			]
		"right":
			relative_faces = [
				"up", "down", "front", "back", "back_up_right", "left_down", 
				"right", "back_left", "right_down", "back_up_left", "back_right", "left"
			]
		"back_left":
			relative_faces = [
				"left_down", "back_up_right", "left", "back_right", "down", "up", 
				"back_left", "right", "back_up_left", "right_down", "back", "front"
			]
		"front":
			pass
		"back":
			relative_faces = [
				"back_up_left", "right_down", "back_up_right", "left_down", "back_left", "right", 
				"back", "front", "back_right", "left", "down", "up"
			]
		"left_down":
			relative_faces = [
				"front", "back", "left", "back_right", "right_down", "back_up_left", 
				"left_down", "back_up_right", "back_left", "right", "down", "up"
			]
		"back_up_right":
			relative_faces = [
				"up", "down", "right", "back_left", "back_up_left", "right_down", 
				"back_up_right", "left_down", "back_right", "left", "back", "front"
			]
		"right_down":
			relative_faces = [
				"front", "back", "left_down", "back_up_right", "right", "back_left", 
				"right_down", "back_up_left", "down", "up", "back_right", "left"
			]
		"back_up_left":
			relative_faces = [
				"up", "down", "back_up_right", "left_down", "left", "back_right", 
				"back_up_left", "right_down", "back", "front", "back_left", "right"
			]
	
	return relative_faces

func get_id(point: Vector3) -> String:
	return ""
