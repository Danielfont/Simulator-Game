# Camera.gd
extends Camera2D

# Camera properties
@export var min_zoom: float = 0.5
@export var max_zoom: float = 4.0
@export var zoom_speed: float = 0.1
@export var pan_speed: float = 300.0
@export var smooth_pan_speed: float = 30.0	# How fast smooth panning is

# Grid properties
var tile_size = 16
var grid_width = 100
var grid_height = 50

# Calculated world size
var world_width = grid_width * tile_size	# 1600 pixels
var world_height = grid_height * tile_size	# 800 pixels

# Smooth panning variables
var target_position: Vector2
var is_smooth_panning: bool = false

func _ready():
	# Set initial camera position to center of grid
	global_position = Vector2(world_width / 2, world_height / 2)
	target_position = global_position
	
	# Set initial zoom to fit the grid nicely
	set_initial_zoom()

func set_initial_zoom():
	# Calculate zoom to fit grid in viewport
	var viewport_size = get_viewport().get_visible_rect().size
	
	var zoom_x = viewport_size.x / world_width
	var zoom_y = viewport_size.y / world_height
	
	# Use the smaller zoom to fit everything
	var initial_zoom_level = min(zoom_x, zoom_y) * 0.9	# 0.9 for some padding
	
	zoom = Vector2(initial_zoom_level, initial_zoom_level)

func _input(event):
	handle_zoom(event)
	handle_pan_input(event)

func handle_zoom(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()

func zoom_in():
	var new_zoom = zoom * (1.0 + zoom_speed)
	zoom = Vector2(
		clamp(new_zoom.x, min_zoom, max_zoom),
		clamp(new_zoom.y, min_zoom, max_zoom)
	)

func zoom_out():
	var new_zoom = zoom * (1.0 - zoom_speed)
	zoom = Vector2(
		clamp(new_zoom.x, min_zoom, max_zoom),
		clamp(new_zoom.y, min_zoom, max_zoom)
	)

func handle_pan_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				# Start smooth panning
				is_smooth_panning = true
			else:
				# Stop smooth panning
				is_smooth_panning = false
	
	elif event is InputEventMouseMotion and is_smooth_panning:
		# Update target position based on mouse movement
		target_position -= event.relative / zoom
		clamp_target_position()

func _process(delta):
	handle_keyboard_pan(delta)
	handle_smooth_pan(delta)

func handle_smooth_pan(delta):
	if is_smooth_panning or global_position.distance_to(target_position) > 1.0:
		# Smoothly move towards target position
		global_position = global_position.move_toward(target_position, smooth_pan_speed * 100 * delta / zoom.x)
		clamp_camera_position()

func handle_keyboard_pan(delta):
	var pan_input = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left"):
		pan_input.x -= 1
	if Input.is_action_pressed("ui_right"):
		pan_input.x += 1
	if Input.is_action_pressed("ui_up"):
		pan_input.y -= 1
	if Input.is_action_pressed("ui_down"):
		pan_input.y += 1
	
	if pan_input != Vector2.ZERO:
		target_position += pan_input * pan_speed * delta / zoom.x
		clamp_target_position()

func clamp_target_position():
	# Keep target position within world bounds
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_half_size = viewport_size / (2 * zoom)
	
	target_position.x = clamp(
		target_position.x,
		camera_half_size.x,
		world_width - camera_half_size.x
	)
	
	target_position.y = clamp(
		target_position.y,
		camera_half_size.y,
		world_height - camera_half_size.y
	)

func clamp_camera_position():
	# Keep camera within world bounds
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_half_size = viewport_size / (2 * zoom)
	
	global_position.x = clamp(
		global_position.x,
		camera_half_size.x,
		world_width - camera_half_size.x
	)
	
	global_position.y = clamp(
		global_position.y,
		camera_half_size.y,
		world_height - camera_half_size.y
	)
	
	# Update target to match clamped position
	target_position = global_position

# Utility functions
func focus_on_position(world_pos: Vector2):
	target_position = world_pos
	clamp_target_position()

func focus_on_grid_tile(grid_pos: Vector2i):
	var world_pos = Vector2(grid_pos.x * tile_size + tile_size/2, grid_pos.y * tile_size + tile_size/2)
	focus_on_position(world_pos)
