package player
import "core:fmt"
import "core:log"
import "core:math"
import "core:strings"
import rl "vendor:raylib"


Inventory :: struct {
	items:          [36]Item,
	selected_index: int,
	is_extended:    bool,
}

Item :: struct {
	id:           ItemID,
	name:         string,
	quantity:     int,
	texture:      rl.Texture,
	model:        rl.Model,
	position:     rl.Vector3,
	rotation:     rl.Vector3,
	state:        ItemState,
	float_height: f32,
	float_speed:  f32,
	base_y:       f32,
	time_offset:  f32,
	on_pickup:    proc(_: ^ItemManager, _: ^Item),
}

ItemID :: distinct string

ItemManager :: struct {
	items:    [dynamic]^Item,
	models:   map[ItemID]rl.Model,
	textures: map[ItemID]rl.Texture2D,
}

ItemState :: enum {
	Ground,
	Floating,
	PickedUp,
}


ability :: enum {
	strong,
	killer,
}


load_texture :: proc(file_path: string) -> rl.Texture2D {
	return rl.LoadTexture(strings.clone_to_cstring(file_path))
}


init_inventory :: proc() -> Inventory {
	inventory: Inventory
	inventory.is_extended = false

	// Initialize all inventory slots with empty items
	for i := 0; i < len(inventory.items); i += 1 {
		inventory.items[i] = Item {
			quantity = 0,
		}
	}

	return inventory
}


handle_inventory_input :: proc(player: ^Player, item_manager: ^ItemManager) {
	mouse_pos := rl.GetMousePosition()

	slot_size: int = 64
	padding: int = 10
	start_x: int = 20
	max_items_row: int = 6

	if rl.IsKeyPressed(.TAB) {
		player.inventory.is_extended = !player.inventory.is_extended
	}

	if player.inventory.is_extended {

		show_extended_inventory(
			player,
			slot_size,
			padding,
			max_items_row,
			start_x,
			mouse_pos,
			item_manager,
		)
	} else {


		hide_extended_inventory(player, slot_size, padding, start_x, mouse_pos, item_manager)
	}
	if rl.IsKeyPressed(.ONE) do player.inventory.selected_index = 0
	if rl.IsKeyPressed(.TWO) do player.inventory.selected_index = 1
	if rl.IsKeyPressed(.THREE) do player.inventory.selected_index = 2
	if rl.IsKeyPressed(.FOUR) do player.inventory.selected_index = 3
	if rl.IsKeyPressed(.FIVE) do player.inventory.selected_index = 4
}

hover_item_in_inventory :: proc() {

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
	case "Wooden Axe":
		item.quantity -= 1
		// If quantity reaches 0, you might want to clear the item
		if item.quantity == 0 {
			clear_item(item)
		}
	}
}


clear_item :: proc(item: ^Item) {
	item.name = ""
	item.quantity = 0
	if item.texture.id != 0 {
		rl.UnloadTexture(item.texture)
	}
	item.texture = rl.Texture2D{}
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
	item_manager: ^ItemManager,
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
						drop_item(player, item_manager, slot_index)
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
	item_manager: ^ItemManager,
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
						drop_item(player, item_manager, i)
					}
				}
			}
		}
	}

}

init_item_manager :: proc() -> ^ItemManager {
	manager := new(ItemManager)
	manager.items = make([dynamic]^Item)
	manager.models = make(map[ItemID]rl.Model)
	manager.textures = make(map[ItemID]rl.Texture2D)
	return manager
}

spawn_item :: proc(
	manager: ^ItemManager,
	id: ItemID,
	position: rl.Vector3,
	on_pickup: proc(_: ^ItemManager, _: ^Item) = nil,
) -> ^Item {
	if _, ok := manager.models[id]; !ok {
		return nil
	}

	item := new(Item)
	item^ = Item {
		id           = id,
		model        = manager.models[id],
		position     = position,
		state        = .Floating,
		float_height = 0.5,
		float_speed  = 2.0,
		base_y       = position.y,
		time_offset  = f32(rl.GetTime()),
		on_pickup    = on_pickup,
	}

	append(&manager.items, item)
	return item
}

