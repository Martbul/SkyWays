package terrain_models

import "../pkg"
import "../shared"
import "base:runtime"
import rl "vendor:raylib"

terrain_elements :: struct {
	starting_island: terrain_3d_model,
	liberty_island:  terrain_3d_model,
	old_garage:      terrain_3d_model,
	room_99:         terrain_3d_model,
	portal:          terrain_3d_model,
	turret_cannon:   terrain_3d_model,
	tower_cannon:    terrain_3d_model,
}

terrain_3d_model :: struct {
	model:           rl.Model,
	bounding_box:    ^rl.BoundingBox, //I hope this is an optinal field
	is_loaded:       bool,
	collision_boxes: [dynamic]shared.terrain_collision_box,
}
terrain: terrain_elements


init_terrain_elements :: proc() {
	//	init_starting_island()
	//	init_liberty_island()
	init_old_garage()
	init_room_99()
	init_portal()
	init_tower_cannon()
	init_turret_cannon()

}

cleanup_terrain_elements :: proc() {
	//	cleanup_starting_island()
	//	cleanup_liberty_island()
	cleanup_old_garage()
	cleanup_room_99()
	cleanup_portal()
	cleanup_tower_cannon()
	cleanup_turret_cannon()
}


//init_starting_island :: proc() {
//	if terrain.starting_island.is_loaded do return

//	init_model(&terrain.starting_island, "assets/terrain/start_island/untitled.glb")
//}


//init_liberty_island :: proc() {
//	if terrain.liberty_island.is_loaded do return
//
//	init_model(&terrain.liberty_island, "assets/terrain/liberty_island/scene.gltf")
//}


init_old_garage :: proc() {
	if terrain.old_garage.is_loaded do return


	collision_bounds := make([]shared.terrain_collision_box, 50)
	init_model(&terrain.old_garage, "assets/terrain/old_garage/scene.gltf", collision_bounds)
}

init_room_99 :: proc() {
	if terrain.room_99.is_loaded do return

	// Create the ground collision box
	ground := shared.terrain_collision_box {
		box = rl.BoundingBox{min = rl.Vector3{3, 3, 3}, max = rl.Vector3{7, 7, 7}},
		position = rl.Vector3{130, 2, 80},
		type = .Ground,
	}

	// Create a dynamic array instead of a fixed-size slice
	collision_bounds := make([dynamic]shared.terrain_collision_box)
	runtime.append_elem(&collision_bounds, ground)

	init_model(&terrain.room_99, "assets/terrain/room_99/scene.gltf", collision_bounds[:])

	// Don't forget to delete the dynamic array after we're done with it
	delete(collision_bounds)
}


init_model :: proc(
	model: ^terrain_3d_model,
	model_path: cstring,
	terrain_collision_boxes: []shared.terrain_collision_box,
) {

	model.model = rl.LoadModel(model_path)
	if model.model.meshCount == 0 {
		pkg.debug("Failed to load model or model has no meshes")
		return
	}

	// Initialize the dynamic array if it hasn't been initialized yet
	if model.collision_boxes == nil {
		model.collision_boxes = make([dynamic]shared.terrain_collision_box)
	}

	//model.bounding_box = rl.GetModelBoundingBox(model.model)

	runtime.append_elems(&model.collision_boxes, ..terrain_collision_boxes)
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
