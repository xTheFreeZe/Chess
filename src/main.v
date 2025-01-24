module main

import raylib as rl

const custom_dark_blue = rl.Color{0, u8(82 * 0.2), u8(172 * 0.2), u8(255 * 0.2)}

struct Window {
mut:
	name          string
	width         int
	height        int
	fps           int
	control_flags rl.ConfigFlags
}

@[heap]
struct Piece {
mut:
	pos   rl.Vector2
	image rl.Texture2D
}

enum GameTurn {
	white
	black
}

struct Board {
mut:
	pieces         [8][8]Piece
	selected_piece &Piece = unsafe { nil }
	turn           GameTurn
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
	black_piece_names := ['Black_Rook', 'Black_Bishop', 'Black_Knight', 'Black_Queen', 'Black_King',
		'Black_Pawn']
	white_piece_names := ['White_Rook', 'White_Bishop', 'White_Knight', 'White_Queen', 'White_King',
		'White_Pawn']

	for i := 0; i < 8; i++ {
		mut index := 0
		if i == 5 {
			index = 2
		} else if i == 6 {
			index = 1
		} else if i == 7 {
			index = 0
		} else {
			index = i
		}

		// Loads all pawns
		board.pieces[1][i] = Piece{
			pos:   rl.Vector2{i * 75 + 195, 75 + 150}
			image: rl.load_texture('assets/png/${black_piece_names[5]}.png')
		}
		board.pieces[6][i] = Piece{
			pos:   rl.Vector2{i * 75 + 195, 6 * 75 + 150}
			image: rl.load_texture('assets/png/${white_piece_names[5]}.png')
		}

		// Black pieces
		board.pieces[0][i] = Piece{
			pos:   rl.Vector2{i * 75 + 195, 0 * 75 + 150}
			image: rl.load_texture('assets/png/${black_piece_names[index]}.png')
		}

		// White pieces
		board.pieces[7][i] = Piece{
			pos:   rl.Vector2{i * 75 + 195, 7 * 75 + 150}
			image: rl.load_texture('assets/png/${white_piece_names[index]}.png')
		}
	}
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
					x:      board.pieces[i][j].pos.x - center_offset
					y:      board.pieces[i][j].pos.y - center_offset
					width:  piece_size
					height: piece_size
				}

				origin := rl.Vector2{0, 0}

				rl.draw_texture_pro(board.pieces[i][j].image, source_rect, dest_rect,
					origin, 0, rl.white)
			}
		}
	}
}

fn (mut board Board) get_pieces() []Piece {
	mut positions := []Piece{}

	for i := 0; i < 8; i++ {
		for j := 0; j < 8; j++ {
			if board.pieces[i][j].image.id != 0 {
				positions << Piece{board.pieces[i][j].pos, board.pieces[i][j].image}
			}
		}
	}

	return positions
}

fn (mut board Board) mouse_on_piece() bool {
	mouse_pos := rl.get_mouse_position()
	piece_positions := board.get_pieces()

	for rect in piece_positions {
		if rl.check_collision_point_rec(mouse_pos, rl.Rectangle{rect.pos.x, rect.pos.y, 75, 75}) {
			return true
		}
	}
	return false
}

fn (mut board Board) drag_piece(mut piece Piece) {
	piece.pos = rl.get_mouse_position()

	rl.draw_texture(piece.image, int(piece.pos.x), int(piece.pos.y), rl.white)
}

fn (mut board Board) hanlde_input() {
	if rl.is_mouse_button_pressed(0) {
		mut piece_positions := board.get_pieces()

		for i, mut rect in piece_positions {
			if rl.check_collision_point_rec(rl.get_mouse_position(), rl.Rectangle{rect.pos.x, rect.pos.y, 75, 75}) {
				println('Piece clicked at x: ${i % 8} y: ${i / 8} with id: ${rect.image.id}')
				board.selected_piece = &rect
				break
			}
		}
	}

	if rl.is_mouse_button_down(0) && board.selected_piece != unsafe { nil } {
		board.drag_piece(mut *board.selected_piece)
	}

	if rl.is_mouse_button_released(0) {
		board.selected_piece = unsafe { nil }
	}
}

fn main() {
	// Only log errors / warnings
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
	board.turn = .white

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
		board.hanlde_input()

		rl.end_drawing()
	}
}
