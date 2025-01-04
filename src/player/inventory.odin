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
	items:          [16]Item, // Adjust size as needed
	selected_index: int,
}


load_texture :: proc(file_path: string) -> rl.Texture2D {
	return rl.LoadTexture(strings.clone_to_cstring(file_path))
}

init_inventory :: proc() -> Inventory {
	inventory: Inventory
	// Example of adding an item
	inventory.items[0] = Item {
		name     = "Health Potion",
		texture  = load_texture("assets/textures/health_potion.png"),
		quantity = 5,
	}
	// Initialize other items as needed
	return inventory
}


draw_inventory :: proc(inventory: Inventory) {
	slot_size: int = 64
	padding: int = 10
	start_x: int = 20
	start_y: int = int(rl.GetScreenHeight()) - slot_size - 20

	// Set the maximum number of slots to display
	max_slots: int = 5
	for i in 0 ..< max_slots {
		slot_x: int = start_x + i * (slot_size + padding)
		slot_rect: rl.Rectangle = rl.Rectangle {
			x      = cast(f32)slot_x,
			y      = cast(f32)start_y,
			width  = cast(f32)slot_size,
			height = cast(f32)slot_size,
		}

		// Draw slot background
		rl.DrawRectangleRec(slot_rect, rl.GRAY)

		// Draw item texture if available (use inventory.items[i] if it exists)
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

			// Draw item quantity if available
			if item.quantity > 1 {
				quantity_text: string = fmt.tprintf("%d", item.quantity)
				text_size: rl.Vector2 = rl.MeasureTextEx(
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

		// Highlight the selected slot
		if i == inventory.selected_index {
			rl.DrawRectangleLinesEx(slot_rect, 2, rl.YELLOW)
		}
	}
}

//TODO: IF THE ACCESSING OF THE INVENTORY
//handle_inventory_input :: proc(player: ^Player) {
//	mouse_pos := rl.GetMousePosition()

// Check if the mouse is over the inventory box
//	if rl.CheckCollisionPointRec(mouse_pos, rl.Rectangle{10, 60, 250, 300}) {
//		if rl.IsMouseButtonPressed(rl.MOUSE_LEFT_BUTTON) {
//			// Handle interaction, like selecting an item
//			for i, item in player.inventory {
// Check if the mouse clicked on an item (you can adjust y position based on item index)
//				item_rect := rl.Rectangle{15, 90 + i * 30, 200, 20} // Example item rectangle
//				if rl.CheckCollisionPointRec(mouse_pos, item_rect) {
//					log.info("Clicked on item: %s", item.name)
// Implement your item interaction logic here
//				}
//			}
//		}
//	}
//}
