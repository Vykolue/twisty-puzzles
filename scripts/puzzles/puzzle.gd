@abstract
extends Node3D
class_name Puzzle

# The puzzle option variables
@export var type: String
@export var size: int
@export var style: String
@export var color_scheme: String
@export var piece_scale: float
@export var sticker_scale: float
@export var sticker_float: float

# A dictionary containing all faces and their corresponding colors and normal vectors
# Syntax should be {String: {"color": String, "normal": Vector3}, ...}
# Face normals should be the unit vector pointing towards that face from the origin
@export var faces: Dictionary[String, Variant]

# Contains a list of all valid operations
# Doesn't include wide, prime, double moves, etc.
@export var operations: Array[String]

# Mesh data
var plastic_mesh_data: Array[Variant]
var sticker_mesh_data: Array[Variant]

# Mesh objects
var plastic_mesh: MeshInstance3D
var sticker_mesh: MeshInstance3D

# Dictionary of ids
# Each id lists the index of plastic_mesh_data and sticker_mesh_data respectively
# that corresponds to a triangle of that mesh in the piece
# as well as what face the triangle is on
# using "p" as the face for inner plastic portions of the mesh
var id_dict_plastic: Dictionary[String, Variant]
var id_dict_stickers: Dictionary[String, Variant]

# The color value associated with that color
@export var colors: Dictionary[String, Color] = {
	"red": Color(0.71, 0.071, 0.071, 1.0), 
	"orange": Color(1.0, 0.407, 0.11, 1.0), 
	"blue": Color(0.211, 0.211, 0.81, 1.0), 
	"green": Color(0.0, 0.76, 0.241, 1.0), 
	"white": Color(1.0, 1.0, 1.0, 1.0), 
	"yellow": Color(1.0, 1.0, 0.20, 1.0),
	"plastic": Color(0.73, 0.73, 0.73, 1.0),
	"unrevealed": Color(0.3, 0.0, 0.8, 1.0)
}

# Stores the color values associated with each color scheme
const COLOR_SCHEME_JSON = "res://resources/color_schemes.json"

# Which face each color is mapped to
var color_map: Dictionary[String, String] = {
	"red": "red",
	"orange": "orange",
	"blue": "blue",
	"green": "green",
	"white": "white",
	"yellow": "yellow",
	"plastic": "plastic",
	"unrevealed": "unrevealed"
}

var mesh_manager: MeshManager

### DEFAULT FUNCTIONS ###

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### OPERATION FUNCTIONS ###

# Rotates the given pieces about the given axis
func rotate_pieces(axis: Vector3, ids_to_rotate: Array[String]) -> void:
	var p_vertices = plastic_mesh_data[Mesh.ARRAY_VERTEX]
	var s_vertices = sticker_mesh_data[Mesh.ARRAY_VERTEX]
	for piece in ids_to_rotate:
		for arr in id_dict_plastic[piece]:
			var i = arr[0]
			p_vertices[i] = p_vertices[i].rotated(axis, PI / 2.0)
			regenerate_mesh(plastic_mesh_data, "plastic")
		for arr in id_dict_stickers[piece]:
			var i = arr[0]
			s_vertices[i] = s_vertices[i].rotated(axis, PI / 2.0)
			regenerate_mesh(sticker_mesh_data, "stickers")

### CONSTRUCTOR ###

# Constructs a game with the given arguments
func construct(args: Dictionary[String, Variant]) -> Puzzle:
	size = args["size"]
	type = args["type"]
	style = args["style"]
	color_scheme = args["color_scheme"]
	piece_scale = args["piece_scale"]
	sticker_scale = args["sticker_scale"]
	sticker_float = 0.01
	args["sticker_float"] = sticker_float
	
	if args["game_mode"] == "solo" and args["randomize_colors"]:
		randomize_colors()
	if args["game_mode"] == "ap":
		color_map = args["color_map"]
	
	color_map["plastic"] = "plastic"
	color_map["unrevealed"] = "unrevealed"
	
	update_color_scheme(args["color_scheme"])
	
	if style == "traditional":
		colors[color_map["plastic"]] = Color(0.05, 0.05, 0.05, 1.0)
	else:
		colors[color_map["plastic"]] = Color(0.65, 0.65, 0.65, 1.0)
	
	assign_faces()
	
	args["faces"] = faces
	args["colors"] = colors
	args["color_map"] = color_map
	
	if args["type"] == "cube":
		mesh_manager = CubeMeshManager.new(args)
	if args["type"] == "pyraminx":
		mesh_manager = PyraminxMeshManager.new(args)
	if args["type"] == "megaminx":
		mesh_manager = MegaminxMeshManager.new(args)
	
	plastic_mesh = mesh_manager.generate_meshes("plastic", (style == "transparent"))
	add_child(plastic_mesh)
	sticker_mesh = mesh_manager.generate_meshes("stickers", (style == "stickerless"))
	add_child(sticker_mesh)
	
	#send_mesh_data()
	
	return self

### INSTANTIATION FUNCTIONS ###

# Assigns a dictionary to faces
@abstract func assign_faces() -> void

# Randomizes color layout
@abstract func randomize_colors() -> void

### MESH GENERATION ###

# Sends mesh data to generate_meshes
@abstract func send_mesh_data() -> void

# Generates meshes
# Hides the visibility if specified
func generate_meshes(data: Dictionary[String, Variant], mesh_type: String, hide_mesh: bool = false) -> void:
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
	
	add_child(shape)
	
	if mesh_type == "plastic":
		plastic_mesh_data = mesh_data
		plastic_mesh = shape
	elif mesh_type == "stickers":
		sticker_mesh_data = mesh_data
		sticker_mesh = shape

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

# Prints a list of directional constants for convenience
func print_directional_consts() -> void:
	print("left: " + str(Vector3.LEFT))
	print("right: " + str(Vector3.RIGHT))
	print("up: " + str(Vector3.UP))
	print("down: " + str(Vector3.DOWN))
	print("\"back\" (F face): " + str(Vector3.BACK))
	print("\"forward\" (B face): " + str(Vector3.FORWARD))

func update_color_scheme(scheme: String) -> void:
	var file = FileAccess.open(COLOR_SCHEME_JSON, FileAccess.READ)
	var json_string = file.get_as_text()
	var data = JSON.parse_string(json_string)
	
	var new_hex_colors = data[scheme]
	for color in new_hex_colors:
		colors[color] = Color.html(new_hex_colors[color])

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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Click"):
		'''
		var p_colors = plastic_mesh_data[Mesh.ARRAY_COLOR]
		var s_colors = sticker_mesh_data[Mesh.ARRAY_COLOR]
		if style == "stickerless":
			for piece in id_dict_plastic:
				for arr in id_dict_plastic[piece]:
					var i = arr[0]
					var f = arr[1]
					if not f == "p":
						p_colors[i] = colors[color_map["unrevealed"]]
		else:
			for piece in id_dict_stickers:
				for arr in id_dict_stickers[piece]:
					var i = arr[0]
					s_colors[i] = colors[color_map["unrevealed"]]
		regenerate_mesh(plastic_mesh_data, "plastic")
		regenerate_mesh(sticker_mesh_data, "stickers")
		'''
