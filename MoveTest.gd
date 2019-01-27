extends KinematicBody

var gravity:int=10
var gravity_speed:float=0
var dir_x:int=1
var dir_y:int=1
var b=0
var c=0
var coin_counter=0

"""func _init():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _input(event):
	if (event is InputEventMouseMotion):
		var a
		a=event.relative
		b=fmod((b-0.001*a.x),360)
		c=max(min(c-0.001*a.y,90),-90)
		$Spatial.set_rotation(Vector3(0,b,0))
		$Spatial/Position3D.set_rotation(Vector3(c,0,0))"""

func _ready()->void:
	$CollisionShape/RayCast.add_exception(self)
	$Label.text=str(coin_counter)
	pass # Replace with function body.

func _physics_process(delta):
	gravity_speed+=gravity*delta
	if $RayCast.is_colliding():
		gravity_speed=0
	calculate_basis()
	var a:Vector3=-transform.basis.y.normalized()*gravity_speed
	var b:Vector3=a
	#var a:Vector3=Vector3(0,0,0)
	if !$Tween.is_active():
		dir_x=0
		dir_y=0
		if Input.is_key_pressed(KEY_D):
			a+=transform.basis.x.normalized()
			dir_x=1
		if Input.is_key_pressed(KEY_A):
			a-=transform.basis.x.normalized()
		if Input.is_key_pressed(KEY_W):
			a-=transform.basis.z.normalized()
			dir_y=1
		if Input.is_key_pressed(KEY_S):
			a+=transform.basis.z.normalized()
			dir_y=-1
		if (b!=a):
			$CollisionShape.rotation=Vector3(0,PI-angle(a.normalized(),transform.basis.z.normalized())+dir_x*(PI+dir_y*PI/2),0)
			#print(PI+dir_x*angle(a.normalized(),transform.basis.z.normalized()))
		if a!=b&& !$CollisionShape/snail/AnimationPlayer.is_playing():
			$CollisionShape/snail/AnimationPlayer.play("default")
	move_and_slide((a.normalized()*5),transform.basis.y,false,4,1,true)

func set_perspective(y_rot)->void:
	if y_rot!=rotation_degrees.y:
		$Tween.interpolate_property(self,"rotation_degrees",rotation_degrees,Vector3(0,y_rot,0),0.1,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
		$Tween.start()

func add_coin()->void:
	$AnimationPlayer.play("Particles")
	coin_counter+=1
	$Label.text=str(coin_counter)

func angle(a:Vector3,b:Vector3)->float:
	return acos(a.dot(b))

func module(a:Vector3)->float:
	var m:float = sqrt(a.x*a.x + a.y*a.y+a.z*a.z)
	return m

func calculate_basis()->void:
	if $CollisionShape/RayCast.is_colliding():
		var plane_normal:Vector3=$CollisionShape/RayCast.get_collision_normal().normalized()
		var versor:Vector3=plane_normal.cross(transform.basis.y.normalized()).normalized()
		if versor!=Vector3(0,0,0):
			soften_basis(versor,plane_normal)
			var a:Basis=transform.basis.rotated(versor,-angle(plane_normal,transform.basis.y)).orthonormalized()
			if !is_nan(a.determinant()) && !a.determinant()==0:
				transform.basis=a

func soften_basis(versor:Vector3,plane_normal:Vector3)->void:
	transform.basis=transform.basis.orthonormalized()
	#$Tween.interpolate_property(self,"transform/basis",transform.basis,transform.basis.rotated(versor,-angle(plane_normal,transform.basis.y)).orthonormalized(),0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	#$Tween.start()
	#transform.basis=transform.basis.rotated(versor,-angle(plane_normal,transform.basis.y)).orthonormalized()