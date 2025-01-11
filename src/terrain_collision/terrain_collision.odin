package terrain_collision

import "../shared"
import rl "vendor:raylib"

Terrain_Collision_Mesh :: struct {
    triangles: [dynamic]Triangle,
    is_generated: bool,
}

Triangle :: struct {
    v1, v2, v3: rl.Vector3,
    normal: rl.Vector3,
}

// Store collision meshes for each terrain instance
collision_meshes: map[int]Terrain_Collision_Mesh

init_collision_system :: proc() {
    collision_meshes = make(map[int]Terrain_Collision_Mesh)
}

cleanup_collision_system :: proc() {
    for _, mesh in collision_meshes {
        delete(mesh.triangles)
    }
    delete(collision_meshes)
}

generate_collision_mesh :: proc(instance_id: int, model: rl.Model) {
    if collision_meshes[instance_id].is_generated do return

    mesh := model.meshes[0]
    vertices := ([^]f32)(mesh.vertices)
    indices := ([^]u16)(mesh.indices)

    new_mesh := Terrain_Collision_Mesh{
        triangles = make([dynamic]Triangle),
        is_generated = true,
    }

    // Generate triangles from mesh
    for i := 0; i < int(mesh.triangleCount); i += 1 {
        idx1 := int(indices[i * 3])
        idx2 := int(indices[i * 3 + 1])
        idx3 := int(indices[i * 3 + 2])

        v1 := rl.Vector3{
            vertices[idx1 * 3],
            vertices[idx1 * 3 + 1],
            vertices[idx1 * 3 + 2],
        }
        v2 := rl.Vector3{
            vertices[idx2 * 3],
            vertices[idx2 * 3 + 1],
            vertices[idx2 * 3 + 2],
        }
        v3 := rl.Vector3{
            vertices[idx3 * 3],
            vertices[idx3 * 3 + 1],
            vertices[idx3 * 3 + 2],
        }

        // Calculate triangle normal
        edge1 := v2 - v1
        edge2 := v3 - v1
        normal := rl.Vector3Normalize(rl.Vector3CrossProduct(edge1, edge2))

        tri := Triangle{v1, v2, v3, normal}
        append_elem(&new_mesh.triangles, tri)
    }

    collision_meshes[instance_id] = new_mesh
}

check_player_collision :: proc(
    player_position: ^rl.Vector3,
    player_velocity: ^rl.Vector3,
    player_radius: f32,
    terrain_instances: []shared.TerrainInstance,
) -> (is_on_ground: bool) {
    is_on_ground = false
    next_pos := player_position^ + player_velocity^

    for instance, idx in terrain_instances {
        if !collision_meshes[idx].is_generated do continue

        // First do broad-phase check with bounding box
        sphere := rl.BoundingBox{
            min = {next_pos.x - player_radius, next_pos.y - player_radius, next_pos.z - player_radius},
            max = {next_pos.x + player_radius, next_pos.y + player_radius, next_pos.z + player_radius},
        }

        if rl.CheckCollisionBoxes(sphere, instance.bounds) {
            // Narrow phase: check triangles
            for triangle in collision_meshes[idx].triangles {
                // Transform triangle to world space
                world_v1 := transform_point(triangle.v1, instance.position, instance.scale)
                world_v2 := transform_point(triangle.v2, instance.position, instance.scale)
                world_v3 := transform_point(triangle.v3, instance.position, instance.scale)
                
                // Check collision with transformed triangle
                if check_sphere_triangle_collision(
                    next_pos,
                    player_radius,
                    world_v1,
                    world_v2,
                    world_v3,
                ) {
                    // Calculate collision response
                    world_normal := transform_normal(triangle.normal, instance.scale)
                    
                    // Ground check
                    if world_normal.y > 0.7 { // Consider surfaces with normal.y > 0.7 as ground
                        is_on_ground = true
                        player_velocity.y = 0
                    }

                    // Sliding collision response
                    penetration := player_radius - rl.Vector3Distance(next_pos, closest_point_on_triangle(
                        next_pos,
                        world_v1,
                        world_v2,
                        world_v3,
                    ))
                    if penetration > 0 {
                        correction := world_normal * penetration
                        player_position^ = player_position^ + correction
                        
                        // Project velocity onto plane for sliding
                        dot := rl.Vector3DotProduct(player_velocity^, world_normal)
                        if dot < 0 {
                            projection := world_normal * dot
                            player_velocity^ = player_velocity^ - projection
                        }
                    }
                }
            }
        }
    }

    return is_on_ground
}

transform_point :: proc(point: rl.Vector3, position: rl.Vector3, scale: f32) -> rl.Vector3 {
    scaled := point * scale
    return scaled + position
}

transform_normal :: proc(normal: rl.Vector3, scale: f32) -> rl.Vector3 {
    return rl.Vector3Normalize(normal * scale)
}

check_sphere_triangle_collision :: proc(
    sphere_center: rl.Vector3,
    sphere_radius: f32,
    v1, v2, v3: rl.Vector3,
) -> bool {
    closest := closest_point_on_triangle(sphere_center, v1, v2, v3)
    dist_sq := vector3_distance_squared(sphere_center, closest)
    return dist_sq <= sphere_radius * sphere_radius
}

vector3_distance_squared :: proc(v1, v2: rl.Vector3) -> f32 {
    dx := v1.x - v2.x
    dy := v1.y - v2.y
    dz := v1.z - v2.z
    return dx * dx + dy * dy + dz * dz
}

closest_point_on_triangle :: proc(
    point: rl.Vector3,
    v1, v2, v3: rl.Vector3,
) -> rl.Vector3 {
    edge0 := v2 - v1
    edge1 := v3 - v1
    v0 := v1 - point

    a := rl.Vector3DotProduct(edge0, edge0)
    b := rl.Vector3DotProduct(edge0, edge1)
    c := rl.Vector3DotProduct(edge1, edge1)
    d := rl.Vector3DotProduct(edge0, v0)
    e := rl.Vector3DotProduct(edge1, v0)

    det := a * c - b * b
    s, t: f32 = 0, 0

    if det < 0.0001 {
        s = clamp(-d/a, 0, 1)
        t = 0
    } else {
        s = clamp((b*e - c*d) / det, 0, 1)
        t = clamp((b*d - a*e) / det, 0, 1)
    }

    if t < 0 {
        t = 0
        s = clamp(-d/a, 0, 1)
    } else if s + t > 1 {
        temp := s + t - 1
        s = clamp(s - temp/2, 0, 1)
        t = clamp(t - temp/2, 0, 1)
    }

    return v1 + edge0 * s + edge1 * t
}

clamp :: proc(value, min, max: f32) -> f32 {
    if value < min do return min
    if value > max do return max
    return value
}




