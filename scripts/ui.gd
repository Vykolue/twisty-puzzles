extends Control

@onready var size_label: Label = $"Home/Size/Size Label"
@onready var size_scroll_bar: HScrollBar = $"Home/Size/Size Scroll Bar"

@onready var cube: Button = $Home/Types/Cube
@onready var pyraminx: Button = $Home/Types/Pyraminx
@onready var megaminx: Button = $Home/Types/Megaminx

@onready var popup: Control = $"Home/Popup"

@onready var archipelago: Button = $Start_Screen/Buttons/Archipelago

@onready var advanced_settings: Button = $"Home/Advanced Settings/Advanced Settings"
@onready var settings_popup: Control = $"Home/Advanced Settings/Popup"
@onready var size_input: LineEdit = $"Home/Advanced Settings/Popup/Size/Size Input"
@onready var toggle_override: CheckButton = $"Home/Advanced Settings/Popup/Size/Toggle Override"
@onready var piece_label: Label = $"Home/Advanced Settings/Popup/Piece/Piece Label"
@onready var piece_slider: HSlider = $"Home/Advanced Settings/Popup/Piece/Piece Slider"
@onready var sticker_label: Label = $"Home/Advanced Settings/Popup/Sticker/Sticker Label"
@onready var sticker_slider: HSlider = $"Home/Advanced Settings/Popup/Sticker/Sticker Slider"

@onready var host_edit: LineEdit = $"Archipelago/Connection Page/Host/Host Edit"
@onready var port_edit: LineEdit = $"Archipelago/Connection Page/Port/Port Edit"
@onready var slot_edit: LineEdit = $"Archipelago/Connection Page/Slot/Slot Edit"
@onready var password_edit: LineEdit = $"Archipelago/Connection Page/Password/Password Edit"
@onready var submit: Button = $"Archipelago/Connection Page/Submit"

var randomize_color_layout = false
var style = "traditional"
var p_size = 3
var puzzle_type = ""
const default_piece_scale = 0.95
var piece_scale = default_piece_scale
const default_sticker_scale = 0.85
var sticker_scale = default_sticker_scale
var use_size_override = false
var size_override = 10
var use_size = 3

var host = "archipelago.gg"
var port = 38281
var slot_name = "Player1"
var password = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	p_size = int(size_scroll_bar.value)
	size_label.text = "Size: " + str(p_size)
	piece_label.text = "Piece Scale: " + str("%.2f" % default_piece_scale)
	sticker_label.text = "Sticker Scale: " + str("%.2f" % default_sticker_scale)
	
	megaminx.disabled = true
	#submit.disabled = true
	
	popup.visible = false
	settings_popup.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Cube button
func _on_cube_pressed() -> void:
	if use_size == 1:
		puzzle_type = "cube"
		popup.visible = true
	else:
		SignalBus.start.emit("cube", use_size, randomize_color_layout, style, piece_scale, sticker_scale)

# Pyraminx button
func _on_pyraminx_pressed() -> void:
	if use_size <= 2:
		puzzle_type = "pyraminx"
		popup.visible = true
	else:
		SignalBus.start.emit("pyraminx", use_size, randomize_color_layout, style, piece_scale, sticker_scale)

# Megaminx button
func _on_megaminx_pressed() -> void:
	if use_size == 1:
		puzzle_type = "megaminx"
		popup.visible = true
	else:
		SignalBus.start.emit("megaminx", use_size, randomize_color_layout, style, piece_scale, sticker_scale)

# Back button
func _on_back_pressed() -> void:
	SignalBus.back.emit()
	#reset_piece_scale()
	#reset_sticker_scale()

# Shows slider value
# Can also be used to disable puzzle types based on value
func _on_size_scroll_bar_value_changed(value: float) -> void:
	p_size = int(size_scroll_bar.value)
	size_label.text = "Size: " + str(p_size)
	
	toggle_override.set_pressed_no_signal(false)
	use_size_override = false
	use_size = p_size
	
	if p_size == 2:
		pyraminx.disabled = true
	else:
		pyraminx.disabled = false

# Gets the state of randomize color layout
func _on_random_color_checkbox_toggled(toggled_on: bool) -> void:
	randomize_color_layout = toggled_on

# Gets the state of selected style
func _on_style_options_item_selected(index: int) -> void:
	match index:
		0:
			style = "traditional"
		1:
			style = "transparent"
		2:
			style = "stickerless"

