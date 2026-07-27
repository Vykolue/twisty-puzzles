@abstract
class_name MeshManager

# Mesh objects
var plastic_mesh: MeshInstance3D
var sticker_mesh: MeshInstance3D

# Mesh data
var plastic_mesh_data: Array[Variant]
var sticker_mesh_data: Array[Variant]

# A list of every shape of piece in the mesh
var piece_shapes: Array[String]

# Puzzle specific variables
var faces

var size
var p_scale
var s_scale

### CONSTRUCTOR ###

func _init(args: Dictionary[String, Variant]):
	faces = args["faces"]
	size = args["size"]
	p_scale = args["piece_scale"]
	s_scale = args["sticker_scale"]
	
	define_variables()

### MAIN FUNCTIONS ###

# Generates the mesh of the given type and returns the final mesh object
func generate_meshes(mesh_type: String, hide_mesh: bool) -> MeshInstance3D:
	# declare variables
	var mesh = MeshInstance3D.new()
	var mesh_data: Array[Variant] = []
	
	if mesh_type == "plastic":
		plastic_mesh = mesh
		plastic_mesh_data = mesh_data
	elif mesh_type == "stickers":
		sticker_mesh = mesh
		sticker_mesh_data = mesh_data
	
	var data_dict = faces.duplicate(true)
	
	for face in faces:
		var vectors = get_helper_vectors(face)
		build_face(mesh_type, vectors)
	
	# return the mesh
	mesh.visible = not hide_mesh
	return mesh

# Builds one face of the mesh
@abstract func build_face(mesh_type: String, vectors: Array[Vector3]) -> void

### HELPER FUNCTIONS ###

# Defines all variables specific to the puzzle type
@abstract func define_variables() -> void

# Gets a list of helper vectors for building the given face
@abstract func get_helper_vectors(face: String) -> Array[Vector3]
