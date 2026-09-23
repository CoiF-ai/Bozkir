extends RefCounted
static func convert_safe(view_size: Vector2, pixel_size: Vector2, safe_pixels: Rect2) -> Rect2:
	var full := Rect2(Vector2.ZERO,view_size)
	if pixel_size.x<=0 or pixel_size.y<=0 or safe_pixels.size.x<=0 or safe_pixels.size.y<=0: return full
	var scale := view_size/pixel_size
	return full.intersection(Rect2(safe_pixels.position*scale,safe_pixels.size*scale))
static func safe_rect(viewport: Viewport) -> Rect2:
	var full := viewport.get_visible_rect()
	if not OS.has_feature("mobile"): return full
	var safe := Rect2(DisplayServer.get_display_safe_area())
	var screen := Vector2(DisplayServer.screen_get_size())
	var result := convert_safe(full.size,screen,safe)
	return result if result.size.x>0 and result.size.y>0 else full
