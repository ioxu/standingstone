extends Node2D
class_name Plot2D, "res://scripts/icons/Plot2D.svg"

var texture_rect := TextureRect.new()
var image := Image.new()
var clear_image := Image.new()
var full_image := Image.new()
var image_texture := ImageTexture.new()

export var width := 200
export var height := 50 

export var y_value_min := 0.0
export var y_value_max := 100.0

enum Side{ Left, Right }
export(Side) var side = Side.Left 

export var color_clear = Color(0,0,0,0)
export var color_plot = Color(0.12616, 0.609375, 0.264221) * 0.75 
export var color_time_marker = Color(0.12616, 0.609375, 0.264221) * 4.0


func _ready() -> void:
	self.add_child( texture_rect )
	texture_rect._set_size( Vector2( width, height ) )
	image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color_clear)
	clear_image.create(1, height, false, Image.FORMAT_RGBA8)
	clear_image.fill(color_clear)
	full_image.create(1, height, false, Image.FORMAT_RGBA8)
	full_image.fill(color_plot)
	image_texture.create(width, height, Image.FORMAT_RGBA8, 0)
	image_texture.set_data(image)
	texture_rect.texture = image_texture
	test_image()

func push(value:float, color:Color=Color.white) -> void:
	# push a value onto the plot
	pass


func pprint(thing) -> void:
	print("[Plot2D:%s] %s"%[self.get_path(), thing])


func test_image() -> void:
	image.fill( Color(color_plot.r, color_plot.g, color_plot.b, 1.0) )
	image.lock()
	image.set_pixel(0,0,Color.red)
	image.set_pixel(width-1,0,Color.red)
	image.set_pixel(width-1,height-1,Color.red)
	image.set_pixel(0,height-1,Color.red)
	image.unlock()
	image_texture.set_data(image)
