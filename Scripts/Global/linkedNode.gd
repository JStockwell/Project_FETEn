extends Node
class_name LinkedNode

var coords # the coordinates of the map tile
var priority: int # the priority for the search algorythm (is tied to movement spent to that tile in the best path found)
var next: LinkedNode # the next node on the linked list

func _init(nodeCoords: Vector2, nodePriority: int, nextNode = null):
	coords = nodeCoords
	priority = nodePriority
	next = nextNode
	

func set_coords(newCoords: Vector2):
	coords = newCoords
	

func set_priority(newPriority: int):
	priority = newPriority
	
