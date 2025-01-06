package items

import pl "../player"
import "core:math"
import rl "vendor:raylib"
Item :: struct {
	ID:          string,
	Model:       rl.Model,
	Position:    rl.Vector3,
	Rotation:    rl.Vector3,
	State:       ItemState,
	FloatHeight: f32,
	FloatSpeed:  f32,
	// Animation properties
	BaseY:       f32,
	TimeOffset:  f32,
	action:      proc(_: ^ItemManager),
}

ItemManager :: struct {
	Items:    [dynamic]^Item,
	Models:   map[string]rl.Model,
	Textures: map[string]rl.Texture2D,
}


ItemState :: enum {
	ItemStateGround,
	ItemStateFloating,
	ItemStatePickedUp,
}

init_item_manager :: proc() -> ^ItemManager {

	item_manager := ItemManager {
		Items    = make([dynamic]^Item, 0),
		Models   = make(map[string]rl.Model),
		Textures = make(map[string]rl.Texture2D),
	}
	model := rl.LoadModel(modelPath)
	texture := rl.LoadTexture(texturePath)
	item_manager.Models[itemID] = model
	item_manager.Textures[itemID] = texture

	return &item_manager
}


spawn_item :: proc(item_manager: ^ItemManager, itemID: string, position: rl.Vector3) -> ^Item {
	model := item_manager.Models[itemID]
	item := &Item {
		ID = itemID,
		Model = model,
		Position = position,
		State = .ItemStateFloating,
		FloatHeight = 0.5,
		FloatSpeed = 2.0,
		BaseY = position.y,
		TimeOffset = f32(rl.GetTime()),
	}
	item_manager.Items = append(item_manager.Items, item)
	return item
}

update :: proc(item_manager: ^ItemManager) {
	currentTime := rl.GetTime()
	for item in item_manager.Items {
		if item.State == .ItemStateFloating {
			// Create floating animation
			item.Position.y =
				item.BaseY +
				item.FloatHeight *
					f32(math.sin((f32(currentTime) - item.TimeOffset) * item.FloatSpeed))
		}
	}
}

draw :: proc(item_manager: ^ItemManager) {
	for item in item_manager.Items {
		if item.State != .ItemStatePickedUp {
			rl.DrawModel(
				item.Model,
				item.Position,
				1.0, // scale
				rl.WHITE,
			)
		}
	}
}

pick_up_item :: proc(item_manager: ^ItemManager, player: ^pl.Player, pickupRange: f32) -> ^Item {
	for item in item_manager.Items {
		if item.State != .ItemStatePickedUp {
			distance := rl.Vector3Distance(player.Position, item.Position)
			if distance <= pickupRange {
				item.State = .ItemStatePickedUp
				return item
			}
		}
	}
	return nil
}

drop_item :: proc(item_manager: ^ItemManager, item: ^Item, position: rl.Vector3) {
	if item.State == .ItemStatePickedUp {
		item.State = .ItemStateFloating
		item.Position = position
		item.BaseY = position.y
		item.TimeOffset = f32(rl.GetTime())
	}
}

unload_resources :: proc(item_manager: ^ItemManager) {
	for model in item_manager.Models {
		rl.UnloadModel(model)
	}
	for texture in item_manager.Textures {
		rl.UnloadTexture(texture)
	}
}
