extends MeshManager
class_name PyraminxMeshManager

### MAIN FUNCTIONS ###

# Builds one face of the mesh
func build_face(mesh_type: String, vectors: Array[Vector3], relative_faces: Array[String], mesh_data: Array[Variant]) -> void:
	# vectors
	var v1 = vectors[0] # front when working on the front side
	var v2 = vectors[1] # left normal when working on the front side
	var v3 = vectors[2] # right normal when working on the front side
	var v4 = vectors[3] # down when working on the front side
	
	# the name of the face currently being built
	var face = relative_faces[0]
	
	var color = colors[color_map[faces[face]["color"]]]
	var plastic_color = colors[color_map["plastic"]]
	var normal = v1
	
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
	var corner = (-v4) * size
	
	var corner_adjustment_float = (1.0 - scale) / 2.0
	var corner_adjustment_vector = (-v4) * corner_adjustment_float # may need to use a combination of -v1, -v2, and -v3??
	var scaled_corner = corner - corner_adjustment_vector
	
	var index
	if mesh_data[Mesh.ARRAY_VERTEX] == null:
		index = 0
		mesh_data[Mesh.ARRAY_VERTEX] = PackedVector3Array()
		mesh_data[Mesh.ARRAY_NORMAL] = PackedVector3Array()
		mesh_data[Mesh.ARRAY_COLOR] = PackedColorArray()
	else:
		index = len(mesh_data[Mesh.ARRAY_VERTEX])
	
	for row in size:
		for col in range(0, row+1):
			var sticker_shift = Vector3(0.0, 0.0, 0.0)
			if mesh_type == "stickers":
				sticker_shift = (s_adjustment - p_adjustment + sticker_float) * v1
			
			var p1 = scaled_corner + (row * (v4 + -v3)) + (col * (v3 + -v2)) + sticker_shift
			var p2 = p1 + ((v4 + -v2) * scale)
			var p3 = p1 + ((v4 + -v3) * scale)
			
			var id = get_id(p1)
			if not id in id_dict:
				id_dict[id] = {
					"plastic": [],
					"stickers": []
				}
			
			var indices_to_add = []
			if mesh_type == "plastic":
				for slice in size:
					if row < size - slice:
						var new_p1 = p1 + ((v4 + -v1) * slice)
						var new_p2 = p2 + ((v4 + -v1) * slice)
						var new_p3 = p3 + ((v4 + -v1) * slice)
						
						indices_to_add.append(new_p1)
						indices_to_add.append(new_p2)
						indices_to_add.append(new_p3)
				
			elif mesh_type == "stickers":
				indices_to_add = [p1, p2, p3, p1, p3, p2]
			
			for c in range(0, len(indices_to_add)):
				var i = indices_to_add[c]
				mesh_data[Mesh.ARRAY_VERTEX].append(i)
				mesh_data[Mesh.ARRAY_NORMAL].append(normal)
				if mesh_type == "plastic" and (not style == "stickerless" or c > 2):
					mesh_data[Mesh.ARRAY_COLOR].append(plastic_color)
				else:
					mesh_data[Mesh.ARRAY_COLOR].append(color)
				id_dict[id][mesh_type].append(index)
				index += 1
			
			# build octahedron pieces
			var oct_norm = ((v3 + -v1) + (v4 + -v2)).normalized()
			if col < row:
				p1 = (corner - (corner_adjustment_float * oct_norm)) + (row * (v4 + -v3)) + (col * (v3 + -v2)) + sticker_shift
				p2 = p1 + ((v3 + -v2) * scale)
				p3 = p1 + ((v4 + -v2) * scale)
				
				id = get_id(p1)
				if not id in id_dict:
					id_dict[id] = {
						"plastic": [],
						"stickers": []
					}
				
				indices_to_add = []
				if mesh_type == "plastic":
					for slice in size:
						if row < size - slice:
							var new_p1 = p1 + ((v4 + -v1) * slice)
							var new_p2 = p2 + ((v4 + -v1) * slice)
							var new_p3 = p3 + ((v4 + -v1) * slice)
							
							indices_to_add.append(new_p1)
							indices_to_add.append(new_p2)
							indices_to_add.append(new_p3)
					
				elif mesh_type == "stickers":
					indices_to_add = [p1, p2, p3, p1, p3, p2]
				
				for c in range(0, len(indices_to_add)):
					var i = indices_to_add[c]
					mesh_data[Mesh.ARRAY_VERTEX].append(i)
					mesh_data[Mesh.ARRAY_NORMAL].append(normal)
					if mesh_type == "plastic" and (not style == "stickerless" or c > 2):
						mesh_data[Mesh.ARRAY_COLOR].append(plastic_color)
					else:
						mesh_data[Mesh.ARRAY_COLOR].append(color)
					id_dict[id][mesh_type].append(index)
					index += 1

### HELPER FUNCTIONS ###

# Defines all variables specific to the puzzle type
func define_variables() -> void:
	piece_shapes = ["tetrahedron", "octahedron"]

# Gets a list of helper vectors for building the given face
func get_helper_vectors(face: String) -> Array[Vector3]:
	var arr: Array[Vector3] = []
	var new_arr: Array[Vector3] = []
	
	for key in faces:
		arr.append(faces[key]["normal"])
	
	for vector in arr:
		match face:
			"down":
				new_arr.append(vector.rotated(faces["left"]["normal"], deg_to_rad(-120)))
			"left":
				new_arr.append(vector.rotated(faces["down"]["normal"], deg_to_rad(120)))
			"right":
				new_arr.append(vector.rotated(faces["down"]["normal"], deg_to_rad(-120)))
			"front":
				new_arr.append(vector)
	
	return new_arr

# Gets a list of where each face is relative to the current face
func switch_faces(face: String) -> Array[String]:
	var relative_faces: Array[String] = ["front", "left", "right", "down"]
	match face:
		"front":
			pass
		"left":
			relative_faces = ["left", "right", "front", "down"]
		"right":
			relative_faces = ["right", "front", "left", "down"]
		"down":
			relative_faces = ["down", "left", "front", "right"]
	
	return relative_faces

func get_id(point: Vector3) -> String:
	return ""
