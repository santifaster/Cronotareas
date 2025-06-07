extends Node

@export var anim_curve : Curve
@export var anim_node : Control
var menu_tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func tween_animation(destination: Vector2):
	if menu_tween:
		menu_tween.kill()
	menu_tween = create_tween()
	#TODO Set tween curves
	#menu_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	#menu_tween.tween_property(self,"position", destination, 0.5)D
	var start_position:Vector2 = anim_node.position
	menu_tween.tween_method(tween_lerp.bind(start_position,destination),0.,1.,0.5)
	
func tween_lerp(weight:float, start_position: Vector2,destination: Vector2):
	var curve_weight: float = anim_curve.sample(weight)
	anim_node.position = lerp(start_position, destination, curve_weight)
