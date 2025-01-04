package main

import perf "../performance"
import "../pkg"
import pl "../player"
import "../shared"
import tgen "../terrain_generation"
import "../textures"
import "core:fmt"
import "core:log"
import rl "vendor:raylib"


SCREEN_WIDTH :: 1300
SCREEN_HEIGHT :: 850

pause := false

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "SkyWays")

	player := init_game()

	defer rl.CloseWindow()
	defer pl.unload_player(&player)
	defer textures.cleanup_custom_material()
	defer textures.cleanup_terrain_elements()

	for !rl.WindowShouldClose() {
		pl.player_update(&player)
		camera := pkg.init_camera(&player)

		rl.BeginDrawing()
		rl.ClearBackground(rl.DARKBLUE)
		rl.BeginMode3D(camera)

		tgen.init_terrain_instances()
		pl.player_render(&player)
		draw_game(&player)

		//	pl.handle_inventory_input(&player)
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
	textures.init_concrete_elements()

	player := pl.init_player()
	return player
}


draw_game :: proc(player: ^pl.Player) {
	textures.draw_custom_material()
	pl.draw_inventory(player.inventory)
	for instance in shared.Terrain_instances {
		log.info(instance)
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
		case .ConcreteCube:
			textures.draw_concrete_cube(instance.position, instance.scale)
		case .ConcreteIslandPlatform:
			textures.draw_concrete_island_platform(instance.position, instance.scale)
		case .ConcreteFormation:
			textures.draw_concrete_formation(instance.position, instance.scale)
		case .ConcreteWall:
			textures.draw_concrete_wall(instance.position, instance.scale)
		case .ConcretePillar:
			textures.draw_concrete_pillar(instance.position, instance.scale)
		}
	}


}
