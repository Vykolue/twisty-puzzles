extends Control

# Puzzle type buttons
@onready var cube: Button = $Home/Types/Cube
@onready var pyraminx: Button = $Home/Types/Pyraminx
@onready var megaminx: Button = $Home/Types/Megaminx

# Joke puzzle popup
@onready var popup: Control = $"Home/Popup"

# Connect to archipelago button
@onready var archipelago: Button = $Start_Screen/Buttons/Archipelago

# Settings popup
@onready var settings_popup: Control = $"Home/Options/Popup"

# Advanced settings objects
@onready var advanced_settings: Button = $"Home/Options/Popup/Advanced Settings/Advanced Settings"
@onready var advanced_settings_popup: Control = $"Home/Options/Popup/Advanced Settings/Popup"
@onready var size_input: LineEdit = $"Home/Options/Popup/Advanced Settings/Popup/Size/Size Input"
@onready var toggle_override: CheckButton = $"Home/Options/Popup/Advanced Settings/Popup/Size/Toggle Override"
@onready var piece_label: Label = $"Home/Options/Popup/Advanced Settings/Popup/Piece/Piece Label"
@onready var piece_slider: HSlider = $"Home/Options/Popup/Advanced Settings/Popup/Piece/Piece Slider"
@onready var sticker_label: Label = $"Home/Options/Popup/Advanced Settings/Popup/Sticker/Sticker Label"
@onready var sticker_slider: HSlider = $"Home/Options/Popup/Advanced Settings/Popup/Sticker/Sticker Slider"

# Size editor
@onready var size_label: Label = $"Home/Size/Size Label"
@onready var size_scroll_bar: HScrollBar = $"Home/Size/Size Scroll Bar"

# Archipelago input fields
@onready var host_edit: LineEdit = $"Archipelago/Connection Page/Host/Host Edit"
@onready var port_edit: LineEdit = $"Archipelago/Connection Page/Port/Port Edit"
@onready var slot_edit: LineEdit = $"Archipelago/Connection Page/Slot/Slot Edit"
@onready var password_edit: LineEdit = $"Archipelago/Connection Page/Password/Password Edit"
@onready var submit: Button = $"Archipelago/Connection Page/Submit"

# Available color schemes
'''
const color_schemes = [
	"standard", "random", "rain", "sunset", "galaxy", "candy", 
	"honeycomb", "forest", "ocean", "pastel", "cupid", 
	"greyscale", "camo"
]
'''
const color_schemes = [
	"standard", "random", "rain", "sunset", "galaxy", "candy", 
	"honeycomb", "forest", "ocean"
]

# Default settings values
const default_rand_colors: bool = false
const default_style: String = "traditional"
const default_color_scheme: String = "standard"
const default_type: String = "cube"
const default_size: int = 3
const default_piece_scale: float = 0.95
const default_sticker_scale: float = 0.85

# Tracks the two places size can come from
var size_slider_val: int = default_size
var size_override: int = 10
var use_size_override: bool = false

var used_rand_scheme = false

# Args used to construct the game
var args: Dictionary[String, Variant] = {
	"size": size_slider_val, 
	"style": default_style, 
	"type": default_type, 
	"color_scheme": default_color_scheme,
	"randomize_colors": default_rand_colors, 
	"piece_scale": default_piece_scale, 
	"sticker_scale": default_sticker_scale
}

# archipelago slot data
var host: String = "archipelago.gg"
var port: int = 38281
var slot_name: String = "Player1"
var password: String = ""

### DEFAULT FUNCTIONS ###

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size_scroll_bar.value = size_slider_val
	size_label.text = "Size: " + str(size_slider_val)
	piece_label.text = "Piece Scale: " + str("%.2f" % default_piece_scale)
	sticker_label.text = "Sticker Scale: " + str("%.2f" % default_sticker_scale)
	
	megaminx.disabled = true
	
	popup.visible = false
	settings_popup.visible = false
	advanced_settings_popup.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### PUZZLE TYPES ###

