package main

import "core:fmt"
import rl "vendor:raylib"


SCREEN_WIDTH :: 1300
SCREEN_HEIGHT :: 850

game_over := false
pause := false

Player :: struct {
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

	player := Player {
		position  = rl.Vector3{0, 0, 0},
		direction = .East,
		healt     = 100,
		inventory = Inventory{},
	}

	for !rl.WindowShouldClose() {
		player_update(&player)


		camera := init_camera(&player)
		rl.BeginDrawing()
		rl.ClearBackground(rl.SKYBLUE)
		rl.BeginMode3D(camera)
		init_game()
		player_render(&player)

		rl.EndMode3D()

		coordText := fmt.aprintf(
			"x: %.2f, y: %.2f, z: %.2f",
			player.position.x,
			player.position.y,
			player.position.z,
		)

		coords: cstring = fmt.caprintf(coordText)


		//	rl.DrawFPS(10, 10)
		rl.DrawText(coords, 10, 10, 10, rl.BLACK)

		rl.EndDrawing()

	}
}

player_render :: proc(player: ^Player) {
	rl.DrawCube(player.position, 1.0, 0.5, 1.0, rl.BEIGE)
}

player_update :: proc(player: ^Player) {
	deltaTime := rl.GetFrameTime()

	input := get_input_vec()

	speed := 5.0
	player.position.x += input.x * f32(speed) * deltaTime
	player.position.y += input.y * f32(speed) * deltaTime
	player.position.z += input.z * f32(speed) * deltaTime
}

init_camera :: proc(player: ^Player) -> rl.Camera3D {
	cameraDistance: f32 = 5.0
	cameraHeight: f32 = 2.0

	rotationAngle := f32(rl.PI * -2)


	rotationMatrix := rl.MatrixRotate(rl.Vector3{0.0, 1.0, 0.0}, rotationAngle)

	offset := rl.Vector3{0.0, cameraHeight, cameraDistance}

	rotationMatrix2 := rl.MatrixRotateY(rotationAngle)

	rotatedOffset := rl.Vector3Transform(offset, rotationMatrix)

	cameraPosition := rl.Vector3 {
		player.position.x + rotatedOffset.x,
		player.position.y + rotatedOffset.y,
		player.position.z + rotatedOffset.z,
	}


	cameraTarget := rl.Vector3Transform(player.position, rotationMatrix)
	camera := rl.Camera3D {
		position = cameraPosition,
		target   = player.position,
		up       = rl.Vector3{0.0, 1.0, 0.0},
		fovy     = 85.0,
		//	projection = .ORTHOGRAPHIC,
	}

	return camera
}

get_input_vec :: proc() -> rl.Vector3 {
	input := rl.Vector3{}

	if rl.IsKeyDown(.A) {
		input.x = -1
	}

	if rl.IsKeyDown(.D) {
		input.x = 1
	}

	if rl.IsKeyDown(.SPACE) {
		input.y = 1
	}

	if rl.IsKeyDown(.LEFT_SHIFT) || rl.IsKeyDown(.RIGHT_SHIFT) {
		input.y = -1
	}

	if rl.IsKeyDown(.S) {
		input.z = +1
	}

	if rl.IsKeyDown(.W) {
		input.z = -1
	}

	if input.x != 0 || input.y != 0 || input.z != 0 {
		input = rl.Vector3Normalize(input)
	}

	return input
}


init_game :: proc() {
	rl.DrawCube(rl.Vector3{0, 0, 0}, 1.0, 2.0, 1.0, rl.BROWN)

}
