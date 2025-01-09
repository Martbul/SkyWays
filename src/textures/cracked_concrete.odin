package textures

import "../constants"
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

concrete_elements :: struct {
	concrete_cube:            textured_model,
	concrete_island_platform: textured_model,
	concrete_formation:       textured_model,
	concrete_wall:            textured_model,
	concrete_pillar:          textured_model,
}

concrete_textured_model :: struct {
	model:            rl.Model,
	diffuse_texture:  rl.Texture2D,
	specular_texture: rl.Texture2D,
	normal_texture:   rl.Texture2D,
	bounding_box:     rl.BoundingBox,
	is_loaded:        bool,
}

concrete: concrete_elements

init_concrete_elements :: proc() {
	init_concrete_cube()
	init_concrete_island_platform()
	init_concrete_formation()
	init_concrete_wall()
}

cleanup_concrete_elements :: proc() {
	cleanup_concrete_cube()
	cleanup_concrete_island_platform()
	cleanup_concrete_formation()
	cleanup_concrete_wall()
	cleanup_concrete_pillar()
}

init_concrete_cube :: proc() {
	if concrete.concrete_cube.is_loaded do return

	mesh := rl.GenMeshCube(1.0, 1.0, 1.0)
	init_concrete_model(&concrete.concrete_cube, mesh, "cracked_concrete")

}

init_concrete_island_platform :: proc() {
	if concrete.concrete_island_platform.is_loaded do return

	mesh := rl.GenMeshCube(5.0, 0.5, 5.0) // wide and flat
	init_concrete_model(&concrete.concrete_island_platform, mesh, "cracked_concrete")
}

init_concrete_formation :: proc() {
	if concrete.concrete_formation.is_loaded do return

	mesh := rl.GenMeshCylinder(1.0, 2.0, 8) // radius, height, sides
	init_concrete_model(&concrete.concrete_formation, mesh, "cracked_concrete")
}

init_concrete_wall :: proc() {
	if concrete.concrete_wall.is_loaded do return

	mesh := rl.GenMeshCube(2.0, 4.0, 0.5) // wide, tall, thin
	init_concrete_model(&concrete.concrete_wall, mesh, "cracked_concrete")
}


init_concrete_model :: proc(model: ^textured_model, mesh: rl.Mesh, texture_name: string) {
	model.model = rl.LoadModelFromMesh(mesh)

	specular_path := fmt.tprintf(
		"assets/textures/%s_1k.gltf/textures/%s_arm_1k.jpg",
		texture_name,
		texture_name,
	)
	diffuse_path := fmt.tprintf(
		"assets/textures/%s_1k.gltf/textures/%s_diff_1k.jpg",
		texture_name,
		texture_name,
	)
	normal_path := fmt.tprintf(
		"assets/textures/%s_1k.gltf/textures/%s_nor_gl_1k.jpg",
		texture_name,
		texture_name,
	)

	model.specular_texture = rl.LoadTexture(strings.clone_to_cstring(specular_path))
	model.diffuse_texture = rl.LoadTexture(strings.clone_to_cstring(diffuse_path))
	model.normal_texture = rl.LoadTexture(strings.clone_to_cstring(normal_path))

	material := &model.model.materials[0]
	material.maps[constants.MAP_DIFFUSE].texture = model.diffuse_texture
	material.maps[constants.MAP_SPECULAR].texture = model.specular_texture
	material.maps[constants.MAP_NORMAL].texture = model.normal_texture

	model.bounding_box = rl.GetMeshBoundingBox(mesh)

	model.is_loaded = true
}

cleanup_concrete_cube :: proc() {
	cleanup_concrete_model(&concrete.concrete_cube)
}

cleanup_concrete_island_platform :: proc() {
	cleanup_concrete_model(&concrete.concrete_island_platform)
}

cleanup_concrete_formation :: proc() {
	cleanup_concrete_model(&concrete.concrete_formation)
}

cleanup_concrete_wall :: proc() {
	cleanup_concrete_model(&concrete.concrete_wall)
}

cleanup_concrete_pillar :: proc() {
	cleanup_concrete_model(&concrete.concrete_pillar)
}

cleanup_concrete_model :: proc(model: ^textured_model) {
	if model.is_loaded {
		rl.UnloadModel(model.model)
		rl.UnloadTexture(model.diffuse_texture)
		rl.UnloadTexture(model.specular_texture)
		rl.UnloadTexture(model.normal_texture)
		model.is_loaded = false
	}
}

draw_concrete_cube :: proc(position: rl.Vector3, scale: f32 = 1.0) {
	if concrete.concrete_cube.is_loaded {
		rl.DrawModel(concrete.concrete_cube.model, position, scale, rl.WHITE)
	}
}

draw_concrete_island_platform :: proc(position: rl.Vector3, scale: f32 = 1.0) {
	if concrete.concrete_island_platform.is_loaded {
		rl.DrawModel(concrete.concrete_island_platform.model, position, scale, rl.WHITE)
	}
}

draw_concrete_formation :: proc(position: rl.Vector3, scale: f32 = 1.0) {
	if concrete.concrete_formation.is_loaded {
		rl.DrawModel(concrete.concrete_formation.model, position, scale, rl.WHITE)
	}
}

draw_concrete_wall :: proc(position: rl.Vector3, scale: f32 = 1.0) {
	if concrete.concrete_wall.is_loaded {
		rl.DrawModel(concrete.concrete_wall.model, position, scale, rl.WHITE)
	}
}

draw_concrete_pillar :: proc(position: rl.Vector3, scale: f32 = 1.0) {
	if concrete.concrete_pillar.is_loaded {
		rl.DrawModel(concrete.concrete_pillar.model, position, scale, rl.WHITE)
	}
}

draw_concrete_island :: proc(base_position: rl.Vector3) {
	draw_concrete_island_platform(base_position)

	draw_concrete_cube(
		rl.Vector3{base_position.x + 2, base_position.y + 0.5, base_position.z + 2},
		0.7,
	)
	draw_concrete_cube(
		rl.Vector3{base_position.x - 2, base_position.y + 0.5, base_position.z - 2},
		0.8,
	)

	draw_concrete_formation(
		rl.Vector3{base_position.x + 1, base_position.y + 0.25, base_position.z},
		0.8,
	)

	draw_concrete_wall(rl.Vector3{base_position.x, base_position.y - 1, base_position.z + 2})

	draw_concrete_pillar(
		rl.Vector3{base_position.x - 1.5, base_position.y + 0.25, base_position.z + 1.5},
		0.6,
	)
}
