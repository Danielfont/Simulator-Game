extends Node2D

var astar_grid: AStarGrid2D
#is the worker player controllable
var isControllable:= true
var current_path: Array[Vector2i]
var speed:= 100
var target_position: Vector2
var isMoving: bool

@onready var terrain: TileMapLayer = $"../Terrain"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	#all hard coded should instead be dynamic
	astar_grid = AStarGrid2D.new()
	astar_grid.region = terrain.get_used_rect()
	astar_grid.cell_size = Vector2(16, 16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	for x in terrain.get_used_rect().size.x:
		for y in terrain.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + terrain.get_used_rect().position.x,
				y + terrain.get_used_rect().position.y)
			var tile_data = terrain.get_cell_tile_data(tile_position)
			if tile_data == null or tile_data.get_custom_data("Blocked") == true:
				astar_grid.set_point_solid(tile_position)
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _move():
	pass

func _input(event):
	#exits of not a click
	if event.is_action_pressed("Click") == false:
		return
	var id_path
	#slices first element as that is current location
	if isMoving:
		id_path = astar_grid.get_id_path(
			terrain.local_to_map(global_position),
			terrain.local_to_map(get_global_mouse_position()))
	else:
			id_path = astar_grid.get_id_path(
			terrain.local_to_map(global_position),
			terrain.local_to_map(get_global_mouse_position())
			).slice(1)
	
	#if not empty eg clicking on same time as self set path
	if id_path.is_empty() == false:
		current_path = id_path


func _physics_process(delta):
	if current_path.is_empty():
		return
	if isMoving == false: 
		var target_position = terrain.map_to_local(current_path.front())
		isMoving = true
	global_position = global_position.move_toward((target_position), speed * delta)
	if global_position == target_position:
		current_path.pop_front()
		if current_path.is_empty() == false:
			target_position = terrain.map_to_local(current_path.front())
		else: 
			isMoving = false
		
