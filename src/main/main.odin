package main

import perf "../performance"
import "../pkg"
import pl "../player"
import "../shared"
import tgen "../terrain_generation"
import "../textures" // Add this import
import "core:fmt"
import "core:log"
import rl "vendor:raylib"

SCREEN_WIDTH :: 1300
SCREEN_HEIGHT :: 850

Game_State :: struct {
	player:       pl.Player,
	item_manager: ^pl.ItemManager,
	pause:        bool,
}

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "SkyWays")
	game_state := init_game()

	defer cleanup_game(&game_state)
	defer rl.CloseWindow()

	for !rl.WindowShouldClose() {
		update_game(&game_state)
		render_game(&game_state)
	}
}

init_game :: proc() -> Game_State {
	perf.init_performance_tracking()
	textures.init_custom_material()
	textures.init_terrain_elements()
	textures.init_concrete_elements()

	// Initialize game state
	game_state := Game_State {
		player       = pl.init_player(),
		item_manager = pl.init_item_manager(),
		pause        = false,
	}

	// Load item resources
	pl.load_item_resources(
		game_state.item_manager,
		"wooden_axe",
		"assets/wooden_axe/wooden_axe_1k.gltf",
		"assets/wooden_axe/wooden_axe.png",
	)

	// Spawn some initial items for testing
	pl.spawn_item(game_state.item_manager, "wooden_axe", {7, 2, 4})

	return game_state
}

update_game :: proc(game_state: ^Game_State) {
	if game_state.pause do return

	pl.player_update(&game_state.player)
	pl.update(game_state.item_manager)

	// Handle item pickup
	if rl.IsKeyPressed(.E) {
		pickup_range := f32(2.0) // Adjust range as needed
		picked_item := pl.pick_up_item(game_state.item_manager, &game_state.player, pickup_range)
		if picked_item != nil {
			// Add to player inventory or handle pickup
			// You'll need to implement this based on your inventory system
		}
	}
}

render_game :: proc(game_state: ^Game_State) {
	camera := pkg.init_camera(&game_state.player)

	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.DARKBLUE)

	rl.BeginMode3D(camera)
	{
		tgen.init_terrain_instances()
		pl.player_render(&game_state.player)
		draw_game(&game_state.player)
		pl.draw(game_state.item_manager) // Draw all items
	}
	rl.EndMode3D()

	screen_text := pkg.format_screen_text(&game_state.player)
	pl.handle_inventory_input(&game_state.player, game_state.item_manager)
	pl.draw_inventory(game_state.player.inventory)

	rl.DrawText(screen_text["coords"], 10, 10, 10, rl.BLACK)
	rl.DrawText(screen_text["gold"], 10, 30, 30, rl.GOLD)

	perf.update_performance_stats()
	perf.draw_performance_overlay()
}

draw_game :: proc(player: ^pl.Player) {
	textures.draw_custom_material()
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

cleanup_game :: proc(game_state: ^Game_State) {
	pl.unload_player(&game_state.player)
	pl.unload_resources(game_state.item_manager)
	textures.cleanup_custom_material()
	textures.cleanup_terrain_elements()
}
