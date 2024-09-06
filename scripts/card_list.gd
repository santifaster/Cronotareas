extends Container

#signal on_card_migrate(card)
signal on_first_card_stored
signal on_emptied_list

var cards:Array = []

var is_dragging
var drag_preview
var drag_index
var drag_position

func _process(_delta):
		
	if (not is_dragging):
		return
	drag_position = drag_preview.global_position
	
	check_drag_position()


#region Drag and Drop

func check_drag_position():
	#TODO Implement to switch between completed and pending lists
	if (drag_index > 0):
		if (drag_position.y < cards[drag_index - 1].global_position.y):
			change_index(drag_index, drag_index-1)
	if (drag_index < cards.size() - 1):
		if (drag_position.y > cards[drag_index + 1].global_position.y):
			change_index(drag_index, drag_index+1)	
	
	
func change_index(old_index, new_index):
	print("Old Index:" + str(old_index) + " / New Index:" + str(new_index))
	print("Drag y position:" + str(drag_preview.global_position.y) + 
	" / card y position:" + str(cards[new_index].global_position.y))
	
	move_child(cards[old_index], new_index)
	var moving_card = cards.pop_at(old_index)
	cards.insert(new_index, moving_card)
	if (is_dragging):
		drag_index = new_index

func _on_card_start_drag(preview_node, card_node):
	is_dragging = true
	drag_preview = preview_node
	drag_index = cards.find(card_node)
	pass

func _on_card_drop():
	print("Dragded card index:" + str(drag_index))
	
	is_dragging = false
	drag_preview = null
	drag_index = null
	pass
#endregion

	
func migrate_card(card_index:int):
	var migrating_card = cards[card_index]
	
	if (not migrating_card.on_drag.is_connected(_on_card_start_drag) 
	or not migrating_card.on_drop.is_connected(_on_card_drop) ):
		push_error("Tried to disable card signals, but one or more signals were not found")
		return
	
	migrating_card.on_drag.disconnect(_on_card_start_drag)
	migrating_card.on_drop.disconnect(_on_card_drop)
	migrating_card.on_delete.disconnect(_on_card_deleted)
	
	cards.pop_at(card_index)
	
	is_dragging = false
	#on_card_migrate.emit(migrating_card)
	remove_child(migrating_card)
	return migrating_card

func _on_card_deleted(card_node):
	cards.pop_at(cards.find(card_node))
	
	if(cards.size() == 0):
		on_emptied_list.emit()

func _add_card(new_card):
	add_child(new_card)
	cards.append(new_card)
	new_card.on_drag.connect(_on_card_start_drag)
	new_card.on_drop.connect(_on_card_drop)
	new_card.on_delete.connect(_on_card_deleted)
	if (cards.size() == 1):
		on_first_card_stored.emit()

func _on_mouse_entered():
	#print("Entered")
	pass

func _on_mouse_exited():
	#print("Exited")
	#if (is_dragging):
		#migrate_card(drag_index)
	pass
