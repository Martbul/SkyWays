package pkg

import pl "../player"
import "core:fmt"

format_screen_text :: proc(player: ^pl.Player) -> map[string]cstring {
	screen_text := make(map[string]cstring)

	coord_text := fmt.aprintf(
		"x: %.2f, y: %.2f, z: %.2f",
		player.position.x,
		player.position.y,
		player.position.z,
	)

	coords: cstring = fmt.caprintf(coord_text)
	gold: cstring = fmt.ctprint(player.gold)


	screen_text["coords"] = coords
	screen_text["gold"] = gold

	return screen_text
}
