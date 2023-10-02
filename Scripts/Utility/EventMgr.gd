extends Node

var listeners : = {}

func new_event(event_id)->void:
	if listeners.has(event_id): return
	listeners[event_id] = []

func fire_event(id, args : = [])->void:
	if listeners.has(id) == false:
		print("event %s is not registered!" % id)
		return
	var event_listeners : Array = listeners[id]
	for i in range(event_listeners.size()):
		if args.size() > 0:
			event_listeners[i].callv(args)
		else:
			event_listeners[i].call()
			
func sub_listener(
	event_id,
	callable : Callable
)->void:
	if listeners.has(event_id) == false:
		# listeners can create the event they want to sub to
		new_event(event_id)
	listeners[event_id].append(callable)

func _exit_tree() -> void:
	listeners.clear()
