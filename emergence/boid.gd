extends CharacterBody3D

@export var target:Node3D
@export var force:Vector3
@export var accel:Vector3

@export var mass:float = 1
var max_speed = 10

@export var seek_enabled = false
@export var arrive_enabled = false
@export var pursue_enabled = false
@export var pursue_target:CharacterBody3D
@export var arrive_target:Node3D
@export var slowing_distance = 20

@export var banking:float = 1
@export var damping:float = 1

@export var player_steering_enabled:bool = true
@export var s_force:float = 10

func pursue(pursue_target):
	var dist = (pursue_target.global_position - )
	
	var time = dist / max_speed
	
	var projected = pursue_target.global_position + (pursue_)
	pass
	



func player_steering():
	var s = Input.get_axis("move_back", "move_forward")
	var f:Vector3 = Vector3.ZERO
	
	
	f = global_basis.z * s * s_force
	
	var l = Input.get_axis("turn_left", "turn_right")
	var xz_direction = global_basis.x
	xz_direction.y = 0
	
	f -= xz_direction * l * s_force
	xz_direction.normalized()
	
	DebugDraw2D.set_text("Gloabl basis: ", global_basis)
	
	return f
	
	pass

func arrive(target) -> Vector3:
	var to_target = target.global_position - global_position
	var dist = to_target.length()
	var ramped = (dist / slowing_distance) * max_speed
	var clamped = min(ramped, max_speed)
	var desired = (to_target * clamped) / dist
	return desired - velocity


func seek(target) -> Vector3:
	var to_target:Vector3 = target - global_position
	var desired = to_target.normalized() * max_speed
	return desired - velocity
	

func _ready() -> void:
	
	
	
	pass
	
func draw_gizmos():
	DebugDraw3D.draw_arrow(global_position, global_position + force, Color.AQUAMARINE, 0.1)
	DebugDraw3D.draw_arrow(global_position, global_position + velocity, Color.CRIMSON, 0.1)
	DebugDraw3D.draw_arrow(global_position, global_position + global_basis.y * 10, Color.CRIMSON, 0.1)
	DebugDraw3D.draw_sphere(arrive_target.global_position, slowing_distance, Color.BURLYWOOD)
	DebugDraw2D.set_text("Veocity:", velocity)
	
	DebugDraw3D.draw_arrow(global_position, global_position + global_basis.x * 10, Color.CRIMSON, 0.1)


func calculate():
	var f:Vector3 = Vector3.ZERO	
	if seek_enabled:
		f += seek(target.global_position)
	if arrive_enabled:
		f += arrive(arrive_target)
	if path_follow_enabled:
		f += follow_path()
	if player_steering_enabled:
		f += player_steering()
	if pursue_enabled()
	return f

@export var path:Path3D

@export var path_follow_enabled:bool = false
var path_index = 0
var looped = false
	
	
func follow_path():
	
	var p = path.global_transform * path.get_curve().get_point_position(path_index)
	var d = (p - global_position).length()
	if d < 2:
		path_index = (path_index + 1) % path.get_curve().point_count
	
	return seek(p)
	
	
func _process(delta: float) -> void:
	
	force = calculate()	
	accel = force / mass	
	velocity = (velocity + accel * delta)
	
	if velocity.length() > 0:
		# Implement Banking as described:
		# https://www.cs.toronto.edu/~dt/siggraph97-course/cwr87/
		var tempUp = transform.basis.y.lerp(Vector3.UP + (accel * banking), delta * 5.0)
		look_at(global_transform.origin - velocity, tempUp)
		
		velocity = velocity - (velocity * damping * delta)
		# look_at(global_position + velocity)
		# global_position += velocity * delta
		
	move_and_slide()	
	
	draw_gizmos()
	
	pass
