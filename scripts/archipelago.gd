extends Control

@onready var ui: Control = $".."
@onready var connection_page: Control = $"Connection Page"
@onready var loading_page: Control = $"Loading Page"
@onready var options_page: Control = $"Options Page"
@onready var back: Button = $"../Back"

@onready var connection: Label = $"Options Page/Connection"
@onready var popup: Control = $"Options Page/Advanced Settings/Popup"
@onready var piece_label: Label = $"Options Page/Advanced Settings/Popup/Piece/Piece Label"
@onready var sticker_label: Label = $"Options Page/Advanced Settings/Popup/Sticker/Sticker Label"
@onready var piece_slider: HSlider = $"Options Page/Advanced Settings/Popup/Piece/Piece Slider"
@onready var sticker_slider: HSlider = $"Options Page/Advanced Settings/Popup/Sticker/Sticker Slider"
@onready var loading_label: Label = $"Loading Page/Label"

var connected = false
var slot_data
var args: Dictionary[String, Variant]

const APStatus = Archipelago.APStatus

var connection_timeout = Timer.new()
var timed_out = false

var style = "traditional"
var color_scheme = "standard"
var piece_scale
var sticker_scale

### DEFAULT FUNCTIONS ###

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Archipelago.connected.connect(_on_connected)
	Archipelago.disconnected.connect(_on_disconnected)
	
	connection_page.visible = true
	loading_page.visible = false
	options_page.visible = false
	popup.visible = false
	
	piece_scale = ui.default_piece_scale
	sticker_scale = ui.default_sticker_scale
	
	piece_label.text = "Piece Scale: " + str("%.2f" % piece_scale)
	sticker_label.text = "Sticker Scale: " + str("%.2f" % sticker_scale)
	
	connection.text = "Not connected"
	
	connection_timeout.wait_time = 20.0
	connection_timeout.one_shot = true
	connection_timeout.timeout.connect(_on_connection_timeout)
	add_child(connection_timeout)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	'''
	if not connected and Archipelago.conn:
		SignalBus.prompt_ap_options.emit()
		connected = true
	'''
	'''
	if connection_timeout.time_left > 0:
		print(connection_timeout.time_left)
	'''
	pass

### NAVIGATION ###

func _on_submit_pressed() -> void:
	await get_tree().create_timer(0.01).timeout
	if not Archipelago.status == APStatus.PLAYING:
		loading_label.text = "Connecting..."
		SignalBus.prompt_loading.emit()
		connection_timeout.start()
		print("timer started")
		Archipelago.ap_connect(ui.host, str(ui.port), ui.slot_name, ui.password)
	else:
		SignalBus.prompt_ap_options.emit()

func _on_start_pressed() -> void:
	args["type"] = "cube"
	args["style"] = style
	args["color_scheme"] = color_scheme
	args["piece_scale"] = piece_scale
	args["sticker_scale"] = sticker_scale
	
	SignalBus.start_ap.emit(args)

'''
func _on_back_pressed() -> void:
	if in_game:
		options_page.visible = true
		in_game = false
	else:
		Archipelago.ap_disconnect()
		options_page.visible = false
		connection_page.visible = true
		loading_page.visible = false
		SignalBus.prompt_ap_connection.emit()
'''

### ARCHIPELAGO CONNECTION ###

func _on_connected(conn: ConnectionInfo, _json: Dictionary):
	SignalBus.prompt_ap_options.emit()
	connection_timeout.stop()
	print("timer stopped")
	
	connection.text = "Connected to " + ui.host + ":" + str(ui.port)
	slot_data = conn.slot_data
	reformat_args()

func _on_disconnected():
	connection_timeout.stop()
	print("timer stopped")
	connection.text = "Not connected"
	connected = false
	print("disconnected from the server")
	
	if not timed_out:
		loading_label.text = "Unable to connect\nReturning to connection page"
		await get_tree().create_timer(2).timeout
		SignalBus.prompt_ap_connection.emit()
	else:
		timed_out = false

func _on_connection_timeout() -> void:
	Archipelago.ap_disconnect()
	
	connection.text = "Not connected"
	connected = false
	timed_out = true
	print("connection timed out")
	
	loading_label.text = "Connection timed out\nReturning to connection page"
	await get_tree().create_timer(2).timeout
	SignalBus.prompt_ap_connection.emit()

### OPTION SETTINGS ###

func _on_advanced_settings_pressed() -> void:
	popup.visible = true

func _on_close_pressed() -> void:
	popup.visible = false

func _on_style_options_item_selected(index: int) -> void:
	match index:
		0:
			style = "traditional"
		1:
			style = "transparent"
		2:
			style = "stickerless"

func _on_color_options_item_selected(index: int) -> void:
	color_scheme = ui.color_schemes[index]

func _on_piece_slider_value_changed(value: float) -> void:
	piece_scale = value
	piece_label.text = "Piece Scale: " + str("%.2f" % piece_scale)
	
	sticker_slider.max_value = piece_scale
	if sticker_scale > piece_scale:
		sticker_scale = piece_scale
		sticker_label.text = "Sticker Scale: " + str("%.2f" % piece_scale)
		sticker_slider.value = piece_scale

func _on_sticker_slider_value_changed(value: float) -> void:
	sticker_scale = value
	sticker_label.text = "Sticker Scale: " + str("%.2f" % sticker_scale)

### RESET TO DEFAULT VALUES ###

func _on_reset_piece_pressed() -> void:
	piece_scale = ui.default_piece_scale
	piece_label.text = "Piece Scale: " + str("%.2f" % ui.default_piece_scale)
	piece_slider.value = ui.default_piece_scale

func _on_reset_sticker_pressed() -> void:
	sticker_scale = min(ui.default_sticker_scale, piece_slider.value)
	sticker_label.text = "Sticker Scale: " + str("%.2f" % min(ui.default_sticker_scale, piece_slider.value))
	sticker_slider.value = min(ui.default_sticker_scale, piece_slider.value)

### REFORMATS APWORLD DATA ###

func reformat_args() -> void:
	for key in slot_data:
		args[key] = slot_data[key]
	
	args["color_map"] = args["color_permutation"].duplicate(true)
	args.erase("color_permutation")
	var key = "minimum_stickers_unlocked_to_goal_when_solved"
	args["min_stickers_to_goal"] = int(args[key])
	args.erase(key)
	args["seed_name"] = int(args["seed_name"])
	args["size"] = int(args["size_of_cube"])
	args.erase("size_of_cube")
	reformat_colors()

func reformat_colors():
	var new_map: Dictionary[String, String] = {}
	for key in args["color_map"]:
		new_map[key.to_lower()] = args["color_map"][key].to_lower()
	new_map["plastic"] = "plastic"
	new_map["unrevealed"] = "unrevealed"
	args["color_map"] = new_map
