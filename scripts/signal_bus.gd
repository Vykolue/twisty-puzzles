extends Node

### GLOBAL SIGNALS ###

# Updates UI and starts the puzzle
signal start_solo(args: Dictionary[String, Variant])
signal start_ap(args: Dictionary[String, Variant])

# Returns to the home page
signal back()

# Opens the solo option menu
signal prompt_solo_options()

# Opens the archipelago pages
signal prompt_ap_connection()
signal prompt_loading()
signal prompt_ap_options()

### DEFAULT FUNCTIONS ###

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
