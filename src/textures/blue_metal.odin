package textures
import rl "vendor:raylib"
MAP_DIFFUSE :: 0
MAP_SPECULAR :: 1
MAP_NORMAL :: 2

textured_cube: struct {
	model:            rl.Model,
	diffuse_texture:  rl.Texture2D,
	specular_texture: rl.Texture2D,
	normal_texture:   rl.Texture2D,
	is_loaded:        bool,
}


init_custom_material :: proc() {
	if textured_cube.is_loaded {
		return
	}

	mesh := rl.GenMeshCube(1.0, 1.0, 1.0)
	textured_cube.model = rl.LoadModelFromMesh(mesh)

	textured_cube.specular_texture = rl.LoadTexture(
		"assets/textures/blue_metal_plate_1k.gltf/textures/blue_metal_plate_arm_1k.jpg",
	)
	textured_cube.diffuse_texture = rl.LoadTexture(
		"assets/textures/blue_metal_plate_1k.gltf/textures/blue_metal_plate_diff_1k.jpg",
	)
	textured_cube.normal_texture = rl.LoadTexture(
		"assets/textures/blue_metal_plate_1k.gltf/textures/blue_metal_plate_nor_gl_1k.jpg",
	)

	material := &textured_cube.model.materials[0]
	material.maps[MAP_DIFFUSE].texture = textured_cube.diffuse_texture
	material.maps[MAP_SPECULAR].texture = textured_cube.specular_texture
	material.maps[MAP_NORMAL].texture = textured_cube.normal_texture

	textured_cube.is_loaded = true
}

cleanup_custom_material :: proc() {
	if textured_cube.is_loaded {
		rl.UnloadModel(textured_cube.model)
		rl.UnloadTexture(textured_cube.diffuse_texture)
		rl.UnloadTexture(textured_cube.specular_texture)
		rl.UnloadTexture(textured_cube.normal_texture)
		textured_cube.is_loaded = false
	}
}

draw_custom_material :: proc() {
	if textured_cube.is_loaded {
		rl.DrawModel(textured_cube.model, 2, 2, rl.WHITE)
	}
}
