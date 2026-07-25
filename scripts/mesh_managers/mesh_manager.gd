@abstract
class_name MeshManager

# puzzle variables
var size
var style
var faces
var colors
var color_map

var piece_scale
var sticker_scale

var sticker_float

var plastic_mesh_data
var sticker_mesh_data

var plastic_mesh
var sticker_mesh

# mesh data
var outer_plastic_data
var inner_plastic_data
var sticker_data

# piece ids
var id_dict_plastic
var id_dict_stickers

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

func _init(args):
	size = args["size"]
	style = args["style"]
	faces = args["faces"]
	colors = args["colors"]
	color_map = args["color_map"]
	piece_scale = args["piece_scale"]
	sticker_scale = args["sticker_scale"]
	sticker_float = args["sticker_float"]
	
	adjustment = (1.0 - piece_scale) / 2.0
	s_adjustment = (1.0 - sticker_scale) / 2.0
	
	set_scales()

### MAIN FUNCTIONS ###

# Sends mesh data to generate_meshes
#@abstract func send_mesh_data() -> void

# Retrieves mesh data for generate_meshes
@abstract func retrieve_mesh_data(mesh_type: String) -> Dictionary[String, Variant]

# Generates meshes
# Hides the visibility if specified
func generate_meshes(mesh_type: String, hide_mesh: bool = false) -> MeshInstance3D:
	var data: Dictionary[String, Variant] = retrieve_mesh_data(mesh_type)
	
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

### HELPER FUNCTIONS ###

# Gets the piece id of each triangle in the mesh
@abstract func get_piece_ids(ids: Array[String]) -> Array[Variant]

# Reformats data from get_piece_ids() into the final dictionary of ids
func reformat_ids(ids) -> Dictionary[String, Variant]:
	var new_ids: Dictionary[String, Variant] = {}
	for i in range(0, len(ids)):
		var arr = ids[i]
		var id = arr[0]
		var face = arr[1]
		if not id in new_ids:
			new_ids[id] = [[i, face]]
		else:
			new_ids[id].append([i, face])
	
	'''
	for key in new_ids:
		print (key + ": ")
		for val in new_ids[key]:
			print("   " + str(val))
		print()
	'''
	
	return new_ids

@abstract func set_scales()
