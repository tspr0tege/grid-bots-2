extends SubViewportContainer


func _ready():
	_on_sub_viewport_container_item_rect_changed()

func _on_sub_viewport_container_item_rect_changed():
	var viewportRatio = get_viewport_rect().size / Vector2(1920, 1080)
	#print(str(viewportRatio))
	# Past a certain horizontal stretch, the y vector becomes a static 0.991667
	# When this is true, the camera starts clipping the bottom as x gets above 1.2
	# It's an INCREDIBLY wide value, but it may not hurt to cover
	if viewportRatio.y < 1 and viewportRatio.x >= 1.2:
		pass
	#var minAxis = viewportRatio.min_axis_index()
	#print(str(minAxis))
	#$SubViewport/Camera3D.zoom = Vector2(viewportRatio[minAxis], viewportRatio[minAxis])
