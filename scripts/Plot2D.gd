tool
extends Node2D
class_name Plot2D, "res://scripts/icons/Plot2D.svg"
## 2d plotting widget to graph values over time
## can plot single points, bars and columns
## colours can be blended with colours beneath 

var texture_rect := TextureRect.new()
var image := Image.new()
var clear_image := Image.new()
var full_image := Image.new()
var time_marker_image := Image.new()
var image_texture := ImageTexture.new()

export var title := "" setget set_title
var title_label = Label.new()
export var title_color := Color.white setget set_title_color

export var width := 200 setget set_width
export var height := 50 setget set_height

export var view_scale := Vector2(1.0, 1.0) setget set_view_scale

# decide on how units are mapped to the TextureRect
# for now the height is normalised 0 to 1
#export var y_value_min := 0.0
#export var y_value_max := 100.0

#export var continuous_update := true # perform updates per update tick in _process
export var update_frequency_fps:= 60.0 # in fps
var update_frequency_timer := 0.0

# which side to add new plot values to (Right means plot will scroll from right to left)
enum Side{ Left, Right }
export(Side) var side = Side.Right setget set_side 

export var color_clear = Color(0,0,0,0)
export var color_plot = Color(0.12616, 0.609375, 0.264221) * 0.75 
export var plot_time_marker := true
var gtime := 0.0
var marker_timer = 0.0
export var time_marker_frequency_fps := 1.0 # every second
export var color_time_marker = Color(0.47, 0.91, 0.26, 0.13)

export var draw_border := true
export var border_color := Color(1, 1, 1, 0.25) setget set_border_color
export var border_thickness := 1.0 setget set_border_thickness

var default_font = Control.new().get_font("font")

# y_rules are additional horizontal lines across the graph
# add new horizontal rules with Plot2D.add_y_rule()
var _y_rules := {}


func _ready() -> void:
	self.add_child( texture_rect )
	texture_rect.set_flip_v(true)
	texture_rect._set_size( Vector2( width, height ) )
	texture_rect.rect_scale = view_scale
	image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill( color_clear )
	clear_image.create(1, height, false, Image.FORMAT_RGBA8)
	clear_image.fill( color_clear )
	full_image.create(1, height, false, Image.FORMAT_RGBA8)
	full_image.fill( color_plot )
	time_marker_image.create(1, height, false, Image.FORMAT_RGBA8)
	time_marker_image.fill( color_time_marker )
	image_texture.create(width, height, Image.FORMAT_RGBA8, 0)
	image_texture.set_data(image)
	texture_rect.texture = image_texture

	self.add_child(title_label)
	title_label.text = str(title)
	title_label.modulate = title_color


func _process(delta: float) -> void:
	gtime += delta
	marker_timer += delta
	update_frequency_timer += delta

	if update_frequency_timer > (1.0/update_frequency_fps):
		update_frequency_timer = 0.0

		# shift graph over
		self.image.blit_rect(self.image, Rect2(0, 0, width+1, height), Vector2(-1,0))

		# clear line (blit a clear column)
		self.image.blit_rect(self.clear_image, Rect2(0, 0, 1, height), Vector2(width-1, 0))

		# time marker
		if plot_time_marker and marker_timer > time_marker_frequency_fps:
			image.blend_rect(time_marker_image, Rect2(0,0,1,height), Vector2(width-1, 0))
			marker_timer = 0.0
		
		# commit image data
		self.image_texture.set_data(self.image)
	#update()


func _draw() -> void:
	if draw_border:
		# TODO: immediate mode ornaments that should be pre-rendered
		var tl = Vector2.ZERO
		var tr = Vector2(width, 0.0) * texture_rect.rect_scale[0] - Vector2(1,0)
		var bl = Vector2(0.0, height) * texture_rect.rect_scale[1]
		var br = Vector2(width, height) * texture_rect.rect_scale - Vector2(1,0)
		draw_line(tl, tr, border_color, border_thickness)
		draw_line(tr, br, border_color, border_thickness)
		draw_line(bl, br, border_color, border_thickness)
		draw_line(tl, bl, border_color, border_thickness)
	
		for _k in _y_rules.keys():
			var _d = _y_rules[_k]
			draw_line(tl+(bl-tl)*(1.0-_d.value), tr+(br-tr)*(1.0-_d.value), _d.color, border_thickness)


func add_y_rule(name:String="y rule", value:=0.5, color:Color=Color(0.392157, 0.721569, 0.941176, 0.780392)) -> void:
	_y_rules[name] = {value = value, color = color}


################################################################################
# value: float: 0.0 to 1.0 is remapped to the full height of the graph
# TODO: these methods should buffer edits so they can be all contained between a single lock/unlock pair
func push_point(value:float, color:Color=Color.white) -> void:
	self.image.lock()
	self.image.set_pixel( width-1, int(min(height-1, value*height)), color )
	self.image.unlock()


func push_point_blend(value:float, color:Color=Color.white) -> void:
	var w = width -1
	var h = min(height-1, int(value*height))
	self.image.lock()
	var p = self.image.get_pixel( w, h)
	self.image.set_pixel( w, h, p.blend(color) )
	self.image.unlock()


func push_column(value:float, color:Color=Color.white) -> void:
	push_line(0.0, value, color)


func push_column_blend(value:float, color:Color=Color.white) -> void:
	push_line_blend(0.0, value, color)


func push_line(value_from:float, value_to:float, color:Color=Color.white) -> void:
	var di = floor(abs(value_to - value_from) * height)
	var f = min(value_from, value_to)
	self.image.lock()
	for i in range(di):
		self.image.set_pixel( width-1, int(min(height-1, f*height + i)) , color )
	self.image.unlock()


func push_line_blend(value_from:float, value_to:float, color:Color=Color.white) -> void:
	var p = Color(0.0, 0.0, 0.0, 0.0)
	var di = floor(abs(value_to - value_from) * height)
	var f = min(value_from, value_to)
	self.image.lock()
	for i in range(di):
		p = self.image.get_pixel( width-1, f*height + i)
		self.image.set_pixel( width-1, int(min( height-1, f*height+i )) , p.blend( color ) )
	self.image.unlock()


################################################################################
func set_title(new_value) -> void:
	title = new_value
	title_label.text = new_value


func set_title_color(new_value) -> void:
	title_color = new_value
	title_label.modulate = title_color


func set_width(new_value) -> void:
	width = new_value
	update_rect()
	update()


func set_height(new_value) -> void:
	height = new_value
	update_rect()
	update()


func set_view_scale(new_value) -> void:
	view_scale = new_value
	update_rect()
	update()


func set_side(new_value) -> void:
	side = new_value
	if new_value == Side.Left:
		texture_rect.set_flip_h(true)
	elif new_value == Side.Right:
		texture_rect.set_flip_h(false)


func set_border_thickness(new_value) -> void:
	border_thickness = new_value
	update()


func set_border_color(new_value) -> void:
	border_color = new_value
	update()


func update_rect() -> void:
	texture_rect._set_size( Vector2( width, height ) )
	texture_rect.rect_scale = view_scale


################################################################################
func pprint(thing) -> void:
	print("[Plot2D:%s] %s"%[self.get_name(), thing])


func test_image() -> void:
	image.lock()
	image.set_pixel(0,0,Color.red)
	image.set_pixel(width-1,0,Color.red)
	image.set_pixel(width-1,height-1,Color.red)
	image.set_pixel(0,height-1,Color.red)
	image.unlock()
	image_texture.set_data(image)
