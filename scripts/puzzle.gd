@abstract
extends Node3D
class_name Puzzle

# The puzzle type and size
@export var type : String
@export var size : int
@export var style : String
@export var piece_scale : float
@export var sticker_scale : float

# A dictionary containing all faces and their corresponding colors and normal vectors
# Syntax should be {String: {"color": String, "normal": Vector3}, ...}
# Face normals should be the unit vector pointing to that face from the origin
@export var faces : Dictionary[String, Variant]

# Contains a list of all valid operations
# Doesn't include wide, prime, double moves, etc.
@export var operations : Array[String]

# Roots each have one child piece and are always centered on the origin
# This is to allow pieces to rotate about the origin rather than their center axis
var roots : Array[Node3D]
var pieces : Array[Node3D]

# mesh oblects
var plastic_mesh_data
var sticker_mesh_data

var plastic_mesh : MeshInstance3D
var sticker_mesh : MeshInstance3D

# dictionary of ids
# each id lists the index of plastic_mesh and sticker_mesh respectively
# that corresponds to a triangle of that mesh in the piece id
# as well as what face the triangle is on
# using "p" as the face for inner plastic portions of the mesh
var id_dict_plastic
var id_dict_stickers

# The color value associated with each face
var colors = {
	"red": Color(0.71, 0.071, 0.071, 1.0), 
	"orange": Color(1.0, 0.407, 0.11, 1.0), 
	"blue": Color(0.211, 0.211, 0.81, 1.0), 
	"green": Color(0.0, 0.76, 0.241, 1.0), 
	"white": Color(1.0, 1.0, 1.0, 1.0), 
	"yellow": Color(1.0, 1.0, 0.20, 1.0),
	"plastic": Color(0.73, 0.73, 0.73, 1.0),
	"unrevealed": Color(0.3, 0.0, 0.8, 1.0)
}
var color_map = {
	"red": "red",
	"orange": "orange",
	"blue": "blue",
	"green": "green",
	"white": "white",
	"yellow": "yellow",
	"plastic": "plastic",
	"unrevealed": "unrevealed"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#SignalBus.rotate_puzzle.connect(rotate_puzzle)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

### MAIN FUNCTIONS ###

# rotates the puzzle
@abstract func rotate_puzzle(dir)

func rotate_pieces(axis : Vector3, ids_to_rotate : Array[String]):
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

func construct(size : int, random_colors : bool, style : String, piece_scale : float, sticker_scale : float) -> Puzzle:
	self.size = size
	self.style = style
	self.piece_scale = piece_scale
	self.sticker_scale = sticker_scale
	
	if random_colors:
		randomize_colors()
	
	if style == "traditional":
		colors[color_map["plastic"]] = Color(0.05, 0.05, 0.05, 1.0)
	else:
		colors[color_map["plastic"]] = Color(0.65, 0.65, 0.65, 1.0)
	
	return self

func construct_ap(args):
	self.size = args["puzzle_size"]
	self.type = args["type"]
	self.color_map = args["color_map"]
	self.style = args["style"]
	self.piece_scale = args["piece_scale"]
	self.sticker_scale = args["sticker_scale"]
	
	color_map["plastic"] = "plastic"
	color_map["unrevealed"] = "unrevealed"
	
	if style == "traditional":
		colors[color_map["plastic"]] = Color(0.05, 0.05, 0.05, 1.0)
	else:
		colors[color_map["plastic"]] = Color(0.65, 0.65, 0.65, 1.0)
	
	return self

### INSTANTIATION FUNCTIONS ###

# Randomizes color layout
@abstract func randomize_colors()

# Generates meshes
# Hides the visibility if specified
func generate_meshes(data, mesh_type, hide_mesh=false):
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

# Sends mesh data to generate_meshes
@abstract func send_mesh_data(style)

### HELPER FUNCTIONS ###

# Determines if a given position is on a given face
# Tolerance is the minimum distance away from the origin the position must be
# to be considered part of that face
func has_face(face : String, pos : Vector3, tolerance : float):
	return true

# Returns the negative of the given vector
func flip_vector(vector : Vector3):
	return Vector3(-vector.x, -vector.y, -vector.z)

# Prints a list of directional constants for convenience
func print_directional_consts():
	print("left: " + str(Vector3.LEFT))
	print("right: " + str(Vector3.RIGHT))
	print("up: " + str(Vector3.UP))
	print("down: " + str(Vector3.DOWN))
	print("\"back\" (F face): " + str(Vector3.BACK))
	print("\"forward\" (B face): " + str(Vector3.FORWARD))

# reformats data from get_piece_ids() into the final dictionary of ids
# get_piece_ids() is defined individually for each puzzle type
func reformat_ids(ids):
	var new_ids = {}
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

func _input(event):
	if event.is_action_pressed("Click"):
		'''
		rotate_pieces(faces["left"]["normal"], ["l0u0f0"])
		'''
		'''
		rotate_pieces(faces["left"]["normal"], ["l0u0f0", "l0u0s0", "l0u0b0", "l0e0f0", "l0e0s0", "l0e0b0", "l0d0f0", "l0d0s0", "l0d0b0"])
		'''
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
		'''
		var p_colors = plastic_mesh_data[Mesh.ARRAY_COLOR]
		var s_colors = sticker_mesh_data[Mesh.ARRAY_COLOR]
		var p_verts = plastic_mesh_data[Mesh.ARRAY_VERTEX]
		var s_verts = sticker_mesh_data[Mesh.ARRAY_VERTEX]
		if style == "stickerless":
			var piece = "l0u0f0"
			for arr in id_dict_plastic[piece]:
				var i = arr[0]
				var f = arr[1]
				#if not f == "p":
				p_colors[i] = colors[color_map["unrevealed"]]
				if f == "p": print("plastic")
				else: print("not plastic")
				print(str(i) + "(" + f + "): " + str(vertex_to_readable(p_verts[i])))
				print()
		else:
			var piece = "l0u0f0"
			for arr in id_dict_stickers[piece]:
				var i = arr[0]
				var f = arr[1]
				s_colors[i] = colors[color_map["unrevealed"]]
				print(str(i) + "(" + f + "): " + str(vertex_to_readable(s_verts[i])))
				print()
		regenerate_mesh(plastic_mesh_data, "plastic")
		regenerate_mesh(sticker_mesh_data, "stickers")
		'''

func regenerate_mesh(mesh_data, mesh_type):
	var arr_mesh = ArrayMesh.new()
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
	
	var mat = StandardMaterial3D.new()
	mat.vertex_color_use_as_albedo = true
	
	arr_mesh.surface_set_material(0, mat)
	
	if mesh_type == "plastic":
		plastic_mesh.mesh = arr_mesh
	if mesh_type == "stickers":
		sticker_mesh.mesh = arr_mesh

@abstract func triangle_to_readable(triangle: Array[Vector3])

@abstract func vertex_to_readable(vertex: Vector3)
