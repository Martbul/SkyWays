package main

import "core:fmt"
import perf "performance"
import "pkg"
import pl "player"
import "textures"
import rl "vendor:raylib"


SCREEN_WIDTH :: 1300
SCREEN_HEIGHT :: 850

pause := false

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
		position  = rl.Vector3{0, 0, 0},
		direction = .East,
		healt     = 100,
		inventory = pl.Inventory{},
		gold      = 1,
		power     = 100,
	}
	return player
}

draw_game :: proc() {
	textures.draw_custom_material()
	textures.draw_island(rl.Vector3{0, 0, 0})
	textures.draw_cliff_wall(rl.Vector3{-5, 0, -5})
	textures.draw_rock_formation(rl.Vector3{5, 0, 5})


}
