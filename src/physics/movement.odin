package physics

import rl "vendor:raylib"

get_input_vec :: proc() -> rl.Vector3 {
	input := rl.Vector3{}
	if rl.IsKeyDown(.A) || rl.IsKeyDown(.LEFT) {
		input.x = -1
	}
	if rl.IsKeyDown(.D) || rl.IsKeyDown(.RIGHT) {
		input.x = 1
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
