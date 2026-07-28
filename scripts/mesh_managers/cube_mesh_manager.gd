extends MeshManager
class_name CubeMeshManager

### MAIN FUNCTIONS ###

# Builds one face of the mesh
func build_face(mesh_type: String, vectors: Array[Vector3], face: String, mesh_data: Array[Variant]) -> void:
	# vectors
	var v1 = vectors[0] # up when working on the front side
	var v2 = vectors[1] # down when working on the front side
	var v3 = vectors[2] # left when working on the front side
	var v4 = vectors[3] # right when working on the front side
	var v5 = vectors[4] # front when working on the front side
	var v6 = vectors[5] # back when working on the front side
	
	var color = colors[color_map[faces[face]["color"]]]
	var plastic_color = colors[color_map["plastic"]]
	var normal = v5
	
	var scale: float
	if mesh_type == "plastic":
		scale = p_scale
	elif mesh_type == "stickers":
		scale = s_scale
	else:
		print("Unexpected mesh type. The supported types are 'plastic' and 'stickers'")
	
	var p_adjustment = (1.0 - p_scale) / 2.0
	var s_adjustment = (1.0 - s_scale) / 2.0
	
	# starting point
	var corner = (v5 + v3 + v1) * 0.5 * size
	
	var corner_adjustment = (v5 + v3 + v1) * (1.0 - scale) / 2.0
	var scaled_corner = corner - corner_adjustment
	
	var index
	if mesh_data[Mesh.ARRAY_VERTEX] == null:
		index = 0
		mesh_data[Mesh.ARRAY_VERTEX] = PackedVector3Array()
		mesh_data[Mesh.ARRAY_NORMAL] = PackedVector3Array()
		mesh_data[Mesh.ARRAY_COLOR] = PackedColorArray()
	else:
		index = len(mesh_data[Mesh.ARRAY_VERTEX])
	
	for row in size:
		for col in size:
			var sticker_shift = Vector3(0.0, 0.0, 0.0)
			if mesh_type == "stickers":
				sticker_shift = (s_adjustment - p_adjustment + sticker_float) * v5
			
			var p1 = scaled_corner + (row * v2) + (col * v4) + sticker_shift
			var p2 = p1 + (v4 * scale)
			var p3 = p1 + (v2 * scale)
			var p4 = p1 + (v4 * scale) + (v2 * scale)
			
			var id = get_id(p1)
			if not id in id_dict:
				id_dict[id] = {
					"plastic": [],
					"stickers": []
				}
			
			var indices_to_add = []
			if mesh_type == "plastic":
				for slice in size:
					var new_p1 = p1 + (v6 * slice)
					var new_p2 = p2 + (v6 * slice)
					var new_p3 = p3 + (v6 * slice)
					var new_p4 = p4 + (v6 * slice)
					
					indices_to_add.append(new_p1)
					indices_to_add.append(new_p2)
					indices_to_add.append(new_p3)
					indices_to_add.append(new_p2)
					indices_to_add.append(new_p4)
					indices_to_add.append(new_p3)
				
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
	piece_shapes = ["cube"]

# Gets a list of helper vectors for building the given face
func get_helper_vectors(face: String) -> Array[Vector3]:
	var arr: Array[Vector3] = []
	var new_arr: Array[Vector3] = []
	
	for key in faces:
		arr.append(faces[key]["normal"])
	
	for vector in arr:
		match face:
			"up":
				new_arr.append(vector.rotated(faces["right"]["normal"], deg_to_rad(-90)))
			"down":
				new_arr.append(vector.rotated(faces["right"]["normal"], deg_to_rad(90)))
			"left":
				new_arr.append(vector.rotated(faces["up"]["normal"], deg_to_rad(-90)))
			"right":
				new_arr.append(vector.rotated(faces["up"]["normal"], deg_to_rad(90)))
			"front":
				new_arr.append(vector)
			"back":
				new_arr.append(vector.rotated(faces["up"]["normal"], deg_to_rad(180)))
	
	return new_arr

func get_id(point: Vector3) -> String:
	return ""
