package textures
import "core:strings"
import rl "vendor:raylib"
import "core:fmt"
// Struct definitions for different terrain elements
Terrain_Elements :: struct {
    rocky_cube: Textured_Model,
    island_platform: Textured_Model,
    rock_formation: Textured_Model,
    cliff_wall: Textured_Model,
    terrain_pillar: Textured_Model,
}

Textured_Model :: struct {
    model: rl.Model,
    diffuse_texture: rl.Texture2D,
    specular_texture: rl.Texture2D,
    normal_texture: rl.Texture2D,
    is_loaded: bool,
}

terrain: Terrain_Elements

// Initialize all terrain elements
init_terrain_elements :: proc() {
    init_rocky_cube()
    init_island_platform()
    init_rock_formation()
    init_cliff_wall()
    init_terrain_pillar()
}

// Cleanup all terrain elements
cleanup_terrain_elements :: proc() {
    cleanup_rocky_cube()
    cleanup_island_platform()
    cleanup_rock_formation()
    cleanup_cliff_wall()
    cleanup_terrain_pillar()
}

// Rocky Cube
init_rocky_cube :: proc() {
    if terrain.rocky_cube.is_loaded do return
    
    mesh := rl.GenMeshCube(1.0, 1.0, 1.0)
    init_textured_model(&terrain.rocky_cube, mesh, "rocky_terrain")
}

// Island Platform (wider, flatter shape)
init_island_platform :: proc() {
    if terrain.island_platform.is_loaded do return
    
    mesh := rl.GenMeshCube(5.0, 0.5, 5.0)  // Wide and flat
    init_textured_model(&terrain.island_platform, mesh, "rocky_terrain")
}

// Rock Formation (using a cylinder for variation)
init_rock_formation :: proc() {
    if terrain.rock_formation.is_loaded do return
    
    mesh := rl.GenMeshCylinder(1.0, 2.0, 8)  // radius, height, sides
    init_textured_model(&terrain.rock_formation, mesh, "rocky_terrain")
}

// Cliff Wall (tall rectangle)
init_cliff_wall :: proc() {
    if terrain.cliff_wall.is_loaded do return
    
    mesh := rl.GenMeshCube(2.0, 4.0, 0.5)  // wide, tall, thin
    init_textured_model(&terrain.cliff_wall, mesh, "rocky_terrain")
}

// Terrain Pillar (taller cylinder)
init_terrain_pillar :: proc() {
    if terrain.terrain_pillar.is_loaded do return
    
    mesh := rl.GenMeshCylinder(0.5, 4.0, 6)  // thin, tall cylinder
    init_textured_model(&terrain.terrain_pillar, mesh, "rocky_terrain")
}

// Helper to initialize a textured model
init_textured_model :: proc(model: ^Textured_Model, mesh: rl.Mesh, texture_name: string) {
    model.model = rl.LoadModelFromMesh(mesh)
    
    // Load textures using cstring paths
    specular_path := fmt.tprintf("assets/textures/%s_1k.gltf/textures/%s_arm_1k.jpg", texture_name, texture_name)
    diffuse_path := fmt.tprintf("assets/textures/%s_1k.gltf/textures/%s_diff_1k.jpg", texture_name, texture_name)
    normal_path := fmt.tprintf("assets/textures/%s_1k.gltf/textures/%s_nor_gl_1k.jpg", texture_name, texture_name)
    
    model.specular_texture = rl.LoadTexture(strings.clone_to_cstring(specular_path))
    model.diffuse_texture = rl.LoadTexture(strings.clone_to_cstring(diffuse_path))
    model.normal_texture = rl.LoadTexture(strings.clone_to_cstring(normal_path))
    
    // Set up material
    material := &model.model.materials[0]
    material.maps[MAP_DIFFUSE].texture = model.diffuse_texture
    material.maps[MAP_SPECULAR].texture = model.specular_texture
    material.maps[MAP_NORMAL].texture = model.normal_texture
    
    model.is_loaded = true
}

// Cleanup procedures for each element
cleanup_rocky_cube :: proc() {
    cleanup_textured_model(&terrain.rocky_cube)
}

cleanup_island_platform :: proc() {
    cleanup_textured_model(&terrain.island_platform)
}

cleanup_rock_formation :: proc() {
    cleanup_textured_model(&terrain.rock_formation)
}

cleanup_cliff_wall :: proc() {
    cleanup_textured_model(&terrain.cliff_wall)
}

cleanup_terrain_pillar :: proc() {
    cleanup_textured_model(&terrain.terrain_pillar)
}

// Helper to cleanup a textured model
cleanup_textured_model :: proc(model: ^Textured_Model) {
    if model.is_loaded {
        rl.UnloadModel(model.model)
        rl.UnloadTexture(model.diffuse_texture)
        rl.UnloadTexture(model.specular_texture)
        rl.UnloadTexture(model.normal_texture)
        model.is_loaded = false
    }
}

// Drawing procedures
draw_rocky_cube :: proc(position: rl.Vector3, scale: f32 = 1.0) {
    if terrain.rocky_cube.is_loaded {
        rl.DrawModel(terrain.rocky_cube.model, position, scale, rl.WHITE)
    }
}

draw_island_platform :: proc(position: rl.Vector3, scale: f32 = 1.0) {
    if terrain.island_platform.is_loaded {
        rl.DrawModel(terrain.island_platform.model, position, scale, rl.WHITE)
    }
}

draw_rock_formation :: proc(position: rl.Vector3, scale: f32 = 1.0) {
    if terrain.rock_formation.is_loaded {
        rl.DrawModel(terrain.rock_formation.model, position, scale, rl.WHITE)
    }
}

draw_cliff_wall :: proc(position: rl.Vector3, scale: f32 = 1.0) {
    if terrain.cliff_wall.is_loaded {
        rl.DrawModel(terrain.cliff_wall.model, position, scale, rl.WHITE)
    }
}

draw_terrain_pillar :: proc(position: rl.Vector3, scale: f32 = 1.0) {
    if terrain.terrain_pillar.is_loaded {
        rl.DrawModel(terrain.terrain_pillar.model, position, scale, rl.WHITE)
    }
}

// Example usage of drawing a complete island
draw_island :: proc(base_position: rl.Vector3) {
    // Draw main platform
    draw_island_platform(base_position)
    
    // Add some rocks around the edges
    draw_rocky_cube(rl.Vector3{base_position.x + 2, base_position.y + 0.5, base_position.z + 2}, 0.7)
    draw_rocky_cube(rl.Vector3{base_position.x - 2, base_position.y + 0.5, base_position.z - 2}, 0.8)
    
    // Add a rock formation
    draw_rock_formation(rl.Vector3{base_position.x + 1, base_position.y + 0.25, base_position.z}, 0.8)
    
    // Add some cliff details
    draw_cliff_wall(rl.Vector3{base_position.x, base_position.y - 1, base_position.z + 2})
    
    // Add pillars for visual interest
    draw_terrain_pillar(rl.Vector3{base_position.x - 1.5, base_position.y + 0.25, base_position.z + 1.5}, 0.6)
}








