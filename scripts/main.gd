extends Node

@export var circle_scene: PackedScene
@export var cross_scene: PackedScene

var player: int
var node: Node
var grid_data: Array
var turn: int
const grid_pins: Array = [
	[Vector2(111.0, 90), Vector2(450.0, 88.0), Vector2(775, 95.0)],
	[Vector2(108.0, 305.0), Vector2(441.0, 306.0), Vector2(773.0, 301.0)],
	[Vector2(120.0, 505.0), Vector2(439.0, 505.0), Vector2(760.0, 505.0)],
]

func _ready() -> void:
	new_game()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed && event.position[0] <= 900:
			var pos = Vector2i(get_column(event.position[0]), get_row(event.position[1]))
			if grid_data[pos.y-1][pos.x-1] == 0:
				grid_data[pos.y-1][pos.x-1] = player
				node.queue_free()
				create_marker(pos)
				create_marker(pos, true)
				if validate_board():
					get_tree().paused = true
					$GameOverMenu.show()
				player *= -1
				turn += 1

# Covert mouse position to column number
func get_column(c: int) -> int:
	if c <= 240:
		return 1
	elif c >= 241 && c <= 645:
		return 2
	else:
		return 3

func get_row(r: int) -> int:
	if r <= 190:
		return 1
	elif r >= 191 && r <= 430:
		return 2
	else:
		return 3

func new_game() -> void:
	turn = 1
	player = -1
	grid_data = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0],
	]
	get_tree().call_group("circles", "queue_free")
	get_tree().call_group("crosses", "queue_free")
	get_tree().paused = false
	
	create_marker(Vector2i(0, 0), true)
	player *= -1
	$GameOverMenu.hide()

func create_marker(pos: Vector2i, temp: bool = false) -> void:
	const panel_pos = Vector2i(1051, 175)
	const scale = Vector2(0.2, 0.2)
	var position = grid_pins[pos.y-1][pos.x-1]
	if player == 1:
		if temp:
			node = circle_scene.instantiate()
			node.position = panel_pos
		else:
			node = cross_scene.instantiate()
			node.position = position
		node.scale = scale
		add_child(node)
	else:
		if temp:
			node = cross_scene.instantiate()
			node.position = panel_pos
		else:
			node = circle_scene.instantiate()
			node.position = position
		node.scale = scale
		add_child(node)

func validate_board() -> bool:
	# check rows for a win
	var winner = ""
	var win = false
	if abs(grid_data[0][0] + grid_data[0][1] + grid_data[0][2]) == 3:
		winner = get_winner(grid_data[0][0])
		win = true
	if abs(grid_data[1][0] + grid_data[1][1] + grid_data[1][2]) == 3:
		winner = get_winner(grid_data[1][0])
		win = true
	if abs(grid_data[2][0] + grid_data[2][1] + grid_data[2][2]) == 3:
		winner = get_winner(grid_data[2][0])
		win = true
	
	# check cols for a win
	if abs(grid_data[0][0] + grid_data[1][0] + grid_data[2][0]) == 3:
		winner = get_winner(grid_data[0][0])
		win = true
	if abs(grid_data[0][1] + grid_data[1][1] + grid_data[2][1]) == 3:
		winner = get_winner(grid_data[0][1])
		win = true
	if abs(grid_data[0][2] + grid_data[1][2] + grid_data[2][2]) == 3:
		winner = get_winner(grid_data[0][3])
		win = true
	
	# check diags for a win
	if abs(grid_data[0][0] + grid_data[1][1] + grid_data[2][2]) == 3:
		winner = get_winner(grid_data[0][0])
		win = true
	if abs(grid_data[0][2] + grid_data[1][1] + grid_data[2][0]) == 3:
		winner = get_winner(grid_data[0][2])
		win = true
	
	# no one wins
	if !win && turn >= 9:
		winner = "Draw"
		win = true
	$GameOverMenu/GameOverLabel.text = winner
	return win
	

func get_winner(i: int) -> String:
	if i == 1:
		return "Crosses Wins!"
	else:
		return "Circles Wins!"

func _on_game_over_menu_restart() -> void:
	new_game()
