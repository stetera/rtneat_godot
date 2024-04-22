extends RigidBody2D

const FOOD_VARIATION = 40
const MIN_FOOD_AMOUNT = 20
const FOOD_TO_SCALE_RATIO = 40
const DISSAPEAR_TIME = 2

var food_amount = 50
var food_per_tick = 10

var starting_scale: Vector2 = Vector2(1, 1)
var target_scale

var Random = RandomNumberGenerator.new()
var content_node: CollisionShape2D

func _init()-> void:
	set_gravity_scale(0.0)
	
	var food_increase = randf_range(-FOOD_VARIATION, FOOD_VARIATION)
	food_amount += food_increase


func _physics_process(delta: float) -> void:
	if content_node.scale.x != target_scale.x:
		content_node.scale.x = lerp(content_node.scale.x, target_scale.x, 0.2)
		content_node.scale.y = lerp(content_node.scale.y, target_scale.y, 0.2)

func _ready() -> void:
	content_node = get_node("CollisionShape2D")
	global_rotation = Util.random_i_range(-180, 180)
	connect("body_entered", try_eat)
	
	_recalculate_scale()


func try_eat(body):
	if body.is_in_group("bodies"):
		food_amount -= food_per_tick
		if food_amount > MIN_FOOD_AMOUNT:
			body._give_food(food_per_tick * 6)
			_recalculate_scale()
		else:
			disconnect("body_entered", try_eat)
			target_scale = Vector2(0,0)
			await get_tree().create_timer(DISSAPEAR_TIME).timeout

			queue_free()


func _recalculate_scale():
	var new_scale = food_amount / FOOD_TO_SCALE_RATIO
	target_scale = Vector2(starting_scale.x, starting_scale.y)  * new_scale