# Cube button
func _on_cube_pressed() -> void:
	args["type"] = "cube"
	
	check_rand_color_scheme()
	
	if args["size"] == 1:
		popup.visible = true
	else:
		SignalBus.start_solo.emit(args)

# Pyraminx button
func _on_pyraminx_pressed() -> void:
	args["type"] = "pyraminx"
	
	check_rand_color_scheme()
	
	if args["size"] <= 2:
		popup.visible = true
	else:
		SignalBus.start_solo.emit(args)

# Megaminx button
func _on_megaminx_pressed() -> void:
	args["type"] = "megaminx"
	
	check_rand_color_scheme()
	
	if args["size"] == 1:
		popup.visible = true
	else:
		SignalBus.start_solo.emit(args)

### POPUP FOR JOKE GAME MODES ###

# Starts the joke puzzle
func _on_popup_yes_pressed() -> void:
	popup.visible = false
	SignalBus.start_solo.emit(args)

# Closes the popup
func _on_popup_no_pressed() -> void:
	popup.visible = false

### NAVIGATION ###

# Back button
func _on_back_pressed() -> void:
	if used_rand_scheme:
		used_rand_scheme = false
		args["color_scheme"] = "random"
	
	SignalBus.back.emit()

# Starts solo mode
func _on_solo_pressed() -> void:
	SignalBus.prompt_solo_options.emit()

# Prompts archipelago connection
func _on_archipelago_pressed() -> void:
	SignalBus.prompt_ap_connection.emit()

### OPTION SETTINGS ###

# Opens additional options menu
func _on_settings_pressed() -> void:
	settings_popup.visible = true

# Closes additional options menu
func _on_settings_close_pressed() -> void:
	settings_popup.visible = false

# Shows slider value
# Can also be used to disable puzzle types based on value
func _on_size_scroll_bar_value_changed(value: float) -> void:
	size_slider_val = int(size_scroll_bar.value)
	size_label.text = "Size: " + str(size_slider_val)
	
	toggle_override.set_pressed_no_signal(false)
	use_size_override = false
	args["size"] = size_slider_val
	
	if size_slider_val <= 2:
		pyraminx.disabled = true
	else:
		pyraminx.disabled = false

# Gets the state of randomize color layout
func _on_random_color_checkbox_toggled(toggled_on: bool) -> void:
	args["randomize_colors"] = toggled_on

# Gets the state of selected style
func _on_style_options_item_selected(index: int) -> void:
	match index:
		0:
			args["style"] = "traditional"
		1:
			args["style"] = "transparent"
		2:
			args["style"] = "stickerless"

# Gets the state of selected color scheme
func _on_color_options_item_selected(index: int) -> void:
	args["color_scheme"] = color_schemes[index]

# Opens a popup to edit advanced settings
func _on_advanced_settings_pressed() -> void:
	advanced_settings_popup.visible = true

# Closes the advanced settings menu
func _on_advanced_close_pressed() -> void:
	advanced_settings_popup.visible = false
	
	if use_size_override and str(size_override) != size_input.text:
		if is_int(size_input.text):
			if int(size_input.text) == get_valid_size(int(size_input.text)):
				size_override = int(size_input.text)
				args["size"] = size_override

# Toggles whether the size should be overridden by the text input
func _on_size_override_toggled(toggled_on: bool) -> void:
	use_size_override = toggled_on
	if toggled_on:
		args["size"] = size_override
		pyraminx.disabled = false
	else:
		args["size"] = size_slider_val
		if size_slider_val <= 2:
			pyraminx.disabled = true

# Verifies the submitted data
func _on_size_input_text_submitted(new_text: String) -> void:
	if is_int(new_text):
		var new_size = int(new_text)
		size_override = get_valid_size(new_size)
		size_input.text = str(get_valid_size(new_size))
	else:
		size_override = 10
		size_input.text = "10"
		#size_input.grab_focus()
		#size_input.select_all()
	
	if use_size_override: args["size"] = size_override

