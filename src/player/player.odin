package player

import "../shared"
import rl "vendor:raylib"
JUMP_FORCE: f32 = 5.0
PLAYER_SPEED: f32 = 5.0
GRAVITY: f32 = 9.8

Player :: struct {
	position:          rl.Vector3,
	previous_position: rl.Vector3,
	velocity:          rl.Vector3,
	direction:         MovableDirection,
	is_on_ground:      bool,
	health:            int,
	inventory:         Inventory,
	gold:              int,
	power:             int,
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

	player.previous_position = player.position

	if !player.is_on_ground {
		player.velocity.y -= GRAVITY * deltaTime
	}
	input := get_input_vec()

	player.velocity.x = input.x * PLAYER_SPEED
	player.velocity.z = input.z * PLAYER_SPEED

	if rl.IsKeyPressed(.SPACE) && player.is_on_ground {
		player.velocity.y = JUMP_FORCE
		player.is_on_ground = false
	}

	player.position += player.velocity * deltaTime

	check_collisions(player)
}


check_collisions :: proc(player: ^Player) {
	player_box := get_player_bounds(player)

	ground_level: f32 = 0.0
	if player.position.y - 0.25 <= ground_level {
		player.position.y = ground_level + 0.25
		player.velocity.y = 0
		player.is_on_ground = true
	}

	// Check collision with all terrain instances
	for instance in shared.Terrain_instances {
		obstacle_box := shared.get_transformed_bounding_box(instance)
		if rl.CheckCollisionBoxes(player_box, obstacle_box) {
			resolve_collision(player, obstacle_box)
			// If we hit something from above, we're on ground
			if player.velocity.y < 0 && player.previous_position.y > obstacle_box.max.y {
				player.is_on_ground = true
			}
		}
	}
}

resolve_collision :: proc(player: ^Player, obstacle_box: rl.BoundingBox) {
	// Calculate penetration depth in each axis
	overlap_x := min(
		player.position.x + 0.5 - obstacle_box.min.x,
		obstacle_box.max.x - (player.position.x - 0.5),
	)
	overlap_y := min(
		player.position.y + 0.25 - obstacle_box.min.y,
		obstacle_box.max.y - (player.position.y - 0.25),
	)
	overlap_z := min(
		player.position.z + 0.5 - obstacle_box.min.z,
		obstacle_box.max.z - (player.position.z - 0.5),
	)

	// Find minimum penetration axis
	if overlap_x < overlap_y && overlap_x < overlap_z {
		// X-axis collision
		if player.velocity.x > 0 {
			player.position.x = obstacle_box.min.x - 0.5
		} else {
			player.position.x = obstacle_box.max.x + 0.5
		}
		player.velocity.x = 0
	} else if overlap_y < overlap_x && overlap_y < overlap_z {
		// Y-axis collision
		if player.velocity.y > 0 {
			player.position.y = obstacle_box.min.y - 0.25
			player.velocity.y = 0
		} else {
			player.position.y = obstacle_box.max.y + 0.25
			player.velocity.y = 0
			player.is_on_ground = true
		}
	} else {
		// Z-axis collision
		if player.velocity.z > 0 {
			player.position.z = obstacle_box.min.z - 0.5
		} else {
			player.position.z = obstacle_box.max.z + 0.5
		}
		player.velocity.z = 0
	}
}

get_player_bounds :: proc(player: ^Player) -> rl.BoundingBox {
	return rl.BoundingBox {
		min = rl.Vector3 {
			player.position.x - 0.5,
			player.position.y - 0.25,
			player.position.z - 0.5,
		},
		max = rl.Vector3 {
			player.position.x + 0.5,
			player.position.y + 0.25,
			player.position.z + 0.5,
		},
	}
}
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
