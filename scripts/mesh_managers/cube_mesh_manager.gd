extends MeshManager
class_name CubeMeshManager

### MAIN FUNCTIONS ###

# Builds one face of the mesh
func build_face(mesh_type: String, vectors: Array[Vector3]) -> void:
	var start_point

### HELPER FUNCTIONS ###

# defines all variables specific to the puzzle type
func define_variables() -> void:
	piece_shapes = ["cube"]

# Gets a list of helper vectors for building the given face
func get_helper_vectors(face: String) -> Array[Vector3]:
	var arr: Array[Vector3] = []
	var new_arr: Array[Vector3] = []
	
	for key in faces:
		arr.append(faces[face]["normal"])
	
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
