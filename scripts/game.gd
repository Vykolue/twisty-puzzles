extends Node3D

@onready var ui: Control = $"../UI"
@onready var camera: Camera3D = $CameraPivot/Camera

# Puzzle scenes
const CUBE = preload("res://scenes/cube.tscn")
const PYRAMINX = preload("res://scenes/pyraminx.tscn")
const MEGAMINX = preload("res://scenes/megaminx.tscn")

# UI pages
var pages: Array[Node]

var page: String

var start_screen: Control
var home_page: Control
var archipelago_page: Control
var game_page: Control

var connection_page: Control
var loading_page: Control
var options_page: Control

var back_button: Button

# Puzzle object
var puzzle: Puzzle

### DEFAULT FUNCTIONS ###

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect signals
	SignalBus.start_solo.connect(start_solo_game)
	SignalBus.start_ap.connect(start_ap_game)
	SignalBus.back.connect(back)
	SignalBus.prompt_solo_options.connect(solo_options)
	SignalBus.prompt_ap_connection.connect(ap_connection)
	SignalBus.prompt_loading.connect(loading)
	SignalBus.prompt_ap_options.connect(ap_options)
	
	# Define ui pages
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
	
	# Displays only the start screen at first
	start_screen.visible = true
	home_page.visible = false
	archipelago_page.visible = false
	game_page.visible = false
	back_button.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### START A GAME ###

# Starts a solo game with the given arguments
func start_solo_game(args: Dictionary[String, Variant]) -> void:
	# Sets navigation helper variables
	page = "in_solo_game"
	args["game_mode"] = "solo"
	home_page.visible = false
	archipelago_page.visible = false
	game_page.visible = true
	
	# Starts a cube puzzle
	if args["type"] == "cube":
		camera.global_position = Vector3(15.0, 15.0, 15.0)
		camera.global_rotation = Vector3(deg_to_rad(-35.5), deg_to_rad(45.0), 0.0)
		camera.fov = 1.0 + (args["size"] * 4.0)
		puzzle = CUBE.instantiate().construct(args)
		add_child(puzzle)
	
	# Starts a pyraminx puzzle
	if args["type"] == "pyraminx":
		camera.global_position = Vector3(40.0, 40.0, 40.0)
		camera.global_rotation = Vector3(deg_to_rad(-35.3), deg_to_rad(45.0), 0.0)
		camera.fov = 0.0 + (args["size"] * 1.6)
		#camera.fov = 1.0 + (args["size"] * 4.5)
		puzzle = PYRAMINX.instantiate().construct(args)
		add_child(puzzle)
		puzzle.rotate_y(-0.25)
	
	# Starts a megaminx puzzle
	if args["type"] == "megaminx":
		puzzle = MEGAMINX.instantiate().construct(args)
		add_child(puzzle)

# Starts an archipelago game with the given arguments
func start_ap_game(args: Dictionary[String, Variant]) -> void:
	# Sets navigation helper variables
	page = "in_ap_game"
	args["game_mode"] = "ap"
	home_page.visible = false
	archipelago_page.visible = false
	game_page.visible = true
	
	# Starts a cube puzzle
	if args["type"] == "cube":
		#camera.global_position = Vector3(15.0, 15.0, 15.0)
		#camera.global_rotation = Vector3(-35.5, 45.0, 0.0)
		camera.fov = 1.0 + (args["size"] * 4.0)
		puzzle = CUBE.instantiate().construct(args)
		add_child(puzzle)
	
	# Starts a pyraminx puzzle
	if args["type"] == "pyraminx":
		#camera.global_position = Vector3(40.0, 40.0, 40.0)
		#camera.global_rotation = Vector3(-35.3, 45.0, 0.0)
		#camera.fov = 0.0 + (size * 1.6)
		camera.fov = 1.0 + (args["size"] * 4.5)
		puzzle = PYRAMINX.instantiate().construct(args)
		add_child(puzzle)
		puzzle.rotate_y(-0.25)
	
	# Starts a megaminx puzzle
	if args["type"] == "megaminx":
		puzzle = MEGAMINX.instantiate().construct(args)
		add_child(puzzle)

### NAVIGATION ###

# Goes back a page
func back() -> void:
	match page:
		"in_solo_game":
			page = "home"
			
			home_page.visible = true
			game_page.visible = false
			
			puzzle.queue_free()
			
		"home":
			page = "start"
			
			start_screen.visible = true
			home_page.visible = false
			archipelago_page.visible = false
			game_page.visible = false
			back_button.visible = false
			
		"archipelago_connection":
			page = "start"
			
			start_screen.visible = true
			home_page.visible = false
			archipelago_page.visible = false
			game_page.visible = false
			back_button.visible = false
			
		"in_ap_game":
			page = "archipelago_options"
			
			start_screen.visible = false
			home_page.visible = false
			archipelago_page.visible = true
			game_page.visible = false
			back_button.visible = true
			
			puzzle.queue_free()
			
		"archipelago_options":
			page = "archipelago_connection"
		
			connection_page.visible = true
			loading_page.visible = false
			options_page.visible = false
			
			start_screen.visible = false
			home_page.visible = false
			archipelago_page.visible = true
			game_page.visible = false
			back_button.visible = true
			
			Archipelago.ap_disconnect()
		"loading":
			page = "archipelago_connection"
		
			connection_page.visible = true
			loading_page.visible = false
			options_page.visible = false
			
			start_screen.visible = false
			home_page.visible = false
			archipelago_page.visible = true
			game_page.visible = false
			back_button.visible = true
			
			Archipelago.ap_disconnect()

# Opens the solo options menu
func solo_options() -> void:
	page = "home"
	
	start_screen.visible = false
	home_page.visible = true
	archipelago_page.visible = false
	game_page.visible = false
	back_button.visible = true

# Opens the connect to archipelago menu
func ap_connection() -> void:
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

# Prompts the loading screen
# useful when waiting for archipelago to connect
func loading() -> void:
	page = "loading"
	
	connection_page.visible = false
	loading_page.visible = true
	options_page.visible = false
	
	start_screen.visible = false
	home_page.visible = false
	archipelago_page.visible = true
	game_page.visible = false
	back_button.visible = true

# Opens the archipelago options menu
# This is only for client-side options
func ap_options() -> void:
	page = "archipelago_options"
	
	connection_page.visible = false
	loading_page.visible = false
	options_page.visible = true
	
	start_screen.visible = false
	home_page.visible = false
	archipelago_page.visible = true
	game_page.visible = false
	back_button.visible = true
