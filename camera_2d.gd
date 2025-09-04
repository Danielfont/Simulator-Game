# Camera.gd
extends Camera2D

@export var pan_speed: float
@export var zoom_max: float
@export var zoom_min: float

var is_panning = false
var camera_start_position = Vector2.ZERO
var pan_start_position = Vector2.ZERO

func _ready() -> void:
	#maybe want to set a dynamic starting position of the camera
	
	pass

func  _physics_process(delta) -> void:
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("pan_right"):
		velocity.x += 1
	if Input.is_action_pressed("pan_left"):
		velocity.x -= 1
	if Input.is_action_pressed("pan_down"):
		velocity.y += 1
	if Input.is_action_pressed("pan_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * pan_speed
	global_position += velocity * delta
	#position = position.clamp(Vector2.ZERO, screen_size)


func _input(event):
	#handles scroll wheel zoom
	if event is InputEventMouseButton:
		var mouse_position = get_global_mouse_position()
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and  zoom.x < zoom_max:
			zoomToPoint(mouse_position, 0.1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and zoom.x > zoom_min:
			zoomToPoint(mouse_position, -0.1)
			
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				pan_start_position = event.position
			else:
				is_panning = false
	elif event is InputEventMouseMotion and is_panning:
		var mouse_delta = event.position - pan_start_position
		global_position -= mouse_delta / zoom.x
		pan_start_position = event.position

func zoomToPoint(point: Vector2, zoom_speed: float):
	var old_zoom = zoom.x
	zoom += Vector2(zoom_speed, zoom_speed)
	var zoom_factor = zoom.x / old_zoom
	global_position += (point - global_position) * (1 - 1/zoom_factor)
	
