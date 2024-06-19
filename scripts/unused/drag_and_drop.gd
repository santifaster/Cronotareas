extends Control

var node_to_instantiate

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func _get_drag_data(_position):

	var instance = node_to_instantiate.instantiate()
	
	#Make the slot follow the mouse where it started dragging
	instance.position -= _position
	var preview_mouse_offset = Control.new()
	preview_mouse_offset.add_child(instance)
	
	set_drag_preview(preview_mouse_offset)
	# Need to get the data
	#instance.set_task(task_data)
	node_to_instantiate.visible = false
	#return task_data

func _can_drop_data(_position, _data):
	pass

func _drop_data(_position, _data):
	node_to_instantiate.visible = true
	pass


func _on_mouse_entered():
	#color_rect.color
	pass
