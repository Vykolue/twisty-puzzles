extends MeshManager
class_name MegaminxMeshManager

### MAIN FUNCTIONS ###

# Builds one face of the mesh
func build_face(mesh_type: String, vectors: Array[Vector3]) -> void:
	pass

### HELPER FUNCTIONS ###

# defines all variables specific to the puzzle type
func define_variables() -> void:
	piece_shapes = []

# Gets a list of helper vectors for building the given face
func get_helper_vectors(face: String) -> Array[Vector3]:
	var arr: Array[Vector3] = []
	var new_arr: Array[Vector3] = []
	
	for key in faces:
		arr.append(faces[face]["normal"])
	
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
