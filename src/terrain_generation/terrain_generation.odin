package terrain_generation

import "../shared"
import "../terrain_models"
import "../textures"
import rl "vendor:raylib"


init_terrain_instances :: proc() {
	shared.Terrain_instances = make([dynamic]shared.TerrainInstance)

	//TODO: Think about how to structure the bounding boxes for every item in each room
	append(
		&shared.Terrain_instances,
		shared.TerrainInstance {
			model_type = .OldGarage,
			model = terrain_models.terrain.old_garage.model,
			position = rl.Vector3{0.0, 8.3, 0.0},
			scale = 1.2,
			bounds = rl.BoundingBox{},
		},
	)


	append(
		&shared.Terrain_instances,
		shared.TerrainInstance {
			model_type = .Room99,
			model = terrain_models.terrain.room_99.model,
			position = rl.Vector3{100.0, 1.24, 100.0},
			scale = 5.0,
			bounds = rl.BoundingBox{},
		},
	)
}

cleanup_terrain_instances :: proc() {
	delete(shared.Terrain_instances)
}


scaled_bounds :: proc(box: rl.BoundingBox, scale: f32, position: rl.Vector3) -> rl.BoundingBox {
	scaled_min := rl.Vector3{box.min.x * scale, box.min.y * scale, box.min.z * scale}
	scaled_max := rl.Vector3{box.max.x * scale, box.max.y * scale, box.max.z * scale}

	return rl.BoundingBox {
		min = rl.Vector3 {
			scaled_min.x + position.x,
			scaled_min.y + position.y,
			scaled_min.z + position.z,
		},
		max = rl.Vector3 {
			scaled_max.x + position.x,
			scaled_max.y + position.y,
			scaled_max.z + position.z,
		},
	}
}
