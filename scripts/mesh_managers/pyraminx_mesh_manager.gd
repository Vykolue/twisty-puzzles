extends MeshManager
class_name PyraminxMeshManager

### MAIN FUNCTIONS ###

# Builds one face of the mesh
func build_face(mesh_type: String, vectors: Array[Vector3], face: String, mesh_data: Array[Variant]) -> void:
	pass

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

func get_id(point: Vector3) -> String:
	return ""