# Updates the piece scale value
# Prevents sticker scale exceeding piece scale
func _on_piece_scale_value_changed(value: float) -> void:
	args["piece_scale"] = value
	piece_label.text = "Piece Scale: " + str("%.2f" % value)
	
	sticker_slider.max_value = args["piece_scale"]
	if args["sticker_scale"] > args["piece_scale"]:
		args["sticker_scale"] = args["piece_scale"]
		sticker_label.text = "Sticker Scale: " + str("%.2f" % args["piece_scale"])
		sticker_slider.value = args["piece_scale"]

# Updates the sticker scale value
func _on_sticker_scale_value_changed(value: float) -> void:
	args["sticker_scale"] = value
	sticker_label.text = "Sticker Scale: " + str("%.2f" % value)

### ARCHIPELAGO CONNECTION DATA ###

# Gets archipelago connection data
func _on_host_edit_text_submitted(new_text: String) -> void:
	host = new_text
	
	host_edit.release_focus()
	port_edit.grab_focus()
	port_edit.select_all()

func _on_port_edit_text_submitted(new_text: String) -> void:
	if is_int(new_text):
		var new_port = int(new_text)
		if not is_valid_port(new_port):
			port = 65535
			port_edit.text = "65535"
			port_edit.grab_focus()
		else:
			port = int(port_edit.text)
			port_edit.release_focus()
			slot_edit.grab_focus()
			slot_edit.select_all()
	else:
		port = 38281
		port_edit.text = "38281"
		port_edit.grab_focus()
		#port_edit.select_all()

func _on_slot_edit_text_submitted(new_text: String) -> void:
	slot_name = new_text
	
	slot_edit.release_focus()
	password_edit.grab_focus()
	password_edit.select_all()

func _on_password_edit_text_submitted(new_text: String) -> void:
	password = new_text
	
	password_edit.release_focus()
	submit.grab_focus()

# Updates these values to the current text, even if the user didn't press enter
func _on_submit_pressed() -> void:
	host = host_edit.text
	if is_int(port_edit.text):
		if is_valid_port(int(port_edit.text)):
			port = int(port_edit.text)
	slot_name = slot_edit.text
	password = password_edit.text

### RESET OPTIONS TO DEFAULT ###

# Resets scale sliders to defaults
func _on_reset_piece_pressed() -> void:
	reset_piece_scale()

func _on_reset_sticker_pressed() -> void:
	reset_sticker_scale()

func reset_piece_scale() -> void:
	args["piece_scale"] = default_piece_scale
	piece_label.text = "Piece Scale: " + str("%.2f" % default_piece_scale)
	piece_slider.value = default_piece_scale

func reset_sticker_scale() -> void:
	args["sticker_scale"] = min(default_sticker_scale, piece_slider.value)
	sticker_label.text = "Sticker Scale: "+ str("%.2f" % min(default_sticker_scale, piece_slider.value))
	sticker_slider.value = min(default_sticker_scale, piece_slider.value)

### HELPER FUNCITONS ###

func is_int(string: String) -> bool:
	for c in string:
		if not (c >= "0" and c <= "9"):
			return false
	return true

func get_valid_size(val: int) -> int:
	if val < 1: return 1
	if val > 20: return 20
	return val

func is_valid_size(val: int) -> bool:
	return val == get_valid_size(val)

func get_valid_port(val: int) -> int:
	if val > 65535: return 65535
	return val

func is_valid_port(val: int) -> bool:
	return val == get_valid_port(val)

func check_rand_color_scheme():
	if args["color_scheme"] == "random":
		used_rand_scheme = true
		var rand_index = randi() % (len(color_schemes) - 1)
		if rand_index >= 1: rand_index += 1
		args["color_scheme"] = color_schemes[rand_index]
