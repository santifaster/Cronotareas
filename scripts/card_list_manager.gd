extends Node

var drag_preview
var migrating_card
#@export var card_lists : Array[Node]
@onready var timer_controller = $"Timer Menu"

@onready var current_task_container = $"Timer Menu/VBoxContainer/CurrentTaskContainer"
@onready var task_container = $ScrollContainer/VBoxContainer/TaskContainer
@onready var finished_task_container = $ScrollContainer/VBoxContainer/FinishedTaskContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
		scroll_on_drag_outside()
		
# Update this scripts to handle drag and drop between lists
#region Drag and drop
func scroll_on_drag_outside():
	#TODO On drag outside the scroll box, scroll in that direction
	pass


func _on_card_start_drag(preview_node, _card_node):
	drag_preview = preview_node
	#search_card_on_lists(card_node)
	pass

func _on_card_drop():
	#print("Dragded card index:" + str(drag_index))
		
	drag_preview = null
	#drag_index = null
	pass
#endregion

func _add_card(new_card):
	#cards.append(new_card)
	new_card.on_start.connect(_on_start_task)
	new_card.on_reset.connect(_on_reset_task)
	#new_card.on_drag.connect(_on_card_start_drag)
	#new_card.on_drop.connect(_on_card_drop)
	
	var card_state = new_card.task_data.state
	match card_state:
		Task.state_type.not_started, Task.state_type.paused:
			task_container._add_card(new_card)
		Task.state_type.in_progress:
			current_task_container._add_card(new_card)
		Task.state_type.completed:
			finished_task_container._add_card(new_card)

func set_task_on_timer(index:int = 0, task_container_origin = task_container):
	if(current_task_container.cards.size() >= 1):
		return
	if(task_container_origin.cards.size() == 0):
		timer_controller.reset_timer()
		return
		
	#Ask migrate cardlist[1].cards[0] to cardlists[0]
	var task_data : Task = task_container_origin.cards[index].task_data
	current_task_container._add_card(task_container_origin.migrate_card(index))
	#Pass new task to task_timer
	timer_controller._add_task(task_data)
	
func _on_completed_card():
	#Migrate card from cardlists[0].cards[0] to cardlists[2]
	if(current_task_container.cards[0] != null):
		finished_task_container._add_card(current_task_container.migrate_card(0))
		set_task_on_timer()
	else:
		push_error("Got on completed event without task on timer, this should not happen")


func _on_first_card_stored_task_container():
	set_task_on_timer()


func _on_current_task_container_emptied():
	set_task_on_timer()
	
func _on_start_task(card_node:Node):
	if(current_task_container.cards.find(card_node) >= 0):
		return
	var task_index = task_container.cards.find(card_node)
	if task_index>= 0:
		task_container._add_card(current_task_container.migrate_card(task_index))
		set_task_on_timer(task_index)
		timer_controller.reset_timer_task_values()
		return
		
	task_index = finished_task_container.cards.find(card_node)
	if task_index>= 0:
		finished_task_container._add_card(current_task_container.migrate_card(task_index))
		set_task_on_timer(task_index, finished_task_container)
		timer_controller.reset_timer_task_values()

func _on_reset_task(card_node:Node):
	var task_index = finished_task_container.cards.find(card_node)
	
	if(task_index >= 0):
		task_container._add_card(finished_task_container.migrate_card(task_index))
		return
		
	task_index = current_task_container.cards.find(card_node)
	if(task_index >= 0):
		timer_controller._stop_timer()
		timer_controller.reset_timer_task_values()


func _on_edit_task(card_node):
	if(current_task_container.cards.find(card_node) >= 0):
		timer_controller.reset_timer_task_values()
