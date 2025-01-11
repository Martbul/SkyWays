package terrain_generation

import "../shared"
import "../terrain_models"
import "../textures"
import rl "vendor:raylib"


init_terrain_instances :: proc() {
	shared.Terrain_instances = make([dynamic]shared.TerrainInstance)


	//	append(
	//		&shared.Terrain_instances,
	//		shared.TerrainInstance {
	//			model_type = .StartingIsland,
	//			model      = terrain_models.terrain.starting_island.model,
	//			position   = rl.Vector3{20.0, -50.0, -10.0},
	//			scale      = 80.0,
	//			bounds     = scaled_bounds(
	//				terrain_models.terrain.starting_island.bounding_box,
	//				80.0, // Use the actual scale
	//				rl.Vector3{20.0, -50.0, -10.0}, // Use the actual position
	//			),
	//		},
	//	)

	//TODO: Make the portal functionality where the player teleports toanother island
	//	append(
	//		&shared.Terrain_instances,
	//		shared.TerrainInstance {
	//			model_type = .LonelyIsland,
	//			model = terrain_models.terrain.lonely_island.model,
	//			position = rl.Vector3{-4000.0, -50.0, -10.0},
	//			scale = 0.30,
	//			bounds = scaled_bounds(
	//				terrain_models.terrain.lonely_island.bounding_box,
	//				0.30,
	//				rl.Vector3{-4000.0, -50.0, -10.0},
	//			),
	//		},
	//	)


	append(
		&shared.Terrain_instances,
		shared.TerrainInstance {
			model_type = .OldGarage,
			model = terrain_models.terrain.old_garage.model,
			position = rl.Vector3{0.0, 6.0, 0.0},
			scale = 1.2,
			bounds = rl.BoundingBox{},
		},
	)


	//	append(
	//		&shared.Terrain_instances,
	//		shared.TerrainInstance {
	//			model_type = .ConcreteIslandPlatform,
	//			position = rl.Vector3{4, 0, 8},
	//			scale = 3.0,
	//			bounds = scaled_bounds(textures.concrete.concrete_island_platform.bounding_box, 1.0),
	//		},
	//	)
	//	append(
	//		&shared.Terrain_instances,
	//		shared.TerrainInstance {
	//			model_type = .ConcreteFormation,

	//			position = rl.Vector3{8, 0, 2},
	///			scale = 1.0,
	//			bounds = scaled_bounds(textures.concrete.concrete_formation.bounding_box, 1.0),
	//		},
	//	)
}

cleanup_terrain_instances :: proc() {
	delete(shared.Terrain_instances)
}


scaled_bounds :: proc(box: rl.BoundingBox, scale: f32, position: rl.Vector3) -> rl.BoundingBox {
	// First scale the box
	scaled_min := rl.Vector3{box.min.x * scale, box.min.y * scale, box.min.z * scale}
	scaled_max := rl.Vector3{box.max.x * scale, box.max.y * scale, box.max.z * scale}

	// Then translate it
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
