class_name Piece

var id: String

var values: Array[int]
var faces: Array[String]

# keys are the name of the face
var plastic: Dictionary[String, Variant]
var stickers

const face_names = [
	"up", "down", "left", "back_right", "right", "back_left", 
	"front", "back", "left_down", "back_up_right", "right_down", "back_up_left"
]
const face_abbr = [
	"u", "d", "l", "br", "r", "bl", "f", "b", "ld", "bur", "rd", "bul"
]

func _init(new_id: String):
	id = new_id
	split_id()

func has(face) -> bool:
	return faces.find(face_to_abbr(face)) != -1

func split_id():
	var on_digit = false
	
	var value_index = 0
	var new_values = []
	var face_index = 0
	faces = []
	for ch in id:
		if is_digit(ch):
			if not on_digit:
				on_digit = true
				face_index += 1
				new_values.append(ch)
			else:
				new_values[value_index] += ch
		else:
			if on_digit:
				on_digit = false
				value_index += 1
				faces.append(ch)
			else:
				faces[face_index] += ch
	
	for i in new_values:
		values.append(int(new_values[i]))

func is_digit(ch: String) -> bool:
	return ord(ch) >= ord("0") and ord(ch) <= ord("9")

func face_to_abbr(face: String):
	return face_abbr[face_names.find(face)]

func abbr_to_face(abbr: String):
	return face_names[face_abbr.find(abbr)]