update :: proc(manager: ^ItemManager) {
	current_time := f32(rl.GetTime())

	for item in manager.items {
		if item.state == .Floating {
			// Create floating animation
			time_factor := (current_time - item.time_offset) * item.float_speed
			item.position.y = item.base_y + item.float_height * math.sin(time_factor)

			// Rotate the item slowly
			item.rotation.y += 1.0 * rl.GetFrameTime()
		}
	}
}

load_item_resources :: proc(
	manager: ^ItemManager,
	id: ItemID,
	model_path: cstring,
	texture_path: cstring,
) {
	model := rl.LoadModel(model_path)
	texture := rl.LoadTexture(texture_path)

	// Set the texture for the model's material
	rl.SetMaterialTexture(&model.materials[0], .ALBEDO, texture)
	manager.models[id] = model
	manager.textures[id] = texture
}

// In draw procedure
draw :: proc(manager: ^ItemManager) {
	for item in manager.items {
		if item.state != .PickedUp {
			transform := rl.Matrix {
				1,
				0,
				0,
				0,
				0,
				1,
				0,
				0,
				0,
				0,
				1,
				0,
				item.position.x,
				item.position.y,
				item.position.z,
				1,
			}

			// Apply rotation using matrix multiplication operator
			transform = transform * rl.MatrixRotateY(item.rotation.y)

			rl.DrawModelEx(
				item.model,
				item.position,
				{0, 1, 0}, // rotation axis (Y-axis)
				item.rotation.y * math.RAD_PER_DEG,
				{3, 3, 3}, // scale
				rl.WHITE,
			)
		}
	}
}

pick_up_item :: proc(manager: ^ItemManager, player: ^Player, pickup_range: f32) -> ^Item {
	for item in manager.items {
		if item.state != .PickedUp {
			distance := rl.Vector3Distance(player.position, item.position)
			if distance <= pickup_range {
				item.state = .PickedUp

				// Find an empty slot in the inventory
				for i := 0; i < len(player.inventory.items); i += 1 {
					if player.inventory.items[i].quantity == 0 {
						// Copy all necessary item properties to inventory
						player.inventory.items[i] = Item {
							id       = item.id,
							name     = item.name,
							quantity = 1,
							texture  = manager.textures[item.id], // Get texture from manager
							model    = item.model,
							state    = .PickedUp,
						}

						// Call on_pickup callback after inventory update
						if item.on_pickup != nil {
							item.on_pickup(manager, item)
						}

						return item
					}
				}
			}
		}
	}
	return nil
}
// Drop item from inventory and spawn it in the world
drop_item :: proc(player: ^Player, item_manager: ^ItemManager, item_index: int) {
	if item_index >= len(player.inventory.items) {
		return
	}

	item := &player.inventory.items[item_index]
	if item.quantity <= 0 {
		return
	}

	// Calculate drop position slightly in front of the player
	drop_offset := rl.Vector3{0, 0, 2} // 2 units in front
	drop_position := rl.Vector3 {
		player.position.x + drop_offset.x,
		player.position.y + 1.0, // Slightly above ground
		player.position.z + drop_offset.z,
	}

	// Spawn the dropped item in the world

	spawned_item := spawn_item(item_manager, item.id, drop_position)
	if spawn_item != nil {
		spawned_item.state = .Floating
		spawned_item.texture = item.texture
		spawned_item.name = item.name
		spawned_item.quantity = 1 // Dropped items start with quantity 1
	}

	// Reduce quantity in inventory
	item.quantity -= 1

	// Clear the inventory slot if no items remain
	if item.quantity == 0 {
		clear_item(item)
	}
}

// Helper proc to drop an item that's already in the world
drop_world_item :: proc(manager: ^ItemManager, item: ^Item, position: rl.Vector3) {
	if item != nil && item.state == .PickedUp {
		item.state = .Floating
		item.position = position
		item.base_y = position.y
		item.time_offset = f32(rl.GetTime())
	}
}
destroy_item :: proc(manager: ^ItemManager, item: ^Item) {
	if item == nil do return

	for i := 0; i < len(manager.items); i += 1 {
		if manager.items[i] == item {
			ordered_remove(&manager.items, i)
			free(item)
			break
		}
	}
}
unload_resources :: proc(manager: ^ItemManager) {
	for _, model in manager.models {
		rl.UnloadModel(model)
	}
	for _, texture in manager.textures {
		rl.UnloadTexture(texture)
	}

	delete(manager.items)
	delete(manager.models)
	delete(manager.textures)
	free(manager)
}
