package main

import "core:fmt"
import rl "vendor:raylib"

Window :: struct {
    name: cstring,
    width: i32,
    height: i32,
    fps: i32,
    control_flags: rl.ConfigFlags,
}

init_board :: proc() {
    rl.ClearBackground(rl.DARKBLUE)
    rl.DrawText("Chess Engine", 10, 10, 20, rl.WHITE)
    for i := 0; i < 8; i+=1 {
        for j := 0; j < 8; j+=1 {
            if (i+j)%2 == 0 {
                rl.DrawRectangle(i32(i*75) + 195, i32(j*75) + 150, 75, 75, rl.BEIGE)
            } else {
                rl.DrawRectangle(i32(i*75) + 195, i32(j*75) + 150, 75, 75, rl.DARKGRAY)
            }
        }
    }
}

main :: proc() {
    window := Window{"Chess Engine", 1000, 900, 60, rl.ConfigFlags{.WINDOW_RESIZABLE}}

    defer {
        rl.CloseWindow()
    }

    rl.InitWindow(window.width, window.height, window.name)
    rl.SetWindowState(window.control_flags)
    rl.SetTargetFPS(window.fps)

    for !rl.WindowShouldClose() {
        if rl.IsWindowResized() {
            window.width = rl.GetScreenWidth()
            window.height = rl.GetScreenHeight()
            rl.SetWindowSize(window.width, window.height)
            fmt.printf("Window Resized to width: %d and height: %d \n", window.width, window.height)
        }
        init_board()
        rl.BeginDrawing()
        rl.EndDrawing()
    }
}
