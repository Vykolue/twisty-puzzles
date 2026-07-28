@abstract
class_name MeshManager

# Mesh objects
var plastic_mesh: MeshInstance3D
var sticker_mesh: MeshInstance3D

# Mesh data
var plastic_mesh_data: Array[Variant]
var sticker_mesh_data: Array[Variant]

# Dictionary of ids
var id_dict: Dictionary[String, Variant]

# A list of every shape of piece in the mesh
var piece_shapes: Array[String]

# Puzzle specific variables
var faces
var colors
var color_map

var size
var style
var p_scale
var s_scale
var sticker_float

### CONSTRUCTOR ###

func _init(args: Dictionary[String, Variant]):
	faces = args["faces"]
	colors = args["colors"]
	color_map = args["color_map"]
	size = args["size"]
	style = args["style"]
	p_scale = args["piece_scale"]
	s_scale = args["sticker_scale"]
	sticker_float = args["sticker_float"]
	
	define_variables()

### MAIN FUNCTIONS ###

# Generates the mesh of the given type and returns the final mesh object
func generate_meshes(mesh_type: String, hide_mesh: bool) -> MeshInstance3D:
	# declare variables
	var mesh_data: Array[Variant] = []
	mesh_data.resize(Mesh.ARRAY_MAX)
	var array_mesh = ArrayMesh.new()
	var mesh_instance = MeshInstance3D.new()
	
	if mesh_type == "plastic":
		plastic_mesh = mesh_instance
		plastic_mesh_data = mesh_data
	elif mesh_type == "stickers":
		sticker_mesh = mesh_instance
		sticker_mesh_data = mesh_data
	
	#var data_dict = faces.duplicate(true)
	
	for face in faces:
		var vectors = get_helper_vectors(face)
		build_face(mesh_type, vectors, face, mesh_data)
	
	var mat = StandardMaterial3D.new()
	
	mat.vertex_color_use_as_albedo = true
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	array_mesh.surface_set_material(0, mat)
	mesh_instance.mesh = array_mesh
	
	# return the mesh
	mesh_instance.visible = not hide_mesh
	return mesh_instance

# Builds one face of the mesh
@abstract func build_face(mesh_type: String, vectors: Array[Vector3], face: String, mesh_data: Array[Variant]) -> void

### HELPER FUNCTIONS ###

# Defines all variables specific to the puzzle type
@abstract func define_variables() -> void

# Gets a list of helper vectors for building the given face
@abstract func get_helper_vectors(face: String) -> Array[Vector3]

@abstract func get_id(point: Vector3) -> String
