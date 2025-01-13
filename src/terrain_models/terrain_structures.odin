package terrain_models

import "../pkg"
import "../shared"
import "base:runtime"
import rl "vendor:raylib"


init_portal :: proc() {
	if terrain.portal.is_loaded do return


	init_structure_model(&terrain.portal, "assets/terrain/bone_portal/scene.gltf")
}


init_turret_cannon :: proc() {
	if terrain.turret_cannon.is_loaded do return


	collision_bounds := make([]shared.terrain_collision_box, 50)
	init_model(&terrain.turret_cannon, "assets/terrain/turret_cannon/scene.gltf", collision_bounds)
}

init_tower_cannon :: proc() {
	if terrain.tower_cannon.is_loaded do return

	collision_bounds := make([dynamic]shared.terrain_collision_box)

	init_model(
		&terrain.tower_cannon,
		"assets/terrain/cannon_tower/scene.gltf",
		collision_bounds[:],
	)

	// Don't forget to delete the dynamic array after we're done with it
	delete(collision_bounds)
}


draw_portal :: proc(position: rl.Vector3, scale: f32) {
	if terrain.portal.is_loaded {
		rl.DrawModel(terrain.portal.model, position, scale, rl.WHITE)
	}
}


draw_tower_cannon :: proc(position: rl.Vector3, scale: f32) {
	if terrain.tower_cannon.is_loaded {
		rl.DrawModel(terrain.tower_cannon.model, position, scale, rl.WHITE)
	}
}


draw_turret_cannon :: proc(position: rl.Vector3, scale: f32) {
	if terrain.turret_cannon.is_loaded {
		rl.DrawModel(terrain.turret_cannon.model, position, scale, rl.WHITE)
	}
}


cleanup_portal :: proc() {
	cleanup_3d_model(&terrain.portal)
}


cleanup_tower_cannon :: proc() {
	cleanup_3d_model(&terrain.tower_cannon)
}


cleanup_turret_cannon :: proc() {
	cleanup_3d_model(&terrain.turret_cannon)
}


init_structure_model :: proc(model: ^terrain_3d_model, model_path: cstring) {

	model.model = rl.LoadModel(model_path)
	if model.model.meshCount == 0 {
		pkg.debug("Failed to load model or model has no meshes")
		return
	}

	temp_bounding_box := rl.GetModelBoundingBox(model.model)
	model.bounding_box = &temp_bounding_box
	model.is_loaded = true
}
