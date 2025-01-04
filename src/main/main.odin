package main

import perf "../performance"
import "../pkg"
import pl "../player"
import "../shared"
import "../textures"
import "core:fmt"
import rl "vendor:raylib"


SCREEN_WIDTH :: 1300
SCREEN_HEIGHT :: 850

pause := false
init_terrain_instances :: proc() {
	// Initialize the dynamic array
	shared.Terrain_instances = make([dynamic]shared.TerrainInstance)

	// Add base island
	append(
		&shared.Terrain_instances,
		shared.TerrainInstance {
			model_type = .IslandPlatform,
			position = rl.Vector3{0, 0, 0},
			scale = 1.0,
			bounds = scaled_bounds(textures.terrain.island_platform.bounding_box, 1.0),
		},
	)

	// Add cliff wall
	append(
		&shared.Terrain_instances,
		shared.TerrainInstance {
			model_type = .CliffWall,
			position = rl.Vector3{-5, 0, -5},
			scale = 1.0,
			bounds = scaled_bounds(textures.terrain.cliff_wall.bounding_box, 1.0),
		},
	)

	// Add rock formation
	append(
		&shared.Terrain_instances,
		shared.TerrainInstance {
			model_type = .RockFormation,
			position = rl.Vector3{5, 0, 5},
			scale = 1.0,
			bounds = scaled_bounds(textures.terrain.rock_formation.bounding_box, 1.0),
		},
	)
}

cleanup_terrain_instances :: proc() {
	delete(shared.Terrain_instances)
}

scaled_bounds :: proc(box: rl.BoundingBox, scale: f32) -> rl.BoundingBox {
	return rl.BoundingBox {
		min = rl.Vector3{box.min.x * scale, box.min.y * scale, box.min.z * scale},
		max = rl.Vector3{box.max.x * scale, box.max.y * scale, box.max.z * scale},
	}
}

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "SkyWays")
	defer rl.CloseWindow()

	player := init_game()

	defer textures.cleanup_custom_material()
	defer textures.cleanup_terrain_elements()

	for !rl.WindowShouldClose() {
		pl.player_update(&player)
		camera := pkg.init_camera(&player)

		rl.BeginDrawing()
		rl.ClearBackground(rl.DARKBLUE)
		rl.BeginMode3D(camera)

		init_terrain_instances()
		pl.player_render(&player)
		draw_game()
		rl.EndMode3D()

		screen_text := pkg.format_screen_text(&player)

		rl.DrawText(screen_text["coords"], 10, 10, 10, rl.BLACK)
		rl.DrawText(screen_text["gold"], 10, 30, 30, rl.GOLD)

		perf.update_performance_stats()
		perf.draw_performance_overlay()

		rl.EndDrawing()
	}
}

init_game :: proc() -> pl.Player {
	perf.init_performance_tracking()
	textures.init_custom_material()
	textures.init_terrain_elements()

	player := pl.Player {
		position          = rl.Vector3{0, 2, 0},
		previous_position = rl.Vector3{0, 2, 0},
		direction         = .East,
		health            = 100,
		inventory         = pl.Inventory{},
		gold              = 1,
		power             = 100,
	}
	return player
}


draw_game :: proc() {
	textures.draw_custom_material()

	for instance in shared.Terrain_instances {
		switch instance.model_type {
		case .RockyCube:
			textures.draw_rocky_cube(instance.position, instance.scale)
		case .IslandPlatform:
			textures.draw_island_platform(instance.position, instance.scale)
		case .RockFormation:
			textures.draw_rock_formation(instance.position, instance.scale)
		case .CliffWall:
			textures.draw_cliff_wall(instance.position, instance.scale)
		case .TerrainPillar:
			textures.draw_terrain_pillar(instance.position, instance.scale)
		}
	}
}
