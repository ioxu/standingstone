@tool # TODO : 3.5 : re-enable
@icon("res://scripts/icons/Plot2D.svg")
class_name Plot2D
extends Node2D

#class_name Plot2D, "res://scripts/icons/Plot2D.svg"

## 2d plotting widget to graph values over time
## can plot single points, bars and columns
## colours can be blended with colours beneath 

var texture_rect := TextureRect.new()
var image := Image.new()
var clear_image := Image.new()
var full_image := Image.new()
var time_marker_image := Image.new()
var image_texture := ImageTexture.new()

@export var theme : Theme:
	set = set_theme

#export var title := "" setget set_title
@export var title := "":
	set = set_title
	
var title_label = Label.new()

#export var title_color := Color.white setget set_title_color
@export var title_color := Color.WHITE:
	set = set_title_color

#export var width := 200 setget set_width
@export var width := 200:
	set = set_width

#export var height := 50 setget set_height
@export var height := 50:
	set = set_height

#export var view_scale := Vector2(1.0, 1.0) setget set_view_scale
@export var view_scale := Vector2(1.0, 1.0):
	set = set_view_scale

# decide on how units are mapped to the TextureRect
# for now the height is normalised 0 to 1
#export var y_value_min := 0.0
#export var y_value_max := 100.0

#export var continuous_update := true # perform updates per update tick in _process
#export var update_frequency_fps:= 60.0 # in fps
@export var update_frequency_fps := 60.0

var update_frequency_timer := 0.0

# which side to add new plot values to (Right means plot will scroll from right to left)
#enum UpdateSide{ Left, Right }
#export(UpdateSide) var side = UpdateSide.Right setget set_side 
#@export_enum("Left", "Right") var side : String = "Right":
enum UpdateSide{ Left, Right }
@export var side : UpdateSide = UpdateSide.Right: # TODO : 3.5 : check this is working
	set = set_side

#export var color_clear = Color(0,0,0,0)
@export var color_clear := Color(0,0,0,0)
#export var color_plot = Color(0.12616, 0.609375, 0.264221) * 0.75 
@export var color_plot = Color(0.12616, 0.609375, 0.264221) * 0.75
#export var plot_time_marker := true
@export var plot_time_marker := true
var gtime := 0.0
var marker_timer = 0.0
#export var time_marker_frequency_fps := 1.0 # every second
@export var time_marker_frequency_fps := 1.0 # every second
#export var color_time_marker = Color(0.47, 0.91, 0.26, 0.13)
@export var color_time_marker := Color(0.47, 0.91, 0.26, 0.13)

#export var draw_border := true
@export var draw_border := true
#export var border_color := Color(1, 1, 1, 0.25) setget set_border_color
@export var border_color := Color(1, 1, 1, 0.25):
	set = set_border_color
#export var border_thickness := 1.0 setget set_border_thickness
@export var border_thickness := 1.0:
	set = set_border_thickness

#var default_font = Control.new().get_font("font")

# y_rules are additional horizontal lines across the graph
# add new horizontal rules with Plot2D.add_y_rule()
var _y_rules := {}


func _ready() -> void:
	self.add_child( texture_rect )
	texture_rect.set_flip_v(true)
	texture_rect._set_size( Vector2( width, height ) )
	#texture_rect.rect_scale = view_scale
	texture_rect.scale = view_scale
	image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill( color_clear )
	print("image: %s"%image)
	clear_image = Image.create(1, height, false, Image.FORMAT_RGBA8)
	clear_image.fill( color_clear )
	print("clear_image: %s"%clear_image)
	full_image = Image.create(1, height, false, Image.FORMAT_RGBA8)
	full_image.fill( color_plot )
	print("full_image: %s"%full_image)
	time_marker_image = Image.create(1, height, false, Image.FORMAT_RGBA8)
	time_marker_image.fill( color_time_marker )
	print("time_marker_image: %s"%time_marker_image)
	#image_texture.create(width, height, Image.FORMAT_RGBA8, 0) # 3.5
	#var im = Image.create( width, height, false, Image.FORMAT_RGBA8 )
	#print("im: %s"%im)
	image_texture = ImageTexture.create_from_image( image )
	#image_texture.set_image( im )
	print("image_texture create: %s"%image_texture)
	#image_texture.set_data(image) # 3.5
	#image_texture.set_image( image )
	#print("imag_texture set_image: %s"%image_texture)
