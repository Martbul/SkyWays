package npcs

import "../pkg"
import "core:math"
import rl "vendor:raylib"

NPC :: struct {
	position:             rl.Vector3,
	rotation:             rl.Vector3,
	model:                rl.Model,
	state:                NPCState,
	patrol_points:        []rl.Vector3,
	current_patrol_index: int,
	detection_radius:     f32,
	movement_speed:       f32,
	animation:            Animation_State,
}

NPCState :: enum {
	Idle,
	Patrolling,
	Chasing,
	Interacting,
}

Animation_State :: struct {
	current_frame:   int,
	frame_counter:   int,
	frame_speed:     int,
	animation_count: int,
}

create_npc :: proc(
	model_path: cstring,
	initial_pos: rl.Vector3,
	patrol_points: []rl.Vector3,
	speed: f32 = 2.0,
	detection_radius: f32 = 5.0,
) -> ^NPC {
	npc := new(NPC)
	npc.model = rl.LoadModel(model_path)
	npc.position = initial_pos
	npc.rotation = rl.Vector3{0, 0, 0}
	npc.patrol_points = patrol_points
	npc.current_patrol_index = 0
	npc.state = .Idle
	npc.movement_speed = speed
	npc.detection_radius = detection_radius
	npc.animation = Animation_State {
		current_frame   = 0,
		frame_counter   = 0,
		frame_speed     = 8,
		animation_count = 0,
	}
	return npc
}


update_npc :: proc(npc: ^NPC, player_pos: rl.Vector3, delta_time: f32) {
	switch npc.state {
	case .Idle:
		npc.state = .Patrolling

	case .Patrolling:
		target := npc.patrol_points[npc.current_patrol_index]
		dir := rl.Vector3Normalize(target - npc.position)
		npc.position = npc.position + (dir * npc.movement_speed * delta_time)

		// Check if reached current patrol point
		if rl.Vector3Distance(npc.position, target) < 0.5 {
			npc.current_patrol_index = (npc.current_patrol_index + 1) % len(npc.patrol_points)
		}

		// Check if player is within detection radius
		if rl.Vector3Distance(npc.position, player_pos) < npc.detection_radius {
			npc.state = .Chasing
		}

	case .Chasing:
		// Move towards player
		dir := rl.Vector3Normalize(player_pos - npc.position)
		npc.position = npc.position + (dir * npc.movement_speed * 1.5 * delta_time)

		// Return to patrolling if player is out of range
		if rl.Vector3Distance(npc.position, player_pos) > npc.detection_radius * 1.5 {
			npc.state = .Patrolling
		}

	case .Interacting:
	// Handle interaction animations or dialogue
	// Add your interaction logic here
	}

	// Update rotation to face movement direction
	if npc.state != .Idle {
		target_pos :=
			player_pos if npc.state == .Chasing else npc.patrol_points[npc.current_patrol_index]
		dir := target_pos - npc.position
		npc.rotation.y = rl.RAD2DEG * math.atan2(dir.x, dir.z)
	}
}


draw_npc :: proc(npc: ^NPC) {
	pkg.info("Creating NPC")
	rl.DrawModel(npc.model, npc.position, 1.0, rl.WHITE)
}

destroy_npc :: proc(npc: ^NPC) {
	rl.UnloadModel(npc.model)
	free(npc)
}
