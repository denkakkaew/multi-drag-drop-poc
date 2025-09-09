extends Node2D

var touches := {} # touch_index -> {data, start_pos, preview}

func _input(event):
	# touch begin / end
	if event is InputEventScreenTouch:
		if event.pressed:
			var picked = gui_pick_at(event.position)
			if picked and picked.has_method("_get_drag_data"):
				# get local position for the control
				var local_pos = event.position
				if picked is Control:
					# Control doesn't have to_local(); convert global -> control local using its global rect
					local_pos = event.position - picked.get_global_rect().position
				var drag_data = picked._get_drag_data(local_pos)
				var info = {"data": drag_data, "start_pos": event.position}
				# create a small visual preview for this touch
				if typeof(drag_data) == TYPE_DICTIONARY and drag_data.has("texture"):
					var prev = TextureRect.new()
					prev.texture = drag_data.texture
					prev.mouse_filter = Control.MOUSE_FILTER_IGNORE
					prev.position = event.position
					add_child(prev)
					info.preview = prev
				touches[event.index] = info
		else:
			if touches.has(event.index):
				var info = touches[event.index]
				var drop_target = gui_pick_at(event.position)
				if drop_target and drop_target.has_method("_drop_data"):
					drop_target._drop_data(event.position, info.data)
				if info.has("preview") and is_instance_valid(info.preview):
					info.preview.queue_free()
				touches.erase(event.index)

	# continuous drag update (move preview)
	elif event is InputEventScreenDrag:
		if touches.has(event.index):
			var info = touches[event.index]
			if info.has("preview") and is_instance_valid(info.preview):
				info.preview.position = event.position

	# mouse fallback for desktop (treat left button as touch index 0)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var idx = 0
		if event.pressed:
			var picked = gui_pick_at(event.position)
			if picked and picked.has_method("_get_drag_data"):
				var local_pos = event.position
				if picked is Control:
					local_pos = event.position - picked.get_global_rect().position
				var drag_data = picked._get_drag_data(local_pos)
				var info = {"data": drag_data, "start_pos": event.position}
				if typeof(drag_data) == TYPE_DICTIONARY and drag_data.has("texture"):
					var prev = TextureRect.new()
					prev.texture = drag_data.texture
					prev.mouse_filter = Control.MOUSE_FILTER_IGNORE
					prev.position = event.position
					add_child(prev)
					info.preview = prev
				touches[idx] = info
		else:
			if touches.has(idx):
				var info = touches[idx]
				var drop_target = gui_pick_at(event.position)
				if drop_target and drop_target.has_method("_drop_data"):
					drop_target._drop_data(event.position, info.data)
				if info.has("preview") and is_instance_valid(info.preview):
					info.preview.queue_free()
				touches.erase(idx)

	# update mouse preview with motion
	elif event is InputEventMouseMotion:
		var idx = 0
		if touches.has(idx):
			var info = touches[idx]
			if info.has("preview") and is_instance_valid(info.preview):
				info.preview.position = event.position


# Helper: find topmost Control under a global position
func gui_pick_at(global_pos: Vector2) -> Control:
	var root = get_tree().get_root()
	return _gui_pick_recursive(root, global_pos)

func _gui_pick_recursive(node: Node, global_pos: Vector2) -> Control:
	# traverse children in reverse to prefer top-most stacked controls
	for i in range(node.get_child_count() - 1, -1, -1):
		var child = node.get_child(i)
		var found = _gui_pick_recursive(child, global_pos)
		if found:
			return found

	# check this node after children (so children are prioritized)
	if node is Control and node.is_visible_in_tree():
		# ignore controls that deliberately don't receive pointer events (previews)
		if node.mouse_filter == Control.MOUSE_FILTER_IGNORE:
			return null
		var rect = node.get_global_rect()
		if rect.has_point(global_pos):
			return node
	return null
