@abstract
class_name MeshManager

# puzzle variables
var faces
var colors
var color_map

var plastic_mesh_data
var sticker_mesh_data

var plastic_mesh
var sticker_mesh

# mesh data
var outer_plastic_data
var inner_plastic_data
var sticker_data

# piece ids
var outer_plastic_ids = []
var inner_plastic_ids = []
var sticker_ids = []

# scales the puzzle based on size while remaining centered on the origin
var scale_by_size
var idk_scales

# scale the pieces so there is a gap between
var adjustment
	
# scale the stickers to not take up the entire surface
# value should be less than piece_scale
var s_adjustment

# piece types
var piece_types

### DEFAULT FUNCTIONS ###

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### CONSTRUCTOR ###

func construct():
	pass

### MAIN FUNCTIONS ###

# Sends mesh data to generate_meshes
@abstract func send_mesh_data() -> void

# Generates meshes
# Hides the visibility if specified
func generate_meshes(data: Dictionary[String, Variant], mesh_type: String, hide_mesh: bool = false) -> MeshInstance3D:
	var array_mesh = ArrayMesh.new()
	var mesh_data = []
	mesh_data.resize(Mesh.ARRAY_MAX)
	
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var color_array = PackedColorArray()
	
	var mat = StandardMaterial3D.new()
	
	for face in data:
		for triangle in data[face]["triangles"]:
			for vertex in triangle:
				vertices.append(vertex)
				normals.append(data[face]["normal"])
				color_array.append(colors[color_map[data[face]["color"]]])
	
	mesh_data[Mesh.ARRAY_VERTEX] = vertices
	mesh_data[Mesh.ARRAY_NORMAL] = normals
	mesh_data[Mesh.ARRAY_COLOR] = color_array
	
	mat.vertex_color_use_as_albedo = true
	
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	array_mesh.surface_set_material(0, mat)
	var shape = MeshInstance3D.new()
	shape.mesh = array_mesh
	
	shape.visible = not hide_mesh
	
	if mesh_type == "plastic":
		plastic_mesh_data = mesh_data
		plastic_mesh = shape
	elif mesh_type == "stickers":
		sticker_mesh_data = mesh_data
		sticker_mesh = shape
	
	return shape

# Regenerates the given mesh type using the new mesh data
func regenerate_mesh(mesh_data: Array[Variant], mesh_type: String) -> void:
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	
	arr_mesh.surface_set_material(0, mat)
	
	if mesh_type == "plastic":
		plastic_mesh.mesh = arr_mesh
	if mesh_type == "stickers":
		sticker_mesh.mesh = arr_mesh
