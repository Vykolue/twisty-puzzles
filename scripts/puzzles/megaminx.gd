extends Puzzle

const PHI = (1.0 + sqrt(5.0)) / 2.0

var UP_NORMAL: Vector3
var DOWN_NORMAL: Vector3
var LEFT_NORMAL: Vector3
var BACK_RIGHT_NORMAL: Vector3
var RIGHT_NORMAL: Vector3
var BACK_LEFT_NORMAL: Vector3
var FRONT_NORMAL: Vector3
var BACK_NORMAL: Vector3
var LEFT_DOWN_NORMAL: Vector3
var BACK_UP_RIGHT_NORMAL: Vector3
var RIGHT_DOWN_NORMAL: Vector3
var BACK_UP_LEFT_NORMAL: Vector3


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# define variables
	operations = ["up", "right", "left", "front", "rdown", "ldown"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### MAIN FUNCTIONS ###

### INSTANTIATION FUNCTIONS ###

# randomizes the color layout
func randomize_colors():
	var new_colors = color_map.duplicate(true)
	var options = [
		"white", "grey", "yellow", "tan", "green", "lime", 
		"purple", "pink", "orange", "red", "sky_blue", "blue"
	]
	
	var colors_to_place = [
		"white", "grey", "yellow", "tan", "green", "lime", 
		"purple", "pink", "orange", "red", "sky_blue", "blue"
	]
	for color in colors_to_place:
		var rand_index = randi() % len(options)
		new_colors[color] = options.pop_at(rand_index)
	color_map = new_colors

### HELPER FUNCTIONS ###

# assigns a dictionary to faces
func assign_faces():
	assign_normals()
	
	var face_names = [
				"up", "down", "left", "back_right", "right", "back_left", 
				"front", "back", "left_down", "back_up_right", "right_down", "back_up_left"
			]
	var color_names = [
		"white", "grey", "yellow", "tan", "green", "lime", 
		"purple", "pink", "orange", "red", "sky_blue", "blue"
	]
	
	var normals = [
		UP_NORMAL, DOWN_NORMAL, LEFT_NORMAL, BACK_RIGHT_NORMAL, 
		RIGHT_NORMAL, BACK_LEFT_NORMAL, FRONT_NORMAL, BACK_NORMAL, 
		LEFT_DOWN_NORMAL, BACK_UP_RIGHT_NORMAL, RIGHT_DOWN_NORMAL, BACK_UP_LEFT_NORMAL
	]
	
	for i in len(face_names):
		faces[face_names[i]] = {"color": color_names[i], "normal": normals[i]}

func assign_normals():
	var a = Vector3(0.0, 1.0 / PHI, PHI)
	var b = Vector3(1.0, 1.0, 1.0)
	var c = Vector3(0, -1.0 / PHI, PHI)
	var d = Vector3(PHI, 0.0, 1.0 / PHI)
	var e = Vector3(1.0, -1.0, 1.0)
	var f = Vector3(-1.0, 1.0, 1.0)
	var g = Vector3(1.0 / PHI, PHI, 0.0)
	var h = Vector3(-1.0 / PHI, PHI, 0.0)
	var i = Vector3(-PHI, 0.0, 1.0 / PHI)
	var j = Vector3(1.0, 1.0, -1.0)
	var k = Vector3(-1.0, -1.0, 1.0)
	var l = Vector3(PHI, 0.0, -1.0 / PHI)
	var m = Vector3(-1.0 / PHI, -PHI, 0.0)
	var n = Vector3(1.0, -1.0, -1.0)
	var o = Vector3(-1.0, 1.0, -1.0)
	var p = Vector3(-PHI, 0.0, -1.0 / PHI)
	var q = Vector3(0.0, 1.0 / PHI, -PHI)
	var r = Vector3(-1.0, -1.0, -1.0)
	var s = Vector3(0.0, -1.0 / PHI, -PHI)
	var t = Vector3(1.0 / PHI, -PHI, 0.0)
	
	FRONT_NORMAL = (a + b + d + e + c).normalized()
	UP_NORMAL = (a + f + h + g + b).normalized()
	LEFT_NORMAL = (a + c + k + i + f).normalized()
	RIGHT_NORMAL = (b + g + j + l + d).normalized()
	BACK_LEFT_NORMAL = (p + i + k + m + r).normalized()
	BACK_RIGHT_NORMAL = (j + q + s + n + l).normalized()
	LEFT_DOWN_NORMAL = (c + e + t + m + k).normalized()
	RIGHT_DOWN_NORMAL = (d + l + n + t + e).normalized()
	DOWN_NORMAL = (t + n + s + r + m).normalized()
	BACK_NORMAL = (o + p + r + s + q).normalized()
	BACK_UP_RIGHT_NORMAL = (g + h + o + q + j).normalized()
	BACK_UP_LEFT_NORMAL = (f + i + p + o + h).normalized()

func get_piece_ids(ids):
	return ids
