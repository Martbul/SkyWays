package shared

import rl "vendor:raylib"

TerrainInstance :: struct {
	model:           rl.Model,
	model_type:      TerrainType,
	position:        rl.Vector3,
	scale:           f32,
	bounds:          rl.BoundingBox,
	collision_boxes: [dynamic]terrain_collision_box,
}

ConcreteTerrainType :: enum {
	ConcreteCube,
	ConcreteIslandPlatform,
	ConcreteFormation,
	ConcreteWall,
	ConcretePillar,
}


terrain_box_type :: enum {
	Ground,
	Obstacle,
	Wall,
}

terrain_collision_box :: struct {
	box:      rl.BoundingBox,
	position: rl.Vector3, // Relative position to model origin
	type:     terrain_box_type,
}


RockyTerrainType :: enum {
	RockyCube,
	IslandPlatform,
	RockFormation,
	CliffWall,
	TerrainPillar,
}

terrain_3d_models :: enum {
	StartingIsland,
	LibertyIsland,
	OldGarage,
	Room99,
}

terrain_3d_structures :: enum {
	portal,
	tower_cannon,
	turret_cannon,
}

TerrainType :: union {
	RockyTerrainType,
	ConcreteTerrainType,
	terrain_3d_models,
	terrain_3d_structures,
}

Terrain_instances: [dynamic]TerrainInstance


get_transformed_bounding_box :: proc(instance: TerrainInstance) -> rl.BoundingBox {
	base_bounds := instance.bounds

	// Transform the bounding box based on instance position
	return rl.BoundingBox {
		min = rl.Vector3 {
			base_bounds.min.x + instance.position.x,
			base_bounds.min.y + instance.position.y,
			base_bounds.min.z + instance.position.z,
		},
		max = rl.Vector3 {
			base_bounds.max.x + instance.position.x,
			base_bounds.max.y + instance.position.y,
			base_bounds.max.z + instance.position.z,
		},
	}
}
