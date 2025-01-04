package player

import rl "vendor:raylib"

Player :: struct {
	position:  rl.Vector3,
	direction: MovableDirection,
	healt:     int,
	inventory: Inventory,
	gold:      int,
	power:     int,
}

MovableDirection :: enum {
	North,
	East,
	South,
	West,
}


player_render :: proc(player: ^Player) {
	rl.DrawCube(player.position, 1.0, 0.5, 1.0, rl.BEIGE)
}

player_update :: proc(player: ^Player) {
	deltaTime := rl.GetFrameTime()

	input := get_input_vec()

	speed := 5.0
	player.position.x += input.x * f32(speed) * deltaTime
	player.position.y += input.y * f32(speed) * deltaTime
	player.position.z += input.z * f32(speed) * deltaTime
}


get_input_vec :: proc() -> rl.Vector3 {
	input := rl.Vector3{}

	if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) {
		input.x = -1
	}

	if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) {
		input.x = 1
	}

	if rl.IsKeyDown(.SPACE) {
		input.y = 1
	}

	if rl.IsKeyDown(.LEFT_SHIFT) || rl.IsKeyDown(.RIGHT_SHIFT) {
		input.y = -1
	}

	if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) {
		input.z = +1
	}

	if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) {
		input.z = -1
	}

	if input.x != 0 || input.y != 0 || input.z != 0 {
		input = rl.Vector3Normalize(input)
	}

	return input
}
