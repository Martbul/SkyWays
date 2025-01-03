package main

import rl "vendor:raylib"

PARALLELEPIPED_WIDTH_SIZE :: 20
PARALLELEPIPED_HEIGHT_SIZE :: 10
PARALLELEPIPED_DEPTH_SIZE :: 5


SCREEN_WIDTH :: 1300
SCREEN_HEIGHT :: 850

game_over := false
pause := false

Player :: struct {
	//	position:  rl.Vector2,
	position:  rl.Vector3,
	direction: MovableDirection,
	healt:     int,
	inventory: Inventory,
}


MovableDirection :: enum {
	North,
	East,
	South,
	West,
}

Inventory :: struct {
	slot1: Item,
	slot2: Item,
	slot3: Item,
	slot4: Item,
	slot5: Item,
}

Item :: struct {}

main :: proc() {
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "SkyWays")
	defer rl.CloseWindow()

	//	camera := rl.Camera2D {
	//		offset = rl.Vector2{0, 0},
	//		zoom   = 3,
	//	}


	player := Player {
		//position  = rl.Vector2{0, 0},
		position  = rl.Vector3{0, 0, 0},
		direction = .East,
		healt     = 100,
		inventory = Inventory{},
	}

	camera := rl.Camera3D {
		position = rl.Vector3{0.0, 2.0, 4.0}, // Camera position
		target   = player.position, // Camera looks at the player
		up       = rl.Vector3{0.0, 1.0, 0.0}, // Up vector
		fovy     = 45.0, // Field of view
	}
	for !rl.WindowShouldClose() {
		player_update(&player)

		rl.BeginDrawing()
		rl.ClearBackground(rl.SKYBLUE)
		//	rl.BeginMode2D(camera)
		camera.target = player.position
		rl.BeginMode3D(camera)
		player_render(&player)


		//	rl.EndMode2D()
		rl.EndMode3D()
		rl.EndDrawing()
	}

}

player_render :: proc(player: ^Player) {

	rl.DrawCube(player.position, 1.0, 2.0, 1.0, rl.BEIGE)
	//	rl.DrawRectanglePro(
	//		rl.Rectangle{player.position.x, player.position.y, 10, 20},
	//		rl.Vector2{0, 0},
	//		0,
	//		rl.BEIGE,
	//	)
}


player_update :: proc(player: ^Player) {
	deltaTime := rl.GetFrameTime()
	input := rl.Vector3{}

	if rl.IsKeyDown(.A) {
		input.x = -1
	}

	if rl.IsKeyDown(.D) {
		input.x = 1
	}


	if rl.IsKeyDown(.S) {
		input.z = +1
	}


	if rl.IsKeyDown(.W) {
		input.z = -1
	}

	if rl.IsKeyDown(.SPACE) {
		input.y = 1
	}


	if rl.IsKeyDown(.LEFT_SHIFT) {
		input.y = -1
	}

	// Normalize input to ensure consistent movement speed
	if input.x != 0 || input.y != 0 || input.z != 0 {
		input = rl.Vector3Normalize(input)
	}

	// Update player position
	speed := 5.0 // Adjust speed as necessary
	player.position.x += input.x * f32(speed) * deltaTime
	player.position.y += input.y * f32(speed) * deltaTime
	player.position.z += input.z * f32(speed) * deltaTime
}


//player_update :: proc(player: ^Player) {
//	deltaTime := rl.GetFrameTime()
//	input := rl.Vector2{}
//
//	if rl.IsKeyDown(.A) {
//		input.x = -1
//	}
//
//	if rl.IsKeyDown(.D) {
//		input.x = 1
//	}
//
//
//	if rl.IsKeyDown(.S) {
//		input.y = +1
//	}
//
//
//	if rl.IsKeyDown(.W) {
//		input.y = -1
//	}
///
//
//	if rl.IsKeyDown(.LEFT) {
//		input.x = -1
//	}
//
//	if rl.IsKeyDown(.RIGHT) {
//		input.x = 1
//	}
//
//
//	if rl.IsKeyDown(.DOWN) {
//		input.y = +1
//	}
//
//
//	if rl.IsKeyDown(.UP) {
//		input.y = -1
//	}
//
//
//	player.position.x += input.x * 100 * deltaTime
//	player.position.y += input.y * 100 * deltaTime
//}
