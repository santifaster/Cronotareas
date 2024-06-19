extends Node

class_name Task

var title : String
var icon : String
var duration : float
var time_left : float

#region Get Set Minutes and Seconds

var duration_minutes :
	get:
		return floor(duration / 60)
	set(value):
		duration += value * 60 - duration_minutes
		
var duration_seconds :
	get:
		return int(duration) % 60
	set(value):
		value = clamp(value, 0, 60)
		duration += value - duration_seconds
		
var time_left_minutes :
	get:
		return floor(time_left / 60)
	set(value):
		time_left += value * 60 - time_left_minutes
				
var time_left_seconds :
	get:
		return int(time_left) % 60
	set(value):
		value = clamp(value, 0, 60)
		time_left += value - time_left_seconds
#endregion


enum state_type {not_started, in_progress, paused, completed}
var state = state_type.not_started
	
func _init(n_icon, n_title, n_duration):	
	title = n_title
	icon = n_icon
	duration = n_duration
	time_left = duration
	
func update_time_left(n_time_left):
	time_left = n_time_left
	
	if (time_left <= 0):
		state = state.completed
		
func _resume():
	state = state_type.in_progress		
func _pause():
	state = state_type.paused		
func _finish():
	state = state_type.completed

func reset_task():
	time_left = duration
	state = state_type.not_started

#region Get time
func _get_string_duration():
	return get_string_time(duration_minutes) + ":" + get_string_time(duration_seconds)
	
func _get_string_time_left():
	return get_string_time(time_left_minutes) + ":" + get_string_time(time_left_seconds)
	
func _get_string_duration_minutes():
	return get_string_time(duration_minutes)
	
func _get_string_duration_seconds():
	return get_string_time(duration_seconds)	
	
func _get_string_time_left_minutes():
	return get_string_time(time_left_minutes)
	
func _get_string_time_left_seconds():
	return get_string_time(time_left_seconds)
#endregion
	
func get_string_time(value:int):
	var text = str(value)
	if(value < 10):
		text = "0" + text
			
	return text
