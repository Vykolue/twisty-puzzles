extends Node3D

@onready var ui: Control = $"../UI"
@onready var camera: Camera3D = $CameraPivot/Camera

const CUBE = preload("res://scenes/cube.tscn")
const PYRAMINX = preload("res://scenes/pyraminx.tscn")
const MEGAMINX = preload("res://scenes/megaminx.tscn")

var pages
var start_screen
var home_page
var archipelago_page
var game_page
var connection_page
var loading_page
var options_page
var back_button
var rotation_ui
var page

var puzzle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.start.connect(start_game)
	SignalBus.start_ap.connect(start_ap_game)
	SignalBus.back.connect(back)
	SignalBus.prompt_solo_options.connect(solo_options)
	SignalBus.prompt_ap_connection.connect(ap_connection)
	SignalBus.prompt_loading.connect(loading)
	SignalBus.prompt_ap_options.connect(ap_options)
	
	pages = ui.get_children()
	
	start_screen = pages[0]
	home_page = pages[1]
	archipelago_page = pages[2]
	game_page = pages[3]
	back_button = pages[4]
	
	var ap_pages = archipelago_page.get_children()
	connection_page = ap_pages[0]
	loading_page = ap_pages[1]
	options_page = ap_pages[2]
	
	rotation_ui = [game_page.get_child(0)]
	
	start_screen.visible = true
	home_page.visible = false
	archipelago_page.visible = false
	game_page.visible = false
	back_button.visible = false
	
	for buttons in rotation_ui:
		buttons.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Starts a game with the given type and size
func start_game(type : String, size : int, random_colors : bool, style : String, piece_scale : float, sticker_scale : float):
	page = "in game"
	home_page.visible = false
	archipelago_page.visible = false
	game_page.visible = true
	if type == "cube":
		#camera.global_position = Vector3(15.0, 15.0, 15.0)
		#camera.global_rotation = Vector3(-35.5, 45.0, 0.0)
		camera.fov = 1.0 + (size * 4.0)
		puzzle = CUBE.instantiate().construct(size, random_colors, style, piece_scale, sticker_scale)
		add_child(puzzle)
		# temp fix to hide rotate cube ui from other puzzle types
		#rotation_ui[0].visible = true
	#else:
		# temp fix to hide rotate cube ui from other puzzle types
		#rotation_ui[0].visible = false
	
	if type == "pyraminx":
		#camera.global_position = Vector3(40.0, 40.0, 40.0)
		#camera.global_rotation = Vector3(-35.3, 45.0, 0.0)
		#camera.fov = 0.0 + (size * 1.6)
		camera.fov = 1.0 + (size * 4.5)
		puzzle = PYRAMINX.instantiate().construct(size, random_colors, style, piece_scale, sticker_scale)
		add_child(puzzle)
		puzzle.rotate_y(-0.25)
	
	if type == "megaminx":
		puzzle = MEGAMINX.instantiate().construct(size, random_colors, style, piece_scale, sticker_scale)
		add_child(puzzle)

# Starts an ap game with the given type and size
func start_ap_game(args):
	page = "in ap game"
	home_page.visible = false
	archipelago_page.visible = false
	game_page.visible = true
	if args["type"] == "cube":
		#camera.global_position = Vector3(15.0, 15.0, 15.0)
		#camera.global_rotation = Vector3(-35.5, 45.0, 0.0)
		camera.fov = 1.0 + (args["puzzle_size"] * 4.0)
		puzzle = CUBE.instantiate().construct_ap(args)
		add_child(puzzle)
		# temp fix to hide rotate cube ui from other puzzle types
		#rotation_ui[0].visible = true
	#else:
		# temp fix to hide rotate cube ui from other puzzle types
		#rotation_ui[0].visible = false
	
	if args["type"] == "pyraminx":
		#camera.global_position = Vector3(40.0, 40.0, 40.0)
		#camera.global_rotation = Vector3(-35.3, 45.0, 0.0)
		#camera.fov = 0.0 + (size * 1.6)
		camera.fov = 1.0 + (args["puzzle_size"] * 4.5)
		puzzle = PYRAMINX.instantiate().construct_ap(args)
		add_child(puzzle)
		puzzle.rotate_y(-0.25)
	
	if args["type"] == "megaminx":
		puzzle = MEGAMINX.instantiate().construct_ap(args)
		add_child(puzzle)

# Goes back a page
func back():
	if page == "in game":
		page = "home"
		home_page.visible = true
		game_page.visible = false
		
		puzzle.queue_free()
	elif page == "home" or page == "archipelago_connection":
		page = "start"
		start_screen.visible = true
		home_page.visible = false
		archipelago_page.visible = false
		game_page.visible = false
		back_button.visible = false
	elif page == "in ap game":
		page = "archipelago_options"
		start_screen.visible = false
		home_page.visible = false
		archipelago_page.visible = true
		game_page.visible = false
		back_button.visible = true
		
		puzzle.queue_free()
	elif page == "archipelago_options" or page == "loading":
		page = "archipelago_connection"
		start_screen.visible = false
		home_page.visible = false
		archipelago_page.visible = true
		game_page.visible = false
		back_button.visible = true
	
		connection_page.visible = true
		loading_page.visible = false
		options_page.visible = false
		
		Archipelago.ap_disconnect()

func solo_options():
	page = "home"
	start_screen.visible = false
	home_page.visible = true
	archipelago_page.visible = false
	game_page.visible = false
	back_button.visible = true

func ap_connection():
	page = "archipelago_connection"
	
	connection_page.visible = true
	loading_page.visible = false
	options_page.visible = false
	
	start_screen.visible = false
	home_page.visible = false
	archipelago_page.visible = true
	game_page.visible = false
	back_button.visible = true
	
	if not (Archipelago.status == Archipelago.APStatus.DISCONNECTED or Archipelago.status == Archipelago.APStatus.DISCONNECTING):
		Archipelago.ap_disconnect()

func loading():
	page = "loading"
	
	connection_page.visible = false
	loading_page.visible = true
	options_page.visible = false
	
	start_screen.visible = false
	home_page.visible = false
	archipelago_page.visible = true
	game_page.visible = false
	back_button.visible = true

func ap_options():
	page = "archipelago_options"
	
	connection_page.visible = false
	loading_page.visible = false
	options_page.visible = true
	
	start_screen.visible = false
	home_page.visible = false
	archipelago_page.visible = true
	game_page.visible = false
	back_button.visible = true
