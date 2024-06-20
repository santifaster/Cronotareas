extends Node

@onready var completed_label = $"Completed Tasks Label"
@onready var finished_task_container = $FinishedTaskContainer

func _ready():
	finished_tasks_visible(false)
	pass

func _on_finished_container_emptied_list():
	finished_tasks_visible(false)


func _on_finished_container_first_card_stored():
	finished_tasks_visible(true)

func finished_tasks_visible(value:bool):
	completed_label.visible = value
	finished_task_container.visible = value
