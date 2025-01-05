package player

import "core:fmt"
import "core:strings"
import rl "vendor:raylib"


Item :: struct {
	name:     string,
	quantity: int,
	texture:  rl.Texture2D,
	image:    string,
	power:    int,
	ability:  ability,
}

ability :: enum {
	strong,
	killer,
}

Inventory :: struct {
	items:          [36]Item,
	selected_index: int,
	is_extended:    bool,
}


load_texture :: proc(file_path: string) -> rl.Texture2D {
	return rl.LoadTexture(strings.clone_to_cstring(file_path))
}


init_inventory :: proc() -> Inventory {
	inventory: Inventory
	inventory.is_extended = false


	inventory.items[0] = Item {
		name     = "Wooden Axe",
		texture  = load_texture("assets/wooden_axe/wooden_axe.png"),
		quantity = 5,
	}
	return inventory
}


handle_inventory_input :: proc(player: ^Player) {
	mouse_pos := rl.GetMousePosition()

	slot_size: int = 64
	padding: int = 10
	start_x: int = 20
	max_items_row: int = 6

	if rl.IsKeyPressed(.TAB) {
		player.inventory.is_extended = !player.inventory.is_extended
	}

	if player.inventory.is_extended {

		show_extended_inventory(player, slot_size, padding, max_items_row, start_x, mouse_pos)
	} else {


		hide_extended_inventory(player, slot_size, padding, start_x, mouse_pos)
	}
	if rl.IsKeyPressed(.ONE) do player.inventory.selected_index = 0
	if rl.IsKeyPressed(.TWO) do player.inventory.selected_index = 1
	if rl.IsKeyPressed(.THREE) do player.inventory.selected_index = 2
	if rl.IsKeyPressed(.FOUR) do player.inventory.selected_index = 3
	if rl.IsKeyPressed(.FIVE) do player.inventory.selected_index = 4
}


use_item :: proc(player: ^Player, item_index: int) {
	if item_index >= len(player.inventory.items) {
		return
	}

	item := &player.inventory.items[item_index]
	if item.quantity <= 0 {
		return
	}

	// Handle different item types
	switch item.name {
	case "Health Potion":
		// Apply healing effect
		item.quantity -= 1
		// If quantity reaches 0, you might want to clear the item
		if item.quantity == 0 {
			clear_item(item)
		}
	// Add other item types here
	}
}

drop_item :: proc(player: ^Player, item_index: int) {
	if item_index >= len(player.inventory.items) {
		return
	}

	item := &player.inventory.items[item_index]
	if item.quantity <= 0 {
		return
	}

	item.quantity -= 1

	if item.quantity == 0 {
		clear_item(item)
	}
}

clear_item :: proc(item: ^Item) {
	item.name = ""
	item.quantity = 0
	if item.texture.id != 0 {
		rl.UnloadTexture(item.texture)
	}
	item.texture = rl.Texture2D{}
	item.power = 0
}


draw_inventory :: proc(inventory: Inventory) {
	slot_size: int = 64
	padding: int = 10
	start_x: int = 20
	start_y: int = int(rl.GetScreenHeight()) - slot_size - 20
	max_slots: int = 5

	for i in 0 ..< max_slots {
		slot_x := start_x + i * (slot_size + padding)
		slot_rect := rl.Rectangle {
			x      = cast(f32)slot_x,
			y      = cast(f32)start_y,
			width  = cast(f32)slot_size,
			height = cast(f32)slot_size,
		}

		rl.DrawRectangleRec(slot_rect, rl.GRAY)

		if i < len(inventory.items) {
			item := inventory.items[i]
			if item.texture.id != 0 {
				rl.DrawTextureEx(
					item.texture,
					rl.Vector2{slot_rect.x, slot_rect.y},
					0.0,
					cast(f32)slot_size / cast(f32)item.texture.width,
					rl.WHITE,
				)
			}

			if item.quantity > 1 {
				quantity_text := fmt.tprintf("%d", item.quantity)
				text_size := rl.MeasureTextEx(
					rl.GetFontDefault(),
					strings.clone_to_cstring(quantity_text),
					20,
					1,
				)
				rl.DrawText(
					strings.clone_to_cstring(quantity_text),
					i32(slot_x + slot_size - int(text_size.x) - 5),
					i32(start_y + slot_size - int(text_size.y) - 5),
					20,
					rl.WHITE,
				)
			}
		}

		if i == inventory.selected_index {
			rl.DrawRectangleLinesEx(slot_rect, 2, rl.YELLOW)
		}
	}
}


show_extended_inventory :: proc(
	player: ^Player,
	slot_size: int,
	padding: int,
	max_items_row: int,
	start_x: int,
	mouse_pos: [2]f32,
) {


	start_y := int(rl.GetScreenHeight()) - (slot_size * 6 + padding * 5) - 20
	max_slots := 36

	for slot_index := 0; slot_index < max_slots; slot_index += 1 {
		row := slot_index / max_items_row
		col := slot_index % max_items_row

		slot_x := start_x + col * (slot_size + padding)
		slot_y := start_y + row * (slot_size + padding)

		slot_rect := rl.Rectangle {
			x      = cast(f32)slot_x,
			y      = cast(f32)slot_y,
			width  = cast(f32)slot_size,
			height = cast(f32)slot_size,
		}

		rl.DrawRectangleRec(slot_rect, rl.GRAY)
		if rl.CheckCollisionPointRec(mouse_pos, slot_rect) {
			if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
				player.inventory.selected_index = slot_index
				if slot_index < len(player.inventory.items) {
					item := player.inventory.items[slot_index]
					if item.quantity > 0 {
						use_item(player, slot_index)
					}
				}
			} else if rl.IsMouseButtonPressed(rl.MouseButton.RIGHT) {
				if slot_index < len(player.inventory.items) {
					item := &player.inventory.items[slot_index]
					if item.quantity > 0 {
						drop_item(player, slot_index)
					}
				}
			}
		}
	}


}
hide_extended_inventory :: proc(
	player: ^Player,
	slot_size: int,
	padding: int,
	start_x: int,
	mouse_pos: [2]f32,
) {
	start_y := int(rl.GetScreenHeight()) - slot_size - 20
	max_slots := 5

	for i in 0 ..< max_slots {
		slot_x := start_x + i * (slot_size + padding)
		slot_rect := rl.Rectangle {
			x      = cast(f32)slot_x,
			y      = cast(f32)start_y,
			width  = cast(f32)slot_size,
			height = cast(f32)slot_size,
		}

		if rl.CheckCollisionPointRec(mouse_pos, slot_rect) {
			if rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
				player.inventory.selected_index = i
				if i < len(player.inventory.items) {
					item := player.inventory.items[i]
					if item.quantity > 0 {
						use_item(player, i)
					}
				}
			} else if rl.IsMouseButtonPressed(rl.MouseButton.RIGHT) {
				if i < len(player.inventory.items) {
					item := &player.inventory.items[i]
					if item.quantity > 0 {
						drop_item(player, i)
					}
				}
			}
		}
	}

}
