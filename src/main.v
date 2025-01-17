module main

import raylib as rl

const custom_dark_blue := rl.Color{0, u8(82 * 0.2), u8(172 * 0.2), u8(255 * 0.2)}

struct Window {
mut:
	name          string
	width         int
	height        int
	fps           int
	control_flags rl.ConfigFlags
}

struct Piece {
	posx int
	posy int
	image rl.Texture2D
}

pub struct Board {
mut:
	pieces [8][8] Piece
}

fn draw_board() {
	for i := 0; i < 8; i++ {
		for j := 0; j < 8; j++ {
			if (i + j) % 2 == 0 {
				rl.draw_rectangle(i * 75 + 195, j * 75 + 150, 75, 75, rl.beige)
			} else {
				rl.draw_rectangle(i * 75 + 195, j * 75 + 150, 75, 75, rl.gray)
			}
		}
	}
}

fn (mut board Board) load_pieces() {
	mut tex := rl.load_texture("assets/png/Black_Rook.png")
	board.pieces[0][0] = Piece{195, 150, tex}

	tex = rl.load_texture("assets/png/Black_Bishop.png")
	board.pieces[1][0] = Piece{270, 150, tex}
}

fn (mut board Board) clear_pieces() {
	for i := 0; i < 8; i++ {
		for j := 0; j < 8; j++ {
			board.pieces[i][j] = Piece{}
			rl.unload_texture(board.pieces[i][j].image)
		}
	}
}

fn (mut board Board) draw_pieces() {
	for i := 0; i < 8; i++ {
		for j := 0; j < 8; j++ {
			if board.pieces[i][j].image.id != 0 {
				source_rect := rl.Rectangle{0, 0, board.pieces[i][j].image.width, board.pieces[i][j].image.height}

				// Chessboard field dimensions
				field_size := 75
				// Scaled piece dimensions
				piece_size := 225

				// Calculate centering offset for piece
				center_offset := (piece_size - field_size) / 2

				dest_rect := rl.Rectangle{
					x: board.pieces[i][j].posx - center_offset
					y: board.pieces[i][j].posy - center_offset
					width: piece_size
					height: piece_size
				}

				origin := rl.Vector2{0, 0}

				rl.draw_texture_pro(board.pieces[i][j].image, source_rect, dest_rect, origin, 0, rl.white)
			}
		}
	}
}

fn main() {
	rl.set_trace_log_level(4)
	rl.set_config_flags(.flag_vsync_hint)

	mut window := Window{'Chess Engine', 1000, 900, 60, .flag_window_resizable}
	mut board := Board{}

	defer {
		rl.close_window()
		board.clear_pieces()
		println('Window closed - All pieces unloaded')
	}

	rl.init_window(window.width, window.height, window.name)
	rl.set_window_state(window.control_flags)
	rl.set_target_fps(window.fps)

	board.load_pieces()

	println('Window ready - All pieces loaded')

	for !rl.window_should_close() {
		if rl.is_window_resized() {
			window.height = rl.get_screen_height()
			window.width = rl.get_screen_width()

			rl.set_window_size(window.height, window.width)
			println('Window resized to width ${window.height} and height ${window.height}')
		}

		rl.begin_drawing()
		rl.clear_background(custom_dark_blue)
		rl.draw_text('Chess Engine', 10, 10, 20, rl.white)
		rl.draw_fps(10, 30)

		draw_board()
		board.draw_pieces()

		rl.end_drawing()
	}
}