# Starts the joke puzzle
func _on_popup_yes_pressed() -> void:
	popup.visible = false
	SignalBus.start.emit(puzzle_type, use_size, randomize_color_layout, style, piece_scale, sticker_scale)

# Closes the popup
func _on_popup_no_pressed() -> void:
	popup.visible = false

### ROTATION BUTTONS ###

func _on_rotate_1_pressed() -> void:
	SignalBus.rotate_puzzle.emit("z")

func _on_rotate_2_pressed() -> void:
	SignalBus.rotate_puzzle.emit("x'")

func _on_rotate_3_pressed() -> void:
	SignalBus.rotate_puzzle.emit("y")

func _on_rotate_4_pressed() -> void:
	SignalBus.rotate_puzzle.emit("y'")

func _on_rotate_5_pressed() -> void:
	SignalBus.rotate_puzzle.emit("z'")

func _on_rotate_6_pressed() -> void:
	SignalBus.rotate_puzzle.emit("x")

# Starts solo mode
func _on_solo_pressed() -> void:
	SignalBus.prompt_solo_options.emit()

# Prompts archipelago connection
func _on_archipelago_pressed() -> void:
	SignalBus.prompt_ap_connection.emit()

# Opens a popup to edit advanced settings
func _on_advanced_settings_pressed() -> void:
	settings_popup.visible = true

# Closes the advanced settings menu
func _on_close_pressed() -> void:
	settings_popup.visible = false
	
	if use_size_override and str(size_override) != size_input.text:
		if is_int(size_input.text):
			if int(size_input.text) == get_valid_size(int(size_input.text)):
				size_override = int(size_input.text)
				use_size = size_override

# Toggles whether the size should be overridden by the text input
func _on_size_override_toggled(toggled_on: bool) -> void:
	use_size_override = toggled_on
	if toggled_on:
		use_size = size_override
		pyraminx.disabled = false
	else:
		use_size = p_size
		if p_size <= 2:
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
	
	if use_size_override: use_size = size_override

# Gets archipelago connection data
func _on_host_edit_text_submitted(new_text: String) -> void:
	host = host_edit.text
	
	host_edit.release_focus()
	port_edit.grab_focus()
	port_edit.select_all()

func _on_port_edit_text_submitted(new_text: String) -> void:
	var is_int = true
	for char in new_text:
		if not (char >= "0" and char <= "9"):
			is_int = false
	
	if is_int:
		var new_size = int(new_text)
		if new_size > 65535:
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
	slot_name = slot_edit.text
	
	slot_edit.release_focus()
	password_edit.grab_focus()
	password_edit.select_all()

func _on_password_edit_text_submitted(new_text: String) -> void:
	password = password_edit.text
	
	password_edit.release_focus()
	submit.grab_focus()

func _on_submit_pressed() -> void:
	host = host_edit.text
	port = port_edit.text
	slot_name = slot_edit.text
	password = password_edit.text

# Updates the piece and sticker scale values
func _on_piece_scale_value_changed(value: float) -> void:
	piece_scale = value
	piece_label.text = "Piece Scale: " + str("%.2f" % value)
	
	sticker_slider.max_value = piece_scale
	if sticker_scale > piece_scale:
		sticker_scale = piece_scale
		sticker_label.text = "Sticker Scale: " + str("%.2f" % piece_scale)
		sticker_slider.value = piece_scale

func _on_sticker_scale_value_changed(value: float) -> void:
	sticker_scale = value
	sticker_label.text = "Sticker Scale: " + str("%.2f" % value)

# Resets sliders to defaults
func _on_reset_piece_pressed() -> void:
	reset_piece_scale()

func _on_reset_sticker_pressed() -> void:
	reset_sticker_scale()

func reset_piece_scale() -> void:
	piece_scale = default_piece_scale
	piece_label.text = "Piece Scale: " + str("%.2f" % default_piece_scale)
	piece_slider.value = default_piece_scale

func reset_sticker_scale() -> void:
	sticker_scale = default_sticker_scale
	sticker_label.text = "Sticker Scale: "+ str("%.2f" % default_piece_scale)
	sticker_slider.value = default_sticker_scale

func is_int(str : String) -> bool:
	for char in str:
		if not (char >= "0" and char <= "9"):
			return false
	return true

func get_valid_size(val : int) -> int:
	if val < 1: return 1
	if val > 20: return 20
	return val
