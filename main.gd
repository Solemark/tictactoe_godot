extends Node

@export var circle_scene: PackedScene
@export var cross_scene: PackedScene

var player: int
var node: Node
var board_width: int
var board_height: int
var grid_data: Array
var winner: String
const grid_pins: Array = [
	[Vector2(111.0, 90), Vector2(450.0, 88.0), Vector2(775, 95.0)],
	[Vector2(108.0, 305.0), Vector2(441.0, 306.0), Vector2(773.0, 301.0)],
	[Vector2(120.0, 505.0), Vector2(439.0, 505.0), Vector2(760.0, 505.0)],
]

func _ready() -> void:
	board_width = $Board.texture.get_width()
	board_height = $Board.texture.get_height()
	new_game()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && winner == "":
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed && event.position[0] <= 900:
			var pos = Vector2i(get_column(event.position[0]), get_row(event.position[1]))
			if grid_data[pos.y-1][pos.x-1] == 0:
				grid_data[pos.y-1][pos.x-1] = player
				node.queue_free()
				create_marker(pos)
				create_marker(pos, true)
				player *= -1
				validate_board()

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
	player = 1
	grid_data = [
		[0, 0, 0],
		[0, 0, 0],
		[0, 0, 0],
	]
	create_marker(Vector2i(0, 0), true)
	winner = ""

func create_marker(pos: Vector2i, temp: bool = false) -> void:
	#create a marker node and add as child
	const panel_pos = Vector2i(1051, 175)
	const scale = Vector2(0.2, 0.2)
	var position = grid_pins[pos.y-1][pos.x-1]
	if player == -1:
		node = circle_scene.instantiate()
		node.scale = scale
		if temp:
			node.position = panel_pos
		else:
			node.position = position
		add_child(node)
	else:
		node = cross_scene.instantiate()
		node.scale = scale
		if temp:
			node.position = panel_pos
		else:
			node.position = position
		add_child(node)

# cross = 1, circle = -1
func validate_board() -> void:
	# check rows for a win
	if abs(grid_data[0][0] + grid_data[0][1] + grid_data[0][2]) == 3:
		winner = get_winner(grid_data[0][0])
	if abs(grid_data[1][0] + grid_data[1][1] + grid_data[1][2]) == 3:
		winner = get_winner(grid_data[1][0])
	if abs(grid_data[2][0] + grid_data[2][1] + grid_data[2][2]) == 3:
		winner = get_winner(grid_data[2][0])
	
	# check cols for a win
	if abs(grid_data[0][0] + grid_data[1][0] + grid_data[2][0]) == 3:
		winner = get_winner(grid_data[0][0])
	if abs(grid_data[0][1] + grid_data[1][1] + grid_data[2][1]) == 3:
		winner = get_winner(grid_data[0][1])
	if abs(grid_data[0][2] + grid_data[1][2] + grid_data[2][2]) == 3:
		winner = get_winner(grid_data[0][3])
	
	# check diags for a win
	if abs(grid_data[0][0] + grid_data[1][1] + grid_data[2][2]) == 3:
		winner = get_winner(grid_data[0][0])
	if abs(grid_data[0][2] + grid_data[1][1] + grid_data[2][0]) == 3:
		winner = get_winner(grid_data[0][2])
	$WinnerLabel.text = winner

func get_winner(i: int) -> String:
	if i == 1:
		return "Crosses Wins!"
	else:
		return "Circles Wins!"
