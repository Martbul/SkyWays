package terrain_models

import "../pkg"
import rl "vendor:raylib"


terrain_elements :: struct {
	starting_island: terrain_3d_model,
	lonely_island:   terrain_3d_model,
	liberty_island:  terrain_3d_model,
	old_garage:      terrain_3d_model,
	room_99:         terrain_3d_model,
}

terrain_3d_model :: struct {
	model:           rl.Model,
	bounding_box:    rl.BoundingBox,
	is_loaded:       bool,
	collision_boxes: [dynamic]Terrain_Collision_Box,
}


Terrain_Collision_Box :: struct {
	box:      rl.BoundingBox,
	position: rl.Vector3, // Relative position to model origin
	type:     Terrain_Box_Type,
}

Terrain_Box_Type :: enum {
	Ground,
	Obstacle,
	Wall,
}

terrain: terrain_elements


init_terrain_elements :: proc() {
	//	init_starting_island()
	//	init_liberty_island()
	init_old_garage()
	init_room_99()
}

cleanup_terrain_elements :: proc() {
	//	cleanup_starting_island()
	//	cleanup_liberty_island()
	cleanup_old_garage()
	cleanup_room_99()
}


init_starting_island :: proc() {
	if terrain.starting_island.is_loaded do return

	init_model(&terrain.starting_island, "assets/terrain/start_island/untitled.glb")
}


init_liberty_island :: proc() {
	if terrain.liberty_island.is_loaded do return

	init_model(&terrain.liberty_island, "assets/terrain/liberty_island/scene.gltf")
}


init_old_garage :: proc() {
	if terrain.old_garage.is_loaded do return

	init_model(&terrain.old_garage, "assets/terrain/old_garage/scene.gltf")
}

init_room_99 :: proc() {
	if terrain.room_99.is_loaded do return

	init_model(&terrain.room_99, "assets/terrain/room_99/scene.gltf")
}


init_model :: proc(model: ^terrain_3d_model, model_path: cstring) {

	model.model = rl.LoadModel(model_path)
	if model.model.meshCount == 0 {
		pkg.debug("Failed to load model or model has no meshes")
		return
	}
	model.bounding_box = rl.GetModelBoundingBox(model.model)

	model.is_loaded = true
}


draw_starting_island :: proc(position: rl.Vector3, scale: f32) {
	if terrain.starting_island.is_loaded {
		rl.DrawModel(terrain.starting_island.model, position, scale, rl.WHITE)
	}
}


draw_liberty_island :: proc(position: rl.Vector3, scale: f32) {
	if terrain.liberty_island.is_loaded {
		rl.DrawModel(terrain.liberty_island.model, position, scale, rl.WHITE)
	}
}


draw_old_garage :: proc(position: rl.Vector3, scale: f32) {
	if terrain.old_garage.is_loaded {
		rl.DrawModel(terrain.old_garage.model, position, scale, rl.WHITE)
	}
}


draw_room_99 :: proc(position: rl.Vector3, scale: f32) {
	if terrain.room_99.is_loaded {
		rl.DrawModel(terrain.room_99.model, position, scale, rl.WHITE)
	}
}


cleanup_starting_island :: proc() {
	cleanup_3d_model(&terrain.starting_island)
}


cleanup_liberty_island :: proc() {
	cleanup_3d_model(&terrain.liberty_island)
}


cleanup_old_garage :: proc() {
	cleanup_3d_model(&terrain.old_garage)
}


cleanup_room_99 :: proc() {
	cleanup_3d_model(&terrain.room_99)
}

cleanup_3d_model :: proc(model: ^terrain_3d_model) {
	if model.is_loaded {
		rl.UnloadModel(model.model)
		model.is_loaded = false
	}
}
