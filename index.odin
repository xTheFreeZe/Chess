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

Pieces_Images :: struct {
    white_king: rl.Texture2D,
    white_queen: rl.Texture2D,
}

init_board :: proc() {
    for i := 0; i < 8; i+=1 {
        for j := 0; j < 8; j+=1 {
            if (i+j)%2 == 0 {
                rl.DrawRectangle(i32(i*75) + 195, i32(j*75) + 150, 75, 75, rl.BEIGE)
            } else {
                rl.DrawRectangle(i32(i*75) + 195, i32(j*75) + 150, 75, 75, rl.GRAY-40)
            }
        }
    }
}

load_pieces :: proc(pieces: ^Pieces_Images) {
    pieces.white_king = rl.LoadTexture("assets/White_King.png")
    pieces.white_queen = rl.LoadTexture("assets/White_Queen.png")

    pieces.white_king.width = 75
    pieces.white_king.height = 75
    pieces.white_queen.width = 75
    pieces.white_queen.height = 75
}

unload_pieces :: proc(pieces: ^Pieces_Images) {
    rl.UnloadTexture(pieces.white_king)
    rl.UnloadTexture(pieces.white_queen)
}

draw_pieces :: proc(pieces: ^Pieces_Images) {
    rl.DrawTexture(pieces.white_king, 195, 135, rl.WHITE)
    rl.DrawTexture(pieces.white_queen, 270, 135, rl.WHITE)
}

main :: proc() {
    window := Window{"Chess Engine", 1000, 900, 60, rl.ConfigFlags{.WINDOW_RESIZABLE}}
    pieces := Pieces_Images{}

    defer {
        unload_pieces(&pieces)
        rl.CloseWindow()
        fmt.println("Unloaded all images and closed the window")
    }

    rl.InitWindow(window.width, window.height, window.name)
    rl.SetWindowState(window.control_flags)
    rl.SetTargetFPS(window.fps)

    load_pieces(&pieces)

    for !rl.WindowShouldClose() {
        if rl.IsWindowResized() {
            window.width = rl.GetScreenWidth()
            window.height = rl.GetScreenHeight()
            rl.SetWindowSize(window.width, window.height)
            fmt.printf("Window Resized to width: %d and height: %d \n", window.width, window.height)
        }
        rl.BeginDrawing()
        rl.ClearBackground(rl.DARKBLUE/5)
        rl.DrawText("Chess Engine", 10, 10, 20, rl.WHITE)
        init_board()
        draw_pieces(&pieces)
        rl.EndDrawing()
    }
}
