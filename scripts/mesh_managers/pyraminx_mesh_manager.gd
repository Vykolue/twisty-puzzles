extends MeshManager
class_name PyraminxMeshManager

var adj_scaled_back = adjustment / (tan(acos(sqrt(3.0) / 3.0)))
var adj_scaled_down = adjustment / (sin(acos(sqrt(3.0) / 3.0)))

var s_adj_scaled_back = s_adjustment / (tan(acos(sqrt(3.0) / 3.0)))
var s_adj_scaled_down = s_adjustment / (sin(acos(sqrt(3.0) / 3.0)))

### DEFAULT FUNCTIONS ###

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

### MAIN FUNCTIONS ###

func send_mesh_data():
	pass
