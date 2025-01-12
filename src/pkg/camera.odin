package pkg

import pl "../player"
import rl "vendor:raylib"

init_camera :: proc(player: ^pl.Player) -> rl.Camera3D {
	cameraDistance: f32 = 7.0
	cameraHeight: f32 = 6.6

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
		position   = cameraPosition,
		target     = player.position,
		up         = rl.Vector3{0.0, 0.0, -5.0},
		fovy       = 95.0,
		projection = .PERSPECTIVE,
	}

	return camera
}
