extends Node2D

var astar_grid: AStarGrid2D
#is the worker player controllable
var isControllable:= true
var current_path: Array[Vector2i]

@onready var terrain: TileMapLayer = $"../Terrain"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	#all hard coded should instead be dynamic
	astar_grid = AStarGrid2D.new()
	astar_grid.region = terrain.get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _move():
	pass

func _input(event):
	#exits of not a click
	if event.is_action_pressed("Click") == false:
		return
	
	var id_path = astar_grid.get_id_path(
		terrain.local_to_map(global_position),
		terrain.local_to_map(get_global_mouse_position())
	).slice(1)
	
	#if not empty eg clicking on same time as self set path
	if id_path.is_empty() == false:
		current_path = id_path

func _physics_process(delta):
	if current_path.is_empty():
		return
	
	var target_position = terrain.map_to_local(current_path.front())
	global_position = global_position.move_toward((target_position), 1)
	if global_position == target_position:
		current_path.pop_front()
