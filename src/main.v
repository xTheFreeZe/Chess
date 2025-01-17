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

fn main() {
	rl.set_trace_log_level(4)
	rl.set_config_flags(.flag_msaa_4x_hint)

	mut window := Window{'Chess Engine', 1000, 900, 60, .flag_window_resizable}

	defer {
		rl.close_window()
		println('Closed Window')
	}

	rl.init_window(window.width, window.height, window.name)
	rl.set_window_state(window.control_flags)
	rl.set_target_fps(window.fps)

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

		rl.end_drawing()
	}
}
