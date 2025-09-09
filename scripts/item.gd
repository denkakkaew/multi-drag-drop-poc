# ...existing code...
extends TextureRect

@export_enum("TreeShort", "TreeShortAlt") var type = 1

func _get_drag_data(at_position):
	var data = {
		"texture": texture,
		"type": type,
		"origin": self
	}
	# simple preview used by the multi-touch manager if desired
	var prev = TextureRect.new()
	prev.texture = texture
	set_drag_preview(prev)
	return data
