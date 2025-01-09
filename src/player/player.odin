package player

import "../constants"
import "../physics"
import "../shared"
import "../textures"
import "core:fmt"
import "core:log"
import "core:math"
import rl "vendor:raylib"


TERMINAL_VELOCITY: f32 = -50.0
JUMP_FORCE: f32 = 5.0
PLAYER_SPEED: f32 = 5.0
GRAVITY: f32 = 9.8
MODEL_PATH :: "assets/models/player4.obj"
AIR_RESISTANCE: f32 = 0.1


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
	model:             rl.Model,
	animation:         rl.ModelAnimation,
	anim_frame:        int,
	rotation:          f32,
	model_loaded:      bool,
	animation_loaded:  bool,
	anim_frame_f32:    f32,
}

MovableDirection :: enum {
	North,
	East,
	South,
	West,
}


init_player :: proc() -> Player {
	player := Player {
		position          = rl.Vector3{0, 5, 0},
		previous_position = rl.Vector3{0, 5, 0},
		health            = 100,
		gold              = 1,
		power             = 100,
		model_loaded      = false,
		animation_loaded  = false,
		inventory         = init_inventory(),
	}

	player.model = rl.LoadModel(MODEL_PATH)

	if player.model.meshCount <= 0 {
		log.error("Failed to load model mesh from:", MODEL_PATH)
	} else {
		player.model_loaded = true
	}

	diffuseTexture := rl.LoadTexture("assets/models/vanguard_diffuse1.png")
	normalTexture := rl.LoadTexture("assets/models/vanguard_normal.png")

	for i in 0 ..< int(player.model.materialCount) {
		player.model.materials[i].maps[constants.MAP_DIFFUSE].texture = diffuseTexture
		player.model.materials[i].maps[constants.MAP_NORMAL].texture = normalTexture
	}

	anim_count: i32
	anims := rl.LoadModelAnimations(MODEL_PATH, &anim_count)

	if anim_count > 0 && anims != nil {
		player.animation = anims[0]
		player.animation_loaded = true
	} else {
		log.error("Failed to load animations from:", MODEL_PATH)
	}

	return player
}


player_render :: proc(player: ^Player) {
	if !player.model_loaded {
		return
	}


	delta_time := rl.GetFrameTime()
	frames_per_second: f32 = 30.0


	model_pos := player.position
	model_pos.y += 1.0
	scale := rl.Vector3{0.020, 0.020, 0.020}

	if player.velocity.x != 0 || player.velocity.z != 0 {
		// Calculate rotation angle from velocity
		target_rotation := math.atan2(player.velocity.x, player.velocity.z)
		target_rotation_degrees := target_rotation * 180.0 / math.PI

		// Smooth rotation transition
		rotation_speed := 720.0 * delta_time // Degrees per second
		current_rotation := player.rotation

		// Find shortest rotation path
		rotation_diff := target_rotation_degrees - current_rotation
		if rotation_diff > 180 {
			rotation_diff -= 360
		} else if rotation_diff < -180 {
			rotation_diff += 360
		}

		// Apply smooth rotation
		if abs(rotation_diff) > 0.1 {
			if rotation_diff > 0 {
				player.rotation += min(rotation_speed, rotation_diff)
			} else {
				player.rotation -= min(rotation_speed, abs(rotation_diff))
			}
		}
	}

	if player.animation_loaded {
		is_moving := player.velocity.x != 0 || player.velocity.z != 0

		if is_moving {
			// Update animation frame based on time
			frame_progress := frames_per_second * delta_time
			player.anim_frame_f32 += frame_progress

			// Wrap animation frame
			if player.anim_frame_f32 >= f32(player.animation.frameCount) {
				player.anim_frame_f32 = 0
			}

			// Update model animation
			player.anim_frame = int(player.anim_frame_f32)
			rl.UpdateModelAnimation(player.model, player.animation, i32(player.anim_frame))
		} else {
			// Reset to idle frame when not moving
			player.anim_frame = 0
			player.anim_frame_f32 = 0
			rl.UpdateModelAnimation(player.model, player.animation, 0)
		}
	}

	rl.DrawModelEx(player.model, model_pos, rl.Vector3{0, 1, 0}, player.rotation, scale, rl.WHITE)
}


unload_player :: proc(player: ^Player) {
	if player.model_loaded {
		rl.UnloadModel(player.model)
	}
	if player.animation_loaded {
		rl.UnloadModelAnimation(player.animation)
	}
}


lerp :: proc(start, end, t: f32) -> f32 {
	return start + t * (end - start)

}


player_update :: proc(player: ^Player) {
	deltaTime := rl.GetFrameTime()

	player.previous_position = player.position

	if !player.is_on_ground {
		player.velocity.y -= GRAVITY * deltaTime

		if player.velocity.y < TERMINAL_VELOCITY {
			player.velocity.y = TERMINAL_VELOCITY
		}
	}

	input := physics.get_input_vec()

	player.velocity.x = input.x * PLAYER_SPEED
	player.velocity.z = input.z * PLAYER_SPEED

	player.velocity.x *= 1.0 - (AIR_RESISTANCE * deltaTime)
	player.velocity.z *= 1.0 - (AIR_RESISTANCE * deltaTime)

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

	// Determine the axis of minimum penetration
	if overlap_y < overlap_x && overlap_y < overlap_z {
		// Y-axis collision
		if player.velocity.y > 0 {
			player.position.y = obstacle_box.min.y - 0.25
			player.velocity.y = 0
		} else {
			player.position.y = obstacle_box.max.y + 0.25
			player.velocity.y = 0
			player.is_on_ground = true
		}
	} else if overlap_x < overlap_y && overlap_x < overlap_z {
		// X-axis collision
		if player.velocity.x > 0 {
			player.position.x = obstacle_box.min.x - 0.5
		} else {
			player.position.x = obstacle_box.max.x + 0.5
		}
		player.velocity.x = 0
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
