package terrain_generation

import "../shared"
import "../textures"
import rl "vendor:raylib"

init_terrain_instances :: proc() {
	shared.Terrain_instances = make([dynamic]shared.TerrainInstance)

	//	append(
	//		&shared.Terrain_instances,
	//		shared.TerrainInstance {
	//			model_type = .IslandPlatform,
	//			position = rl.Vector3{0, 0, 0},
	//			scale = 1.0,
	//			bounds = scaled_bounds(textures.terrain.island_platform.bounding_box, 1.0),
	//		},
	//	)

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
	//			model_type = .CliffWall,
	//			position = rl.Vector3{-8, 0, -1},
	//			scale = 1.0,
	//			bounds = scaled_bounds(textures.terrain.cliff_wall.bounding_box, 1.0),
	//		},
	//	)


	//	append(
	//		&shared.Terrain_instances,
	//		shared.TerrainInstance {
	//			model_type = .ConcreteWall,
	//			position = rl.Vector3{-5, 0, -5},
	//			scale = 1.0,
	//			bounds = scaled_bounds(textures.concrete.concrete_wall.bounding_box, 1.0),
	//		},
	//	)

	//	append(
	//		&shared.Terrain_instances,
	//		shared.TerrainInstance {
	//			model_type = .RockFormation,
	//			position = rl.Vector3{5, 0, 5},
	//			scale = 1.0,
	//			bounds = scaled_bounds(textures.terrain.rock_formation.bounding_box, 1.0),
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


scaled_bounds :: proc(box: rl.BoundingBox, scale: f32) -> rl.BoundingBox {
	return rl.BoundingBox {
		min = rl.Vector3{box.min.x * scale, box.min.y * scale, box.min.z * scale},
		max = rl.Vector3{box.max.x * scale, box.max.y * scale, box.max.z * scale},
	}
}
