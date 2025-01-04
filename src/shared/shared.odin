package shared

import rl "vendor:raylib"


TerrainInstance :: struct {
	model_type: TerrainType,
	position:   rl.Vector3,
	scale:      f32,
	bounds:     rl.BoundingBox,
}

TerrainType :: enum {
	RockyCube,
	IslandPlatform,
	RockFormation,
	CliffWall,
	TerrainPillar,
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
