extends ColorRect

func _can_drop_data(at_position, data):
	return true

func _drop_data(at_position, data):
	# accept either the dictionary produced by item.gd or legacy array form
	var tex = null
	if typeof(data) == TYPE_DICTIONARY and data.has("texture"):
		tex = data.texture
	elif typeof(data) == TYPE_ARRAY and data.size() > 0 and data[0] is TextureRect:
		tex = data[0].texture

	if tex:
		var item = TextureRect.new()
		item.texture = tex
		# convert global drop position to local ColorRect coords
		# Control doesn't have to_local(); subtract the control's global position
		item.position = at_position - get_global_position()
		item.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(item)
