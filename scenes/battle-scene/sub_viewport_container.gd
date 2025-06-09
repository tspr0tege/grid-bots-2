extends SubViewportContainer

#Camera3D default size: 6.75
#camera v_offset +/- 0.1 is fairly significant
const CAMERA_DEFAULT_SIZE = 6.75


func _ready():
	_on_sub_viewport_container_item_rect_changed()


func _on_sub_viewport_container_item_rect_changed():
	var viewportRatio = get_viewport_rect().size / Vector2(1920, 1080)
	
	if viewportRatio.y < 1 and viewportRatio.x >= 1.2:
		$SubViewport/Camera3D.size = CAMERA_DEFAULT_SIZE * (viewportRatio.x - .2)
		$SubViewport/Camera3D.v_offset = -(viewportRatio.x - 1)
	else:
		$SubViewport/Camera3D.size = CAMERA_DEFAULT_SIZE
		$SubViewport/Camera3D.v_offset = viewportRatio.x - 1
	#print(str(viewportRatio))
	# Past a certain horizontal stretch, the y vector becomes a static 0.991667
	# When this is true, the camera starts clipping the bottom as x gets above 1.2
	# It's an INCREDIBLY wide value, but it may not hurt to cover
	#var minAxis = viewportRatio.min_axis_index()
	#print(str(minAxis))
	#$SubViewport/Camera3D.zoom = Vector2(viewportRatio[minAxis], viewportRatio[minAxis])