#	image_texture.update( image )
#	print("imag_texture update: %s"%image_texture)
	texture_rect.texture = image_texture
	print("texture_rect.texture: %s"%texture_rect.texture)

	self.add_child(title_label)
	title_label.text = str(title)
	title_label.modulate = title_color


func _process(delta: float) -> void:
	if !self.visible:
		return
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
		#self.image_texture.set_data(self.image)
		self.image_texture.set_image(self.image)
	
	#update() # 3.5
	queue_redraw()


func _draw() -> void:
	if !self.visible:
		return

	if draw_border:
		# TODO: immediate mode ornaments that should be pre-rendered
		var tl = Vector2.ZERO
		#var tr = Vector2(width, 0.0) * texture_rect.rect_scale[0] - Vector2(1,0) # 3.5
		var tr = Vector2(width, 0.0) * texture_rect.scale[0] - Vector2(1,0)
		#var bl = Vector2(0.0, height) * texture_rect.rect_scale[1] # 3.5
		var bl = Vector2(0.0, height) * texture_rect.scale[1]
		#var br = Vector2(width, height) * texture_rect.rect_scale - Vector2(1,0) # 3.5
		var br = Vector2(width, height) * texture_rect.scale - Vector2(1,0)
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
func push_point(value:float, color:Color=Color.WHITE) -> void:
	if !self.visible:
		return
	#self.image.lock() # 3.5
	self.image.set_pixel( width-1, int(min(height-1, value*height)), color )
	#self.image.unlock() # 3.5


func push_point_blend(value:float, color:Color=Color.WHITE) -> void:
	if !self.visible:
		return
	var w = width -1
	var h = min(height-1, int(value*height))
	#self.image.lock() # 3.5
	var p = self.image.get_pixel( w, h)
	self.image.set_pixel( w, h, p.blend(color) )
	#self.image.unlock() # 3.5


func push_column(value:float, color:Color=Color.WHITE) -> void:
	push_line(0.0, value, color)


func push_column_blend(value:float, color:Color=Color.WHITE) -> void:
	push_line_blend(0.0, value, color)


func push_line(value_from:float, value_to:float, color:Color=Color.WHITE) -> void:
	if !self.visible:
		return
	var di = floor(abs(value_to - value_from) * height)
	var f = min(value_from, value_to)
	#self.image.lock() # 3.5
	for i in range(di):
		self.image.set_pixel( width-1, int(min(height-1, f*height + i)) , color )
	#self.image.unlock() # 3.5


func push_line_blend(value_from:float, value_to:float, color:Color=Color.WHITE) -> void:
	if !self.visible:
		return
	var p = Color(0.0, 0.0, 0.0, 0.0)
	var di = floor(abs(value_to - value_from) * height)
	var f = min(value_from, value_to)
	self.image.lock()
	for i in range(di):
		p = self.image.get_pixel( width-1, f*height + i)
		self.image.set_pixel( width-1, int(min( height-1, f*height+i )) , p.blend( color ) )
	self.image.unlock()


################################################################################
func set_theme(new_value) -> void:
	theme = new_value
	title_label.theme = new_value

func set_title(new_value) -> void:
	title = new_value
	title_label.text = new_value


func set_title_color(new_value) -> void:
	title_color = new_value
	title_label.modulate = title_color


func set_width(new_value) -> void:
	width = new_value
	update_rect()
	#update()
	queue_redraw ( )


func set_height(new_value) -> void:
	height = new_value
	update_rect()
	#update()
	queue_redraw ( )


func set_view_scale(new_value) -> void:
	view_scale = new_value
	update_rect()
	#update()
	queue_redraw ( )


func set_side(new_value) -> void:
	side = new_value
	if new_value == UpdateSide.Left:
		texture_rect.set_flip_h(true)
	elif new_value == UpdateSide.Right:
		texture_rect.set_flip_h(false)


func set_border_thickness(new_value) -> void:
	border_thickness = new_value
	#update()
	queue_redraw ( )


func set_border_color(new_value) -> void:
	border_color = new_value
	#update()
	queue_redraw ( )


func update_rect() -> void:
	texture_rect._set_size( Vector2( width, height ) )
	texture_rect.rect_scale = view_scale


################################################################################
func pprint(thing) -> void:
	print("[Plot2D:%s] %s"%[self.get_name(), thing])


func test_image() -> void:
	image.lock()
	image.set_pixel(0,0,Color.RED)
	image.set_pixel(width-1,0,Color.RED)
	image.set_pixel(width-1,height-1,Color.RED)
	image.set_pixel(0,height-1,Color.RED)
	image.unlock()
	image_texture.set_data(image)
