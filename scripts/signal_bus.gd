extends Node

# Updates UI and starts the puzzle
signal start(type, size, random_colors, style, piece_scale, sticker_scale)
signal start_ap(args)

# Returns to the home page
signal back()

# Opens the solo option menu
signal prompt_solo_options()

# Opens the archipelago pages
signal prompt_ap_connection()
signal prompt_loading()
signal prompt_ap_options()

# rotates the cube
signal rotate_puzzle(direction)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
