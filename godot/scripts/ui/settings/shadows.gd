extends OptionButton

const MODES = {
	VLOW = 512,
	LOW = 2048,
	MEDIUM = 4096,
	HIGH = 8192,
	ULTRA = 8192 * 2,
	EXTREME = 8192 * 4,
}

func _ready() -> void:
	item_selected.connect(_on_item_selected)

func _on_item_selected(idx: int) -> void:
	match idx:
		0:
			## Very Low
			get_viewport().positional_shadow_atlas_16_bits = true
			get_viewport().positional_shadow_atlas_size = MODES.VLOW
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
			RenderingServer.directional_shadow_atlas_set_size(MODES.VLOW, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_VERY_LOW)
		1:
			## Low
			get_viewport().positional_shadow_atlas_16_bits = true
			get_viewport().positional_shadow_atlas_size = MODES.LOW
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
			RenderingServer.directional_shadow_atlas_set_size(MODES.LOW, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_LOW)
		2:
			## Medium (default) 4096 on desktop, 2048 on mobile and web
			get_viewport().positional_shadow_atlas_16_bits = true
			get_viewport().positional_shadow_atlas_size = MODES.MEDIUM
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
			RenderingServer.directional_shadow_atlas_set_size(MODES.MEDIUM, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_MEDIUM)
		3:
			## High
			get_viewport().positional_shadow_atlas_16_bits = true
			get_viewport().positional_shadow_atlas_size = MODES.HIGH
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
			RenderingServer.directional_shadow_atlas_set_size(MODES.HIGH, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
		4:
			## Ultra
			get_viewport().positional_shadow_atlas_16_bits = true
			get_viewport().positional_shadow_atlas_size = MODES.ULTRA
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
			RenderingServer.directional_shadow_atlas_set_size(MODES.ULTRA, true)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_HIGH)
		5:
			## Extreme
			get_viewport().positional_shadow_atlas_16_bits = false
			get_viewport().positional_shadow_atlas_size = MODES.EXTREME
			RenderingServer.positional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
			RenderingServer.directional_shadow_atlas_set_size(MODES.EXTREME, false)
			RenderingServer.directional_soft_shadow_filter_set_quality(RenderingServer.SHADOW_QUALITY_SOFT_ULTRA)
