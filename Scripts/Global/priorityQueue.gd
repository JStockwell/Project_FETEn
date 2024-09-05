extends Node
class_name PriorityQueue

var front
var newNode
var temp

func _init():
	front = null
	

func is_empty():
	return front == null
	

func push(coords: Vector2, priority: int):
	if is_empty():
		front =  LinkedNode.new(coords, priority) # We create a new node from scratch if the list was previously empty
		front.queue_free()
		
	elif front.priority > priority: # > to find the shortest path from lowest to highest, if reverted would work for reversed distances
		newNode = LinkedNode.new(coords, priority, front) # We insert the current node as the next node
		newNode.next = front # we set the next node in the priority list as the front of the linked list
		front = newNode
		newNode.queue_free()
		
	else:
		temp = front
		while temp.next:
			if priority <= temp.next.priority: #if the current priority is <= of that of the next node, we continue with our current prio
				break
				
			temp = temp.next
		
		newNode = LinkedNode.new(coords, priority, temp.next)
		temp.next = newNode
		front.queue_free()
		newNode.queue_free()

func pop(): # function to take the node out of the queue
	if is_empty():
		return
	else:
		temp = front
		front = front.next
		return temp
