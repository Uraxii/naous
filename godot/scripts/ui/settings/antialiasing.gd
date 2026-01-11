extends OptionButton

func _ready() -> void:
	item_selected.connect(_on_item_selected)
	
func _on_item_selected(idx: int) -> void:
	var vp = get_viewport()
	match idx:
		0:
			## No AA
			vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
			vp.use_taa = false
			vp.msaa_3d = Viewport.MSAA_DISABLED
		1:
			## FXAA
			vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
			vp.use_taa = false
			vp.msaa_3d = Viewport.MSAA_DISABLED
		2:
			## SMAA
			vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_SMAA
			vp.use_taa = false
			vp.msaa_3d = Viewport.MSAA_DISABLED
		3:
			## MSAA 2x
			vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
			vp.use_taa = false
			vp.msaa_3d = Viewport.MSAA_2X
		4:
			## MSAA 4x
			vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
			vp.use_taa = false
			vp.msaa_3d = Viewport.MSAA_4X
		5:
			## MSAA 8x
			vp.screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
			vp.use_taa = false
			vp.msaa_3d = Viewport.MSAA_8X
